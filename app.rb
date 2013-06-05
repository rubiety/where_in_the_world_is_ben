require "sinatra" 
require "redis"
require "foursquare2"

EXPIRE_MINUTES = 120

set :root, Proc.new { File.dirname(__FILE__) }
set :views, Proc.new { File.join(File.dirname(__FILE__), "views") }
set :public_folder, "public"

APP_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "config/app.yml"))

LOCATION_KEY = "whereintheworldisben.location"
REDIS = Redis.new

class Location
  def self.foursquare
    @foursquare = Foursquare2::Client.new(:oauth_token => APP_CONFIG["foursquare_oauth_token"])
  end

  def self.last_checkin
    last_checkin = foursquare.user_checkins(:limit => 1, :sort => "newestfirst").items.first
  end

  def self.find
    location = last_checkin.venue.location
    [location.city, location.state, location.country].compact.join(", ")
  end

  def self.stored
    REDIS.get(LOCATION_KEY)
  end

  def self.set(value, expiration = nil)
    expiration ||= APP_CONFIG["expire_minutes"]
    REDIS.setex(LOCATION_KEY, expiration * 60, value)
  end

  def self.cached
    stored || (set(Location.find); stored)
  end
end

get "/" do
  @location = Location.cached
  haml :index
end

# With proper passwor (:pw) can set location manually via :to
get "/set" do
  if params[:pw] == APP_CONFIG["set_password"]
    Location.set(params[:to], params[:minutes])
    redirect "/"
  else
    redirect "/"
  end
end

