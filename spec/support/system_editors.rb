module SystemEditors
  def replace_react(selector, value)
    input = find(selector)
    input.click
    input.send_keys([:command, 'a'], :backspace)
    input.send_keys(value.to_s, :tab)
    if input[:role] == 'combobox'
      expect(page).to have_content(value.to_s)
    elsif input[:type] == 'number'
      expect(input.value.to_f).to eq(Float(value))
    else
      expect(input.value).to eq(value.to_s)
    end
  end

  def enter_column_text(text)
    editor = find('.ql-editor[contenteditable=true]', match: :first)
    editor.click
    editor.send_keys([:command, 'a'], text, :tab)
    expect(editor).to have_text(text)
  end
end

RSpec.configure { |config| config.include SystemEditors, type: :system }
