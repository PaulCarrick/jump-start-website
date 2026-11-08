require 'rails_helper'

RSpec.describe 'Search, pages API, new sections and deletes', type: :request do
  let!(:setup) { create(:site_setup) }
  let!(:administrator) { create(:user, name: 'Administrator', access: 'admin') }
  let!(:public_page) { create(:page, name: 'employment', title: 'Employment', section: 'Employment') }
  let!(:section) { create(:section, page: public_page, section_name: 'nava', description: '<p>Work history</p>') }
  let!(:cell) { create(:cell, section: section, section_name: 'nava', cell_name: 'nava-1', cell_type: 'text', content: '<p>Senior engineer at Nava PBC in Minnesota</p>') }

  describe 'site search' do
    it 'finds words that are only in a column' do
      get '/section', params: { q: { description_cont: 'Nava' } }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Employment', 'Nava PBC')
    end

    it 'still finds words in a section description' do
      get '/section', params: { q: { description_cont: 'work history' } }
      expect(response.body).to include('Work history')
    end

    it 'says so when nothing matches' do
      get '/section', params: { q: { description_cont: 'zzzz-nothing' } }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No pages contain')
    end
  end

  describe 'pages API' do
    it 'lists pages, including when the request says it is JSON' do
      get '/api/v1/pages'
      expect(response).to have_http_status(:ok)
      get '/api/v1/pages', params: { limit: 5 }, headers: { 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).map { |page| page['name'] }).to include('employment')
    end
  end

  describe 'admin' do
    before { sign_in administrator }

    it 'asks which page a new section belongs to, then opens Add Section for it' do
      get new_admin_section_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Choose the page to add it to', 'Employment')

      get new_admin_section_path(page_id: public_page.id)
      expect(response).to redirect_to(%r{/admin/page/new_section/#{public_page.id}})
    end

    it 'no longer deletes through a plain link' do
      expect { Rails.application.routes.recognize_path("/admin/sections/#{section.id}/delete", method: :get) }
        .to raise_error(ActionController::RoutingError)
      expect { get "/admin/sections/#{section.id}", params: { method: 'delete' } }
        .not_to change { Section.unscoped.where(id: section.id, temporal_deleted: true).count }
    end

    it 'deletes with a DELETE request' do
      delete "/admin/sections/#{section.id}"
      expect(response).to have_http_status(:see_other).or have_http_status(:found)
      expect(Section.unscoped.where(id: section.id, temporal_deleted: true)).to exist
    end

    it 'shows Delete as a form that sends DELETE (forms carry the security token outside tests)' do
      get admin_sections_path
      document = Nokogiri::HTML(response.body)
      form = document.at_css("form[action='#{admin_section_path(section)}']")
      expect(form).to be_present
      expect(form.at_css("input[name='_method']")['value']).to eq('delete')
      expect(document.css('a').map { |link| link['href'].to_s }.grep(%r{/delete\z})).to be_empty
    end

    it 'lets the Add Section cancel link remove only a new, never-published section of that page' do
      get edit_admin_page_path(public_page), params: { canceled: 'true', new_section: 'true', section_id: section.id }
      expect(response).to have_http_status(:ok)
      expect(Section.unscoped.where(id: section.id, temporal_deleted: true)).not_to exist

      get admin_add_section_to_existing_page_path(public_page)
      new_section = Section.unscoped.where(page_id: public_page.id).where.not(id: section.id).order(:id).last
      get edit_admin_page_path(public_page), params: { canceled: 'true', new_section: 'true', section_id: new_section.id }
      expect(Section.unscoped.where(id: new_section.id, temporal_deleted: false)).to be_empty
    end
  end
end
