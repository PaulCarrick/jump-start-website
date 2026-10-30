require 'rails_helper'

RSpec.describe 'Section column ratios', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  it 'previews and saves the ratio as draft column widths while preserving live widths' do
    section = create(:section)
    left = create(:cell, section: section, cell_order: 1, width: '50%')
    right = create(:cell, section: section, cell_order: 2, width: '50%')
    visit edit_admin_section_path(section)
    fill_in 'Div Ratio:', with: '59:41'
    click_button 'Apply Ratio'
    expect(page).to have_css('#sectionPreview .admin-section-cell[style*="width: 59%"]')
    expect(page).to have_css('#sectionPreview .admin-section-cell[style*="width: 41%"]')
    click_button 'Save Section'
    expect(page).to have_current_path(admin_sections_path, ignore_query: true)
    expect(Cell.find(left.id).width).to eq('59%')
    expect(Cell.find(right.id).width).to eq('41%')
    PublishingContext.live = true
    expect(Cell.find(left.id).width).to eq('50%')
    expect(Cell.find(right.id).width).to eq('50%')
  end
end
