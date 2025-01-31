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
  factory :section do
    content_type { "Test" }
    section_name { "Test" }
    section_order { 1 }
    image { "ImageFile:test" }
    link { "/images/test.jpg" }
    formatting { { "row_style": "text-left" } }
    description { "This is a test." }

    # Traits
    trait :plain_text do
      content_type  { "text_page" }
      section_name  { 'plain_text' }
      section_order { nil }
      image         { nil }
      link          { nil }
      formatting    { {} }
      description   { Faker::Lorem.paragraphs(number: 5).join(". ") }
    end

    trait :plain_html do
      content_type  { "html_page" }
      section_name  { 'plain_html' }
      section_order { nil }
      image         { nil }
      link          { nil }
      formatting    { { "row_classes": "col-12" } }

      after(:build) do |section, evaluator|
        section.description = build_html_paragraphs(9)
      end
    end

    trait :text_left do
      content_type  { "text_left" }
      section_name  { 'text_left' }
      section_order { nil }
      image         { "ImageFile:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-left", "image_classes": "col-4 mb-3", "text_classes": "col-8" } }

      after(:build) do |section, evaluator|
        section.description = build_html_paragraphs(9)
      end
    end

    trait :text_right do
      content_type  { "text_right" }
      section_name  { 'text_right' }
      section_order { nil }
      image         { "ImageFile:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-right", "image_classes": "col-4 mb-3", "text_classes": "col-8" } }

      after(:build) do |section, evaluator|
        section.description = build_html_paragraphs(9)
      end
    end

    trait :text_top do
      content_type  { "text_top" }
      section_name  { 'text_top' }
      section_order { nil }
      image         { "ImageFile:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-top", "row_classes": "col-12" } }

      after(:build) do |section, evaluator|
        section.description = build_html_paragraphs(9)
      end
    end

    trait :text_bottom do
      content_type  { "text_bottom" }
      section_name  { 'text_bottom' }
      section_order { nil }
      image         { "ImageFile:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-bottom", "row_classes": "col-12"  } }
      description   { Faker::Lorem.paragraphs(number: 5).join(". ") }

      after(:build) do |section, evaluator|
        section.description = build_html_paragraphs(9)
      end
    end

    trait :image_section do
      content_type  { "image_section" }
      section_name  { 'image_section' }
      section_order { nil }
      image         { "ImageSection:test-photo" }
      link          { nil }
      formatting    { { "row_style": "text-left", "text_classes ": "col-lg-4", "image_classes": "col-lg-8" } }
    end

    trait :image_group do
      content_type  { "image_group" }
      section_name  { 'image_group' }
      section_order { nil }
      image         { "ImageGroup:test-group" }
      link          { nil }
      formatting    { { "row_style": "text-left", "text_classes ": "col-lg-4", "image_classes": "col-lg-8" } }
    end

    trait :video_image do
      content_type  { "video_image" }
      section_name  { 'video_image' }
      section_order { nil }
      image         { nil }
      link          { nil }
      formatting    { { "row_style": "text-left", "text_classes ": "col-lg-4", "image_classes": "col-lg-8" } }
    end
  end
end
