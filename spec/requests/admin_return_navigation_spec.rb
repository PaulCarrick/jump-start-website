require "rails_helper"

RSpec.describe "Admin return navigation", type: :request do
  before { sign_in create(:user, access: "super") }

  let!(:caller_page) { create(:page) }
  let(:caller_url) { edit_admin_page_path(caller_page, section_name: "Overview", return_url: admin_pages_path) }

  {
    pages: [ :page, :title, "Updated title" ],
    sections: [ :section, :description, "Updated description" ],
    cells: [ :cell, :content, "Updated content" ],
    blog_posts: [ :blog_post, :title, "Updated blog" ],
    footer_items: [ :footer_item, :label, "Updated footer" ],
    menu_items: [ :menu_item, :label, "Updated menu" ],
    site_setups: [ :site_setup, :site_name, "Updated site" ],
    image_files: [ :image_file, :caption, "Updated caption" ],
    users: [ :user, :name, "Updated user" ]
  }.each do |resource, (factory, field, value)|
    context resource.to_s do
      let!(:record) { create(factory) }
      let(:edit_path) { "/admin/#{resource}/#{record.id}/edit" }
      let(:record_path) { "/admin/#{resource}/#{record.id}" }
      let(:key) { resource.to_s.singularize }

      it "preserves the caller for Save and Cancel" do
        get edit_path, headers: { "HTTP_REFERER" => "http://www.example.com#{caller_url}" }
        expect(response).to have_http_status(:ok)
        if %i[cells sections].include?(resource)
          props = Nokogiri::HTML(response.body).at_css('[data-react-props]')['data-react-props']
          options = JSON.parse(props).values.find { |v| v.is_a?(Hash) && v.key?('returnUrl') }
          expect(options.values_at('returnUrl', 'cancelUrl')).to eq([ caller_url, caller_url ])
        else
          html = Nokogiri::HTML(response.body)
          expect(html.at_css('input[name="return_url"]')['value']).to eq(caller_url)
          expect(html.css('a').find { |a| a.text == 'Cancel' }['href']).to eq(caller_url)
        end
        patch record_path, params: { return_url: caller_url, key => { field => value } }
        expect(response).to redirect_to(caller_url)
        expect(record.class.find(record.id).public_send(field)).to include(value)
      end

      it "returns a newly created record to the caller" do
        attrs = record.attributes.except('id', 'created_at', 'updated_at')
        %w[name cell_name section_name configuration_name email].each do |name|
          next unless attrs[name].present?
          next if name == 'section_name' && resource == :cells
          attrs[name] = "new-#{attrs[name]}"
        end
        attrs['section'] = "new-#{attrs['section']}" if resource == :pages
        attrs['default_setup'] = false if resource == :site_setups
        if resource == :users
          attrs['password'] = attrs['password_confirmation'] = 'Valid-password-123!'
        elsif resource == :image_files
          attrs['image'] = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.jpg'), 'image/jpeg')
        end
        expect {
          post "/admin/#{resource}", params: { return_url: caller_url, key => attrs }
        }.to change(record.class, :count).by(1)
        expect(response).to redirect_to(caller_url)
      end

      it "returns to its own index when opened directly" do
        patch record_path, params: { key => { field => value } }
        expect(response).to redirect_to("/admin/#{resource}")
      end
    end
  end

  it "retains the caller after validation failure" do
    record = create(:page)
    patch admin_page_path(record), params: { return_url: caller_url, page: { name: '' } }
    follow_redirect!
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('input[name="return_url"]')['value']).to eq(caller_url)
    expect(html.css('a').find { |a| a.text == 'Cancel' }['href']).to eq(caller_url)
  end

  [ "https://evil.example/admin/pages", "//evil.example/admin/pages", "/admin/pages/1/renumber_sections", "/users/sign_out", "/admin/cells/1?method=delete" ].each do |unsafe|
    it "rejects unsafe return target #{unsafe}" do
      record = create(:page)
      patch admin_page_path(record), params: { return_url: unsafe, page: { title: 'Safe' } }
      expect(response).to redirect_to(admin_pages_path)
    end
  end
end
