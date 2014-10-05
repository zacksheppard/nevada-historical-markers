require 'open-uri'
class Marker < ActiveRecord::Base

  def self.get_official_urls
    url = "http://nvshpo.org/home-topmenu-17-17/historical-markers/list-of-markers.html"
    doc = Nokogiri::HTML(open(url))
    marker_list = doc.css('ul')[10]
    marker_list.css('li').each do |item|
      link = item.css('a')[0]['href']
      full_url = "http://http://nvshpo.org" + link
      marker = Marker.new
      marker.url = full_url
      marker.save
    end
  end

  def self.get_lat_lon
    url = "http://www.oiccam.com/reno/historical_markers/nvmarkers/number.htm"
    doc = Nokogiri::HTML(open(url))
  end

end
