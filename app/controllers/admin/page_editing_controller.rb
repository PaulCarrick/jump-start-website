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

  # Takes the page's visible sections in their new order (dragged on the
  # page) and saves it as drafts. Sections the page does not show (hidden
  # ones) keep their places; the visible ones are reordered among the rest.
  def move_sections
    ids = Array(params[:sections]).map(&:to_i)
    sections = @page.ordered_sections.to_a
    moved = ids.map { |id| sections.find { |section| section.id == id } }
    if ids.empty? || ids.uniq.size != ids.size || moved.any?(&:nil?)
      render json: { error: "The page has changed since it was opened. Reload the page." }, status: :unprocessable_content
      return
    end

    slots = sections.each_index.select { |index| ids.include?(sections[index].id) }
    ordered = sections.dup
    slots.each_with_index { |slot, position| ordered[slot] = moved[position] }
    # Reuse the page's own order numbers when they are distinct, so a move
    # changes only the sections that moved; otherwise number them 10, 20, ...
    numbers = sections.map(&:section_order)
    numbers = (1..sections.size).map { |index| index * 10 } if numbers.any?(&:nil?) || numbers.uniq.size != numbers.size
    numbers = numbers.sort
    changed = 0
    Section.transaction do
      ordered.each_with_index do |section, index|
        order = numbers[index]
        next if section.section_order == order

        section.update!(section_order: order)
        changed += 1
      end
    end
    render json: { changed: changed }
  rescue ActiveRecord::StaleObjectError
    render json: { error: "Someone else changed this page. Reload the page and try again." }, status: :conflict
  rescue ActiveRecord::RecordInvalid => error
    render json: { error: error.record.errors.full_messages.to_sentence }, status: :unprocessable_content
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
