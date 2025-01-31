# /app/controllers/admin/footer_items

class Admin::FooterItemsController < Admin::AbstractAdminController
  def initialize
    super

    @page_limit = 20
    @default_column = 'label'
    @has_query = false
    @has_sort = true
    @model_class = FooterItem
  end
end
