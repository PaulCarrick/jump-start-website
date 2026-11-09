# What each publish contained, in plain words ("Paul's Family (3 changes),
# Header menu (1 change)"), shown in the publishing history.
class AddContentsToDeployments < ActiveRecord::Migration[8.0]
  def change
    add_column :deployments, :contents, :text
  end
end
