#require 'cache_yotag'
class CreateYotags < ActiveRecord::Migration
  def self.up
    create_table :yotags do |t|
      t.column :tag, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :active, :boolean, :default => true
    end
    #NOTE insert from script
    yotag = CacheYotag.new
    Yotag.transaction do
      yotag.set.each do |tag|
        Yotag.create(:tag => tag)
      end
    end
  end

  def self.down
    drop_table :yotags
  end
end
