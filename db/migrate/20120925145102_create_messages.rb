class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :subject
      t.text :body
      t.integer :sender_id
      t.integer :recipient_id
      t.datetime :read_at
      t.datetime :archived_at

      t.timestamps
    end
  end
end
