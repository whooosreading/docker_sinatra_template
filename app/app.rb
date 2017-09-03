require "sinatra"
require "sinatra/activerecord"
require "json"
require "rabl"
require "will_paginate"
require "will_paginate/active_record"

["./lib/models/*.rb", "./lib/utility/*.rb", "./config/initializers/*.rb"].each do |pattern|
	Dir[pattern].each do |file|
		require file
	end
end

##############################
# Basic Views ################
##############################

get "/" do
	erb :home, views: "views"
end

get "/info" do
	"Docker-Sinatra Template - by Whooo's Reading!"
end

##############################
# API Routes #################
##############################

get "/foos" do
	load_pagination
	@foos = Foo.all.paginate(page: @page, per_page: @per_page)
	render_rabl :foos
end

get "/foos/:id" do
	watch_for_404 do
		@foo = Foo.find(params[:id])
	end
	render_rabl :foo
end

get "/new_foo" do
	Foo.create(body: "Foo at #{ Time.now.to_i }")
	render_json({ count: Foo.count })
end