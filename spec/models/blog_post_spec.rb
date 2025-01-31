require 'rails_helper'

RSpec.describe BlogPost, type: :model do
  include_context "debug setup"

  let(:valid_content) { "<html><body><p>Valid HTML</p></body></html>" }
  let(:invalid_content) { "<html><body><p>Invalid HTML" }
  let(:checksum) { Digest::SHA256.hexdigest(valid_content) }

  describe "validations" do
    it "validates presence of title" do
      blog_post = BlogPost.new(author: "Author", posted: Time.now, content: valid_content, checksum: checksum)
      expect(blog_post.valid?).to be false
      expect(blog_post.errors[:title]).to include("can't be blank")
    end

    it "validates presence of author" do
      blog_post = BlogPost.new(title: "Title", posted: Time.now, content: valid_content, checksum: checksum)
      expect(blog_post.valid?).to be false
      expect(blog_post.errors[:author]).to include("can't be blank")
    end

    it "validates presence of posted" do
      blog_post = BlogPost.new(title: "Title", author: "Author", content: valid_content, checksum: checksum)
      expect(blog_post.valid?).to be false
      expect(blog_post.errors[:posted]).to include("can't be blank")
    end

    it "validates presence of content" do
      blog_post = BlogPost.new(title: "Title", author: "Author", posted: Time.now, checksum: checksum)
      expect(blog_post.valid?).to be false
      expect(blog_post.errors[:content]).to include("can't be blank")
    end

    it "adds an error for invalid HTML in content" do
      blog_post = BlogPost.new(title: "Title", author: "Author", posted: Time.now, content: invalid_content, checksum: checksum)
      blog_post.valid?
      expect(blog_post.errors[:base]).to include("Invalid HTML in Content.")
    end

    it "does not add an error for valid HTML in content" do
      blog_post = BlogPost.new(title: "Title", author: "Author", posted: Time.now, content: valid_content, checksum: checksum)
      expect(blog_post.valid?).to be true
    end

    it "skips HTML validation if content starts with <title>" do
      skip_html = "<title>Valid Title</title>"
      blog_post = BlogPost.new(title: "Title", author: "Author", posted: Time.now, content: skip_html, checksum: checksum)
      expect(blog_post.valid?).to be true
    end
  end

  describe "checksum verification" do
    it "does not raise an error if checksum matches content" do
      blog_post = BlogPost.create!(
        title: "Title",
        author: "Author",
        posted: Time.now,
        content: valid_content,
        checksum: checksum
      )

      expect { blog_post.reload }.not_to raise_error
    end
  end

  describe "associations" do
    it "has many post_comments with dependent destroy" do
      blog_post = BlogPost.create!(
        title: "Title",
        author: "Author",
        posted: Time.now,
        content: valid_content,
        checksum: checksum
      )

      comment = blog_post.post_comments.create!(
        title: "Comment Title",
        author: "Comment Author",
        posted: Time.now,
        content: "Comment content",
        checksum: Digest::SHA256.hexdigest("Comment content")
      )

      expect(blog_post.post_comments).to include(comment)
      blog_post.destroy
      expect(PostComment.exists?(comment.id)).to be false
    end
  end

  describe ".ransackable_attributes" do
    it "returns only ransackable attributes" do
      expect(BlogPost.ransackable_attributes).to eq([ "author", "title", "posted", "posted_date", "content" ])
    end
  end

  describe ".ransackable_associations" do
    it "returns only ransackable associations" do
      expect(BlogPost.ransackable_associations).to eq([ "post_comments" ])
    end
  end
end
