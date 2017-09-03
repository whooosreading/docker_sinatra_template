object @foo

attributes :id, :body

node(:exra, if: embed?("foo.extra"))