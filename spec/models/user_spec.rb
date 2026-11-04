require 'rails_helper'

RSpec.describe User, type: :model do
  include_context "debug setup"

  describe "devise modules" do
    it "includes database_authenticatable" do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it "includes registerable" do
      expect(User.devise_modules).to include(:registerable)
    end

    it "includes recoverable" do
      expect(User.devise_modules).to include(:recoverable)
    end

    it "includes rememberable" do
      expect(User.devise_modules).to include(:rememberable)
    end

    it "includes validatable" do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe "validations" do
    it "rejects an email belonging to another current user" do
      existing = create(:user)
      replacement = build(:user, email: existing.email)
      expect(replacement).not_to be_valid
      expect(replacement.errors[:email]).to include("has already been taken")
    end

    it "reuses a draft-deleted user's email and preserves history through deployment" do
      admin = create(:user, access: 'super')
      existing = create(:user)
      PublishingContext.editing = true
      existing.destroy!
      replacement = create(:user, email: existing.email)
      PublishingContext.editing = false
      Publishing.deploy!(actor: admin, summary: 'Replace deleted user')
      PublishingContext.live = true
      expect(User.find_by!(email: existing.email).id).to eq(replacement.id)
      expect(User.unscoped.where(id: existing.id)).to exist
      expect(build(:user, email: existing.email)).not_to be_valid
    end

    it "allows reuse of an email retained only by a previous published version" do
      admin = create(:user, access: 'super')
      existing = create(:user)
      old_email = existing.email
      PublishingContext.editing = true
      existing.update!(email: 'changed@example.com')
      PublishingContext.editing = false
      Publishing.deploy!(actor: admin, summary: 'Change email')
      expect(create(:user, email: old_email)).to be_persisted
    end

    it "validates presence of email" do
      user = User.new(password: "password123")
      expect(user.valid?).to be false
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "validates presence of password" do
      user = User.new(email: "test@example.com")
      expect(user.valid?).to be false
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "is valid with valid email and password" do
      user = User.new(email: "test@example.com", password: "password123")
      expect(user.valid?).to be true
    end
  end

  describe "instance methods" do
    describe "#admin?" do
      it "returns true if the user is an admin" do
        user = User.new(access: 'admin')
        expect(user.admin?).to be true
      end

      it "returns false if the user is not an admin" do
        user = User.new(access: nil)
        expect(user.admin?).to be false
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns only ransackable attributes" do
      expect(User.ransackable_attributes).to eq([ "email", "name" ])
    end
  end
end
