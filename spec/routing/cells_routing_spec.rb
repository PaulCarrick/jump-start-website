require "rails_helper"

RSpec.describe CellsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cells").to route_to("cells#index")
    end

    # The public CellsController only implements #index (see config/routes.rb:
    # `resources :cells, only: [:index]`). Full CRUD (new/show/edit/create/
    # update/destroy) is only exposed under /admin/cells and the API - there is
    # no public cells CRUD, so those routes intentionally don't exist.
  end
end
