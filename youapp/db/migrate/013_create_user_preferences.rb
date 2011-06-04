class CreateUserPreferences < ActiveRecord::Migration
  def self.up
    create_table :user_preferences do |t|
      t.column :user_id, :integer
      t.column :invite_in, :boolean, :default => true
      t.column :times_up, :boolean, :default => true
      t.column :afirm_out, :boolean, :default => true
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :user_preferences
  end
end
