module Persistence
  def set_search(parameters = params.dup)
    model_class = controller_name.classify.constantize
    name = model_class.table_name
    search_key = "#{name}_search".to_sym

    if parameters.present?
      if parameters[:clear_search]
        session.delete(search_key)
        parameters.delete(:q)
      else
        if parameters[:q].present?
          session[search_key] = parameters[:q]
        elsif session[search_key].present?
          parameters[:q] = session[search_key]
        else
          session[search_key] = nil
        end
      end
    end

    @q = model_class.ransack(parameters[:q])
  end

  def set_sorting(default_column, default_direction, parameters = params.dup)
    @sort_column = nil
    @sort_direction = nil
    model_class = controller_name.classify.constantize
    name = model_class.table_name
    sort_key = "#{name}_sort".to_sym
    direction_key = "#{name}_sort_direction".to_sym

    if parameters.present?
      if parameters[:clear_sort]
        session.delete(:sort_key)
        session.delete(:direction_key)

        @sort_column = nil
        @sort_direction = nil
      else
        if parameters[:sort].present?
          session[sort_key] = parameters[:sort]
        elsif session[sort_key].present?
          parameters[:sort] = session[sort_key]
        else
          parameters[:sort] = nil
        end

        if parameters[:direction].present?
          session[direction_key] = parameters[:direction]
        elsif session[direction_key].present?
          parameters[:direction] = session[direction_key]
        else
          parameters[:direction] = nil
        end

        # Set default sort column and direction
        @sort_column = parameters[:sort].presence || default_column
        @sort_direction = parameters[:direction].presence || default_direction

        # Safeguard against invalid cells and directions
        @sort_column = model_class.column_names.include?(@sort_column) ? @sort_column : default_column
        @sort_direction = %w[asc desc].include?(@sort_direction) ? @sort_direction : default_direction
      end
    end

    [ @sort_column, @sort_direction ]
  end
end
