FactoryBot.define do
  factory :page do
    sequence(:name) { |n| "test-page-#{n}" }
    title { "This is a test." }
    section { name }
    access { "" }
  end
end
