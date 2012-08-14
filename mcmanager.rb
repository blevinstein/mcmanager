#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/contrib'
require 'haml'

require 'server.rb'

$server = MinecraftServer.new('server')

enable :sessions
set :haml, :layout => :template

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
  haml :index, :locals => {:server => $server}
end

post '/server' do
  require_auth
  if params[:start] and params[:version]
    $server.start params[:version]
  elsif params[:stop]
    $server.stop
  end
  redirect '/'
end

post '/backup' do
  require_auth
  if params[:backup]
    $server.backup
  elsif params[:restore] and params[:file]
    $server.restore params[:file]
  elsif params[:delete] and params[:file]
    $server.delete_backup params[:file]
  end
  redirect '/'
end

post '/op' do
  require_auth
  if params[:op] and params[:player]
    $server.op params[:player]
  elsif params[:deop] and params[:player]
    $server.deop params[:player]
  end
  redirect '/'
end
