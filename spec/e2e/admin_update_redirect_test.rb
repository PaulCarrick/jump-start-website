# Standalone test of the actual controller action; no Rails or database startup.
require 'minitest/autorun'
module Admin; end
module Pagy
  module Backend; end
end
module Persistence; end
class ApplicationController; end
require_relative '../../app/controllers/admin/abstract_admin_controller'

class AdminUpdateRedirectTest < Minitest::Test
  class Controller < Admin::AbstractAdminController
    attr_reader :redirect, :handled_error, :updated_params
    def initialize
      @application_user = Struct.new(:admin?).new(true)
    end
    def controller_name
      # The action needs only these two display-name transformations.
      name = 'image_files'
      def name.singularize; self; end
      def name.titleize; self; end
      name
    end
    def flash; @flash ||= {}; end
    def set_item; end
    def get_record; self; end
    def get_params; { group: 'Other Gallery', slide_order: 2 }; end
    def update(params = nil)
      return super() unless params
      @updated_params = params
      true
    end
    def redirect_to(**options); @redirect = options; end
    def handle_error(action, error); @handled_error = [action, error]; end
  end

  def test_successful_patch_redirects_to_list_with_303
    controller = Controller.new
    controller.update
    assert_nil controller.handled_error
    assert_equal({ group: 'Other Gallery', slide_order: 2 }, controller.updated_params)
    assert_equal({ action: :index, turbo: false, status: :see_other }, controller.redirect)
  end
end
