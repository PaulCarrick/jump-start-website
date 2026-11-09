require 'rails_helper'

RSpec.describe 'Check spelling and grammar in the editor', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Our Garden') }
  let!(:section) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'garden-intro', image: nil, description: nil) }
  let!(:column) do
    create(:cell, section: section, section_name: 'garden-intro', cell_name: 'intro-text', cell_order: 1, image: nil, link: nil,
                  content: '<p>The <strong>the</strong> roses grwo in June.</p>')
  end

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
    # LanguageTool, faked: it finds the repeated word and the misspelling wherever they are.
    allow(GrammarCheck).to receive(:check) do |text|
      problems = []
      if (at = text.index('The the'))
        problems << { offset: at, length: 7, message: 'Possible typo: you repeated a word.', short_message: '',
                      replacements: [ 'The' ], rule: 'ENGLISH_WORD_REPEAT_RULE', kind: 'grammar' }
      end
      if (at = text.index('grwo'))
        problems << { offset: at, length: 4, message: 'Possible spelling mistake found.', short_message: '',
                      replacements: %w[grow grown], rule: 'MORFOLOGIK_RULE_EN_US', kind: 'spelling' }
      end
      problems
    end
  end

  def editor_text = first('.workspace-panel .ql-editor').text

  it 'underlines the problems, fixes one with a click, and saves the fixed text' do
    visit admin_page_workspace_path(page_record, cell: column.id)
    within('.workspace-panel') { click_button 'Check spelling and grammar' }
    expect(page).to have_css('.grammar-problem', count: 2)
    expect(page).to have_css('.grammar-mark.is-spelling', count: 1)
    expect(page).to have_css('.grammar-mark.is-grammar', minimum: 1)
    # Each underline sits just under its word.
    gap = page.evaluate_script(<<~JS)
      (() => {
        const editor = document.querySelector('.workspace-panel .ql-editor');
        const walker = document.createTreeWalker(editor, NodeFilter.SHOW_TEXT); let node, word = null;
        while ((node = walker.nextNode())) { const at = node.nodeValue.indexOf('grwo'); if (at >= 0) { const range = document.createRange(); range.setStart(node, at); range.setEnd(node, at + 4); word = range.getBoundingClientRect(); } }
        const mark = document.querySelector('.grammar-mark.is-spelling').getBoundingClientRect();
        return [Math.abs(mark.left - word.left), Math.abs(mark.width - word.width), Math.abs(mark.top - word.bottom)];
      })()
    JS
    expect(gap.max).to be < 4
    expect(page).to have_css('.grammar-check-status', text: '2 possible problems found')

    within('.grammar-problem.is-spelling') { click_button 'grow' }
    expect(editor_text).to include('roses grow in June')
    expect(page).to have_css('.grammar-problem', count: 1)

    within('.grammar-problem.is-grammar') { click_button 'The' }
    expect(editor_text).to start_with('The roses grow')
    expect(page).to have_css('.grammar-check-status', text: 'All done')

    wait_for_new_page { click_button 'Save Column' }
    expect(Cell.find(column.id).content).to include('roses grow in June')
    expect(Cell.find(column.id).content).not_to include('grwo')
  end

  it 'clears the results when the text is typed in after a check' do
    visit admin_page_workspace_path(page_record, cell: column.id)
    within('.workspace-panel') { click_button 'Check spelling and grammar' }
    expect(page).to have_css('.grammar-problem', count: 2)
    first('.workspace-panel .ql-editor').send_keys(:end, ' More.')
    expect(page).to have_css('.grammar-check-status', text: 'The text changed')
    expect(page).to have_no_css('.grammar-problem')
    expect(page).to have_no_css('.grammar-mark')
  end

  it 'is not offered on the public contact form' do
    logout
    visit new_contact_path
    expect(page).to have_css('.ql-editor')
    expect(page).to have_no_button('Check spelling and grammar')
  end
end
