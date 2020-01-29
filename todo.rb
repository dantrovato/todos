require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'pry'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

# View list of lists
get '/lists' do
  # binding.pry
  @lists = session[:lists]

  erb :lists
end

# Render the new list form
get '/lists/new' do
  erb :new_list
end

# Return an error message if the name is invalid or nil if valid.
def error_for_list_name(name)
  if !(1..50).cover?(name.size)
    'The list name must be between 1 and 50 characters.'
  elsif session[:lists].any? { |list| list[:name] == name }
    'List name must be unique.'
  end
end

def error_for_todo(name)
  if !(1..50).cover?(name.size)
    'The todo must be between 1 and 50 characters.'
  end
end

# Create a new list
post '/lists' do
  list_name = params[:list_name].strip.squeeze(' ')

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list
  else
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = 'The list has been created.'
    redirect '/lists'
  end
end

# View a single todo list
get '/lists/:id' do
  @list_id = params[:id].to_i
  @list = session[:lists][@list_id]
  erb :list
end

# Edit an existing todo list
get '/lists/:id/edit' do
  id = params[:id].to_i
  @list = session[:lists][id]
  erb :edit_list
end

# Update an existing todo list
post '/lists/:id' do
  list_name = params[:list_name].strip.squeeze(' ')
  id = params[:id].to_i
  @list = session[:lists][id]

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :edit_list
  else
    # binding.pry
    @list[:name] = list_name
    session[:success] = 'The list has been edited.'
    redirect "/lists/#{id}"
  end
end

# Delete a todo list
post '/lists/:id/destroy' do
  id = params[:id].to_i
  session[:lists].delete_at(id)
  session[:success] = "The list has been deleted."
  redirect '/lists'
end

# Add a new todo to a list
post '/lists/:list_id/todos' do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  text = params[:todo].strip.squeeze(' ')
  error = error_for_todo(text)

  if error
    session[:error] = error
    erb :list
  else
    @list[:todos] << { name: text, completed: false }
    session[:success] = "The todo has been added."
    redirect "/lists/#{@list_id}"
  end
end

# Delete a todo from a list
post '/lists/:list_id/todos/:id/destroy' do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]

  todo_id = params[:id].to_i
  @list[:todos].delete_at(todo_id)
  session[:success] = "The todo has been removed."
  redirect "/lists/#{@list_id}"
end

# Complete a todo from a list
# post '/lists/:list_id/todos/:id/completed' do
#   @list_id = params[:list_id].to_i
#   @list = session[:lists][@list_id]
#   @todo_id = params[:id].to_i
#   if @list[:todos][@todo_id][:completed]
#     @list[:todos][@todo_id][:completed] = false
#     session[:success] = "The todo has been updated as incomplete."
#   else
#     @list[:todos][@todo_id][:completed] = true
#     session[:success] = "The todo has been completed."
#   end
#   redirect "/lists/#{@list_id}"
# end

# Update the status of todo
post '/lists/:list_id/todos/:id' do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]

  todo_id = params[:id].to_i
  is_completed = params[:completed] == 'true'
  @list[:todos][todo_id][:completed] = is_completed

  session[:success] = "The todo has been updated."
  redirect "/lists/#{@list_id}"
end
