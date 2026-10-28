require "rails_helper"

RSpec.describe "Cell routes", type: :routing do
  it "routes the public listing" do
    expect(get: "/cells").to route_to("cells#index")
  end

  { new: [ :get, "/admin/cells/new" ],
    show: [ :get, "/admin/cells/1" ],
    edit: [ :get, "/admin/cells/1/edit" ],
    create: [ :post, "/admin/cells" ],
    update: [ :patch, "/admin/cells/1" ],
    destroy: [ :delete, "/admin/cells/1" ] }.each do |action, (verb, path)|
    it "routes admin #{action}" do
      target = { controller: "admin/cells", action: action.to_s }
      target[:id] = "1" if path.include?("/1")
      expect(verb => path).to route_to(target)
    end
  end

  it "routes PUT updates to the admin controller" do
    expect(put: "/admin/cells/1").to route_to("admin/cells#update", id: "1")
  end

  it "does not expose public write routes" do
    expect(post: "/cells").not_to be_routable
    expect(patch: "/cells/1").not_to be_routable
    expect(delete: "/cells/1").not_to be_routable
  end
end
