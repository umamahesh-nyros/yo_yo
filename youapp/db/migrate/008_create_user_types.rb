class CreateUserTypes < ActiveRecord::Migration
  def self.up
    create_table :user_types do |t|
      t.column :name, :string
    end
    %w(common admin).each do |type|
      UserType.create(:name => type)
    end
  end

  def self.down
    drop_table :user_types
  end
end
