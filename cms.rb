require "sinatra"
require "sinatra/reloader"
require "erubis"
require "pry"
require "redcarpet"

root = File.expand_path("..", __FILE__)



# set :public_folder, 'data' # for some reason this doesn't render format correctly

configure do
  enable :sessions
  set :session_secret, 'set'
end

helpers do
  def render_markdown(txt)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(txt)
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

  headers["Content-Type"] = "text/plain"

  if @files.include?(params[:filename])
    if File.extname(params[:filename]) == ".md"
       render_markdown(file_path)
    else
      File.read(file_path)
    end
  else
    session[:error] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end
