require 'rails_helper'

RSpec.describe "cells/index", type: :view do
  before(:each) do
    # This view (app/views/cells/index.html.erb) renders the shared header/
    # footer layout partials inline, which need @site_information (a SiteSetup)
    # and @main_menu_items/@footer_items - empty arrays are enough since the
    # partials just skip their loops when there's nothing to iterate.
    assign(:site_information, SiteSetup.new(site_name: "Test Site"))
    assign(:main_menu_items, [])
    assign(:footer_items, [])

    section = create(:section, section_name: "Section Name")

    # The view iterates @results (not @cells - see the fix in
    # app/views/cells/index.html.erb) and reads cell_name/link/content, not
    # description. cell_name is required/unique, and cell requires an
    # associated section.
    assign(:results, [
      Cell.create!(
        cell_name:    "Cell One",
        section:      section,
        section_name: "Section Name",
        cell_order:   1,
        content:      "MyText One",
        image:        "Image",
        link:         "/link-one",
        width:        "Width",
        checksum:     "MyText One"
      ),
      Cell.create!(
        cell_name:    "Cell Two",
        section:      section,
        section_name: "Section Name",
        cell_order:   2,
        content:      "MyText Two",
        image:        "Image",
        link:         "/link-two",
        width:        "Width",
        checksum:     "MyText Two"
      )
    ])
  end

  it "renders a list of cells" do
    render

    assert_select "a[href='/link-one']", text: "Cell One"
    assert_select "a[href='/link-two']", text: "Cell Two"
    assert_select "div.col-10", text: /MyText One/
    assert_select "div.col-10", text: /MyText Two/
  end
end
