require 'rails_helper'

RSpec.describe "columns/edit", type: :view do
  let(:column) {
    Column.create!(
      section_nmme: "MyString",
      column_order: 1,
      description: "MyText",
      image: "MyString",
      link: "MyString",
      options: "",
      formatting: "",
      width: "MyString",
      checksum: "MyText"
    )
  }

  before(:each) do
    assign(:column, column)
  end

  it "renders the edit column form" do
    render

    assert_select "form[action=?][method=?]", column_path(column), "post" do

      assert_select "input[name=?]", "column[section_nmme]"

      assert_select "input[name=?]", "column[column_order]"

      assert_select "textarea[name=?]", "column[description]"

      assert_select "input[name=?]", "column[image]"

      assert_select "input[name=?]", "column[link]"

      assert_select "input[name=?]", "column[options]"

      assert_select "input[name=?]", "column[formatting]"

      assert_select "input[name=?]", "column[width]"

      assert_select "textarea[name=?]", "column[checksum]"
    end
  end
end
