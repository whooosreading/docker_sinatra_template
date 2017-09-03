require "./spec/spec_helper.rb"

describe "Foo API" do
	include Rack::Test::Methods

	let!(:_) { Foo.delete_all }

	let!(:foo_1) { FactoryGirl.create(:foo) }

	let(:foo_data) { { body: "Foo haha!" } }

	describe "| GET /foo" do
		let!(:foo_2) { FactoryGirl.create(:foo) }
		let!(:foo_3) { FactoryGirl.create(:foo) }

		it "| Status" do
			get "/api/v1/foos"
			rsp = last_response

			rsp.should be_ok
		end

		it "| Search for a user's responses" do
			get "/api/v1/foos"

			body = JSON.parse(last_response.body)
			body["foos"].pluck(:id).should =~ [foo_1.id, foo_2.id, foo_3.id]
		end

		it "| Default Pagination" do
			get "/api/v1/foos"

			body = JSON.parse(last_response.body)
			body["page"].should == 1
			body["per_page"].should == 20
		end

		it "| Pagination" do
			get "/api/v1/foos?user_id=876&page=1&per_page=2"
			body = JSON.parse(last_response.body)
			body["foos"].length.should == 2

			get "/api/v1/foos?user_id=876&page=2&per_page=2"
			body = JSON.parse(last_response.body)
			body["foos"].length.should == 1

			get "/api/v1/foos?user_id=876&page=3&per_page=2"
			body = JSON.parse(last_response.body)
			body["foos"].length.should == 0
		end
	end

	describe "| GET /foos/:id" do
		it "| Status" do
			get "/api/v1/foos/#{ foo_1.id }"
			rsp = last_response
			rsp.should be_ok
		end

		it "| Basic data" do
			get "/api/v1/foos/#{ foo_1.id }"
			body = JSON.parse(last_response.body)

			body["foo"]["id"].should == foo_1.id
		end
	end

	describe "| POST /foos" do
		it "| Status" do
			post "/api/v1/foos", { foo: foo_data }

			rsp = last_response
			rsp.should be_ok
		end

		it "| Change and response" do
			expect do
				post "/api/v1/foos", { foo: foo_data }
			end.to change { Foo.count }.by(1)

			body = JSON.parse(last_response.body)

			body["foo"].should_not be_nil
			body["foo"]["id"].should_not be_nil
			body["foo"]["id"].should == Foo.last.id
			body["foo"]["errors"].should be_nil
		end

		it "| Errors" do
			expect do
				post "/api/v1/foos", { foo: { body: "" } }
			end.to change { Foo.count }.by(0)

			body = JSON.parse(last_response.body)

			body["foo"].should_not be_nil
			body["foo"]["id"].should be_nil
			body["foo"]["errors"].should_not be_nil
			body["foo"]["errors"].length.should >= 1
		end
	end

	describe "| PATCH /foos/:id" do
		it "| Status" do
			patch "/api/v1/foos/#{ foo_1.id }", { foo: foo_data }

			rsp = last_response
			rsp.should be_ok
		end

		it "| Change and response" do
			patch "/api/v1/foos/#{ foo_1.id }", { foo: foo_data }

			body = JSON.parse(last_response.body)

			body["foo"].should_not be_nil
			body["foo"]["id"].should == foo_1.id
			body["foo"]["errors"].should be_nil

			foo_1.reload.body.should == "Foo haha!"
		end

		it "| Errors" do
			patch "/api/v1/foos/#{ foo_1.id }", { foo: { body: "" } }

			body = JSON.parse(last_response.body)

			body["foo"].should_not be_nil
			body["foo"]["errors"].should_not be_nil
			body["foo"]["errors"].length.should >= 1

			foo_1.reload.body.should_not == ""
		end
	end

	describe "| DELETE /foos/:id" do
		it "| Status" do
			delete "/api/v1/foos/#{ foo_1.id }"

			rsp = last_response
			rsp.should be_ok
		end

		it "| Change and response" do
			expect do
				delete "/api/v1/foos/#{ foo_1.id }"
			end.to change { Foo.count }.by(-1)

			body = JSON.parse(last_response.body)

			Foo.find_by(id: foo_1.id).should be_nil
		end
	end

end
