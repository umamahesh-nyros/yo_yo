class CreateCachedPopulaceCommunities < ActiveRecord::Migration
  def self.up
    create_table :cached_populace_communities do |t|
      t.column :community_id, :integer
      t.column :population, :integer
      t.column :active, :boolean, :default => true
    end
  end

  def self.down
    drop_table :cached_populace_communities
  end
end
