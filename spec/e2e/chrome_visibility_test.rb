# Standalone regression check: no Rails, browser or database is started.
require 'minitest/autorun'
module Selenium
  module WebDriver
    module Error
      class UnknownError < StandardError; end
      class StaleElementReferenceError < StandardError; end
    end
  end
end
require_relative 'chrome_visibility'

class ChromeVisibilityTest < Minitest::Test
  class Node
    attr_accessor :error
    def visible?
      raise error if error
      true
    end
    def visible_text
      raise error if error
      'Text'
    end
    alias all_text visible_text
    def click(keys = [], **options)
      raise error if error
      [keys, options]
    end
    prepend AdminE2EChromeVisibility
  end

  def test_visible_node_is_unchanged
    assert Node.new.visible?
  end

  def test_detached_document_node_becomes_retryable_stale_node
    node = Node.new
    node.error = Selenium::WebDriver::Error::UnknownError.new('unhandled inspector error: Node with given id does not belong to the document')
    error = assert_raises(Selenium::WebDriver::Error::StaleElementReferenceError) { node.visible? }
    assert_equal node.error.message, error.message
  end

  def test_text_reads_translate_only_the_detached_node_error
    %i[visible_text all_text].each do |method|
      node = Node.new
      assert_equal 'Text', node.public_send(method)
      node.error = Selenium::WebDriver::Error::UnknownError.new('Node with given id does not belong to the document')
      assert_raises(Selenium::WebDriver::Error::StaleElementReferenceError) { node.public_send(method) }
      node.error = Selenium::WebDriver::Error::UnknownError.new('browser disconnected')
      error = assert_raises(Selenium::WebDriver::Error::UnknownError) { node.public_send(method) }
      assert_same node.error, error
    end
  end

  def test_click_preserves_arguments_and_translates_only_detached_nodes
    node = Node.new
    assert_equal [[:shift], { x: 10 }], node.click([:shift], x: 10)
    node.error = Selenium::WebDriver::Error::UnknownError.new('Node with given id does not belong to the document')
    assert_raises(Selenium::WebDriver::Error::StaleElementReferenceError) { node.click }
    node.error = Selenium::WebDriver::Error::UnknownError.new('browser disconnected')
    error = assert_raises(Selenium::WebDriver::Error::UnknownError) { node.click }
    assert_same node.error, error
  end

  def test_other_unknown_errors_are_not_hidden
    node = Node.new
    node.error = Selenium::WebDriver::Error::UnknownError.new('browser disconnected')
    error = assert_raises(Selenium::WebDriver::Error::UnknownError) { node.visible? }
    assert_same node.error, error
  end
end
