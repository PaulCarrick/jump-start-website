FactoryBot.define do
  factory :footer_item do
    label { "Test" }
    icon { "/images/search.svg" }
    options { "" }
    link { "/test" }
    access { "" }
    footer_order { 1 }
    parent_id { nil }
  end
end
