require "rubygems"
require "bundler"
Bundler.require

require "sass/plugin/rack"

require "./app"

# Use scss for stylesheets
Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

run Sinatra::Application

