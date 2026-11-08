module Api
  module V1
    class PostCommentsController < ApplicationController
      include Pagy::Backend # Include Pagy for pagination

      before_action :set_post_comment, only: %i[show update destroy]

      def index
        @pagy, @post_comments = pagy(PostComment.enabled, items: params[:items] || 10)

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

          # The writer is always the signed-in user, whatever the request says.
          # Administrators may set the author and date; everyone else gets their
          # own name and the current time.
          post_comment.user_id = current_user.id
          unless current_user.admin? && post_comment.author.present?
            post_comment.author = current_user.name.presence || "Visitor"
          end
          post_comment.posted = Time.current unless current_user.admin? && post_comment.posted.present?

          post_comment.save!

          render json: post_comment, status: :created
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      def update
        return unless @post_comment.present?
        return forbid_change unless @post_comment.changeable_by?(current_user)

        begin
          @post_comment.update!(post_comment_params)

          render json: { error: "" }, status: :ok
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      def destroy
        return unless @post_comment.present?
        return forbid_change unless @post_comment.changeable_by?(current_user)

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
          @post_comment = (action_name == "show" ? PostComment.enabled : PostComment.all).find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Post comment: #{params[:id]} not found" }, status: :not_found
        end
      end

      def forbid_change
        render json: { errors: [ "You can change or delete only your own comments." ] }, status: :forbidden
      end

      # Administrators may set every field. Other users may set only the text of
      # their comment, and the post it belongs to when they first write it.
      def post_comment_params
        if current_user.admin?
          params.require(:post_comment).permit(:enabled, :blog_post_id, :title, :author, :posted, :content)
        elsif action_name == "create"
          params.require(:post_comment).permit(:blog_post_id, :title, :content)
        else
          params.require(:post_comment).permit(:title, :content)
        end
      end
    end
  end
end
