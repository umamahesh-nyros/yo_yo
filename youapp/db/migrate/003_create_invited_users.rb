class CreateInvitedUsers < ActiveRecord::Migration
  def self.up
    create_table :invited_users do |t|
      t.column :invite_id, :integer
      t.column :user_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :active, :boolean, :default => true
      t.column :confirmed, :boolean, :default => false
    end
  end

  def self.down
    drop_table :invited_users
  end
end
