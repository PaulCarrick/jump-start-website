module Api
  module V1
    class PostCommentsController < ApplicationController
      include Pagy::Backend # Include Pagy for pagination

      before_action :set_post_comment, only: %i[show update destroy]

      def index
        @pagy, @post_comments = pagy(PostComment.all, items: params[:items] || 10)

        render json: {
          meta: pagy_metadata(@pagy),
          post_comments: @post_comments
        }

        # Add pagination details to headers
        pagy_headers_merge(@pagy)
      end

      def show
        return unless @post_comment.present?

        render json: @post_comment
      end

      def create
        begin
          post_comment = PostComment.new(post_comment_params)

          post_comment.save!

          render json: post_comment, status: :created
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      def update
        return unless @post_comment.present?

        begin
          @post_comment.update!(post_comment_params)

          render json: { error: "" }, status: :ok
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      def destroy
        return unless @post_comment.present?

        begin
          @post_comment.destroy!

          render json: { error: "" }, status: :ok
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      private

      def set_post_comment
        @post_comment = nil

        return unless params[:id].present?

        begin
          @post_comment = PostComment.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Post comment: #{params[:id]} not found" }, status: :not_found
        end
      end

      def post_comment_params
        params.require(:post_comment).permit(:blog_post_id, :title, :author, :posted, :content)
      end
    end
  end
end
