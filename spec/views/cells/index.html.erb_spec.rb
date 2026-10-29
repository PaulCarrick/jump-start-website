require 'rails_helper'

RSpec.describe "cells/index", type: :view do
  it "renders cell links and content" do
    assign(:site_information, double(site_name: "Test site"))
    assign(:cells, [ { cell_name: "Example cell", url: "/example", content: "<p>Cell content</p>" } ])
    stub_template "layouts/_header.html.erb" => ""
    stub_template "layouts/_footer.html.erb" => ""
    stub_template "shared/_page_navigation.html.erb" => ""

    render

    assert_select 'a[href="/example"]', text: "Example cell"
    assert_select 'p', text: "Cell content"
  end
end
