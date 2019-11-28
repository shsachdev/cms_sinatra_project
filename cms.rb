require "sinatra"
require "sinatra/reloader"
require "erubis"

root = File.expand_path("..", __FILE__)

set :public_folder, 'data'

get '/' do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end
