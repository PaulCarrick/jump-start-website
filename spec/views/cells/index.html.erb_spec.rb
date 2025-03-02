require 'rails_helper'

RSpec.describe "cells/index", type: :view do
  before(:each) do
    assign(:cells, [
      Cell.create!(
        section_name: "Section Name",
        cell_order: 2,
        description: "MyText",
        image: "Image",
        link: "Link",
        options: "",
        formatting: "",
        width: "Width",
        checksum: "MyText"
      ),
      Cell.create!(
        section_name: "Section Name",
        cell_order: 2,
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

  it "renders a list of cells" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Section Name".to_s), count: 2
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
