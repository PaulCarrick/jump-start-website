require 'rails_helper'
require Rails.root.join('db/migrate/20261030120000_add_enabled_to_editable_models')

RSpec.describe AddEnabledToEditableModels do
  it 'backfills missing required timestamps and enables existing records' do
    connection = ActiveRecord::Base.connection
    table = :enabled_migration_records
    connection.create_table(table) { |t| t.string :name }
    connection.execute("INSERT INTO enabled_migration_records (name) VALUES ('existing')")
    stub_const('AddEnabledToEditableModels::TABLES', [ table ])
    described_class.new.migrate(:up)
    row = connection.select_one('SELECT * FROM enabled_migration_records')
    expect(row['enabled']).to be(true)
    expect(row['created_at']).to be_present
    expect(row['updated_at']).to be_present
    expect(connection.columns(table).select { |c| %w[created_at updated_at enabled].include?(c.name) }.map(&:null)).to eq([ false, false, false ])
  ensure
    connection.drop_table(table, if_exists: true)
  end
end
