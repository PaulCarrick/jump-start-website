require "rails_helper"

RSpec.describe "Public blog visibility", type: :request do
  let!(:public_post) do
    BlogPost.create!(title: "Published post", author: "Admin", posted: 1.day.ago,
                     content: "<p>Published body</p>", blog_type: "Personal", visibility: "Public")
  end
  let!(:private_post) do
    BlogPost.create!(title: "Secret post", author: "Admin", posted: Time.current,
                     content: "<p>Secret body</p>", blog_type: "Personal", visibility: "Private")
  end

  it "shows the latest public post instead of a newer private post" do
    get "/blogs/latest"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Published body")
    expect(response.body).not_to include("Secret body")
  end

  it "does not expose a private post at its direct public URL" do
    get "/blogs/#{private_post.id}"
    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include("Secret body")
  end

  it "renders a public post at its direct URL" do
    get "/blogs/#{public_post.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Published body")
  end

  it "does not let a guest request private posts through the API" do
    get "/api/v1/blog_posts", params: { visibility: "Private", include_comments: true }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Published body")
    expect(response.body).not_to include("Secret body")
  end

  it "does not expose private content through the direct API route" do
    get "/api/v1/blog_posts/#{private_post.id}"
    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include("Secret body")
  end

  it "preserves private-post access for signed-in users" do
    user = User.create!(email: "blog-reader@example.com", name: "Reader",
                        password: "Reader-Password123!", access: "regular")
    sign_in user
    get "/blogs/#{private_post.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Secret body")
    get "/api/v1/blog_posts", params: { visibility: "Private" }
    expect(response.body).to include("Secret body")
  end
end
