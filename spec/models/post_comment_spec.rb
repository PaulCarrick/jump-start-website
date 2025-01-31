require 'rails_helper'

RSpec.describe PostComment, type: :model do
  include_context "debug setup"

  let(:blog_post) { BlogPost.create!(author: "Test User",
                                     title: "Test Blog",
                                     content: "Sample content",
                                     posted: DateTime.now) }

  describe "validations" do
    it "validates presence of title" do
      post_comment = PostComment.new(author: "John Doe", posted: Time.now, content: "Sample content", blog_post: blog_post)
      expect(post_comment.valid?).to be false
      expect(post_comment.errors[:title]).to include("can't be blank")
    end

    it "validates presence of author" do
      post_comment = PostComment.new(title: "Comment Title", posted: Time.now, content: "Sample content", blog_post: blog_post)
      expect(post_comment.valid?).to be false
      expect(post_comment.errors[:author]).to include("can't be blank")
    end

    it "validates presence of posted" do
      post_comment = PostComment.new(title: "Comment Title", author: "John Doe", content: "Sample content", blog_post: blog_post)
      expect(post_comment.valid?).to be false
      expect(post_comment.errors[:posted]).to include("can't be blank")
    end

    it "validates presence of content" do
      post_comment = PostComment.new(title: "Comment Title", author: "John Doe", posted: Time.now, blog_post: blog_post)
      expect(post_comment.valid?).to be false
      expect(post_comment.errors[:content]).to include("can't be blank")
    end
  end

  describe "checksum verification" do
    it "does not raise an error if checksum matches content" do
      content = "Sample content"
      checksum = Digest::SHA256.hexdigest(content)

      post_comment = PostComment.create!(
        title: "Comment Title",
        author: "John Doe",
        posted: DateTime.now,
        content: content,
        checksum: checksum,
        blog_post: blog_post
      )

      expect { post_comment.reload }.not_to raise_error
    end
  end

  describe "HTML validation" do
    it "adds an error if content has invalid HTML" do
      invalid_html = "<html><body><p>Invalid HTML"
      post_comment = PostComment.new(
        title: "Comment Title",
        author: "John Doe",
        posted: Time.now,
        content: invalid_html,
        blog_post: blog_post
      )

      post_comment.valid? # Triggers validation
      expect(post_comment.errors[:base]).to include("Invalid HTML in Content.")
    end

    it "does not add an error if content has valid HTML" do
      valid_html = "<html><body><p>Valid HTML</p></body></html>"
      post_comment = PostComment.new(
        title: "Comment Title",
        author: "John Doe",
        posted: Time.now,
        content: valid_html,
        blog_post: blog_post
      )

      post_comment.valid? # Triggers validation

      expect(post_comment.errors[:base]).to be_empty
    end

    it "skips HTML validation if content starts with <title>" do
      skip_html = "<title>Some Content</title>"
      post_comment = PostComment.new(
        title: "Comment Title",
        author: "John Doe",
        posted: Time.now,
        content: skip_html,
        blog_post: blog_post
      )

      post_comment.valid? # Triggers validation

      expect(post_comment.errors[:base]).to be_empty
    end
  end

  describe ".ransackable_attributes" do
    it "returns only ransackable attributes" do
      expect(PostComment.ransackable_attributes).to eq([ "content" ])
    end
  end
end
