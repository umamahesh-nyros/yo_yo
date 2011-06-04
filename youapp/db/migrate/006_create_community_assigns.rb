class CreateCommunityAssigns < ActiveRecord::Migration
  def self.up
    create_table :community_assigns do |t|
      t.column :user_id, :integer
      t.column :community_id, :integer
      t.column :active, :boolean, :default => true
    end
    if TESTMODE
      CommunityAssign.transaction do 
        [{:community_id => 3, :user_id => 1, :active => true},
        {:community_id => 7, :user_id => 1, :active => true},
        {:community_id => 3, :user_id => 2, :active => true},
        {:community_id => 7, :user_id => 3, :active => true},
        {:community_id => 9, :user_id => 1, :active => true},
        {:community_id => 9, :user_id => 3, :active => true},
        {:community_id => 11, :user_id => 1, :active => true}].each do |rec|
          CommunityAssign.create(rec)
        end
      end
    end
  end

  def self.down
    drop_table :community_assigns
  end
end
