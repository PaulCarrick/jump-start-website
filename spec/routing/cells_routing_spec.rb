require "rails_helper"

RSpec.describe "Cell routes", type: :routing do
  it "routes the public listing" do
    expect(get: "/cells").to route_to("cells#index")
  end

  it "routes cell editing through admin" do
    expect(get: "/admin/cells/new").to route_to("admin/cells#new")
    expect(get: "/admin/cells/1").to route_to("admin/cells#show", id: "1")
    expect(get: "/admin/cells/1/edit").to route_to("admin/cells#edit", id: "1")
    expect(post: "/admin/cells").to route_to("admin/cells#create")
    expect(patch: "/admin/cells/1").to route_to("admin/cells#update", id: "1")
    expect(put: "/admin/cells/1").to route_to("admin/cells#update", id: "1")
    expect(delete: "/admin/cells/1").to route_to("admin/cells#destroy", id: "1")
  end

  it "does not expose public cell writes" do
    expect(post: "/cells").not_to be_routable
    expect(patch: "/cells/1").not_to be_routable
    expect(delete: "/cells/1").not_to be_routable
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
