FactoryBot.define do
  factory :page do
    sequence(:name)    { |n| "test-page-#{n}" }
    title { "This is a test." }
    sequence(:section) { |n| "test-section-#{n}" }
    access { "" }
  end
end
