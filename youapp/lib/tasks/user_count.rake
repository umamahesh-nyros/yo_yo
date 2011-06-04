desc "Fetch the users that are active"
namespace :user do
  task :fetch => :environment do
    rec = User.find(:all, :conditions => ['active = ? and user_type_id = ?',true,1])
    rec.each{|u| puts "%s: %s" % [u.name,u.email]}
    puts "Total yywt users: %s" % rec.length
  end
end
