require 'sinatra'
require 'instagram'
require 'net/http'

set :bind, '0.0.0.0'

Instagram.configure do |config|
  config.client_id = "40bb9dee3fe547ed90c621b468db18c4"
  config.client_secret = "df5f10e4c6a447039d04f0e5aaf081bb"
end

get '/' do
  results = Instagram.user_recent_media(545590)
  @ig_feed = Hash.new do |hash, key|
    hash[key] = {}
  end
  for post in results
    if post.type != 'image'
      next
    end
    src = post.images.standard_resolution.url
    img_file = "public/images/igcache/" + src.split('/').last
    @ig_feed[img_file]["comments"] = post.comments['count']
    @ig_feed[img_file]["likes"] = post.likes['count']
    @ig_feed[img_file]["caption"] = post.caption.text
    if !File.exists?(img_file)
      puts "Writing #{img_file}" 
      uri = URI(src)
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new uri

        http.request request do |response|
          open img_file, 'w' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
    end
  end
  #puts "hash: #{@ig_feed}"
  erb :index
end
