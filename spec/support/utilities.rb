module Utilities
  def select_option_from_dropdown(dropdown_selector, option_text)
    find(dropdown_selector).click
    find(:css, "[id]", id: /react-select-.*-option-.*/, text: option_text).click
  end

  def get_react_select_value(id)
    container = find("#{id}")

    container.find("div[class$='-singleValue']").text if container.present?
  end

  def shutdown
    Capybara.current_session.driver.quit if Capybara.current_session&.driver&.browser
    exit
  end
end
