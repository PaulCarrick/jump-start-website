require 'rails_helper'

RSpec.describe 'Contact email, validation, page numbers and the blog page', type: :request do
  let!(:setup) { create(:site_setup, owner_name: 'Site Owner') }

  describe 'contact email' do
    let(:mail) do
      ContactMailer.contact_email('Visitor <b>Name</b>', 'visitor@example.com', '555-0100',
                                  '<div>Hello <strong>there</strong></div><script>alert(1)</script><img src=x onerror=alert(2)><a href="javascript:alert(3)">x</a>',
                                  setup)
    end
    let(:body) { mail.body.encoded }

    it 'keeps formatting but removes scripts, images and javascript links from the message' do
      expect(body).to include('<strong>there</strong>')
      expect(body).not_to include('<script', '<img', 'onerror', 'javascript:')
      expect(body).to include('Visitor &lt;b&gt;Name&lt;/b&gt;')
    end

    it 'replies to the visitor and greets the site owner by name' do
      expect(mail.reply_to).to eq([ 'visitor@example.com' ])
      expect(body).to include('Site Owner:')
      expect(body).not_to include('Paul:')
    end

    it 'does not show visitors the server error when sending fails' do
      allow(Recaptcha.configuration).to receive(:site_key).and_return('test-site-key')
      allow(Recaptcha.configuration).to receive(:secret_key).and_return('test-secret-key')
      allow_any_instance_of(ContactsController).to receive(:verify_recaptcha).and_return(true)
      allow(ContactMailer).to receive(:contact_email).and_raise(Net::SMTPAuthenticationError.new('535 secret.mail.example rejected user'))

      post contacts_path, params: { contact: { name: 'Visitor', email: 'visitor@example.com', message: 'Hello' } }
      follow_redirect!
      expect(response.body).to include('Your message could not be sent')
      expect(response.body).not_to include('secret.mail.example')
    end
  end

  describe 'validation' do
    it 'refuses unsafe or unreasonable menu items' do
      item = MenuItem.new(menu_type: 'Nonsense', label: 'L' * 61, link: 'java script:alert(1)', menu_order: -5)
      expect(item).not_to be_valid
      expect(item.errors.attribute_names).to include(:menu_type, :label, :link, :menu_order)
      expect(MenuItem.new(menu_type: 'Main', label: 'Letters', menu_order: 'abc')).not_to be_valid
      expect(MenuItem.new(menu_type: 'Main', label: 'Bio', link: '/bio', menu_order: 3)).to be_valid
      expect(MenuItem.new(menu_type: 'Main', label: 'Site', link: 'https://example.com', menu_order: 1)).to be_valid
    end

    it 'refuses unsafe footer links' do
      expect(FooterItem.new(label: 'Footer', link: 'data:text/html,hi', footer_order: 1)).not_to be_valid
      expect(FooterItem.new(label: 'Footer', link: 'mailto:someone@example.com', footer_order: 1)).to be_valid
    end

    it 'refuses access levels the Users form does not offer and reports a password mismatch once' do
      user = User.new(email: 'super@example.test', password: 'abcdefgh', password_confirmation: 'abcdefgh', access: 'superuser')
      expect(user).not_to be_valid
      expect(user.errors[:access]).to be_present

      mismatch = User.new(email: 'mismatch@example.test', password: 'abcdefgh', password_confirmation: 'zzzzzzzz', access: 'regular')
      mismatch.valid?
      expect(mismatch.errors.full_messages.count { |message| message.include?('confirmation') }).to eq(1)

      expect(User.new(email: 'signup@example.test', password: 'abcdefgh', password_confirmation: 'abcdefgh')).to be_valid
    end
  end

  describe 'page numbers' do
    %w[abc 0 -1].each do |page_number|
      it "shows the first page instead of failing for page=#{page_number}" do
        get '/section', params: { q: { description_cont: 'anything' }, page: page_number }
        expect(response).to have_http_status(:ok)
        get '/api/v1/blog_posts', params: { page: page_number }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'blog page' do
    def blog_user_props
      get blogs_path(blog_type: 'Personal')
      props = JSON.parse(Nokogiri::HTML(response.body).at_css('[data-react-class="PostList"]')['data-react-props'])
      props['user']
    end

    it 'tells the page whether someone is signed in, with only the fields it uses' do
      expect(blog_user_props['logged_in']).to be(false)

      sign_in create(:user, name: 'Reader', access: 'regular')
      user = blog_user_props
      expect(user['logged_in']).to be(true)
      expect(user.keys).to match_array(%w[id name email access logged_in])
    end

    it 'names a commenter without a name "Visitor"' do
      blog = create(:blog_post)
      sign_in create(:user, name: nil, access: 'regular')
      post '/api/v1/post_comments', params: { post_comment: { blog_post_id: blog.id, title: 'Hi', content: '<p>Hello</p>' } }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['author']).to eq('Visitor')
    end
  end
end
