require "selenium-webdriver"

# Bootstrap enables smooth scrolling when reduced motion is not requested.
# Chrome can then click/type while WebDriver's automatic scroll is still moving.
# Request reduced motion so native form interactions target settled coordinates.
{ selenium_chrome: false, selenium_chrome_headless: true }.each do |name, headless|
  Capybara.register_driver name do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless=new") if headless
    options.add_argument("--disable-site-isolation-trials")
    options.add_argument("--force-prefers-reduced-motion")
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
end
