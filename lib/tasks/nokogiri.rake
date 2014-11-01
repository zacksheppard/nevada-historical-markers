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
      puts "Marker(#{marker.id}) saved #{marker.official_url}."
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

      # UNIT OF WORK parse_location_info
      m.location_info = ""
      doc.css('.leading-0 p').each do |line| 
        if line.text.include?('Location')
          m.location_info = "#{line.text.gsub(/\A[[:space:]]+|\.*[[:space:]]+\z/, '')}."
          m.location_info = m.location_info.gsub("Location:", "").gsub(/[[:space:]]{2}/, ". ")
        end
      end

      # UNIT OF WORK parse_description
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
      end
    end
  end

  # Write a method to remove the UPCASE text in descriptions left over from scraping.

end
