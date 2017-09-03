require "./spec/spec_helper.rb"

describe Foo, type: :model do

	let!(:foo) { FactoryGirl.create(:foo) }

	subject { foo }

	it "| Responds" do
		should respond_to(:id)
		should respond_to(:body)
	end

	it { should be_valid }

	describe "| Validations" do
		it { should validate_presence_of(:body) }
	end
end


