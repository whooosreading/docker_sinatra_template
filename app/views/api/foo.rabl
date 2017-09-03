object @foo

attributes :id, :body

node(:extra, if: embed?("foo.extra")) { |foo| foo.id ** 2 }

node(:errors, if: :invalid?) do |foo|
	foo.errors.full_messages
end