class CreateMarkers < ActiveRecord::Migration
  def change
    create_table :markers do |t|
      t.integer :number
      t.string :title
      t.string :office_marker_info
      t.string :official_url
      t.text :description
      t.string :county
      t.string :location_info
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
