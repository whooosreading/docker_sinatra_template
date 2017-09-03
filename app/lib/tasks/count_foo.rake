namespace :convert do
	task :count_foo do
		puts "Foo: #{ Foo.count }"
	end
end