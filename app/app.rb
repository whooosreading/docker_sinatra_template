require "sinatra"
require "sinatra/activerecord"
require "json"
require "rabl"
require "will_paginate"
require "will_paginate/active_record"
require "rack/contrib"
require "logger"

configure do
	set :environments, %w{development test production staging}
end

configure :development do
	disable :show_exceptions
end


["./lib/models/*.rb", "./lib/utility/*.rb", "./lib/domain/*.rb", 
	"./config/initializers/*.rb"].each do |pattern|
	Dir[pattern].each do |file|
		require file
	end
end

use Rack::PostBodyContentTypeParser

if !Sinatra::Application.test?
	ActiveRecord::Base.logger = nil
	use Rack::JSONLogger
	$stdout.sync = true
end

##############################
## Basic Views ###############
##############################

get "/" do
	erb :home, views: "views"
end

get "/info" do
	"Docker-Sinatra Template - by Whooo's Reading!"
end

##############################
## API Routes ################
##############################

get "/api/v1/foos" do
	load_pagination
	@foos = Foo.all.paginate(page: @page, per_page: @per_page)
	render_rabl :foos
end

get "/api/v1/foos/:id" do
	watch_for_404 do
		@foo = Foo.find(params[:id])
	end
	render_rabl :foo
end

post "/api/v1/foos" do
	@foo = Foo.create(strong_foo_params)
	render_rabl :foo
end

patch "/api/v1/foos/:id" do
	watch_for_404 do
		@foo = Foo.find(params[:id])
	end
	@foo.update_attributes(strong_foo_params)
	render_rabl :foo
end

delete "/api/v1/foos/:id" do
	watch_for_404 do
		@foo = Foo.find(params[:id])
	end
	@foo.destroy
	render_rabl :foo
end

get "/api/v1/new_foo" do
	Foo.create(body: "Foo at #{ Time.now.to_i }")
	render_json({ count: Foo.count })
end

def strong_foo_params
	strong_params(:foo, [:body])
end