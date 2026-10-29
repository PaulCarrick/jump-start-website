module Persistence
  def set_search(parameters = params.dup)
    model_class = controller_name.classify.constantize
    search_key = "#{model_class.table_name}_search".to_sym

    if parameters[:clear_search]
      session.delete(search_key)
      parameters.delete(:q)
    elsif parameters[:q].present?
      session[search_key] = parameters[:q]
    else
      parameters[:q] = session[search_key]
    end

    @q = model_class.ransack(parameters[:q])
  end

  def set_sorting(default_column, default_direction, parameters = params.dup)
    model_class = controller_name.classify.constantize
    sort_key = "#{model_class.table_name}_sort".to_sym
    direction_key = "#{model_class.table_name}_sort_direction".to_sym

    if parameters[:clear_sort]
      session.delete(sort_key)
      session.delete(direction_key)
      @sort_column = @sort_direction = nil
      return [ @sort_column, @sort_direction ]
    end

    session[sort_key] = parameters[:sort] if parameters[:sort].present?
    session[direction_key] = parameters[:direction] if parameters[:direction].present?

    column = parameters[:sort].presence || session[sort_key].presence || default_column
    direction = parameters[:direction].presence || session[direction_key].presence || default_direction
    @sort_column = model_class.column_names.include?(column) ? column : default_column
    @sort_direction = %w[asc desc].include?(direction) ? direction : default_direction

    [ @sort_column, @sort_direction ]
  end
end
