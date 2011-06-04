class CreateEmailInvites < ActiveRecord::Migration
  def self.up
    create_table :email_invites do |t|
      t.column :email, :string
      t.column :user_id, :integer
      t.column :invite_id, :integer
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :active, :boolean, :default => true
    end
  end

  def self.down
    drop_table :email_invites
  end
end
