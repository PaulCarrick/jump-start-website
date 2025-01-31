# frozen_string_literal: true

# app/controllers/api/footer_items_controller.rb
module Api
  module V1
    class FooterItemsController < ApplicationController
      def index
        # Fetch all top-level items (where `parent_id` is nil)
        footer_items = FooterItem.where(parent_id: nil)
                                 .order(:footer_order)
                                 .includes(:sub_items)
                                 .references(:sub_items)
                                 .order("footer_items.footer_order", "sub_items_footer_items.footer_order")
        render json: footer_items.as_json(include: { sub_items: { only: %i[id label icon options footer_order
                                                                         link] } })
      end

      def show
        # Fetch all top-level items (where `parent_id` is nil)
        footer_item = FooterItem.where(id: params[:id])
                                .includes(:sub_items)
                                .references(:sub_items)
                                .order("sub_items_footer_items.footer_order")
        render json: footer_item.as_json(include: { sub_items: { only: %i[id label icon options footer_order
                                                                        link] } })
      end
    end
  end
end
