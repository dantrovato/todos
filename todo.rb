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

# View list of lists
get "/lists" do
  # binding.pry
  @lists = session[:lists]

  erb :lists
end

# Render the new list form
get "/lists/new" do
  erb :new_list
end

# Create a new list
post "/lists" do
  list_name = params[:list_name].strip.squeeze(' ')
  if (1..50).cover?(list_name.size)
    session[:lists] << { name: params[:list_name], todos: [] }
    session[:success] = "The list has been created."
    redirect "/lists"
  else
    session[:error] = "The list name must be between 1 and 50 characters."
    erb :new_list
  end

end
