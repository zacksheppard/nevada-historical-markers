class AddDetailsToMarker < ActiveRecord::Migration
  def change
    add_column :markers, :url, :string
  end
end
