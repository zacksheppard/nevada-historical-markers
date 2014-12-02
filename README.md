## Nevada State Historical Maker map

### Viewable on [Heruko](http://nevada-historical-markers.herokuapp.com/) 
__Note:__ Data in the markers is still a little rough as there wasn't a way to seperate the descriptions when scraping so that is still a work in progress. 

__Related blog post:__ [Removing Leading and Trailing Spaces and &nbsp in Ruby](http://io.zack.io/blog/2014/10/17/removing-leading-and-trailing-spaces-and-and-nbsp-in-ruby/)

### What?
A map of the Historical Markers in the State of Nevada. In addition to the markers themselves, information is used from the [State Historic Preservation Office](http://shpo.nv.gov/home/historical-markers) and [this wonderful page of markers](http://www.oiccam.com/reno/historical_markers/nvmarkers/number.htm) compiled by [Jim Alexander](http://www.oiccam.com/reno/historical_markers/nvmarkers/).

### Why?
When you travel around the state of Nevada you often happen upon historical markers like [this one](https://www.flickr.com/photos/quikbeam/192446147). They very often are a marker of history that left no other traces behind. I've heard many Nevadans say they'd love to know more about these, where they are, what they mean and how many are really around and that is what this project is about. 

### Configuration:
* Ruby 2.1.2, Rails 4.1.4
* For the map I'm first using CartoDB because I'd like to try it out. After that is done I'll also create a map myself using JavaScript and Google Maps.
* Because it is more useful on mobile I'll optimize for both desktop and mobile views and add location awareness.




