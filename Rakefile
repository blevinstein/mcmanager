require './config.rb'

namespace 'db' do

  desc 'Add a user to the database.'
  task :add_user, :username, :password do |t, args|
    print args
    User.create args
  end

  desc 'List all users.'
  task :print_users do
    User.all.each do |user|
      puts "- #{user.username}"
    end
  end

  desc 'Migrate the database; destroys existing data.'
  task :migrate do
    DataMapper.auto_upgrade!
    #DataMapper.auto_migrate!
  end

end
