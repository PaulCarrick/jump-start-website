require 'rails_helper'

RSpec.describe "cells/show", type: :view do
  before(:each) do
    assign(:cell, Cell.create!(
      section_name: "Section Name",
      cell_order: 2,
      description: "MyText",
      image: "Image",
      link: "Link",
      options: "",
      formatting: "",
      width: "Width",
      checksum: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Section Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Image/)
    expect(rendered).to match(/Link/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Width/)
    expect(rendered).to match(/MyText/)
  end
end
