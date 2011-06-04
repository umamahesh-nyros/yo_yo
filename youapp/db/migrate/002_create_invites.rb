class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.column :content, :text
      t.column :user_id, :integer
      t.column :maximum_users, :integer
      t.column :expiration_interval, :integer
      t.column :expires_at, :datetime
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :active, :boolean, :default => true
    end
  end

  def self.down
    drop_table :invites
  end
end
