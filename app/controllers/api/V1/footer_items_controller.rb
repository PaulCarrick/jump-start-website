# frozen_string_literal: true

# app/controllers/api/v1/footer_items_controller.rb

module Api
  module V1
    # noinspection RailsParamDefResolve
    class FooterItemsController < ApplicationController
      # noinspection RailsParamDefResolve
      def index
        if params[:all]
          footer_items = FooterItem.all.order(:footer_order)
          render json: footer_items
        else
          # Fetch all top-level items (where `parent_id` is nil), with sub-items
          footer_items = FooterItem.where(parent_id: nil)
                                   .includes(:sub_items)
                                   .order("footer_items.footer_order", "sub_items_footer_items.footer_order")

          render json: footer_items.as_json(include: {
            sub_items: { only: %i[id label icon options footer_order link] }
          })
        end
      end

      def show
        if params[:single]
          footer_item = FooterItem.find_by(id: params[:id])
          render json: footer_item
        else
          footer_item = FooterItem.where(id: params[:id])
                                  .includes(:sub_items)
                                  .order("sub_items_footer_items.footer_order")

          render json: footer_item.as_json(include: {
            sub_items: { only: %i[id label icon options footer_order link] }
          })
        end
      end

      def get
        footer_item = FooterItem.find_by(id: params[:id])

        render json: footer_item
      end

      def create
        footer_item = FooterItem.new(get_params)

        if footer_item.save
          render json: footer_item, status: :created
        else
          render json: { errors: footer_item.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end

      def update
        footer_item = FooterItem.find_by(id: params[:id])

        if footer_item&.update(get_params)
          render json: footer_item, status: :ok
        else
          render json:   { errors: footer_item&.errors&.full_messages || [ "Footer item not found" ] },
                 status: :unprocessable_entity
        end
      end

      def destroy
        footer_item = FooterItem.find_by(id: params[:id])

        if footer_item&.destroy
          render json: { message: "Footer item deleted successfully" }
        else
          render json: { error: "Footer item not found or couldn't be deleted" }, status: :not_found
        end
      rescue => e
        render json: { error: "Footer item couldn't be deleted. Error: #{e.message}" }, status: :internal_server_error
      end

      private

      def get_params
        params.require(:footer_item).permit(
          :id,
          :label,
          :icon,
          :options,
          :link,
          :access,
          :footer_order,
          :parent_id
        )
      end
    end
  end
end
