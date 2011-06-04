class CreateUserAssigns < ActiveRecord::Migration
  def self.up
    create_table :user_assigns do |t|
      t.column :user_alpha_id, :integer
      t.column :user_beta_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :active, :boolean, :default => true
    end
    if TESTMODE
      UserAssign.transaction do 
        [{:user_alpha_id => 1, :user_beta_id => 2, :active => true}].each do |rec|
          UserAssign.create(rec)
        end
      end
    end
  end

  def self.down
    drop_table :user_assigns
  end
end
