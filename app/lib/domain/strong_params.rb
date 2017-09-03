# Uses strong params from domain

def strong_foo_params
	strong_params(:foo, [:body])
end
