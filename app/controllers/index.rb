# get '/' do
#   erb :index
# end

enable :sessions

CALLBACK_URL = "http://localhost:9393/oauth/callback"



get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/feed"
end

get "/feed" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user

  html = "<h1>#{user.username}'s recent photos</h1>"
  for media_item in client.user_recent_media
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/devbootcamp" do
  html = "<h1>DBC Chicago</h1>"
  html << append_images(Instagram.location_recent_media(Instagram.location_search("511d1294e4b09e46f103ba30")[0].id))

  html << "<h1>DBC SF</h1>"
  html << append_images(Instagram.location_recent_media(Instagram.location_search("4fa4422fe4b0dd0f11bfcff8")[0].id))

  html
end


get "/user" do
erb :index
end

post "/user" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  @user = client.user_search(params["username"])[0]

  html = "<h1>Images from #{@user.username}</h1>"
  html << append_images(client.user_recent_media(@user.id))
  html
end

def append_images(images)
  html = ""
  images.each do |media_item|
    html << "<a href='#{media_item.images.standard_resolution.url}'><img src='#{media_item.images.low_resolution.url}'></a>"
  end
  html
end
