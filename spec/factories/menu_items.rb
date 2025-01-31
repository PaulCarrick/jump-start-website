FactoryBot.define do
  factory :menu_item do
    label { "Test" }
    icon { "/images/search.svg" }
    options { "" }
    link { "/test" }
    access { "" }
    menu_order { 1 }
    parent_id { nil }
  end
end
