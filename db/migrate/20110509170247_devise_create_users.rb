class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      #t.database_authenticatable :null => false
      t.string   "email",                                 :default => "", :null => false, :unique => true
      t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable

    end

    #adapter = User.connection.instance_variable_get("@config")[:adapter]
    #if adapter != "sqlite3"
      add_index :users, :email #,                :unique => true
    #end

    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    add_index :users, :authentication_token, :unique => true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
