require "sinatra"
require "sinatra/reloader"
require "erubis"
require "pry"
require "fileutils"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'set'
end

helpers do
  def render_markdown(txt)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(File.read(txt))
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

# Homepage
get '/' do
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end
  erb :index
end

# Sign in Page
get "/users/signin" do
  erb :sign_in
end

post "/users/signin" do
  if params[:username] == "admin" && params[:password] == "secret"
    session[:username] = true
    session[:password] = true
    session[:message] = "Welcome"
    redirect "/"
  else
    session[:message] = "Error"
    redirect "/users/signin"
  end
end

post "/users/signout" do
  session[:username] == false
  session[:password] == false
  session[:message] = "You have been successfully signed out!"
  redirect "/"
end

get "/new" do
  erb :new_doc
end

# Create a new document
post "/new" do
  if params[:new_doc_name].to_s.size == 0
    status 422
    session[:message] = "A name is required"
    erb :new_doc
  else
    create_document(params[:new_doc_name])
    session[:message] = "#{params[:new_doc_name]} has been created."
    redirect "/"
  end
end

get "/:filename" do
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end

  file_path = File.join(data_path, params[:filename])

  if @files.include?(params[:filename])
    if File.extname(params[:filename]) == ".md"
       erb render_markdown(file_path)
    elsif File.extname(params[:filename]) == ".txt"
      headers["Content-Type"] = "text/plain"
      File.read(file_path)
    end
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end

get "/:filename/edit" do
  @file_path = File.join(data_path, params[:filename])
  erb :edit
end

# saves the changes made to the document that is being edited
post "/:filename" do
  file_path = File.join(data_path, params[:filename])
  File.write(file_path,params[:new_text])
  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end

# Delete a file
post "/:filename/destroy" do
  @file_path = File.join(data_path, params[:filename])
  File.delete(@file_path)
  session[:message] = "#{params[:filename]} has been deleted."
  redirect "/"
end
