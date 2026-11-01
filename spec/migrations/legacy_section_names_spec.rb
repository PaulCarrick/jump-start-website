require 'rails_helper'
require Rails.root.join('db/migrate/20250222131434_create_cells')

RSpec.describe CreateCells do
  it 'preserves legacy sections and assigns collision-free names before requiring them' do
    connection = ActiveRecord::Base.connection
    original_path = connection.schema_search_path
    connection.execute('CREATE SCHEMA legacy_section_test')
    connection.schema_search_path = 'legacy_section_test, public'
    connection.create_table('legacy_section_test.sections') do |table|
      table.string :section_name
      table.text :description
      table.timestamps
    end
    connection.execute("INSERT INTO legacy_section_test.sections (id, section_name, description, created_at, updated_at) VALUES (1, NULL, 'Existing content', '2020-01-01', '2020-01-02'), (2, '  ', 'Blank name', '2020-01-01', '2020-01-02'), (3, 'legacy-section-1', 'Named content', '2020-01-01', '2020-01-02')")
    before = connection.select_all('SELECT id, description, created_at, updated_at FROM legacy_section_test.sections ORDER BY id').to_a
    described_class.new.migrate(:up)
    expect(connection.select_values('SELECT section_name FROM legacy_section_test.sections ORDER BY id')).to eq(%w[legacy-section-1-1 legacy-section-2 legacy-section-1])
    expect(connection.select_all('SELECT id, description, created_at, updated_at FROM legacy_section_test.sections ORDER BY id').to_a).to eq(before)
    expect(connection.columns('legacy_section_test.sections').find { |column| column.name == 'section_name' }.null).to be(false)
  ensure
    if connection && original_path
      connection.schema_search_path = original_path
      connection.execute('DROP SCHEMA IF EXISTS legacy_section_test CASCADE')
    end
  end
end
