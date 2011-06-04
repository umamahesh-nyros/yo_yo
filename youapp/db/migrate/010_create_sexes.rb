class CreateSexes < ActiveRecord::Migration
  def self.up
    create_table :sexes do |t|
      t.column :name, :string
    end
    %w(male female).each do |type|
      Sex.create(:name => type)
    end
  end

  def self.down
    drop_table :sexes
  end
end
