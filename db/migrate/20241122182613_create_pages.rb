class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.string :name, null: false
      t.string :section, null: false
      t.string :title
      t.string :access

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end
  end
end
