require "rails_helper"

RSpec.describe "Ruby and Rails upgrade regressions" do
  describe "stored checksums" do
    it "keeps the legacy four-round checksum when saving and loading content" do
      post = BlogPost.create!(title: "Checksum test", author: "Admin", posted: Time.current, content: "<p>Hello</p>")
      checksum = post.checksum
      expect(checksum.length).to eq(512)
      data = post.content
      legacy = 4.times.map do
        hash = OpenSSL::Digest::SHA512.digest(data)
        data = hash
        hash.unpack1("H*")
      end.join
      expect(checksum).to eq(legacy)
      expect(post.reload.content).to eq("<p>Hello</p>")
    end

    it "does not modify an image description while combining its caption" do
      image = ImageFile.new(description: "Description", caption: "Caption")
      image.send(:populate_checksum)
      expect(image.description).to eq("Description")
      expect(image.checksum).to eq(image.send(:generate_checksum, "DescriptionCaption"))
    end

    it "returns a record-backed validation error for tampered content" do
      post = BlogPost.create!(title: "Checksum test", author: "Admin", posted: Time.current, content: "<p>Hello</p>")
      post.update_column(:checksum, "tampered")
      expect { post.reload }.to raise_error(ActiveRecord::RecordInvalid) { |error|
        expect(error.record).to be_a(BlogPost)
        expect(error.record.errors[:base].join).to include("Checksum verification failed")
      }
    end
  end

  describe "admin sorting" do
    let(:controller) { Admin::PagesController.new }

    it "clears the persisted column and direction for the current resource" do
      allow(controller).to receive(:session).and_return({ pages_sort: "title", pages_sort_direction: "desc", cells_sort: "id" })
      controller.set_sorting("name", "asc", ActionController::Parameters.new(clear_sort: "true"))
      expect(controller.session).to eq(cells_sort: "id")
    end

    it "rejects unrecognized sort columns and directions" do
      allow(controller).to receive(:session).and_return({})
      result = controller.set_sorting("name", "asc", ActionController::Parameters.new(sort: "name; DROP TABLE pages", direction: "bad"))
      expect(result).to eq([ "name", "asc" ])
    end

    it "retains valid sorting between requests" do
      allow(controller).to receive(:session).and_return({ pages_sort: "title", pages_sort_direction: "desc" })
      result = controller.set_sorting("name", "asc", ActionController::Parameters.new(controller: "admin/pages"))
      expect(result).to eq([ "title", "desc" ])
    end

    it "applies the page limit when listing an unsearched resource" do
      21.times { |i| Page.create!(name: "Page #{i}", section: "page-#{i}") }
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(controller: "admin/pages"))
      allow(controller).to receive(:session).and_return({})
      allow(controller).to receive(:request).and_return(ActionDispatch::TestRequest.create)
      controller.send(:set_items)
      expect(controller.get_items.length).to eq(20)
      expect(controller.instance_variable_get(:@pagy).count).to eq(21)
    end
  end
end

RSpec.describe "Admin workflows after the Rails upgrade", type: :request do
  before do
    admin = User.create!(email: "upgrade-admin@example.com", name: "Upgrade Admin", password: "Upgrade-Password123!", access: "super")
    sign_in admin
  end

  it "renders the page list with the upgraded view and authentication libraries" do
    get admin_pages_path
    expect(response).to have_http_status(:ok)
  end

  it "creates, updates, and deletes a page through admin routes" do
    post admin_pages_path, params: { page: { name: "Upgrade Page", section: "upgrade" } }
    expect(response).to have_http_status(:redirect)
    page = Page.find_by!(name: "Upgrade Page")
    patch admin_page_path(page), params: { page: { title: "Updated title" } }
    expect(response).to have_http_status(:see_other)
    expect(page.reload.title).to eq("Updated title")
    delete admin_page_path(page)
    expect(response).to have_http_status(:redirect)
    expect(Page.exists?(page.id)).to be(false)
  end

  it "renders a searched and sorted section list with Ransack and Pagy" do
    get admin_sections_path, params: { q: { section_name_cont: "Upgrade" }, sort: "section_name", direction: "asc" }
    expect(response).to have_http_status(:ok)
  end
end
