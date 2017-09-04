class CreateFoos < ActiveRecord::Migration[5.1]
  def change
  	create_table :foos do |t|
  		t.string :body
  		t.timestamps null: true
  	end
  end
end
