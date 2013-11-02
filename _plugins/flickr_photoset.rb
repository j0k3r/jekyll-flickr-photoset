# Flickr Photoset Tag
#
# A Jekyll plug-in for embedding Flickr photoset in your Liquid templates.
#
# Usage:
#
#   {% flickr_photoset 72157624158475427 %}
#   {% flickr_photoset 72157624158475427 "Square" "Medium 640" "Large" "Site MP4" %}
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
      @photoThumbnail = params[1] || "Large Square"
      @photoEmbeded   = params[2] || "Medium 800"
      @photoOpened    = params[3] || "Large"
      @video          = params[4] || "Site MP4"
    end

    def render(context)
      # hack to convert a variable into an actual flickr set id
      if @photoset =~ /([\w]+\.[\w]+)/i
        @photoset = Liquid::Template.parse('{{ '+@photoset+' }}').render context
      end

      flickrConfig = context.registers[:site].config["flickr"]

      if cache_dir = flickrConfig['cache_dir']
        if !Dir.exist?(cache_dir)
          Dir.mkdir(cache_dir, 0777)
        end

        path = File.join(cache_dir, "#{@photoset}-#{@photoThumbnail}-#{@photoEmbeded}-#{@photoOpened}-#{@video}.yml")
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
        if photos[0]['urlVideo'] != ''
          output = "<p style=\"text-align: center;\">\n"
          output += "  <video controls poster=\"#{photos[0]['urlEmbeded']}\">\n"
          output += "    <source src=\"#{photos[0]['urlVideo']}\" type=\"video/mp4\" />\n"
          output += "  </video>\n"
          output += "  <br/><span class=\"alt-flickr\"><a href=\"#{photos[0]['urlFlickr']}\" target=\"_blank\">Voir la video en grand</a></span>\n"
          output += "</p>\n"
        else
          output = "<p style=\"text-align: center;\"><img class=\"th\" src=\"#{photos[0]['urlEmbeded']}\" title=\"#{photos[0]['title']}\" longdesc=\"#{photos[0]['title']}\" alt=\"#{photos[0]['title']}\" /></p>\n"
        end
      else
        output = "<div class=\"row\">\n"
        output += "  <div class=\"large-11 columns large-centered\">\n"
        output += "    <ul class=\"clearing-thumbs\" data-clearing>\n"

        photos.each_with_index do |photo, i|
          if photo['urlVideo'] != ''
            output += "      <li>\n"
            output += "        <video controls poster=\"#{photo['urlEmbeded']}\">\n"
            output += "          <source src=\"#{photo['urlVideo']}\" type=\"video/mp4\" />\n"
            output += "        </video>\n"
            output += "        <br/><span class=\"alt-flickr\"><a href=\"#{photo['urlFlickr']}\" target=\"_blank\">Voir la video en grand</a></span>\n"
            output += "      </li>\n"
          else
            output += "      <li><a class=\"th\" href=\"#{photo['urlOpened']}\"><img src=\"#{photo['urlThumb']}\"></a></li>\n"
          end
        end

        output += "    </ul>\n"
        output += "  </div>\n"
        output += "</div>\n"
      end

      # return content
      output
    end

    def generate_photo_data(photoset, flickrConfig)
      returnSet = Array.new

      FlickRaw.api_key       = flickrConfig['api_key']
      FlickRaw.shared_secret = flickrConfig['shared_secret']
      flickr.access_token    = flickrConfig['access_token']
      flickr.access_secret   = flickrConfig['access_secret']

      begin
        flickr.test.login
      rescue Exception => e
        raise "Bad token: #{flickrConfig['access_token']}"
      end

      begin
        photos = flickr.photosets.getPhotos :photoset_id => photoset
      rescue Exception => e
        raise "Bad photoset: #{photoset}"
      end

      photos.photo.each_index do | i |

        title = photos.photo[i].title
        id    = photos.photo[i].id

        urlThumb   = String.new
        urlEmbeded = String.new
        urlOpened  = String.new
        urlVideo   = String.new

        sizes = flickr.photos.getSizes(:photo_id => id)

        urlThumb       = sizes.find {|s| s.label == @photoThumbnail }
        urlEmbeded     = sizes.find {|s| s.label == @photoEmbeded }
        urlOpened      = sizes.find {|s| s.label == @photoOpened }
        urlVideo       = sizes.find {|s| s.label == @video }

        photo = FlickrPhoto.new(title, urlThumb, urlEmbeded, urlOpened, urlVideo)
        returnSet.push photo
      end

      # sleep a little so that you don't get in trouble for bombarding the Flickr servers
      sleep 1

      returnSet
    end
  end

  class FlickrPhoto
    attr_accessor :title, :urlThumb, :urlEmbeded, :urlOpened, :urlVideo, :urlFlickr

    def initialize(title, urlThumb, urlEmbeded, urlOpened, urlVideo)
      @title      = title
      @urlThumb   = urlThumb ? urlThumb.source : ''
      @urlEmbeded = urlEmbeded ? urlEmbeded.source : ''
      @urlOpened  = urlOpened ? urlOpened.source : ''
      @urlVideo   = urlVideo ? urlVideo.source : ''
      @urlFlickr  = urlVideo ? urlVideo.url : ''
    end
  end

end

Liquid::Template.register_tag('flickr_photoset', Jekyll::FlickrPhotosetTag)
