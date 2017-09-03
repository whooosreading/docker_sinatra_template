require 'sinatra'
require File.expand_path '../app.rb', __FILE__

require "rack/contrib"
use Rack::PostBodyContentTypeParser

run Sinatra::Application