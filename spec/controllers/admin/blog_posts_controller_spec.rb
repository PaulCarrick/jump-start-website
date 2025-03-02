require 'rails_helper'

RSpec.describe Admin::BlogPostsController, type: :controller do
  include_context "debug setup"

  BlogPost.destroy_all # Clear out existing records for testing

  let!(:admin_user) { create_admin_user }
  let!(:blog_post) {
    create(:blog_post,
           blog_type:  "Personal",
           visibility: "Public",
           posted:     Time.now - 1.day,
           content:    "<b>Content 1</b>")
  }
  let!(:valid_attributes) {
    {
      title:      'Test Blog',
      author:     'Test User',
      posted:     Time.now - 1.day,
      content:    "<b>Content</b>",
      visibility: "Public",
      blog_type:  "Personal"
    }
  }
  let!(:invalid_attributes) {
    {
      title:      nil,
      author:     nil,
      posted:     nil,
      content:    nil,
      visibility: nil,
      blog_type:  nil
    }
  }

  before do
    allow(controller).to receive(:controller_name).and_return("blog_posts")
  end

  describe "Initialization" do
    it "inherits from Admin::AbstractAdminController" do
      expect(controller).to be_a_kind_of(Admin::AbstractAdminController)
    end

    it "sets the correct default attributes" do
      get :index
      expect(controller.instance_variable_get(:@page_limit)).to eq(3)
      expect(controller.instance_variable_get(:@default_column)).to eq('posted')
      expect(controller.instance_variable_get(:@has_query)).to be(true)
      expect(controller.instance_variable_get(:@has_sort)).to be(true)
      expect(controller.instance_variable_get(:@model_class)).to eq(BlogPost)
    end
  end

  describe "GET #index" do
    it "assigns @results and paginates records" do
      get :index
      expect(assigns(:results)).to include(blog_post)
      expect(assigns(:pagy)).to be_present
    end

    it "filters records using Ransack queries" do
      get :index, params: { q: { title_cont: "Test" } }
      expect(assigns(:results)).to include(blog_post)
    end

    it "sorts records by the default cell" do
      get :index
      expect(assigns(:results).first).to eq(blog_post)
    end
  end

  describe "GET #new" do
    it "assigns a new instance of the model" do
      get :new
      expect(assigns(:_blog_post)).to be_a_new(BlogPost)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new record and redirects to index" do
        expect {
          post :create, params: { blog_post: valid_attributes }
        }.to change(BlogPost, :count).by(1)

        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Blog Post created successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new record and redirects to new" do
        expect {
          post :create, params: { blog_post: invalid_attributes }
        }.not_to change(BlogPost, :count)

        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :new, turbo: false)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested record" do
      get :edit, params: { id: blog_post.id }
      expect(assigns(:_blog_post)).to eq(blog_post)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the record and redirects to index" do
        patch :update, params: { id: blog_post.id, blog_post: { title: "Updated Blog Post" } }
        blog_post.reload
        expect(blog_post.title).to eq("Updated Blog Post")
        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Blog Post updated successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not update the record and redirects to edit" do
        patch :update, params: { id: blog_post.id, blog_post: invalid_attributes }
        expect(blog_post.title).to eq("Test Blog")
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :edit, turbo: false)
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested record" do
      get :show, params: { id: blog_post.id }
      expect(assigns(:_blog_post)).to eq(blog_post)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the record and redirects to index" do
      expect {
        delete :destroy, params: { id: blog_post.id }
      }.to change(BlogPost, :count).by(-1)

      expect(response).to redirect_to(action: :index, turbo: false)
      expect(flash[:notice]).to eq("Blog Post deleted successfully.")
    end
  end
end
