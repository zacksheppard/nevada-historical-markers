require 'open-uri'
class Marker < ActiveRecord::Base

  def self.get_official_urls
    url = "http://nvshpo.org/home-topmenu-17-17/historical-markers/list-of-markers.html"
    doc = Nokogiri::HTML(open(url))
    marker_list = doc.css('ul')[10]
    marker_list.css('li').each do |item|
      link = item.css('a')[0]['href']
      full_url = "http://nvshpo.org" + link
      marker = Marker.new
      marker.url = full_url
      marker.save
    end

      # Correct for bad data
      minden = Marker.find_by_url("http://nvshpo.org/administrator/index.php/component/content/?sectionid=-1&task=edit&cid[]=210")
      minden.url = "http://nvshpo.org/index.php/component/content/?view=article&id=209&Itemid=9"
      minden.save
      sppr = Marker.find_by_url("http://nvshpo.org/index.php/component/content/?view=article&id=370&Itemid=9")
      sppr.delete

  end

  def self.get_info
    Marker.all.each do |m|
      url = m.url
      doc = Nokogiri::HTML(open(url))
      m.title = doc.css('.item-page').css('h2').inner_html.gsub!(/\n/, "").gsub!(/\t/, "")

      m.number = doc.css('.item-page p')[0].css('strong').inner_html.to_s.gsub!(/\s/, '')

      m.location = doc.css('.item-page p')[1].children[2].to_s

      m.description = ""
      doc.css('.item-page p')[7..-1].each do |line|
        m.description += "#{line.inner_html}\n"
      end

      m.save

    end
  end

  def self.get_lat_lon
    url = "http://www.oiccam.com/reno/historical_markers/nvmarkers/number.htm"
    doc = Nokogiri::HTML(open(url))
  end

end
