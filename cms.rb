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

get '/' do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end

  file_path = root + "/data/" + params[:filename]

  if @files.include?(params[:filename])
    if File.extname(params[:filename]) == ".md"
       render_markdown(file_path)
    else
      headers["Content-Type"] = "text/plain"
      File.read(file_path)
    end
  else
    session[:update] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end

get "/:filename/edit" do
  @file_path = root + "/data/" + params[:filename]
  erb :edit
end

# saves the changes made to the document that is being edited
post "/:filename/edit/save" do
  file_path = root + "/data/" + params[:filename] # just the path to the current file
  file = File.open(file_path, "w")
  # file.map {|line| ""}
  file.puts(params[:new_text]) # update the file with this new text
  file.close
  session[:update] = "#{params[:filename]} has been updated."
  redirect "/"
end
