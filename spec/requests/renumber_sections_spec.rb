require "rails_helper"

RSpec.describe "Renumber page sections", type: :request do
  let!(:section) { create(:section, section_order: -10) }
  let!(:second) { create(:section, page: section.page, content_type: section.content_type, section_order: 75) }
  let(:path) { admin_renumber_page_sections_path(section.page) }

  it "saves the new numbers for an administrator and returns to the editor" do
    sign_in create(:user, access: "super")
    post path
    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(edit_admin_page_path(section.page))
    expect([ section.class.find(section.id).section_order, second.class.find(second.id).section_order ]).to eq([ 10, 20 ])
  end

  it "requires login" do
    post path
    expect(response).to redirect_to(new_user_session_path)
    expect(section.class.find(section.id).section_order).to eq(-10)
  end

  it "hides the button and rejects the action for a read-only user" do
    sign_in create(:user, access: "read_only")
    get edit_admin_page_path(section.page)
    expect(response.body).not_to include("Renumber Sections")
    post path
    expect(response).to redirect_to(edit_admin_page_path(section.page))
    expect(flash[:alert]).to include("not permitted")
    expect([ section.class.find(section.id).section_order, second.class.find(second.id).section_order ]).to eq([ -10, 75 ])
  end

  it "reports a failed update without a success notice" do
    sign_in create(:user, access: "super")
    allow_any_instance_of(Page).to receive(:renumber_sections!).and_raise(ActiveRecord::RecordNotSaved)
    post path
    expect(response).to redirect_to(edit_admin_page_path(section.page))
    expect(flash[:alert]).to include("No changes were saved")
    expect(flash[:notice]).to be_nil
    expect(section.class.find(section.id).section_order).to eq(-10)
  end
end
