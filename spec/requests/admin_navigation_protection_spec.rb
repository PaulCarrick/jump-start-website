require 'rails_helper'

RSpec.describe 'Read-only admin navigation', type: :request do
  let!(:setup) { create(:site_setup) }

  %w[menu footer].each do |kind|
    it "disables editing and rejects saves for an admin #{kind} link" do
      sign_in create(:user, access: 'super')
      record = create("#{kind}_item", link: '/admin/pages')
      get public_send("edit_admin_#{kind}_item_path", record)
      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML(response.body)
      expect(document.at_css('fieldset[disabled]')).to be_present
      expect(document.at_css('input[type=submit][disabled].admin-navigation-readonly')).to be_present
      patch public_send("admin_#{kind}_item_path", record), params: {
        "#{kind}_item" => { label: 'Attempted edit', link: '/public' }
      }
      current = record.class.find(record.id)
      expect(current.label).to eq(record.label)
      expect(current.link).to eq('/admin/pages')
      expect(record.class.pending_versions.where(id: record.id)).not_to exist
    end

    it "leaves an ordinary #{kind} link editable" do
      sign_in create(:user, access: 'super')
      record = create("#{kind}_item", link: '/public')
      get public_send("edit_admin_#{kind}_item_path", record)
      document = Nokogiri::HTML(response.body)
      expect(document.at_css('fieldset[disabled]')).to be_nil
      expect(document.at_css('input[type=submit][disabled]')).to be_nil
      patch public_send("admin_#{kind}_item_path", record), params: { "#{kind}_item" => { label: 'Updated label' } }
      expect(record.class.find(record.id).label).to eq('Updated label')
    end
  end
end
