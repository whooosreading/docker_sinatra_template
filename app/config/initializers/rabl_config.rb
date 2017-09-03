class PrettyJson
	def self.dump(object)
		JSON.pretty_generate(object, {:indent => "  "})
	end
end

Rabl.configure do |config|
	if !Sinatra::Application.production?
		config.json_engine = PrettyJson
	end
	config.include_json_root = true
	config.include_child_root = false
end
