class CreateCommunityTypes < ActiveRecord::Migration
  def self.up
    create_table :community_types do |t|
      t.column :name, :string
    end
    types = ['Student Group', 'Dorm', 'Academic Affiliation', 'Course']
    CommunityType.transaction do |typ|
      types.each{|t| CommunityType.create(:name => t)}
    end
  end

  def self.down
    drop_table :community_types
  end
end
