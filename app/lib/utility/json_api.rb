def development_only
	raise "Development only!" unless Sinatra::Application.development?
end

def pretty_json(json_data)
	JSON.pretty_generate(json_data.as_json, { indent: "  " })
end

def render_rabl(view_file)
	extract_embeds

	content_type :json
	rabl view_file, views: "views/api"
end

def render_json(data)
	content_type :json
	data.to_json
end

def render_nothing
	content_type :json
	{}.to_json
end

def extract_embeds
	@request_embeds = Set.new(params[:embed].to_s.split(","))
end

helpers do
	def embed?(*keys)
		return false if @request_embeds.nil?
		(@request_embeds & keys).any?
	end
end

def controller_embed?(*keys)
	return false if @request_embeds.nil?
	(@request_embeds & keys).any?
end

def strong_params(key, permitted)
	data = params[key].to_h
	Hash[permitted.map do |attribute|
		if data.has_key?(attribute.to_sym) || data.has_key?(attribute.to_s)
			[attribute, data[attribute]]
		end
	end.compact]
end

def load_pagination(fallback_per_page = nil)
	@page = params[:page].to_i || 1
	@page = 1 if @page < 1

	@per_page = params[:per_page] || fallback_per_page || DEFAULT_PER_PAGE
end
DEFAULT_PER_PAGE = 20

def watch_for_404(&block)
	begin
		block.call
	rescue ActiveRecord::RecordNotFound
		halt(404, "No record found with ID: #{ params[:id] }")
	end

end


