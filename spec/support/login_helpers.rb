module LoginHelper
  def create_admin_user
    user = create(:user,
                  name:   "Test User",
                  access: "super")
    user = nil unless controller.signin_user(user)

    user
  end

  def create_regular_user
    user = create(:user,
                  name:   "Test User",
                  access: "regular")
    user = nil unless controller.signin_user(user)

    user
  end
end
