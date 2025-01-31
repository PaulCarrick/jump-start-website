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
