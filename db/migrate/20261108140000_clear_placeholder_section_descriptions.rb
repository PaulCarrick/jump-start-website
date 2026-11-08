# "Add Section" used to fill every new section's description with a placeholder.
# The section editor has no description field, so it could never be changed,
# and site search showed it. Clear it in every version of those sections. Search
# then shows the section's matching column text instead.
class ClearPlaceholderSectionDescriptions < ActiveRecord::Migration[8.1]
  PLACEHOLDER = "New Section. Please replace this text."

  def up
    execute "UPDATE sections SET description = NULL WHERE description = #{connection.quote(PLACEHOLDER)}"
  end

  def down
    # The placeholder carried no information, so there is nothing to restore.
  end
end
