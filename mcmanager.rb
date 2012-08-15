require 'sinatra/base'
require 'sinatra/contrib'

require 'data_mapper'

require 'haml'

require './config.rb'
require './mcserver.rb'

class MCManager < Sinatra::Base

  set :environment, $environment
  enable :sessions
  set :haml, :layout => :template
  register Sinatra::Contrib

  set :mcserver, MCServer.new('mcserver')

  def require_auth
    redirect '/login' unless session[:user]
  end

  get '/login' do
    redirect '/' if session[:user]
    haml :login, :locals => {:flash => nil}
  end

  post '/login' do
    user = User.get(params[:username])
    if user && user.password?(params[:password])
      session[:user] = user.username
      haml :index, :locals => {:server => settings.mcserver}
    else
      haml :login, :locals => {:flash => 'Incorrect username or password.'}
    end
  end

  get '/logout' do
    session[:user] = nil
    redirect '/'
  end

  get '/' do
    require_auth
    haml :index, :locals => {:server => settings.mcserver}
  end

  post '/server' do
    require_auth
    if params[:start] and params[:version]
      settings.mcserver.start params[:version]
    elsif params[:stop]
      settings.mcserver.stop
    end
    haml :index, :locals => {:server => settings.mcserver}
  end

  post '/backup' do
    require_auth
    if params[:backup]
      settings.mcserver.backup
    elsif params[:restore] and params[:file]
      settings.mcserver.restore params[:file]
    elsif params[:delete] and params[:file]
      settings.mcserver.delete_backup params[:file]
    end
    haml :index, :locals => {:server => settings.mcserver}
  end

  post '/op' do
    require_auth
    if params[:op] and params[:player]
      settings.mcserver.op params[:player]
    elsif params[:deop] and params[:player]
      settings.mcserver.deop params[:player]
    end
    redirect '/'
  end

  run! if app_file == $0
end
