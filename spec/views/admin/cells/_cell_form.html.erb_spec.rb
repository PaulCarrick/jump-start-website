require 'rails_helper'

RSpec.describe "admin/cells/_cell_form", type: :view do
  let(:admin_controller) { Admin::CellsController.new }

  before do
    admin_controller.set_request!(controller.request)
    allow(view).to receive(:controller).and_return(admin_controller)
  end

  [ false, true ].each do |persisted|
    it "passes #{persisted ? 'existing' : 'new'} cell content and navigation options to the editor" do
      cell = persisted ? create(:cell, content: "Cell editor content") : build(:cell, content: "Cell editor content")
      allow(admin_controller).to receive(:get_item).and_return(cell)
      render partial: "admin/cells/cell_form"

      editor = Nokogiri::HTML.fragment(rendered).at_css('[data-react-class="CellEditor"]')
      expect(editor).to be_present
      props = JSON.parse(editor['data-react-props'])
      expect(props['cell']['content']).to eq("Cell editor content")
      expect(props.fetch('editorOptions').fetch('returnUrl')).to eq(persisted ? admin_cell_url(cell) : admin_cells_url)
    end
  end
end
