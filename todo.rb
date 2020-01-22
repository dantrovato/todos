require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "pry"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:lists] ||= []
end

get "/" do
  redirect "/lists"
end

get "/lists" do
  # binding.pry
  @lists = session[:lists]

  erb :lists
end

get "/lists/new" do
  erb :new_list
end

post "/lists" do
  session[:lists] << { name: params[:list_name], todos: [] }
  redirect "/lists"
end
