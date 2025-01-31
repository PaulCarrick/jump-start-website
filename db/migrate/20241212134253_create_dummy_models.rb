class CreateDummyModels < ActiveRecord::Migration[6.1]
  def change
    if Rails.env === 'test'
      create_table :dummy_models do |t|
        t.text :description
        t.text :content
        t.string :checksum

        t.timestamps
      end
    end
  end
end
