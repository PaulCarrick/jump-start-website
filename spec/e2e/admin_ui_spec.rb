# Opt in via bin/admin-ui-e2e so the ordinary suite cannot erase a shared DB.
if ENV['ADMIN_UI_E2E'] == '1'
require_relative 'helper'

RSpec.describe 'Admin Selenium UI', admin_e2e: true do
  describe 'authentication', no_login: true do
    it 'redirects the gear link to login and signs in with Remember me' do
      visit '/users/sign_in'
      # The same gear link used during the audit, in the shared header.
      find('header a[href="/admin"], nav a[href="/admin"]', match: :first).click
      expect(page).to have_current_path('/users/sign_in', ignore_query: true)
      fill_field 'Email Address', with: AdminE2E::EMAIL
      find('input[type=password]').set('wrong-password')
      click_button 'Log in'
      expect(page).to have_current_path('/users/sign_in', ignore_query: true)
      expect(page).to have_content(/Invalid|incorrect/i)
      fill_field 'Email Address', with: AdminE2E::EMAIL
      find('input[type=password]').set(AdminE2E::PASSWORD)
      check 'Remember me'; click_button 'Log in'
      expect(page).to have_current_path('/admin', ignore_query: true)
      screenshot('dashboard')
      visit '/users/sign_out'; visit '/admin'
      expect(page).to have_current_path('/users/sign_in', ignore_query: true)
    end

    it 'toggles the login password visibility' do
      visit '/users/sign_in'
      find('input[type=password]').set(AdminE2E::PASSWORD)
      find('.fa-eye, .bi-eye, [onclick*="togglePassword"]', match: :first).click
      expect(find('#password-field')[:type]).to eq('text')
    end
  end

  describe 'navigation and empty listings' do
    AdminE2E::AREAS.each do |label, resource|
      it "opens #{label} from the sidebar with no content records" do
        area(resource)
        expect(page).to have_title(/#{Regexp.escape(label == 'Blogs' ? 'Blog Posts' : label)}/i)
        expect(page).to have_no_content('Exception caught')
        AdminE2E::AREAS.each_key { |menu| expect(page).to have_link(menu, exact: true) }
        screenshot("empty-#{resource}")
      end
    end

    it 'expands and collapses the narrow-screen navigation' do
      page.driver.browser.manage.window.resize_to(674, 850)
      visit '/admin'; find('button[aria-label="Toggle navigation"]').click
      expect(page).to have_css('button[aria-label="Toggle navigation"][aria-expanded="true"]')
      expect(page).to have_link('HOME', exact: true)
      find('button[aria-label="Toggle navigation"]').click
      expect(page).to have_css('button[aria-label="Toggle navigation"][aria-expanded="false"]')
      screenshot('mobile-dashboard')
    rescue StandardError
      screenshot('mobile-navigation-failure-before-resize')
      raise
    ensure
      page.driver.browser.manage.window.resize_to(1440, 1000)
    end
  end

  describe 'Site Setups' do
    def fill_setup
      { 'Configuration Name*'=>'e2e-config', 'Owner Name*'=>'Selenium Owner',
        'Site Name*'=>'Selenium Site', 'Site Domain*'=>'e2e.example', 'Site Host*'=>'e2e.example',
        'Site URL*'=>'https://e2e.example', 'Guest User Name*'=>'guest',
        'Email server (SMTP host)'=>'smtp.e2e.example', 'Email Server Port'=>'587',
        'Email server username'=>'fake-user', 'Email server password'=>'fake-password',
        'Email server default domain'=>'e2e.example', 'Contact email from address'=>'from@e2e.example',
        'Contact email to address'=>'to@e2e.example', 'Contact Email subject line'=>'E2E Subject',
        'Background Image'=>'none', 'Copyright'=>'E2E Copyright' }.each { |field,value| fill_field field, with: value }
      select 'Plain', from: 'SMTP Server Authentication'
      %w[Header Footer Container].each do |part|
        select 'Blue', from: "#{part} Background Color*"
        select 'White', from: "#{part} Text Color*"
      end
      %w[Facebook Twitter Instagram Linkedin GitHub].each { |name| fill_field "#{name} URL", with: "https://e2e.example/#{name.downcase}" }
    end

    it 'creates, views, edits, cancels and deletes a configuration' do
      area('site_setups'); click_link 'New Site Setup'
      expect(page).to have_field('Email Server Port', with: '465')
      expect(page).to have_unchecked_field('Default setup')
      fill_setup; click_button 'Save Site Setup'
      expect(page).to have_current_path('/admin/site_setups', ignore_query: true)
      open_record('site_setups', 'e2e-config', 'View')
      expect(page).to have_content('Selenium Site')
      area('site_setups'); open_record('site_setups', 'e2e-config', 'Edit')
      expect(page).to have_field('Copyright', with: 'E2E Copyright')
      expect(page).to have_select('SMTP Server Authentication', selected: 'Plain')
      fill_field 'Copyright', with: 'Canceled change'; cancel
      open_record('site_setups', 'e2e-config', 'Edit')
      expect(page).to have_field('Copyright', with: 'E2E Copyright')
      fill_field 'Copyright', with: 'Updated Copyright'; click_button 'Save Site Setup'
      open_record('site_setups', 'e2e-config', 'Edit')
      expect(page).to have_field('Copyright', with: 'Updated Copyright')
      screenshot('site-setup-edit'); cancel
      delete_record('site_setups', 'e2e-config')
    end

    it 'blocks incomplete required fields and a second default configuration' do
      area('site_setups'); click_link 'New Site Setup'; click_button 'Save Site Setup'
      expect(page).to have_current_path('/admin/site_setups/new', ignore_query: true)
      expect(page).to have_css('input:invalid')
      fill_setup; check 'Default setup'; click_button 'Save Site Setup'
      expect(page).to have_content(/only.*one default/i)
      expect(SiteSetup.where(default_setup: true).count).to eq(1)
    end
  end

  describe 'Users' do
    it 'creates, views, updates without changing password, cancels and deletes' do
      create_user
      open_record('users', 'E2E Member', 'View'); expect(page).to have_content('E2E Member')
      area('users'); open_record('users', 'E2E Member', 'Edit')
      expect(page).to have_field('Password*', with: '')
      select 'Post Blogs', from: 'Access'; fill_field 'Roles', with: 'professional'
      click_button 'Save User'; open_record('users', 'E2E Member', 'Edit')
      expect(page).to have_select('Access', selected: 'Post Blogs')
      expect(page).to have_field('Roles', with: 'professional')
      fill_field 'Name*', with: 'Discarded'; cancel
      expect(find('.scrollable-container')).to have_content('E2E Member')
      delete_record('users', 'E2E Member')
    end

    it 'validates required fields and duplicate email' do
      create_user; click_link 'New User'; click_button 'Save User'
      expect(page).to have_css('input:invalid')
      fill_field 'Email*', with: 'e2e-member@e2e.example'
      fill_field 'Name*', with: 'Duplicate'; fill_field 'Password*', with: AdminE2E::PASSWORD
      select 'Regular', from: 'Access'; click_button 'Save User'
      expect(page).to have_content(/already been taken/i)
    end

    %w[Regular Administrator].concat(['Read Only','Post Blogs','Super User']).each do |access|
      it "persists the #{access} access option" do
        create_user; open_record('users', 'E2E Member', 'Edit')
        select access, from: 'Access'; click_button 'Save User'
        open_record('users', 'E2E Member', 'Edit')
        expect(page).to have_select('Access', selected: access)
      end
    end
  end

  %w[menu_items footer_items].each do |resource|
    type = resource == 'menu_items' ? 'Menu Item' : 'Footer Item'
    describe type do
      it 'creates parent and child links, views, edits, cancels and deletes' do
        create_link_item(resource, 'E2E Parent')
        create_link_item(resource, 'E2E Child', parent: 'E2E Parent')
        open_record(resource, 'E2E Child', 'View'); expect(page).to have_content('E2E Child')
        area(resource); open_record(resource, 'E2E Child', 'Edit')
        expect(page).to have_field('Icon', with: '/images/gear.svg')
        expect(page).to have_select(resource == 'menu_items' ? 'Parent menu' : 'Parent footer', selected: 'E2E Parent')
        fill_field 'Options', with: 'discarded'; cancel
        open_record(resource, 'E2E Child', 'Edit'); expect(page).to have_field('Options', with: 'image-file')
        fill_field 'Label*', with: 'E2E Updated'; fill_field 'Link', with: '/admin/users'
        click_button "Save #{type}"
        expect(find('.scrollable-container')).to have_content('E2E Updated')
        delete_record(resource, 'E2E Updated'); delete_record(resource, 'E2E Parent')
      end
      it 'validates label and numeric order and cancels New without saving' do
        area(resource); click_link "New #{type}"; click_button "Save #{type}"
        expect(page).to have_css('input:invalid')
        fill_field 'Label*', with: 'Unsaved Link'
        order_field = resource == 'menu_items' ? 'menu-order-field' : 'footer-order-field'
        fill_field order_field, with: '0'; click_button "Save #{type}"
        expect(find_field(order_field)).to match_selector(':invalid')
        fill_field order_field, with: '1000'; click_button "Save #{type}"
        expect(find_field(order_field)).to match_selector(':invalid')
        cancel
        expect(find('.scrollable-container')).to have_no_content('Unsaved Link')
      end
    end
  end

  describe 'Blogs' do
    it 'creates, views, edits visibility/type, cancels and deletes' do
      create_blog; open_record('blog_posts', 'E2E Blog', 'View')
      expect(page).to have_content('E2E post content')
      area('blog_posts'); open_record('blog_posts', 'E2E Blog', 'Edit')
      select 'Private', from: 'Visibility'; select 'Professional', from: 'Blog Type'
      fill_field 'Title*', with: 'E2E Updated Blog'; quill('Updated post content')
      click_button 'Save Blog Post'
      open_record('blog_posts', 'E2E Updated Blog', 'Edit')
      expect(page).to have_select('Visibility', selected: 'Private')
      expect(page).to have_select('Blog Type', selected: 'Professional')
      fill_field 'Title*', with: 'Discarded'; cancel
      expect(find('.scrollable-container')).to have_content('E2E Updated Blog')
      delete_record('blog_posts', 'E2E Updated Blog')
    end

    it 'round trips HTML mode and persists rich text formatting' do
      area('blog_posts'); click_link 'New Blog'; fill_field 'Title*', with: 'E2E Formatting'
      editor = find('.ql-editor'); editor.click
      find('.ql-bold').click; editor.send_keys('Bold content', :tab)
      expect(editor).to have_css('strong', text: 'Bold content')
      click_button 'Switch to HTML View **'
      expect(page).to have_css('textarea[placeholder="Edit raw HTML here"]')
      expect(find('textarea').value).to include('Bold content')
      find('textarea').set('<p><em>HTML edited content</em></p>')
      click_button 'Switch to Editor View'
      expect(find('.ql-editor')).to have_css('em', text: 'HTML edited content')
      click_button 'Save Blog Post'
      open_record('blog_posts', 'E2E Formatting', 'View')
      expect(page).to have_css('em', text: 'HTML edited content')
    end

    it 'validates title and cancels an unsaved post' do
      area('blog_posts'); click_link 'New Blog'; click_button 'Save Blog Post'
      expect(page).to have_css('input:invalid')
      fill_field 'Title*', with: 'Unsaved Blog'; quill('Discarded post'); cancel
      expect(find('.scrollable-container')).to have_no_content('Unsaved Blog')
    end

    { 'q_author_cont'=>'UI Test Admin', 'q_title_cont'=>'E2E Blog', 'q_content_cont'=>'E2E post content', 'q_posted_date_eq'=>Date.today.to_s }.each do |field, value|
      it "searches #{field}, returns no results, and clears the search" do
        create_blog; fill_field field, with: value; click_button 'Search Blogs'
        expect(find('.scrollable-container')).to have_content('E2E Blog')
        clear_search
        fill_field field, with: field.include?('date') ? '1900-01-01' : 'unmatched-e2e-token'
        click_button 'Search Blogs'; expect(find('.scrollable-container')).to have_no_content('E2E Blog')
        clear_search; expect(find('.scrollable-container')).to have_content('E2E Blog')
      end
    end
  end

  describe 'Image Files' do
    it 'uploads, previews, edits caption/description/group/order, cancels and deletes' do
      create_image; open_record('image_files', 'e2e-image', 'View')
      expect(page).to have_css('img')
      area('image_files'); open_record('image_files', 'e2e-image', 'Edit')
      expect(find_field('Name*')[:readonly]).to be_truthy
      expect(find_field('Upload Image*')[:required]).not_to be_in([true, 'true', 'required'])
      quill('Updated caption', index: 0); quill('Updated description', index: 1)
      fill_field 'slide-order-field', with: '2'; click_button 'Save Image'
      expect(find('.scrollable-container')).to have_content('Updated caption')
      open_record('image_files', 'e2e-image', 'Edit')
      find('#group-field').set('Discarded'); cancel
      expect(find('.scrollable-container')).to have_content('E2E Gallery')
      delete_record('image_files', 'e2e-image')
    end

    it 'selects an existing group in the form and updates group through the list prompt' do
      create_image('first-image', order: 3)
      # Groups derive from their images; retain a member when moving second-image out.
      create_image('group-anchor', group: 'Other Gallery')
      create_image('second-image', group: 'Other Gallery')
      open_record('image_files', 'second-image', 'Edit'); click_button 'Add to Group'
      expect(page).to have_select('group-select')
      select 'E2E Gallery (Max Slide Order: 3)', from: 'group-select'
      expect(find('#group-field').value).to eq('E2E Gallery')
      expect(find('#slide-order-field').value).to eq('4')
      click_button 'Save Image'
      href = record_href('image_files', 'second-image', 'Edit')
      row = find_link('Edit', href: href).find(:xpath, "ancestor::div[contains(@class,'row')][1]")
      accept_prompt(with: 'Other Gallery') { row.click_button 'Add Group' }
      expect(page).to have_current_path('/admin/image_files', ignore_query: true)
      updated = find_link('Edit', href: href).find(:xpath, "ancestor::div[contains(@class,'row')][1]")
      expect(updated).to have_content('Other Gallery')
    end

    it 'validates upload and name, and round trips HTML mode' do
      area('image_files'); click_link 'New Image'; click_button 'Save Image'
      expect(page).to have_css('input:invalid')
      quill('Caption draft', index: 0); quill('Description draft', index: 1)
      click_button 'Switch to HTML View **'
      expect(page).to have_css('textarea[placeholder="Edit raw HTML here"]')
      click_button 'Switch to Editor View'; expect(page).to have_css('.ql-editor', text: 'Description draft')
      cancel; expect(page).to have_current_path('/admin/image_files', ignore_query: true)
    end

    { 'q_name_cont'=>'e2e-image', 'q_group_cont'=>'E2E Gallery', 'q_caption_cont'=>'Caption e2e-image', 'q_description_cont'=>'Description e2e-image' }.each do |field,value|
      it "filters images by #{field} and clears search" do
        create_image; fill_field field, with: value; click_button 'Search Images'
        expect(find('.scrollable-container')).to have_content('e2e-image')
        clear_search; fill_field field, with: 'unmatched-e2e-token'; click_button 'Search Images'
        expect(find('.scrollable-container')).to have_no_content('e2e-image')
        clear_search; expect(find('.scrollable-container')).to have_content('e2e-image')
      end
    end
  end

  describe 'Pages, Sections and Cells' do
    it 'creates content through New Page, views, edits, cancels and deletes the page' do
      create_page
      open_record('pages', 'e2e-page', 'View'); expect(page).to have_content('Content e2e-page')
      area('pages'); open_record('pages', 'e2e-page', 'Edit')
      fill_field 'Title', with: 'Updated Page Title'; click_button 'Save Page'
      expect(find('.scrollable-container')).to have_content('Updated Page Title')
      open_record('pages', 'e2e-page', 'Edit'); fill_field 'Title', with: 'Discarded'; cancel
      expect(find('.scrollable-container')).to have_content('Updated Page Title')
      delete_record('pages', 'e2e-page')
      area('sections'); expect(page).to have_no_link('View')
      area('cells'); expect(page).to have_no_link('View')
    end

    it 'cancels New Page without creating a content record' do
      area('pages'); click_link 'New page'; replace_input('#name', 'unsaved-page')
      replace_input('#section', 'unsaved-page'); cancel
      expect(page).to have_current_path('/admin/pages', ignore_query: true)
      expect(find('.scrollable-container')).to have_no_content('unsaved-page')
    end

    it 'opens Add Section, generates columns and cancels its temporary record' do
      create_page; open_record('pages', 'e2e-page', 'Edit'); click_link 'Add Section'
      expect(page).to have_current_path(%r{/admin/sections/\d+/edit}, ignore_query: true)
      select 'Text Only', from: 'cellTemplates'; quill('Temporary section text')
      click_button 'Generate Columns'
      expect(page).to have_content('Temporary section text')
      cancel
      expect(page).to have_current_path(%r{/admin/pages/\d+/edit}, ignore_query: true)
      expect(page).to have_no_content('Temporary section text')
      expect(Section.count).to eq(1)
    end

    ['Text Only','Image Only','Dual Column - Text Left','Dual Column - Text Right','Three Column','Four Column','Five Column'].each do |template|
      it "generates the #{template} column template and saves it" do
        create_image if template.include?('Image') || template.include?('Dual')
        create_page; open_record('pages', 'e2e-page', 'Edit'); click_link 'Add Section'
        select template, from: 'cellTemplates'
        quill('Generated text') if page.has_css?('.ql-editor', wait: 0)
        if page.has_css?('#image', wait: 0)
          find('#image').click
          find('[id*="react-select"][id*="option"]', text: 'e2e-image', match: :first).click
        end
        click_button 'Generate Columns'
        expect(page).to have_button('Save Section')
        expected = { 'Text Only'=>1, 'Image Only'=>1, 'Dual Column - Text Left'=>2, 'Dual Column - Text Right'=>2, 'Three Column'=>3, 'Four Column'=>4, 'Five Column'=>5 }.fetch(template)
        expect(page).to have_link('Edit Column', count: expected, exact: true)
        click_button 'Save Section'
        expect(page).to have_current_path(%r{/admin/pages/\d+/edit}, ignore_query: true)
      end
    end

    it 'views, edits, cancels and deletes Sections and Cells from their lists' do
      create_page; area('sections'); click_link 'View', exact: true
      expect(page).to have_content('e2e-page-section'); click_link 'Back to Sections'
      click_link 'Edit', exact: true
      expect(page).to have_button('Save Section'); cancel
      area('cells'); click_link 'View', exact: true
      expect(page).to have_content('Content e2e-page'); click_link 'Back to Cells'
      click_link 'Edit', exact: true
      expect(page).to have_button('Save Column')
      replace_input('#cell_name', 'renamed-cell'); quill('Updated cell content')
      click_button 'Save Column'
      expect(page).to have_content('Updated cell content')
      area('cells'); delete_record('cells', 'renamed-cell')
      area('sections'); delete_record('sections', 'e2e-page-section')
    end

    it 'round trips Column HTML and formatting modes and persists margins and background' do
      create_page; area('cells'); click_link 'Edit', exact: true
      click_button 'Switch to HTML View **'
      expect(page).to have_css('textarea[placeholder="Edit raw HTML here"]')
      find('textarea').set('<p><strong>Column HTML</strong></p>')
      click_button 'Switch to Editor View'; expect(page).to have_css('strong', text: 'Column HTML')
      %w[marginTop marginLeft marginBottom marginRight].each { |id| find("##{id}").find('option', text: /3/, match: :first).select_option }
      select 'Red', from: 'backgroundColor'
      click_button 'Switch to Formatting Mode **'
      expect(page).to have_content('Current'); expect(page).to have_select('formattingField')
      click_button 'Switch to Normal Mode'; click_button 'Save Column'
      expect(page).to have_content('Column HTML')
      area('cells'); click_link 'Edit', exact: true
      %w[marginTop marginLeft marginBottom marginRight].each { |id| expect(find("##{id}").value).to match(/3/) }
      expect(page).to have_select('backgroundColor', selected: 'Red')
    end

    { 'sections'=>%w[q_content_type_cont q_section_name_cont q_image_cont q_link_cont q_description_cont],
      'cells'=>%w[q_section_name_cont q_cell_name_cont q_image_cont q_link_cont q_content_cont] }.each do |resource,fields|
      fields.each do |field|
        it "searches #{resource} with #{field} and clears empty results" do
          create_page; area(resource)
          fill_field field, with: 'unmatched-e2e-token'; click_button(resource == 'sections' ? 'Search Sections' : 'Search Cells')
          expect(page).to have_no_link('View', exact: true)
          clear_search; expect(page).to have_link('View', exact: true)
        end
      end
    end

    it 'navigates First, Next, Previous and Last on Sections and Cells' do
      create_page('e2e-first'); create_page('e2e-second')
      %w[sections cells].each do |resource|
        area(resource); first_href = find_link('View', exact: true)[:href]
        first('a', text: 'Next', exact_text: true).click
        expect(find_link('View', exact: true)[:href]).not_to eq(first_href)
        first('a', text: 'Previous', exact_text: true).click
        expect(find_link('View', exact: true)[:href]).to eq(first_href)
        first('a', text: 'Last', exact_text: true).click
        expect(find_link('View', exact: true)[:href]).not_to eq(first_href)
        first('a', text: 'First', exact_text: true).click
        expect(find_link('View', exact: true)[:href]).to eq(first_href)
      end
    end
  end

  describe 'additional editor and persistence controls' do
    it 'persists Column name, order, link and content and leaves canceled edits unchanged' do
      create_page; area('cells'); click_link 'Edit', exact: true
      replace_input('#cell_name', 'ordered-column'); replace_input('#cell_order', '7')
      replace_input('#link', '/admin'); quill('Linked column text')
      click_button 'Save Column'
      area('cells'); click_link 'Edit', exact: true
      expect(find('#cell_name').value).to eq('ordered-column')
      expect(find('#cell_order').value).to eq('7')
      expect(find('#link').value).to eq('/admin')
      quill('Discarded column text'); cancel
      area('cells'); click_link 'View', exact: true
      expect(page).to have_content('Linked column text')
      expect(page).to have_no_content('Discarded column text')
    end

    it 'adds, edits and removes CSS entries through Formatting Mode' do
      create_page; area('cells'); click_link 'Edit', exact: true
      click_button 'Switch to Formatting Mode **'
      options = find('#formattingField').all('option').reject { |option| option.value.to_s.empty? }
      expect(options).not_to be_empty
      style = options.first.value
      options.first.select_option
      expect(page).to have_field(style)
      fill_field style, with: 'e2e-formatting-value'
      field = find_field(style)
      row = field.find(:xpath, "ancestor::div[contains(@class,'row')][1]")
      row.click_button 'Delete'
      expect(page).to have_no_field(style)
      expect(page).to have_select('formattingField')
      cancel
    end

    %w[Images Groups Videos].each do |mode|
      it "switches the Column image picker to #{mode}" do
        create_image; create_page; area('cells'); click_link 'Edit', exact: true
        find("#image_type option[value='#{mode}']").select_option
        expect(find('#image_type').value).to eq(mode)
        expect(page).to have_css('#image')
        cancel
      end
    end

    it 'adds the new page to a header menu and footer through their checkbox controls' do
      area('pages'); click_link 'New page'
      replace_input('#name', 'linked-page'); replace_input('#title', 'Linked Page'); replace_input('#section', 'linked-page')
      check 'Add to menu'; check 'Add to footer'
      within('#menuItemDiv') { select 'Root', from: 'parent_id' }
      within('#footerItemDiv') { select 'OTHER', from: 'parent_id' }
      replace_input('#menu_order', '8'); replace_input('#footer_order', '8')
      click_button 'Save Page'
      expect(page).to have_current_path('/admin/pages', ignore_query: true)
      area('menu_items'); expect(find('.scrollable-container')).to have_content('Linked Page')
      area('footer_items'); expect(find('.scrollable-container')).to have_content('Linked Page')
      visit '/linked-page'; expect(page).to have_title(/Linked Page/)
    end

    it 'opens and cancels section and column editors from the Page preview' do
      create_page; open_record('pages', 'e2e-page', 'Edit')
      click_link 'Edit Section'; expect(page).to have_button('Save Section')
      click_link 'Edit Column'; expect(page).to have_button('Save Column')
      quill('Unsaved inline content'); cancel
      expect(page).to have_content('Content e2e-page')
      expect(page).to have_no_content('Unsaved inline content')
      cancel
    end

    it 'confirms Delete Section and Delete Column in the Page preview' do
      create_page; open_record('pages', 'e2e-page', 'Edit')
      dismiss_confirm { click_link 'Delete Column' }
      expect(page).to have_content('Content e2e-page')
      accept_confirm { click_link 'Delete Section' }
      expect(page).to have_no_content('Content e2e-page')
      expect(Section.count).to eq(0)
      expect(Cell.count).to eq(0)
    end

    it 'shows all rich-text toolbar controls and applies inline and list formats' do
      area('blog_posts'); click_link 'New Blog'
      editor = find('.ql-editor'); editor.click
      %w[bold italic underline strike].each { |name| find(".ql-#{name}").click }
      editor.send_keys('Formatted text')
      %w[strong em u s].each { |tag| expect(editor).to have_css(tag, text: 'Formatted text') }
      %w[font header color background script size list align link image blockquote code-block clean].each do |name|
        expect(page).to have_css(".ql-toolbar .ql-#{name}")
      end
      find('.ql-list[value=bullet]').click
      expect(editor).to have_css('li', text: 'Formatted text')
      cancel
    end

    it 'sorts real records in both directions and restores the default list' do
      create_user('Zulu Member'); create_user('Alpha Member')
      click_link 'Name ↓↑', exact: true
      rows = find('.scrollable-container').text
      expect(rows.index('Alpha Member')).to be < rows.index('Zulu Member')
      click_link 'Name ↓', exact: true
      rows = find('.scrollable-container').text
      expect(rows.index('Zulu Member')).to be < rows.index('Alpha Member')
    end

    it 'paginates Image Files across four-item pages' do
      5.times { |i| create_image("e2e-image-#{i}", order: i+1) }
      first_href = URI(all('a', text: 'View', exact_text: true).first[:href]).request_uri
      first('a', text: 'Next', exact_text: true).click
      expect(page).to have_no_link('View', href: first_href)
      first('a', text: 'First', exact_text: true).click
      expect(page).to have_link('View', href: first_href)
      first('a', text: 'Last', exact_text: true).click
      expect(page).to have_no_link('View', href: first_href)
      first('a', text: 'Previous', exact_text: true).click
      expect(page).to have_link('View', href: first_href)
    end
  end

  describe 'sort controls' do
    AdminE2E::AREAS.each do |label, resource|
      it "exercises every sort column and Clear Sort in #{label}" do
        create_page if %w[sections cells].include?(resource)
        area(resource)
        links = all('a[href*="sort="]').filter_map do |link|
          query = URI(link[:href]).query
          [link.text, query] if URI.decode_www_form(query || '').to_h.key?('sort')
        end
        expect(links).not_to be_empty
        links.each do |text, query|
          column = URI.decode_www_form(query).to_h.fetch('sort')
          click_link text, exact: true
          expect(URI.decode_www_form(URI(page.current_url).query || '').to_h['sort']).to eq(column)
          expect(URI.decode_www_form(URI(page.current_url).query || '').to_h['direction']).to eq('asc')
          find("a[href*='sort=#{column}'][href*='direction=desc']").click
          expect(URI.decode_www_form(URI(page.current_url).query || '').to_h['direction']).to eq('desc')
          area(resource)
        end
        click_link 'Clear Sort' if page.has_link?('Clear Sort', wait: 0)
        expect(page).to have_current_path("/admin/#{resource}", ignore_query: true)
      end
    end
  end
  describe 'public website after admin changes' do
    def public_visit(path)
      Capybara.reset_sessions!
      visit path
      expect(page).to have_no_link('Edit Page', exact: true)
      expect(page).to have_no_link('Edit Column', exact: true)
    end

    it 'publishes page content and title updates, preserves canceled edits, and removes deleted pages' do
      create_page
      public_visit('/e2e-page')
      expect(page).to have_title(/Title e2e-page/)
      expect(page).to have_content('Content e2e-page')
      log_in
      area('pages'); open_record('pages', 'e2e-page', 'Edit')
      fill_field 'Title', with: 'Public Updated Title'; click_button 'Save Page'
      area('cells'); click_link 'Edit', exact: true
      quill('Public updated body'); click_button 'Save Column'
      public_visit('/e2e-page')
      expect(page).to have_title(/Public Updated Title/)
      expect(page).to have_content('Public updated body')
      expect(page).to have_no_content('Content e2e-page')
      log_in
      area('cells'); click_link 'Edit', exact: true
      quill('Discarded public body'); cancel
      public_visit('/e2e-page')
      expect(page).to have_content('Public updated body')
      expect(page).to have_no_content('Discarded public body')
      log_in
      area('pages'); delete_record('pages', 'e2e-page')
      public_visit('/e2e-page')
      expect(page).to have_content("Can't find page for: e2e-page.")
      expect(page).to have_no_content('Public updated body')
    end

    it 'renders saved rich text and background formatting on the public page' do
      create_page
      area('cells'); click_link 'Edit', exact: true
      click_button 'Switch to HTML View **'
      find('textarea').set('<p><strong>Public bold text</strong> <em>Public italic text</em></p>')
      click_button 'Switch to Editor View'
      select 'Red', from: 'backgroundColor'
      click_button 'Save Column'
      public_visit('/e2e-page')
      expect(page).to have_css('strong', text: 'Public bold text')
      expect(page).to have_css('em', text: 'Public italic text')
      colored_block = find('strong', text: 'Public bold text').find(:xpath, 'ancestor::div[@style][1]')
      expect(colored_block.style('background-color')['background-color']).to match(/rgba?\(255,\s*0,\s*0(?:,\s*1)?\)/)
    end

    it 'removes deleted columns and sections from a public page' do
      create_page
      public_visit('/e2e-page')
      expect(page).to have_content('Content e2e-page')
      log_in
      area('cells'); click_link 'Edit', exact: true
      cell_name = find('#cell_name').value
      cancel
      delete_record('cells', cell_name)
      public_visit('/e2e-page')
      expect(page).to have_no_content('Content e2e-page')
      log_in
      area('sections'); delete_record('sections', 'e2e-page-section')
      public_visit('/e2e-page')
      expect(page).to have_title(/Title e2e-page/)
      expect(page).to have_no_content('Content e2e-page')
      expect(page).to have_no_css('[data-react-props*="e2e-page-section"]')
    end

    { 'menu_items' => 'header', 'footer_items' => 'footer' }.each do |resource, container|
      it "publishes edited #{container} links and removes deleted links for visitors" do
        create_page
        create_link_item(resource, 'Public Link', parent: resource == 'footer_items' ? 'OTHER' : nil)
        open_record(resource, 'Public Link', 'Edit')
        fill_field 'Options', with: ''; fill_field 'Link', with: '/e2e-page'
        click_button(resource == 'menu_items' ? 'Save Menu Item' : 'Save Footer Item')
        public_visit('/e2e-page')
        within(container) do
          expect(page).to have_link('Public Link', href: '/e2e-page')
          click_link 'Public Link', exact: true
        end
        expect(page).to have_current_path('/e2e-page', ignore_query: true)
        expect(page).to have_content('Content e2e-page')
        log_in
        area(resource); open_record(resource, 'Public Link', 'Edit')
        fill_field 'Label*', with: 'Updated Public Link'
        click_button(resource == 'menu_items' ? 'Save Menu Item' : 'Save Footer Item')
        public_visit('/e2e-page')
        within(container) do
          expect(page).to have_link('Updated Public Link', href: '/e2e-page')
          expect(page).to have_no_link('Public Link', exact: true)
        end
        log_in
        area(resource); delete_record(resource, 'Updated Public Link')
        public_visit('/e2e-page')
        within(container) { expect(page).to have_no_link('Updated Public Link', exact: true) }
      end
    end

    it 'loads an uploaded image publicly and shows updated captions and descriptions' do
      create_image
      image_path = "/image_files/#{ImageFile.find_by!(name: 'e2e-image').id}"
      public_visit(image_path)
      expect(page).to have_content('Caption e2e-image')
      image = find('img[alt="e2e-image"]') { |node| node.evaluate_script('this.complete && this.naturalWidth > 0') }
      expect(image).to match_css('img[src*="/rails/active_storage/"]')
      log_in
      area('image_files'); open_record('image_files', 'e2e-image', 'Edit')
      quill('Public updated caption', index: 0); quill('Public updated description', index: 1)
      click_button 'Save Image'
      public_visit(image_path)
      expect(page).to have_content('Public updated caption')
      expect(page).to have_content('Public updated description')
      expect(page).to have_no_content('Caption e2e-image')
      log_in
      area('image_files'); delete_record('image_files', 'e2e-image')
      public_visit(image_path)
      expect(page).to have_no_css('img[alt="e2e-image"]')
      expect(page).to have_no_content('Public updated description')
    end

    it 'publishes blog edits to visitors and removes deleted posts from the public list' do
      create_blog
      blog_path = "/blogs/#{BlogPost.find_by!(title: 'E2E Blog').id}"
      public_visit('/blogs')
      expect(page).to have_css('h2', text: 'E2E Blog')
      expect(page).to have_content('E2E post content')
      public_visit(blog_path)
      expect(page).to have_content('E2E post content')
      log_in
      area('blog_posts'); open_record('blog_posts', 'E2E Blog', 'Edit')
      fill_field 'Title*', with: 'Public Updated Blog'; quill('Public updated post body')
      click_button 'Save Blog Post'
      public_visit('/blogs')
      expect(page).to have_css('h2', text: 'Public Updated Blog')
      expect(page).to have_content('Public updated post body')
      expect(page).to have_no_content('E2E post content')
      public_visit(blog_path)
      expect(page).to have_content('Public updated post body')
      log_in
      area('blog_posts'); delete_record('blog_posts', 'Public Updated Blog')
      public_visit('/blogs')
      expect(page).to have_no_css('h2', text: 'Public Updated Blog')
      expect(page).to have_no_content('Public updated post body')
      public_visit(blog_path)
      expect(page).to have_no_content('Public updated post body')
    end

    it 'hides a post changed to Private from the public list, latest view, and direct URL' do
      create_blog('Private visibility test', 'Visitor-secret body')
      blog_path = "/blogs/#{BlogPost.find_by!(title: 'Private visibility test').id}"
      open_record('blog_posts', 'Private visibility test', 'Edit')
      select 'Private', from: 'Visibility'; click_button 'Save Blog Post'
      public_visit('/blogs')
      expect(page).to have_css('input[placeholder="Search by title"]')
      expect(page).to have_no_css('h2', text: 'Private visibility test')
      expect(page).to have_no_content('Visitor-secret body')
      aggregate_failures('private post public routes') do
        public_visit('/blogs/latest')
        expect(page).to have_no_content('Visitor-secret body')
        public_visit(blog_path)
        expect(page).to have_no_content('Visitor-secret body')
      end
    end
  end
end

end
