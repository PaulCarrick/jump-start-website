class Contact < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :message, null: false
      t.string :phone
      t.string :submit_information

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :contacts,
              [ :name, :email, :phone, :message ],
              name: "index_contacts_on_name_email_phone_and_message"
  end
end
