class CreateCommunityTags < ActiveRecord::Migration
  def self.up
    create_table :community_tags do |t|
      t.column :tagname, :string
      t.column :community_id, :integer
      t.column :created_at, :datetime
      t.column :active, :boolean, :default => true
    end
  end

  def self.down
    drop_table :community_tags
  end
end
