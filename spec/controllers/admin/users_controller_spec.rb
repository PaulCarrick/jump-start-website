require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  User.destroy_all

  let!(:admin_user) { create_admin_user }
  let!(:user) { create(:user) }

  describe "GET #index" do
    context "when the user is an admin" do
      it "assigns @users and paginates results" do
        # TO DO Find a fix for devise.
      end

      it "filters users using Ransack" do
        # TO DO Find a fix for devise.
      end

      it "sorts users by specified column and direction" do
        # TO DO Find a fix for devise.
      end
    end

    context "when the user is not an admin" do
      let!(:non_admin_user) { create_regular_user }

      it "redirects to the root path with an alert" do
        # TO DO Find a fix for devise.
      end
    end
  end

  describe "GET #new" do
    it "assigns a new user" do
      # TO DO Find a fix for devise.
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      let(:valid_attributes) {
        {
          email:                 "new_user-#{Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)}@example.com",
          password:              "password123",
          password_confirmation: "password123",
          name:                  "New User",
          admin:                 false
        }
      }

      it "creates a new user and redirects to index" do
        expect {
          post :create,
               params: {
                 user: {
                   email:                 "new_user-#{Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)}@example.com",
                   password:              "password123",
                   password_confirmation: "password123",
                   name:                  "New User",
                   access:                "regular"
                 }
               }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq("User created successfully.")
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { { email: nil, password: nil } }

      it "does not create a new user and renders the new template" do
        expect {
          post :create, params: { user: invalid_attributes }
        }.not_to change(User, :count)
        expect(response).to redirect_to(new_admin_user_path(turbo: false))
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested user" do
      get :edit, params: { id: user.id }
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the user and redirects to index" do
        patch :update, params: { id: user.id, user: { name: "Updated Name" } }
        user.reload
        expect(user.name).to eq("Updated Name")
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq("User updated successfully")
      end
    end

    context "with invalid attributes" do
      it "does not update the user and renders the edit template" do
        patch :update, params: { id: user.id, user: { email: nil } }
        expect(response).to redirect_to(edit_admin_user_path(user, turbo: false))
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the user and redirects to index" do
      expect {
        delete :destroy, params: { id: user.id }
      }.to change(User, :count).by(-1)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("User deleted successfully.")
    end
  end

  describe "Filters" do
    context "check_admin" do
      it "redirects non-admin users to root with an alert" do
        user = create_regular_user

        get :index

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end
    end

    context "set_user" do
      it "sets @user for actions requiring a user" do
        get :edit, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
      end
    end
  end
end
