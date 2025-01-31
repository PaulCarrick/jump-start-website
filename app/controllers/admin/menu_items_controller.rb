# /app/controllers/admin/menu_items

class Admin::MenuItemsController < Admin::AbstractAdminController
  def initialize
    super

    @page_limit = 20
    @default_column = 'label'
    @has_query = false
    @has_sort = true
    @model_class = MenuItem
  end
end
