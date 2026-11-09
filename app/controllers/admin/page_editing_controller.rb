# app/controllers/admin/page_editing_controller.rb

# Editing a page from the public site. "Edit Page" starts an editing session:
# the page is shown with its drafts and right-clicking it opens the editors.
# "Save Changes" publishes, and "Cancel" discards, the drafts made since the
# session started; drafts made before it, or elsewhere earlier, are left as
# they are.
class Admin::PageEditingController < ApplicationController
  before_action :authenticate_user!
  before_action :require_administrator
  before_action :set_page

  SESSION_KEY = :page_editing

  def self.session_changes(session_value)
    started_at = session_value && Time.zone.parse(session_value["started_at"].to_s)
    return [] unless started_at

    Publishing.pending.select { |draft| draft.updated_at && draft.updated_at >= started_at }
  end

  # Starts editing, or carries on with this page's session if one is open.
  def start
    session[SESSION_KEY] = { "page_id" => @page.id, "started_at" => Time.current.iso8601(6) } unless editing_session
    redirect_to page_path(@page.name, preview: "draft", editing: 1), status: :see_other
  end

  def save
    changes = self.class.session_changes(editing_session)
    if changes.empty?
      finish(notice: "No changes to publish.")
      return
    end

    contents = PublishingReview.groups(changes).map(&:summary).join(", ")
    Publishing.deploy!(actor: current_user, summary: "Edited from the #{@page.title.presence || @page.name} page",
                       only: changes.map { |draft| [ draft.class.name, draft.id ] }, contents: contents)
    finish(notice: "Published: #{contents}.".truncate(400))
  rescue Publishing::Conflict, ActiveRecord::ActiveRecordError => error
    message = error.is_a?(Publishing::Conflict) ? error.message : "a database error prevented it; your drafts are still there"
    redirect_to page_path(@page.name, preview: "draft", editing: 1), status: :see_other,
                alert: "Nothing was published: #{message.truncate(240)}"
  end

  def cancel
    changes = self.class.session_changes(editing_session)
    Publishing.discard!(only: changes.map { |draft| [ draft.class.name, draft.id ] }) if changes.any?
    finish(notice: changes.any? ? "Discarded #{changes.size == 1 ? '1 change' : "#{changes.size} changes"}. The page is as it was." : "Nothing to discard.")
  end

  private

  def editing_session
    value = session[SESSION_KEY]
    value if value.is_a?(Hash) && value["page_id"].to_i == @page.id
  end

  def finish(notice:)
    session.delete(SESSION_KEY)
    redirect_to page_path(@page.name), status: :see_other, notice: notice
  end

  def set_page
    @page = Page.find(params[:page_id])
  end

  def require_administrator
    head :forbidden unless @application_user&.admin?
  end
end
