class CreateCommunities < ActiveRecord::Migration
  def self.up
    create_table :communities do |t|
      t.column :name, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :expires_at, :datetime
      t.column :hashed_name, :string
      t.column :regex_email, :string
      t.column :community_type_id, :integer
      t.column :parent, :integer
      t.column :active, :boolean, :default => true
    end
    if TESTMODE
      Community.transaction do
        [{:name => 'Animals', :active => true},
        {:name => 'Mammals', :parent => 1, :active => true},
        {:name => 'Rodents', :parent => 2, :active => true},
        {:name => 'Kangaroo', :parent => 3, :active => true},
        {:name => 'Mouse', :parent => 3, :active => true},
        {:name => 'Rat', :parent => 3, :active => true},
        {:name => 'Lagamorphs', :parent => 2, :active => true},
        {:name => 'Movies', :active => true, :regex_email => 'testman.net'},
        {:name => 'Comedies', :parent => 8, :active => true },
        {:name => 'Foreign', :parent => 8, :active => true},
        {:name => 'French', :parent => 10, :active => true},
        {:name => 'Sports', :active => true}, 
        {:name => 'Bouldering', :parent => 12, :active => true, :created_at => Time.at(333333333)}].each do |rec|
          Community.create(rec)
        end
      end
    end
  end

  def self.down
    drop_table :communities
  end
end
