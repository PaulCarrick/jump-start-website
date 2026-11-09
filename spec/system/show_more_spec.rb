require 'rails_helper'

# "Show More" hides the rest of a group (content with a shared class) until it
# is clicked. Moving sections must not change that: the hidden part used to
# show when it was drawn after the button was set up.
RSpec.describe 'Show More on a page', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'work', section: 'work-content', title: 'Work') }
  let!(:details) { create(:section, page: page_record, content_type: 'work-content', section_name: 'job-details', section_order: 1) }
  let!(:summary) { create(:section, page: page_record, content_type: 'work-content', section_name: 'job-summary', section_order: 2) }

  before do
    driven_by(:selenium_chrome_headless)
    # The details come first on the page, before the section with the button.
    create(:cell, section: details, section_name: 'job-details', image: nil, link: nil, cell_order: 1,
                  content: '<p>Hidden details</p>', formatting: { 'container_classes' => 'expandableJobCells pt-3' })
    create(:cell, section: summary, section_name: 'job-summary', image: nil, link: nil, cell_order: 1, content: '<p>Job summary</p>',
                  formatting: { 'expanding_cells' => 'toggle, .expandableJobCells, btn btn-link p-0 text-dark' })
  end

  def check_show_more
    expect(page).to have_content('Job summary')
    expect(page).to have_button('Show More')
    expect(page).to have_no_content('Hidden details')
    click_button 'Show More'
    expect(page).to have_content('Hidden details')
    expect(page).to have_button('Show Less')
    click_button 'Show Less'
    expect(page).to have_no_content('Hidden details')
  end

  it 'keeps the rest of the group hidden until Show More, wherever it is on the page' do
    visit page_path('work')
    check_show_more
  end

  it 'works the same in the page editing mode' do
    login_as(create(:user, access: 'super'))
    visit page_path('work')
    click_button 'Edit Page'
    expect(page).to have_button(text: /Editing…\s+Save Changes/)
    check_show_more
  end

  # Moving one part of a group used to split it, leaving the Show More far from
  # the heading it belonged to. Now the group moves as one and comes back together.
  it 'moves a section with the sections its Show More opens' do
    other = create(:section, page: page_record, content_type: 'work-content', section_name: 'other-job', section_order: 3)
    create(:cell, section: other, section_name: 'other-job', image: nil, link: nil, cell_order: 1, content: '<p>Another job</p>')
    login_as(create(:user, access: 'super'))
    visit page_path('work')
    click_button 'Edit Page'
    # The page reads: hidden details, summary, another job.
    find("[data-section-id='#{summary.id}']").hover
    within("[data-section-id='#{summary.id}'] .page-edit-section-handle") do
      click_button 'Move this section down with its Show More group'
    end
    expect(page).to have_button(text: /Save Changes \(\d\)/)
    expect(page).to have_text(/Another job.*Job summary/m)
    click_button 'Show More'
    expect(page).to have_text(/Another job.*Hidden details.*Job summary/m)
    expect(Section.find(other.id).section_order).to be < Section.find(details.id).section_order
  end

  # With boxes (rounded, spaced cards), an open Show More reads as one box:
  # the box it is in and the boxes it opened meet with no gap.
  it 'joins the boxes while open and separates them again when closed' do
    card = 'bg-white rounded-4 shadow-sm p-4 mb-4'
    Cell.where(section_id: summary.id).update_all(formatting: { 'container_classes' => card, 'expanding_cells' => 'toggle, .expandableJobCells, btn btn-link p-0 text-dark' })
    Cell.where(section_id: details.id).update_all(formatting: { 'container_classes' => "expandableJobCells #{card}" })
    summary.update_columns(section_order: 1)
    details.update_columns(section_order: 2)
    visit page_path('work')
    expect(page).to have_no_css('[data-box-join]')
    click_button 'Show More'
    expect(page).to have_content('Hidden details')
    expect(page).to have_css('[data-box-join="first"]#job-summary')
    expect(page).to have_css('[data-box-join="last"]#job-details')
    gap = page.evaluate_script("document.querySelector('#job-details').getBoundingClientRect().top - document.querySelector('#job-summary').getBoundingClientRect().bottom")
    expect(gap.abs).to be < 1
    click_button 'Show Less'
    expect(page).to have_no_css('[data-box-join]')
  end
end
