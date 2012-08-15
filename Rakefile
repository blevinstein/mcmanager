require './config.rb'

namespace 'db' do

  desc 'Add a user to the database.'
  task :add_user do
    print 'Username > '
    username = STDIN.gets.strip
    print 'Password > '
    password = STDIN.gets.strip
    User.create :username => username, :password => password
  end

  desc 'List all users.'
  task :print_users do
    User.all.each do |user|
      print "- #{user.username}"
    end
  end

  desc 'Migrate the database.'
  task :migrate do
    DataMapper.auto_migrate!
  end

end
