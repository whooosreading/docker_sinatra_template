require "sinatra"
require "sinatra/activerecord"
require "json"

Dir["./lib/models/*.rb"].each { |file| require file }

get "/" do
	{ body: "Hello World!" }.to_json
end

get "/foos" do
	{ foos: Foo.last(10).as_json }.to_json
end

get "/new_foo" do
	Foo.create(body: "Foo at #{ Time.now.to_i }")
	{ count: Foo.count }.to_json
end