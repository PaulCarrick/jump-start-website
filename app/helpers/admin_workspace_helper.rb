# Short names for the page workspace's outline (docs/admin-redesign-plan.md,
# stage 5).
module AdminWorkspaceHelper
  # What a column shows, in a few words: its text, else its image.
  def workspace_cell_label(cell)
    text = strip_tags(cell.content.to_s.gsub(/<\/?(p|div|h[1-6]|li|br)[^>]*>/i, " ")).squish
    return truncate(text, length: 40) if text.present?

    image = cell.image.to_s.sub(/\A\s*(ImageFile|ImageGroup|ImageSection):\s*/, "").delete('"').strip
    return "Image: #{truncate(image, length: 32)}" if image.present?

    cell.cell_name
  end
end
