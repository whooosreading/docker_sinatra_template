require "sinatra"
require "rack/test"
set :environment, :test
require "./app.rb"
require "factory_girl"
require "shoulda-matchers"
require "rspec/its"
require "pry"
require "timecop"

# For some reason "/spec" is being appened to Sinatra::Application.root
spec_dir_path = "/spec"
if Sinatra::Application.root.end_with?(spec_dir_path)
	clean_path = Sinatra::Application.root[0...(spec_dir_path.length*-1)]
	Sinatra::Application.root = clean_path
end

FactoryGirl.definition_file_paths = %w{./factories ./test/factories ./spec/factories}
FactoryGirl.find_definitions

RSpec.configure do |config|
	config.expect_with :rspec do |c|
		c.syntax = [:should, :expect]

		config.include(Shoulda::Matchers::ActiveModel, type: :model)
		config.include(Shoulda::Matchers::ActiveRecord, type: :model)

		require "database_cleaner"
		config.before(:suite) do
			DatabaseCleaner.strategy = :transaction
			DatabaseCleaner.clean_with(:truncation)
		end
	end
end

class Array
	def pluck(key)
		map { |h| h[key.to_s] || h[key.to_sym] }
	end
end


def app
	Sinatra::Application
end
