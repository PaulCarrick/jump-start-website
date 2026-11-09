# app/controllers/admin/menus_controller.rb

# One screen for the header menu and the footer: each shown as a tree that can
# be reordered by dragging, with a panel that edits the chosen item. Saving
# the order goes through the models, so every change is a draft until it is
# published, like any other admin edit.
class Admin::MenusController < ApplicationController
  include AdminReturnNavigation

  before_action :authenticate_user!

  # The public header and footer show two levels: top items and their items.
  MAX_DEPTH = 2
  KINDS = {
    "header" => { model: MenuItem, order: :menu_order, label: "Header menu" },
    "footer" => { model: FooterItem, order: :footer_order, label: "Footer" }
  }.freeze

  def initialize(...)
    super

    @title = "#{get_site_information.site_name} - Admin Dashboard: Menus"

    set_title(@title)
  end

  def index
    @kind = KINDS.key?(params[:kind]) ? params[:kind] : "header"
    @kind_settings = KINDS.fetch(@kind)
    @items = menu_items(@kind).to_a
    @children = @items.group_by(&:parent_id)
    item_ids = @items.map(&:id)
    # An item whose parent is missing (or not in this menu) is shown at the top.
    @roots = @items.select { |item| item.parent_id.nil? || !item_ids.include?(item.parent_id) }
    @selected = @items.find { |item| item.id == params[:selected].to_i } if params[:selected].present?
    @pages = Page.order(:title).to_a
  end

  # Takes the whole tree of one menu, as [{ id:, parent_id: }, ...] in the order
  # shown, and saves the order and nesting of the items that changed.
  def reorder
    return render(json: { error: "Only administrators can change the menus." }, status: :forbidden) unless @application_user&.admin?

    kind = KINDS.key?(params[:kind]) ? params[:kind] : nil
    return render(json: { error: "Unknown menu." }, status: :unprocessable_content) unless kind

    settings = KINDS.fetch(kind)
    entries = Array(params.require(:items)).map do |entry|
      { id: entry[:id].to_i, parent_id: entry[:parent_id].presence&.to_i }
    end
    items = menu_items(kind).index_by(&:id)
    error = check_tree(entries, items)
    return render(json: { error: error }, status: :unprocessable_content) if error

    changed = 0
    settings[:model].transaction do
      positions = Hash.new(0)
      entries.each do |entry|
        position = (positions[entry[:parent_id]] += 1)
        item = items.fetch(entry[:id])
        next if item.parent_id == entry[:parent_id] && item.public_send(settings[:order]) == position

        item.update!(settings[:order] => position, parent_id: entry[:parent_id])
        changed += 1
      end
    end

    render json: { changed: changed, pending: Publishing.pending.size }
  rescue ActiveRecord::StaleObjectError
    render json: { error: "Someone else changed this menu. Reload the page and try again." }, status: :conflict
  rescue ActiveRecord::RecordInvalid => error
    render json: { error: error.record.errors.full_messages.to_sentence }, status: :unprocessable_content
  end

  private

  def menu_items(kind)
    settings = KINDS.fetch(kind)
    scope = settings[:model].order(settings[:order], :id)
    # The admin sidebar is defined in code, so the "Admin" menu items are not
    # part of this screen (they stay in the Header menu list).
    kind == "header" ? scope.where(menu_type: [ "Main", nil, "" ]) : scope
  end

  # The new tree must hold exactly this menu's items, each once, with parents
  # from the same menu, no loops, and no deeper than the site can show.
  def check_tree(entries, items)
    ids = entries.map { |entry| entry[:id] }
    return "The menu has changed since the page was opened. Reload the page." unless ids.sort == items.keys.sort && ids.uniq.size == ids.size

    parents = entries.to_h { |entry| [ entry[:id], entry[:parent_id] ] }
    entries.each do |entry|
      next if entry[:parent_id].nil?
      return "An item can only sit inside an item of the same menu." unless parents.key?(entry[:parent_id])

      depth = 1
      parent = entry[:parent_id]
      while parent
        depth += 1
        return "An item cannot sit inside itself." if parent == entry[:id] || depth > entries.size
        parent = parents[parent]
      end
      return "Menus can only be #{MAX_DEPTH} levels deep." if depth > MAX_DEPTH
    end
    nil
  end
end
