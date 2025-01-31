module EditorHelper
  def get_quill_editor(id)
    begin
      container = find("div[data-react-props*=\"#{id}\"]")

      editor = container.find('div[contenteditable="true"]')
    rescue
      begin
        container = find("#{id}")

        # Find the contenteditable element within the container
        editor = container.find('div[contenteditable="true"]')
      rescue
        editor = find(".ql-editor")
      end
    end

    editor
  end
  def fill_in_quill_editor(id, with:)
    editor = get_quill_editor(id)

    # Set the desired text
    editor.set(with) if editor.present?
  end

  def check_quill_editor_text(id, text:)
    editor = get_quill_editor(id)

    # Check if the editor contains the specified text
    expect(editor).to have_content(text)
  end

  def fill_in_trix_editor(id, with:)
    trix_editor = find("trix-editor##{id}") # This finds the `trix-editor` by its `id`
    page.execute_script("arguments[0].editor.insertString('#{with}')", trix_editor.native)
  end
end
