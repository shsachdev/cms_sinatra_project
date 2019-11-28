require "sinatra"
require "sinatra/reloader"
require "erubis"

root = File.expand_path("..", __FILE__)

# set :public_folder, 'data' # for some reason this doesn't render format correctly

get '/' do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do
  file_path = root + "/data/" + params[:filename]

  headers["Content-Type"] = "text/plain"
  File.read(file_path)
end
