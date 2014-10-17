require 'open-uri'
class Marker < ActiveRecord::Base

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |marker|
        csv << marker.attributes.values_at(*column_names)
      end
    end
  end

  def self.get_official_urls
    url = "http://shpo.nv.gov/historical-markers/list/"
    doc = Nokogiri::HTML(open(url))
    marker_list = doc.css('.leading-0 ul')
    marker_list.css('li').each do |item|
      link = item.css('a')[0]['href']
      full_url = "http://nvshpo.org" + link
      marker = Marker.new
      marker.official_url = full_url
      marker.save
    end
  end

  def self.get_info
    Marker.all.each do |m|
      url = m.official_url
      doc = Nokogiri::HTML(open(url))

      m.title = doc.css('h2').inner_html

      m.number = m.official_url.gsub(/\D/, "").to_i

      m.location_info = ""
      doc.css('.leading-0 p').each do |line| 
        if line.text.include?('Location')
          m.location_info = "#{line.text.gsub(/\A[[:space:]]+|\.*[[:space:]]+\z/, '')}."
          m.location_info = m.location_info.gsub("Location:", "").gsub(/[[:space:]]{2}/, ". ")
        end
      end

      # doc.css('.MsoNormal').inner_html
      m.description = ""
      m.office_marker_info = ""
      binding.pry
      doc.css('p.StyleLinespacing15lines, p.MsoNormal').each do |line|

        # if it is a blank line do nothing
        if line.text.gsub(/\A[[:space:]]+|\.*[[:space:]]+\z/, '') == ""
          next

        # elsif it matches the title, do nothing
        elsif line.text.gsub(/\A[[:space:]]+|\.*[[:space:]]+\z/, '') == m.title.upcase
          next

        # elsif it has 'No. ' or distinct words in upcase add to office info
        elsif line.text =~ /No\.\s|No\.\s|HISTORIC|MUSEUM|SOCIETY|CHAMBER|STATE|OFFICE|INTERNATIONAL/
          m.office_marker_info += "<p>#{line.text.gsub(/\A[[:space:]]+|\.*[[:space:]]+\z/, '')}</p>"

        # if it passes the above, add to description
        else 
          m.description += "<p>#{line.text.gsub(/\A[[:space:]]+|\.*[[:space:]]+\z/, '')}</p>"
        end
      end
      m.save
    end
  end

  def self.get_lat_lon
    url = "http://www.oiccam.com/reno/historical_markers/nvmarkers/number.htm"
    doc = Nokogiri::HTML(open(url))
    doc.css('tr')[1..-1].each do |row|
      if row.css('td')[0].css('a').text.include?('NV')
        number = row.css('td')[0].css('a').text
        number.gsub!(/(V00|V0|[^0123456789])/, '')
        marker = Marker.find_or_create_by(number: number)
        marker.latitude = marker.convert_geo(row.css('td')[3].inner_html)
        marker.longitude = marker.convert_geo(row.css('td')[4].inner_html)
        marker.save
      end
    end
  end

  # N39° 09' 12.9''  W119° 48' 54.0''
  # => Should be 39.153583, -119.815
  # Marker.convert_geo("N39° 09' 12.9''")
  # w/o the .0 it was => 39.18733333333333, -119.70636111111111
  def convert_geo(dms)
    dms_array = dms.scan(/[0-9.]+/)
    coordinate = dms_array[0].to_f + dms_array[1].to_f/60.0 + dms_array[2].to_f/3600.0
    coordinate = coordinate * -1 if dms.include?('W') || dms.include?('S')
    coordinate
  end

  # The HTML usage is very inconsistent at the source page.
  # This method, saves the <strong> tag that we will need, 
  # strips all other tags, restores <strong>,
  # then puts <p> tags at the beginning and end of lines.
  def self.clean_data
    Marker.all.each do |marker|
      unless marker.description == nil
        marker.description = marker.description.gsub(/<strong[^>]*>/, "111strong111")
        marker.description = marker.description.gsub(/<\/strong[^>]*>/, "111/strong111")
        marker.description = marker.description.gsub(/<\/?[^>]*>/, "")
        marker.description = marker.description.gsub(/^/, "<p>")
        marker.description = marker.description.gsub(/$/, "</p>")
        marker.description = marker.description.gsub(/111strong111/, "<strong>")
        marker.description = marker.description.gsub(/111\/strong111/, "</strong>")
        marker.description = marker.description.gsub(/<strong>\s*<\/strong>/, '')
        marker.description = marker.description.gsub(/<p>\S*<\/p>/, '')
        marker.description = marker.description.gsub(/[\n]+/, "\n")
        marker.description = marker.description.gsub(/^<\/p>$/, "")
        # puts "==========================================="
        # puts "NUMBER #{marker.number}"
        # puts marker.description
        marker.save
      end
    end
  end
end
