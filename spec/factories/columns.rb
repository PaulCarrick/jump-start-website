def build_html_paragraphs(paragraph_count = 9)
  styles = [
    ->(p) { "<p>#{p}</p>\n" },
    ->(p) { "<p><b>#{p}</b></p>\n" },
    ->(p) { "<p><i>#{p}</i></p>\n" },
    ->(p) { "<ul><li>#{p}</li></ul>\n" },
    ->(p) { "<h1>#{p}</h1>" },
    ->(p) { "<div class=\"fs-2\">#{p}</div>" },
    ->(p) { "<div class=\"display-4\">#{p}</div>" },
    ->(p) { "<div style=\"background: red\">#{p}</div>" },
    ->(p) { "<div class=\"row\"><div class=\"col-6\">#{p}</div><div class=\"col-6\">#{p}</div></div>" }
  ]

  Faker::Lorem.paragraphs(number: paragraph_count).each_with_index.map do |paragraph, index|
    styles[index % styles.length].call(paragraph)
  end.join
end

FactoryBot.define do
  factory :column do
    section_name { "Test" }
    column_name { "Test" }
    column_order { 1 }
    image { "ImageFile:test" }
    link { "/images/test.jpg" }
    formatting { { "row_style": "text-left" } }
    content { "This is a test." }

    # Traits
    trait :plain_text do
      section_name  { "text_section" }
      column_name  { 'plain_text' }
      column_order { nil }
      image         { nil }
      link          { nil }
      formatting    { {} }
      content   { Faker::Lorem.paragraphs(number: 5).join(". ") }
    end

    trait :plain_html do
      section_name  { "html_section" }
      column_name  { 'plain_html' }
      column_order { nil }
      image         { nil }
      link          { nil }
      formatting    { { "row_classes": "col-12" } }

      after(:build) do |column, evaluator|
        column.content = build_html_paragraphs(9)
      end
    end

    trait :text_left do
      section_name  { "text_left" }
      column_name  { 'text_left' }
      column_order { nil }
      image         { "ImageFile:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-left", "image_classes": "col-4 mb-3", "text_classes": "col-8" } }

      after(:build) do |column, evaluator|
        column.content = build_html_paragraphs(9)
      end
    end

    trait :text_right do
      section_name  { "text_right" }
      column_name  { 'text_right' }
      column_order { nil }
      image         { "ImageFile:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-right", "image_classes": "col-4 mb-3", "text_classes": "col-8" } }

      after(:build) do |column, evaluator|
        column.content = build_html_paragraphs(9)
      end
    end

    trait :text_top do
      section_name  { "text_top" }
      column_name  { 'text_top' }
      column_order { nil }
      image         { "ImageFile:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-top", "row_classes": "col-12" } }

      after(:build) do |column, evaluator|
        column.content = build_html_paragraphs(9)
      end
    end

    trait :text_bottom do
      section_name  { "text_bottom" }
      column_name  { 'text_bottom' }
      column_order { nil }
      image         { "ImageFile:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-bottom", "row_classes": "col-12"  } }
      content   { Faker::Lorem.paragraphs(number: 5).join(". ") }

      after(:build) do |column, evaluator|
        column.content = build_html_paragraphs(9)
      end
    end

    trait :image_column do
      section_name  { "image_column" }
      column_name  { 'image_column' }
      column_order { nil }
      image         { "ImageColumn:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-left", "text_classes ": "col-lg-4", "image_classes": "col-lg-8" } }
    end

    trait :image_group do
      section_name  { "image_group" }
      column_name  { 'image_group' }
      column_order { nil }
      image         { "ImageGroup:test-group" }
      link          { nil }
      formatting    { { "row_style": "text-left", "text_classes ": "col-lg-4", "image_classes": "col-lg-8" } }
    end

    trait :video_image do
      section_name  { "video_image" }
      column_name  { 'video_image' }
      column_order { nil }
      image         { nil }
      link          { nil }
      formatting    { { "row_style": "text-left", "text_classes ": "col-lg-4", "image_classes": "col-lg-8" } }
    end
  end
end
