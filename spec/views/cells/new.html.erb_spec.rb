require 'rails_helper'

RSpec.describe "cells/new", type: :view do
  before(:each) do
    assign(:cell, Cell.new(
      section_name: "MyString",
      cell_order: 1,
      description: "MyText",
      image: "MyString",
      link: "MyString",
      options: "",
      formatting: "",
      width: "MyString",
      checksum: "MyText"
    ))
  end

  it "renders new cell form" do
    render

    assert_select "form[action=?][method=?]", cells_path, "post" do

      assert_select "input[name=?]", "cell[section_name]"

      assert_select "input[name=?]", "cell[cell_order]"

      assert_select "textarea[name=?]", "cell[description]"

      assert_select "input[name=?]", "cell[image]"

      assert_select "input[name=?]", "cell[link]"

      assert_select "input[name=?]", "cell[options]"

      assert_select "input[name=?]", "cell[formatting]"

      assert_select "input[name=?]", "cell[width]"

      assert_select "textarea[name=?]", "cell[checksum]"
    end
  end
end
