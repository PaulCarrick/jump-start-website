FactoryBot.define do
  factory :blog_post do
    title { "Test Blog" }
    author { "Test" }
    posted { DateTime.now }
    content { "This is a test blog." }
    blog_type { "Personal" }
    visibility { "Public" }
  end
end
