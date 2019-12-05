require "sinatra"
require "sinatra/reloader"
require "erubis"
require "pry"
require "redcarpet"

root = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :session_secret, 'set'
end

helpers do
  def render_markdown(txt)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(File.read(txt))
  end
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end


get '/' do
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end
  erb :index
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
    else
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
