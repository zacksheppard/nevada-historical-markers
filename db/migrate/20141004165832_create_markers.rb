class CreateMarkers < ActiveRecord::Migration
  def change
    create_table :markers do |t|
      t.integer :number
      t.string :title
      t.string :description
      t.string :county
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
