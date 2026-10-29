require 'rails_helper'

RSpec.describe "Cell administration", type: :request do
  let(:section) { create(:section) }
  let(:cell) { create(:cell, section: section, section_name: section.section_name) }

  before { sign_in create(:user, access: "super") }

  it "renders the new cell editor" do
    get new_admin_cell_path
    expect(response).to be_successful
    expect(response.body).to include('data-react-class="CellEditor"')
  end

  it "renders existing cell content in the editor" do
    get edit_admin_cell_path(cell)
    expect(response).to be_successful
    expect(response.body).to include('data-react-class="CellEditor"')
    expect(response.body).to include(cell.content)
  end

  it "creates a cell attached to the selected section" do
    expect {
      post admin_cells_path, params: { cell: { section_name: section.section_name, cell_name: "New column", content: "New content" } }
    }.to change(Cell, :count).by(1)
    expect(Cell.last.section).to eq(section)
    expect(response).to redirect_to(admin_cells_path)
  end

  it "updates content" do
    patch admin_cell_path(cell), params: { cell: { content: "Updated content" } }
    expect(cell.reload.content).to eq("Updated content")
    expect(response).to redirect_to(admin_cells_path)
  end

  it "rejects an invalid cell" do
    expect {
      post admin_cells_path, params: { cell: { section_name: section.section_name, cell_name: "" } }
    }.not_to change(Cell, :count)
    expect(response).to redirect_to(new_admin_cell_path(turbo: false))
  end

  it "deletes a cell" do
    cell
    expect { delete admin_delete_cell_path(cell) }.to change(Cell, :count).by(-1)
  end
end
