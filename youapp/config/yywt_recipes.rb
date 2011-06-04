Capistrano.configuration(:must_exist).load do
  task :my_funky_task, :roles => :app do
  end

  task :another_funky_task do
  end
end
