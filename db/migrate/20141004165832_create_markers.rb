class CreateMarkers < ActiveRecord::Migration
  def change
    create_table :markers do |t|
      t.integer :number
      t.string :title
      t.text :description
      t.string :location
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
