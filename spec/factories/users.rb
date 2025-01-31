FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test-#{n}@example.com" }
    password { "password123" }
    approved { true } # Add additional fields as required by your model
  end
end
