require 'rails_helper'

RSpec.describe "Admin Blog Posts", type: :system do
  def search_blog_posts(content)
    visit admin_blog_posts_path

    expect(page).to have_field(name: 'q[content_cont]')
    fill_in "q[content_cont]", with: content
    click_button "Search Blogs"
  end

  let(:admin_user) { create(:user, access: "super") }
  let!(:blog_post) { create(:blog_post) }
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:blog_post_1) { create(:blog_post, author: "Author One", title: "Title One", posted: 1.day.ago, content: "Content One") }
  let!(:blog_post_2) { create(:blog_post, author: "Author Two", title: "Title Two", posted: 2.days.ago, content: "Content Two") }

  before do
    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end

    login_as(admin_user)
  end

  describe "Search for title" do
    before do
      blog_post_1.save!
    end

    it "finds a Post with a given title" do
      visit admin_blog_posts_path

      expect(page).to have_field(name: 'q[title_cont]')
      fill_in "q[title_cont]", with: "Title One"
      click_button "Search Blogs"
      expect(page).to have_content("Title One")
    end

    it "finds a Post with a given author" do
      visit admin_blog_posts_path

      expect(page).to have_field(name: 'q[author_cont]')
      fill_in "q[author_cont]", with: "Author One"
      click_button "Search Blogs"
      expect(page).to have_content("Author One")
    end

    it "finds a Post with a given content" do
      visit admin_blog_posts_path

      expect(page).to have_field(name: 'q[content_cont]')
      fill_in "q[content_cont]", with: "Content One"
      click_button "Search Blogs"
      expect(page).to have_content("Content One")
    end

    it "finds a Post with a given posted date" do
      formatted_date = Date.today.strftime("%Y-%m-%d")

      visit admin_blog_posts_path

      expect(page).to have_field(name: 'q[posted_date_eq]')
      fill_in "q[posted_date_eq]", with: formatted_date
      click_button "Search Blogs"
      expect(page).to have_content("Test Blog")
    end
  end

  describe "New/Edit page" do
    it "renders the blog form with all fields" do
      visit new_admin_blog_post_path

      sleep 3

      expect(page).to have_field("Author*", with: admin_user.name)
      expect(page).to have_field("Title*", placeholder: "Enter the title")
      expect(page).to have_select("Visibility", options: %w[Public Private])
      expect(page).to have_select("Blog Type", options: %w[Personal Professional])
      expect(page).to have_button("Switch to HTML View **")
      expect(page).to have_button("Save Blog")
      expect(page).to have_link("Cancel", href: %r{/admin/blog_posts})
    end

    it "renders the HTML Editor and raw text editor for content" do
      visit new_admin_blog_post_path

      sleep 3

      # Click the button to toggle the visibility of the raw text editor
      click_button "Switch to HTML View **"

      # Now, check for the visibility of the raw content textarea
      expect(page).to have_selector('textarea.form-control[placeholder="Edit raw HTML here"][rows="10"]')
    end

    it "submits the form successfully" do
      visit new_admin_blog_post_path
      sleep 2
      fill_in "blog_post[author]", with: "Test Author"
      fill_in "blog_post[title]", with: "Test Title"
      select "Public", from: "blog_post[visibility]"
      select "Personal", from: "blog_post[blog_type]"
      fill_in_quill_editor("blog-post-content", with: "Test Content")
      sleep 1
      click_button "Save Blog"
      sleep 2
      expect(page).to have_content("Blog Post created successfully")
      expect(page).to have_current_path(admin_blog_posts_path(turbo: false))
    end
  end

  describe "Show Page" do
    let!(:blog_post) do
      create(:blog_post,
             title:   "Latest Blog Title",
             posted:  "2024-12-15",
             author:  "Jane Doe",
             content: "<p>This is the content of the latest blog post.</p>")
    end

    before do
      driven_by(:selenium_chrome_headless) # Use JavaScript-enabled driver
    end
  end

  describe "Index page" do
    before do
      visit admin_blog_posts_path
    end

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Blog Post")
    end

    it "renders the sortable columns" do
      expect(page).to have_link("Author", href: /sort=author/)
      expect(page).to have_link("Title", href: /sort=title/)
      expect(page).to have_link("Posted", href: /sort=posted/)
    end

    it "lists all blog posts" do
      expect(page).to have_content("View")
      expect(page).to have_content("Edit")
      expect(page).to have_content("Delete")
    end


    it "renders action links for each blog post" do
      search_blog_posts("Content One")
      expect(page).to have_link("View", href: admin_blog_post_path(blog_post_1))
      expect(page).to have_link("Edit", href: edit_admin_blog_post_path(blog_post_1))
      expect(page).to have_link("Delete", href: "#{admin_blog_post_path(blog_post_1)}/delete")
    end

    it "renders the pagination controls" do
      expect(page).to have_link("First", href: /page=1/)
      expect(page).to have_link("Previous")
      expect(page).to have_link("Next")
      expect(page).to have_link("Last", href: /page=\d+/)
    end

    it "navigates to the new blog page" do
      sleep 1
      click_link "New Blog"
      sleep 2
      expect(page).to have_current_path(new_admin_blog_post_path)
    end

    it "performs a search with the form" do
      fill_in "Author", with: "Author One"
      click_button "Search Blogs"

      expect(page).to have_content("Author One")
      expect(page).not_to have_content("Author Two")
    end

    it "clears the search results" do
      fill_in "Author", with: "Author One"
      click_button "Search Blogs"
      click_link "Clear Search"
      sleep 1

      anchor_count = all('a').filter { |anchor| anchor.text == 'Edit' }.size
      expect(anchor_count).to be > 1
    end
  end

  describe "Sorting functionality" do
    it "sorts by posted date" do
      visit admin_blog_posts_path(sort: "posted", direction: "desc")
      posted_dates = page.all(".row .col-2:nth-child(3)").map(&:text)
      expect(posted_dates).to eq(posted_dates.sort.reverse)
    end
  end

  describe "Action links" do
    it "redirects to the edit page when clicking Edit" do
      search_blog_posts("Content One")
      sleep 1
      click_link "Edit", href: edit_admin_blog_post_path(blog_post_1)
      sleep 2
      expect(page).to have_current_path(edit_admin_blog_post_path(blog_post_1))
      expect(page).to have_content("Edit Blog Post")
    end

    it "deletes a blog post when clicking Delete" do
      search_blog_posts("Content One")

      expect {
        sleep 1
        click_link "Delete", href: "#{admin_blog_post_path(blog_post_1)}/delete"
        sleep 2
        page.driver.browser.switch_to.alert.accept # Confirm the alert
      }.not_to raise_error
      expect(page).to have_content("Blog Post deleted successfully.")
    end
  end
end
