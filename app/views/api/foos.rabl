node(:foos) do
	@foos.map do |foo|
		partial("foo", object: foo, view_path: "views/api")
	end
end

node(:page) { @page }
node(:per_page) { @per_page }