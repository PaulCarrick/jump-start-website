# frozen_string_literal: true

# app/controllers/api/v1/menu_items_controller.rb

module Api
  module V1
    # noinspection RailsParamDefResolve
    class MenuItemsController < ApplicationController
      # noinspection RailsParamDefResolve
      def index
        if params[:all]
          menu_items = MenuItem.all.order(:menu_order)
          render json: menu_items
        else
          # Fetch all top-level items (where `parent_id` is nil), with sub-items
          menu_items = MenuItem.where(parent_id: nil)
                               .includes(:sub_items)
                               .order("menu_items.menu_order", "sub_items_menu_items.menu_order")

          render json: menu_items.as_json(include: {
            sub_items: { only: %i[id label icon options menu_order link] }
          })
        end
      end

      def show
        if params[:single]
          menu_item = MenuItem.find_by(id: params[:id])
          render json: menu_item
        else
          menu_item = MenuItem.where(id: params[:id])
                              .includes(:sub_items)
                              .order("sub_items_menu_items.menu_order")

          render json: menu_item.as_json(include: {
            sub_items: { only: %i[id label icon options menu_order link] }
          })
        end
      end

      def get
        menu_item = MenuItem.find_by(id: params[:id])
        render json: menu_item
      end

      def create
        menu_item = MenuItem.new(get_params)

        if menu_item.save
          render json: menu_item, status: :created
        else
          render json: { errors: menu_item.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end

      def update
        menu_item = MenuItem.find_by(id: params[:id])

        if menu_item&.update(get_params)
          render json: menu_item, status: :ok
        else
          render json: { errors: menu_item&.errors&.full_messages || [ "Menu item not found" ] },
                 status: :unprocessable_entity
        end
      end

      def destroy
        menu_item = MenuItem.find_by(id: params[:id])

        if menu_item&.destroy
          render json: { message: "Menu item deleted successfully" }
        else
          render json: { error: "Menu item not found or couldn't be deleted" }, status: :not_found
        end
      rescue => e
        render json: { error: "Menu item couldn't be deleted. Error: #{e.message}" }, status: :internal_server_error
      end

      private

      def get_params
        params.require(:menu_item).permit(
          :id,
          :menu_type,
          :label,
          :icon,
          :options,
          :link,
          :access,
          :menu_order,
          :parent_id
        )
      end
    end
  end
end
