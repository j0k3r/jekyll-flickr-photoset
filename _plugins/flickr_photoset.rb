# Flickr Photoset Tag
#
# A Jekyll plug-in for embedding Flickr photoset in your Liquid templates.
#
# Usage:
#
#   {% flickr_photoset 72157624158475427 %}
#   {% flickr_photoset 72157624158475427 "Square" "Medium 640" "Large" %}
#
# For futher information please visit: https://github.com/j0k3r/jekyll-flickr-photoset
#
# Author: Jeremy Benoist
# Source: https://github.com/j0k3r/jekyll-flickr-photoset

require 'flickraw'
require 'shellwords'

module Jekyll

  class FlickrPhotosetTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)

      super
      params = Shellwords.shellwords markup

      @photoset       = params[0]
      @photoThumbnail = params[1] || "Square"
      @photoEmbeded   = params[2] || "Medium 640"
      @photoOpened    = params[3] || "Large"

    end

    def render(context)

      flickrConfig = context.registers[:site].config["flickr"]

      if cache_dir = flickrConfig['cache_dir']
        path = File.join(cache_dir, "#{@photoset}.yml")
        if File.exist?(path)
          photos = YAML::load(File.read(path))
        else
          photos = generate_photo_data(@photoset, flickrConfig)
          File.open(path, 'w') {|f| f.print(YAML::dump(photos)) }
        end
      else
        photos = generate_photo_data(@photoset, flickrConfig)
      end

      if photos.count == 1

        output = "<img src=\"#{photos[0].urlEmbeded}\" title=\"#{photos[0].title}\" longdesc=\"#{photos[0].title}\" alt=\"#{photos[0].title}\" />\n"

      else

        output = "<div id=\"gallery-#{@photoset}\" class=\"ad-gallery\">\n"
        output += "  <div class=\"ad-image-wrapper\"></div>\n"
        output += "  <div class=\"ad-controls\"></div>\n"
        output += "  <div class=\"ad-nav\">\n"
        output += "    <div class=\"ad-thumbs\">\n"
        output += "      <ul class=\"ad-thumb-list\">\n"

        photos.each_with_index do |photo, i|

          output += "      <li>\n"
          # custom id needed to correctly handle multiple gallery on the same page
          output += "        <a id=\"photo-#{@photoset}-#{i}\" href=\"#{photo.urlEmbeded}\">\n"
          output += "          <img src=\"#{photo.urlThumb}\" longdesc=\"#{photo.urlOpened}\" class=\"image-#{i}\" />\n"
          output += "        </a>\n"
          output += "      </li>\n"

        end

        output += "      </ul>\n"
        output += "    </div>\n"
        output += "  </div>\n"
        output += "</div>\n"

      end

      # return content
      output

    end

    def generate_photo_data(photoset, flickrConfig)

      returnSet = Array.new

      FlickRaw.api_key       = ENV['FLICKR_API_KEY'] || flickrConfig['api_key']
      FlickRaw.shared_secret = ENV['FLICKR_SHARED_SECRET'] || flickrConfig['shared_secret']
      flickr.access_token    = ENV['FLICKR_ACCESS_TOKEN'] || flickrConfig['access_token']
      flickr.access_secret   = ENV['FLICKR_ACCESS_SECRET'] || flickrConfig['access_secret']

      begin
        flickr.test.login
      rescue Exception => e
        raise "Unable to login, please check documentation for correctly configuring Environment Variables, or _config.yaml."
      end

      photos = flickr.photosets.getPhotos :photoset_id => photoset

      photos.photo.each_index do | i |

        title      = photos.photo[i].title
        id         = photos.photo[i].id
        urlThumb   = String.new
        urlEmbeded = String.new
        urlOpened  = String.new

        sizes = flickr.photos.getSizes(:photo_id => id)

        urlThumb   = sizes.find {|s| s.label == @photoThumbnail }
        urlEmbeded = sizes.find {|s| s.label == @photoEmbeded }
        urlOpened  = sizes.find {|s| s.label == @photoOpened }

        photo = FlickrPhoto.new(title, urlThumb.source, urlEmbeded.source, urlOpened.source)
        returnSet.push photo

      end

      # sleep a little so that you don't get in trouble for bombarding the Flickr servers
      sleep 1

      returnSet

    end

  end

  class FlickrPhoto

    attr_accessor :title, :urlThumb, :urlEmbeded, :urlOpened

    def initialize(title, urlThumb, urlEmbeded, urlOpened)
      @title      = title
      @urlThumb   = urlThumb
      @urlEmbeded = urlEmbeded
      @urlOpened  = urlOpened
    end

  end

end

Liquid::Template.register_tag('flickr_photoset', Jekyll::FlickrPhotosetTag)
