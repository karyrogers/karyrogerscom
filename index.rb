require 'sinatra'
require 'instagram'

#set :bind, '0.0.0.0'

Instagram.configure do |config|
  config.client_id = "XXXX"
  config.client_secret = "XXXX"
end

get '/' do
  results = Instagram.user_recent_media(XXXX)
  @ig_feed = Hash.new do |hash, key|
    hash[key] = {}
  end
  for post in results
    if post.type != 'image'
      next
    end
    if post.tags.include? 'karyrogerscom'
      src = post.images.standard_resolution.url
      @ig_feed[src]["comments"] = post.comments['count']
      @ig_feed[src]["likes"] = post.likes['count']
      @ig_feed[src]["caption"] = post.caption.text
      @ig_feed[src]["link"] = post.link
    end
  end
  erb :index
end
