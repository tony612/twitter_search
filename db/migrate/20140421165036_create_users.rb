class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid
      t.string :nickname
      t.string :name
      t.string :location
      t.string :image
      t.string :description
      t.string :access_token

      t.timestamps
    end
  end
end
