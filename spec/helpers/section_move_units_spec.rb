require 'rails_helper'

RSpec.describe ApplicationHelper, '#section_move_units', type: :helper do
  def section(id, cells: [], group: nil, formatting: nil)
    { "id" => id, "section_group" => group, "formatting" => formatting,
      "cells" => cells.map { |cell_formatting| { "formatting" => cell_formatting } } }
  end

  it 'keeps a Show More with the sections it opens, wherever they are' do
    contents = [
      section(1, cells: [ { "container_classes" => "expandableJobCells pt-3" } ]),
      section(2, cells: [ { "expanding_cells" => "toggle, .expandableJobCells, btn btn-link" } ]),
      section(3)
    ]
    units = helper.section_move_units(contents)
    expect(units[1]).to eq(units[2])
    expect(units[3]).not_to eq(units[2])
  end

  # Minnesota Paid Leave's hidden part also carries IBI's row class by mistake.
  it 'joins a hidden section to its first Show More only' do
    contents = [
      section(1, cells: [ { "expanding_cells" => "toggle, .expandableMNPLCells, btn" } ]),
      section(2, cells: [ { "container_classes" => "expandableMNPLCells" } ], formatting: { "row_classes" => "expandableIbiRows" }),
      section(3, cells: [ { "expanding_cells" => "toggle, .expandableIbiCells, btn", "expanding_rows" => "toggle, .expandableIbiRows, btn" } ]),
      section(4, cells: [ { "container_classes" => "expandableIbiCells" } ])
    ]
    units = helper.section_move_units(contents)
    expect(units[2]).to eq(units[1])
    expect(units[4]).to eq(units[3])
    expect(units[1]).not_to eq(units[3])
  end

  it 'keeps a section group together' do
    units = helper.section_move_units([ section(1, group: 'team'), section(2), section(3, group: 'team') ])
    expect(units[1]).to eq(units[3])
    expect(units[2]).not_to eq(units[1])
  end
end
