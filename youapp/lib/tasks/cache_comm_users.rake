desc "Cache the user count in each community"
namespace :cache do
  task :comm_user_count => :environment do
    CacheCommCount.new
    puts "Done"
  end
end

