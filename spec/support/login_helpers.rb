module LoginHelper
  def create_admin_user
    user = create(:user,
                  name:   "Test User",
                  access: "super")
    sign_in(user)

    user
  end

  def create_regular_user
    user = create(:user,
                  name:   "Test User",
                  access: "regular")
    sign_in(user)

    user
  end
end
