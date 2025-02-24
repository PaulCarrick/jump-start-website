require 'rails_helper'

RSpec.describe "columns/index", type: :view do
  before(:each) do
    assign(:columns, [
      Column.create!(
        section_nmme: "Section Nmme",
        column_order: 2,
        description: "MyText",
        image: "Image",
        link: "Link",
        options: "",
        formatting: "",
        width: "Width",
        checksum: "MyText"
      ),
      Column.create!(
        section_nmme: "Section Nmme",
        column_order: 2,
        description: "MyText",
        image: "Image",
        link: "Link",
        options: "",
        formatting: "",
        width: "Width",
        checksum: "MyText"
      )
    ])
  end

  it "renders a list of columns" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Section Nmme".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Image".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Link".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Width".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end
