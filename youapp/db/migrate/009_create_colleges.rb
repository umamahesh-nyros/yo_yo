class CreateColleges < ActiveRecord::Migration
  def self.up
    create_table :colleges do |t|
      t.column :name, :string
      t.column :active, :boolean, :default => false
    end
  end

  def self.down
    drop_table :colleges
  end
end
