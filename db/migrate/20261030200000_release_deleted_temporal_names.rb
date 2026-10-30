# Tombstones preserve history and identity, but do not reserve live names.
class ReleaseDeletedTemporalNames < ActiveRecord::Migration[8.1]
  CONSTRAINTS = {
    cells: { index_cells_on_cell_name_and_section_name_period: %w[cell_name section_name] },
    image_files: { index_image_files_on_name_period: %w[name] },
    pages: { index_pages_on_name_period: %w[name], index_pages_on_section_period: %w[section] },
    sections: { index_sections_on_section_name_period: %w[section_name] },
    users: { index_users_on_email_period: %w[email], index_users_on_reset_password_token_period: %w[reset_password_token] }
  }.freeze

  def up
    execute "SET LOCAL lock_timeout = '10s'"
    CONSTRAINTS.each do |table, constraints|
      constraints.each do |name, columns|
        remove_exclusion_constraint table, name: name.to_s
        expression = (columns.map { |column| "#{quote_column_name(column)} WITH =" } + ['validity WITH &&']).join(', ')
        add_exclusion_constraint table, expression, using: :gist, where: 'NOT temporal_deleted', name: name.to_s
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Deleted names may have been reused; do not restore constraints that include tombstones.'
  end
end
