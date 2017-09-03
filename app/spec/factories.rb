FactoryGirl.define do

	factory :foo do
		sequence(:body) { |n| "Foo says '#{ n }'" }
	end

end
