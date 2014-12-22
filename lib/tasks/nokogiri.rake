namespace :scrape do

  desc "Fetch official state marker URLs"
  task :official_urls => :environment do
    require 'nokogiri'  
    require 'open-uri' 
    url = "http://shpo.nv.gov/historical-markers/list/"
    doc = Nokogiri::HTML(open(url))
    marker_list = doc.css('.leading-0 ul')
    marker_list.css('li').each do |item|
      link = item.css('a')[0]['href']
      full_url = "http://nvshpo.org" + link
      marker = Marker.new
      marker.official_url = full_url
      marker.save
      puts "Marker URL saved as: #{marker.official_url}"
    end
    puts "#{Marker.count} marker URL's saved."
  end

  desc "Fetch official details"
  task :official_details => :environment do
    require 'nokogiri'  
    require 'open-uri' 
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

      m.description = ""
      m.office_marker_info = ""
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
      puts "Marker No. #{m.number} saved."
    end
  end

  desc "Fetch latitude & longitude data"
  task :lat_lon => :environment do
    require 'nokogiri'  
    require 'open-uri' 
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
        puts "Marker No. #{marker.number} coordinates saved as: [#{marker.latitude}, #{marker.longitude}]."
      end
    end
  end

  desc "Fetch data from dev DB"
  # with http://localtunnel.me/
  task :dev_db => :environment do
    require 'nokogiri'  
    require 'open-uri' 
    data = JSON.load(open("https://lrrnhmkgcc.localtunnel.me/markers.json"))
    data.each do |item|
      marker = Marker.new
      item_data = JSON.load(open("https://lrrnhmkgcc.localtunnel.me/markers/#{item['properties']['id']}.json"))

      marker.number = item['properties']['number']
      marker.title = item['properties']['name']
      marker.longitude = item['geometry']['coordinates'][0]
      marker.latitude = item['geometry']['coordinates'][1]
      marker.description = item_data[0]['properties']['description']
      marker.official_url = item_data[0]['properties']['official_url']
      marker.county = item_data[0]['properties']['county']
      marker.location_info = item_data[0]['properties']['location_info']
      marker.office_marker_info = item_data[0]['properties']['office_marker_info']

      marker.save
      puts "Marker No. #{marker.number} saved."
    end
    puts "#{Marker.count} marker URL's saved."
  end

  # TO DO
  # Some markers are saving with blank lat/lon
  # some are saving with too many decimal places 
  desc "Fetch additional latitude & longitude data"
  task :lat_lon_additional => :environment do
    require 'nokogiri'  
    require 'open-uri' 
    docs = []
    # Get each page 
    docs << Nokogiri::HTML(open("http://www.nevada-landmarks.com/markerlist.htm"))
    docs << Nokogiri::HTML(open("http://www.nevada-landmarks.com/markerlist2.htm"))
    docs.each do |doc|
      # Select the table with the marker list
      doc.css('table')[1].css('tr')[1..-1].each do |row|
        # unassigned markers have no info. 0 is here because blank rows show as 0
        unassigned = [0, 226, 260, 268, 269, 241]
        num = row.css('td')[0].text.gsub(/[^0-9]/, "").to_i
        unless unassigned.include?(num)
          m = Marker.find_by(number: num)
          m.county = row.css('td')[2].text.gsub(/\A[[:space:]]+|\.*[[:space:]]+\z/, '')
          # Markers with 'firebrick' color are missing and shouldn't be included
          unless row.css('td')[0].inner_html.include?('firebrick') 
            # We have to divide the float by 1.0 or the number wont match when saved
            m.latitude = row.css('td')[3].text.match(/N\d*\.\d*/).to_s.gsub('N', '').to_f/1.0
            # divide by -1.0 as these West longitides have to be negative
            m.longitude = row.css('td')[3].text.match(/W\d*\.\d*/).to_s.gsub('W', '').to_f/-1.0
          end
          puts "-----------------------------------------------"
          puts "[#{row.css('td')[3].text.match(/N\d*\.\d*/).to_s.gsub('N', '')}, -#{longitude = row.css('td')[3].text.match(/W\d*\.\d*/).to_s.gsub('W', '')}]: Cell data in Nokogiri."
          puts "[#{m.latitude.inspect}, #{m.longitude.inspect}]: Pre-save lat/lon for #{m.title}[#{m.number}]"
          m.save
          puts "[#{m.latitude.inspect}, #{m.longitude.inspect}]: Lat/Lon saved for #{m.title}[#{m.number}]"
        end
      end
    end
  end

  # Write a method to remove the UPCASE text in descriptions left over from scraping.

end

desc "Set default text for empty descriptions"
task :fill_empty_desc => :environment do
  Marker.all.each do |m| 
    m.description = "(Official text not available)" if m.description == ""
    m.save
  end
end

# "(Official data not available)"

