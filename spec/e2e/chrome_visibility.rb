# Chrome sometimes reports a detached node as UnknownError during a node read or click.
# Translate only that error so Capybara's bounded stale-node retry can reacquire
# the element. All other browser errors retain their original failure.
module AdminE2EChromeVisibility
  %i[visible? visible_text all_text click].each do |method_name|
    define_method(method_name) do |*args, **options|
      super(*args, **options)
    rescue Selenium::WebDriver::Error::UnknownError => error
      raise unless error.message.include?('Node with given id does not belong to the document')

      raise Selenium::WebDriver::Error::StaleElementReferenceError, error.message
    end
  end
end
