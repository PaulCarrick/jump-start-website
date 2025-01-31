FactoryBot.define do
  factory :post_comment do
    id { 999 }
    blog_post_id { 999 }
    title { "Test Comment" }
    author { "Test" }
    posted { DateTime.now }
    content { "This is a test comment." }
  end
end
