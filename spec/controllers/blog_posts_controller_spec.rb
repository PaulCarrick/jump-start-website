require 'rails_helper'

RSpec.describe BlogsController, type: :controller do
  BlogPost.destroy_all

  include_context "debug setup"

  let!(:blog_post1) { create(:blog_post, blog_type: "Personal", visibility: "Public", posted: Time.now - 1.day, content: "<b>Content 1</b>") }
  let!(:blog_post2) { create(:blog_post, blog_type: "Personal", visibility: "Public", posted: Time.now, content: "<i>Content 2</i>") }
  let!(:private_blog_post) { create(:blog_post, blog_type: "Personal", visibility: "Private", content: "<u>Private Content</u>") }
  let!(:tech_blog_post) { create(:blog_post, blog_type: "Tech", visibility: "Public", content: "<p>Tech Blog</p>") }

  describe "GET #index" do
    it "assigns the default blog type to Personal when no blog_type is provided" do
      get :index
      expect(assigns(:blog_type)).to eq("Personal")
    end

    it "assigns blog_type from params if provided" do
      get :index, params: { blog_type: "Tech" }
      expect(assigns(:blog_type)).to eq("Tech")
    end

    it "sanitizes the content of public blogs for the given blog type" do
      get :index, params: { blog_type: "Personal" }
      expect(assigns(:contents)).to eq([ "<b>Content 1</b>", "<i>Content 2</i>" ])
    end

    it "excludes private blogs from the contents" do
      get :index, params: { blog_type: "Personal" }
      expect(assigns(:contents)).not_to include(private_blog_post.content)
    end
  end

  describe "GET #show" do
    context "when the id is 'latest'" do
      it "assigns the latest blog for the given blog type" do
        blog_post3 = create(:blog_post,
                            blog_type:  "Personal",
                            visibility: "Public",
                            posted:     Time.now + 5.seconds,
                            content:    "<i>Content 3</i>")
        get :show, params: { id: "latest", blog_type: "Personal" }
        expect(assigns(:blog)).to eq(blog_post3) # Most recently posted
      end

      it "sanitizes the content of the latest blog" do
        get :show, params: { id: "latest", blog_type: "Personal" }
        expect(assigns(:blog).content).to eq("Private Content")
      end

      it "renders the 'latest' template" do
        get :show, params: { id: "latest", blog_type: "Personal" }
        expect(response).to render_template("latest")
      end

      it "assigns nil to @blog if no blogs exist for the given blog type" do
        BlogPost.where(blog_type: "Personal").destroy_all
        get :show, params: { id: "latest", blog_type: "Personal" }
        expect(assigns(:blog)).to be_nil
      end
    end

    context "when the id is a specific blog ID" do
      it "assigns the blog corresponding to the given ID" do
        get :show, params: { id: blog_post1.id }
        expect(assigns(:blog)).to eq(blog_post1)
      end

      it "raises ActiveRecord::RecordNotFound if the blog ID does not exist" do
        expect {
          get :show, params: { id: -1 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
