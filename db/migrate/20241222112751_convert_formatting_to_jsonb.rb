class ConvertFormattingToJsonb < ActiveRecord::Migration[6.0]
  def up
    # Step 1: Add a temporary JSONB column
    add_column :sections, :formatting_tmp, :jsonb, default: {}, null: false

    # Step 2: Migrate data from the old string column to the new JSONB column
    Section.reset_column_information # Ensure ActiveRecord knows about the new column

    Section.find_each do |section|
      begin
        # Try parsing the existing string into JSON
        formatting_data = section.formatting.present? ? JSON.parse(section.formatting) : {}
      rescue JSON::ParserError
        # Default to an empty object if parsing fails
        formatting_data = {}
      end

      # Update the temporary JSONB column
      section.update_column(:formatting_tmp, formatting_data)
    end

    # Step 3: Remove the old string column
    remove_column :sections, :formatting, :string

    # Step 4: Rename the temporary column to the original column name
    rename_column :sections, :formatting_tmp, :formatting
  end

  def down
    # Step 1: Add the old string column back
    add_column :sections, :formatting_tmp, :string

    # Step 2: Convert JSONB data back to string
    Section.reset_column_information

    Section.find_each do |section|
      section.update_column(:formatting_tmp, section.formatting.to_json)
    end

    # Step 3: Remove the JSONB column
    remove_column :sections, :formatting, :jsonb

    # Step 4: Rename the temporary column back to the original column name
    rename_column :sections, :formatting_tmp, :formatting
  end
end
