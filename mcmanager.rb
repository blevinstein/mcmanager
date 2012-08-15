#!/usr/bin/ruby

require 'sinatra/base'
require 'sinatra/contrib'

require 'haml'

require 'server.rb'

class MCManager < Sinatra::Base

  enable :sessions
  set :haml, :layout => :template
  set :mcserver, MinecraftServer.new('server')
  register Sinatra::Contrib

  def require_auth
    redirect '/login' unless session[:auth]
  end

  get '/login' do
    redirect '/' if session[:auth]
    haml :login
  end

  post '/login' do
    if params[:password]=='insecurepassword'
      session[:auth] = true
    end
    redirect '/login'
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
    redirect '/'
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
    redirect '/'
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
