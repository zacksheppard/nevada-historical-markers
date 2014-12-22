class Marker < ActiveRecord::Base

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |marker|
        csv << marker.attributes.values_at(*column_names)
      end
    end
  end



  # def self.to_geojson
  #   @markers = Marker.all
  #   @geojson = []
    
  #   @markers.each do |m|
  #     @geojson << {
  #       type: 'Feature',
  #       geometry: {
  #         type: 'Point',
  #         coordinates: [m.latitude, m.longitude]
  #       },
  #       properties: {
  #         id: m.id,
  #         name: m.title,
  #         number: m.number,
  #         description: m.description,
  #         :'marker-color' => '#00607d',
  #         :'marker-symbol' => 'circle',
  #         :'marker-size' => 'small'
  #       }
  #     }
  #   end
  # end

  def to_geojson
    @geojson = []
    @geojson << {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [self.latitude, self.longitude]
      },
      properties: {
        id: self.id,
        name: self.title,
        number: self.number,
        description: self.description,
        :'marker-color' => '#00607d',
        :'marker-symbol' => 'circle',
        :'marker-size' => 'medium'
      }
    }
  end

  # Notes for a blog post:
  # N39° 09' 12.9''  W119° 48' 54.0''
  # => Should be 39.153583, -119.815
  # Marker.convert_geo("N39° 09' 12.9''")
  # w/o the .0 it was => 39.18733333333333, -119.70636111111111

  # dms is geo location shorthand for Degrees Minutes Seconds.
  def convert_geo(dms)
    dms_array = dms.scan(/[0-9.]+/)  # put dms into an array, numbers only
    coordinate = dms_array[0].to_f + dms_array[1].to_f/60.0 + dms_array[2].to_f/3600.0
    coordinate = coordinate * -1 if dms.include?('W') || dms.include?('S')
    coordinate
  end

  def short_desc
    if description.length > 140
      "#{description[0..140]}<a href='/markers/#{id}'>...more</a>"
    else
      description
    end
  end

end
