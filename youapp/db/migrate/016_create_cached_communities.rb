class CreateCachedCommunities < ActiveRecord::Migration
  def self.up
    create_table :cached_communities do |t|
      t.column :name, :string
      t.column :community_id, :integer
      t.column :preferred_parent_id, :integer
      t.column :active, :boolean, :default => true
    end
  end

  def self.down
    drop_table :cached_communities
  end
end
