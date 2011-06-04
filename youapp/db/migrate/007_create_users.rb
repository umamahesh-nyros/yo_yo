class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string
      t.column :yotag_id, :integer
      t.column :user_type_id, :integer
      t.column :phone, :string
      t.column :sex_id, :integer
      t.column :interest_1, :string
      t.column :interest_2, :string
      t.column :interest_3, :string
      t.column :college_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :hashed_password, :string
      t.column :salt, :string
      t.column :terms, :boolean, :default => false
      t.column :active, :boolean, :default => true
    end
    if TESTMODE
      User.transaction do 
        test0 = {:terms => true, :user_type_id => 1, :first_name => 'Test', :last_name => 'Testman', :email => 'test@testman.net', :password => 'thx1138', :password_confirmation => 'thx1138', :active => true}
        User.create(test0)
        test1 = {:terms => true, :user_type_id => 1, :first_name => 'Lorn', :last_name => 'Goodman', :email => 'LGoodman@test.net', :password => '1234567', :password_confirmation => '1234567', :active => true}
        User.create(test1)
        test2 = {:terms => true, :user_type_id => 1, :first_name => 'Jan', :last_name => 'Stein', :email => 'jan.stein@test.net', :password => '1234567', :password_confirmation => '1234567', :active => true}
      User.create(test2)
      end
    end
    admin = {:terms => true, :user_type_id => 2, :first_name => 'Admin', :email => 'admin@yoyouwantto.com', :password => 'yywt123', :password_confirmation => 'yywt123', :active => true}
    User.create(admin)
  end

  def self.down
    drop_table :users
  end
end
