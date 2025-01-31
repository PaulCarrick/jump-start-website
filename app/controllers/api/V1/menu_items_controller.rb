# frozen_string_literal: true

# app/controllers/api/menu_items_controller.rb
module Api
  module V1
    class MenuItemsController < ApplicationController
      def index
        # Fetch all top-level items (where `parent_id` is nil)
        menu_items = MenuItem.where(parent_id: nil)
                             .order(:menu_order)
                             .includes(:sub_items)
                             .references(:sub_items)
                             .order("menu_items.menu_order", "sub_items_menu_items.menu_order")
        render json: menu_items.as_json(include: { sub_items: { only: %i[id label icon options menu_order
                                                                         link] } })
      end

      def show
        # Fetch all top-level items (where `parent_id` is nil)
        menu_item = MenuItem.where(id: params[:id])
                            .includes(:sub_items)
                            .references(:sub_items)
                            .order("sub_items_menu_items.menu_order")
        render json: menu_item.as_json(include: { sub_items: { only: %i[id label icon options menu_order
                                                                        link] } })
      end
    end
  end
end
