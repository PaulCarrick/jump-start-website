require "rails_helper"

RSpec.describe "Cell administration", type: :request do
  let(:section) { create(:section) }
  let(:attributes) do
    { section_id: section.id, section_name: section.section_name,
      cell_name: "Request column", content: "<p>Saved column</p>",
      formatting: { "classes" => "col-12" } }
  end
  let(:cell) { create(:cell, section: section, section_name: section.section_name) }

  before { sign_in create(:user, access: "super") }

  it "renders public columns with links to their page sections" do
    cell
    get cells_path
    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    link = html.at_css("a[href='#{page_path(section.page.name, section_name: section.section_name)}']")
    expect(link.text).to eq(cell.cell_name)
    expect(response.body).to include(cell.content)
  end

  it "filters public columns by name" do
    cell
    get cells_path, params: { q: { cell_name_cont: "no-matching-column" } }
    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include(cell.cell_name)
  end

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

  it "creates a column with its parent and formatting" do
    expect { post admin_cells_path, params: { cell: attributes } }.to change(Cell, :count).by(1)
    saved = Cell.find_by!(cell_name: attributes[:cell_name])
    expect(saved.section).to eq(section)
    expect(saved.formatting).to eq(attributes[:formatting])
    expect(saved.content).to include("Saved column")
    expect(response).to redirect_to(admin_cells_path)
  end

  it "updates content" do
    patch admin_cell_path(cell), params: { cell: { content: "Updated content" } }
    expect(cell.reload.content).to eq("Updated content")
    expect(response).to redirect_to(admin_cells_path)
  end

  it "persists edits without changing the parent" do
    patch admin_cell_path(cell), params: { cell: { cell_name: "Renamed column", content: "<p>Edited</p>" } }
    expect(cell.reload.cell_name).to eq("Renamed column")
    expect(cell.content).to include("Edited")
    expect(cell.section).to eq(section)
    expect(response).to redirect_to(admin_cells_path)
  end

  it "rejects an invalid cell" do
    expect {
      post admin_cells_path, params: { cell: { section_name: section.section_name, cell_name: "" } }
    }.not_to change(Cell, :count)
    expect(response).to redirect_to(new_admin_cell_path)
  end

  it "rejects creation without a name" do
    expect { post admin_cells_path, params: { cell: attributes.merge(cell_name: nil) } }.not_to change(Cell, :count)
    expect(response).to redirect_to(new_admin_cell_path)
    expect(flash[:error]).to include("Cell name")
  end

  it "returns the created column ID for JSON clients" do
    expect { post admin_cells_path, params: { cell: attributes }, as: :json }.to change(Cell, :count).by(1)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("id")).to eq(Cell.find_by!(cell_name: attributes[:cell_name]).id)
  end

  it "returns validation errors to JSON clients without creating a column" do
    expect {
      post admin_cells_path, params: { cell: attributes.merge(cell_name: nil) }, as: :json
    }.not_to change(Cell, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body.fetch("error")).to include("Cell name")
  end

  it "deletes a cell" do
    cell
    expect { delete admin_delete_cell_path(cell) }.to change(Cell, :count).by(-1)
  end

  it "deletes only the requested column" do
    cell
    expect { delete admin_cell_path(cell) }.to change(Cell, :count).by(-1)
    expect(Section.exists?(section.id)).to be(true)
    expect(response).to redirect_to(admin_cells_path(turbo: false))
  end

  it "requires login to open the admin editor" do
    sign_out :user
    get edit_admin_cell_path(cell)
    expect(response).to redirect_to(new_user_session_path)
  end

  context "as an administrator" do
    before { sign_in create(:user, access: "super") }

    it "renders the new React editor with section options" do
      section
      get new_admin_cell_path
      expect(response).to have_http_status(:ok)
      editor = Nokogiri::HTML(response.body).at_css('[data-react-class="CellEditor"]')
      props = JSON.parse(editor['data-react-props'])
      expect(props.fetch("editorOptions").fetch("availableSectionNames")).to include(section.section_name)
    end

    it "renders the existing column in the edit React component" do
      get edit_admin_cell_path(cell)
      expect(response).to have_http_status(:ok)
      editor = Nokogiri::HTML(response.body).at_css('[data-react-class="CellEditor"]')
      expect(JSON.parse(editor['data-react-props']).fetch("cell").fetch("id")).to eq(cell.id)
    end

    it "renders a read-only column preview without an edit link" do
      get admin_cell_path(cell)
      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML(response.body)
      preview = document.at_css('[data-react-class="RenderCell"]')
      expect(preview).to be_present
      props = JSON.parse(preview['data-react-props'])
      expect(props.fetch('cell').fetch('id')).to eq(cell.id)
      expect(props.fetch('editing')).to be(false)
      expect(document.at_css("a[href='#{edit_admin_cell_path(cell)}']")).to be_nil
    end

    it "lists columns and exposes their search controls" do
      get admin_cells_path
      expect(response).to have_http_status(:ok)
      expect(Nokogiri::HTML(response.body).at_css('input[name="q[cell_name_cont]"]')).to be_present
    end
  end
end
