require "sinatra" 
require "logger"
require "redis"
require "foursquare2"
require "./location"

EXPIRE_MINUTES = 120

set :root, Proc.new { File.dirname(__FILE__) }
set :views, Proc.new { File.join(File.dirname(__FILE__), "views") }
set :public_folder, "public"

APP_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "config/app.yml"))

LOCATION_KEY = "whereintheworldisben.location"
REDIS = Redis.new

## Configuration
configure do
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = "views"
  end

  set :scss, Compass.sass_engine_options
end

configure :production do
  set :haml, :ugly => true
  set :clean_trace, true

  Dir.mkdir('logs') unless File.exist?('logs')

  $logger = Logger.new(File.join(File.dirname(__FILE__), "log/common.log"), "weekly")
  $logger.level = Logger::WARN

  # Spit stdout and stderr to a file during production in case something goes wrong:
  $stdout.reopen(File.join(File.dirname(__FILE__), "log/output.log"), "w")
  $stdout.sync = true
  $stderr.reopen($stdout)
end

configure :development do
  $logger = Logger.new(STDOUT)
end


## Handlers
get "/" do
  @location = Location.cached
  haml :index
end

get "/location.json" do
  content_type :json
  { :location => Location.cached }.to_json
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

get "/stylesheets/screen.css" do
  scss :screen
end
