# jekyll-flickr-photoset

It's a Jekyll plugin for embedding Flickr photosets in your Liquid templates.

I was moving from Posterous to Jekyll and I was looking for a slideshow gallery like Posteours has. You put a simple tag with a Flickr photoset ID inside your post and it builds a slideshow gallery. So I made it: one tag generate a gallery, no more. Dead simple.

## Usage

    {% flickr_photoset 12345678901234567 %}
    {% flickr_photoset 12345678901234567 "Square" "Medium 640" "Large" %}

Where:

- `12345678901234567` is the Flickr photoset ID (can be found in this kind of url: `http://www.flickr.com/photos/j0k/sets/72157624158475427/`)
- `"Square"` is the size for the thumbnail image (*which also the one by default*)
- `"Medium 640"` is the size for the displayed image (*which also the one by default*)
- `"Large"` is the size for the opened image (*which also the one by default*)

Other Flickr size can be found [here](http://www.flickr.com/services/api/flickr.photos.getSizes.html).

## Requirements

#### FlickRaw

*Flickraw is a library to access flickr api in a simple way.*

    gem install flickraw

#### A Flickr API key

You can obtain a Flickr API key [here](http://www.flickr.com/services/apps/create/).
And follow instructions on [the FlickRaw page for authentication](http://hanklords.github.com/flickraw/):

  - create a `flickr.rb` file with content of "Authentication" bloc code
  - replace api key by the one previously generated on the Flickr website
  - launch it with `ruby -rubygems flickr.rb`
  - follow instructions

Then put them inside `_config.yml` (where `flickr:` is defined on the root level):

    flickr:
      cache_dir:       ./_cache/flickr
      api_key:          xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      shared_secret:    xxxxxxxxxxxxxxxx
      access_token:     xxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxx
      access_secret:    xxxxxxxxxxxxxxxx

There is also an ability to generate cache. It will put all images references from each photoset. It will save **a lot of time** when you will have to regenerate all your posts. Cache are written in a yml file. Photoset ID is the file name.

#### [AD Gallery](http://adgallery.codeplex.com/)
This is the plugin used to generate the slideshow gallery, which is almost the same from Posterous. You will find references in `adgallery` folder, I put the latest version (1.2.7).

So you need to load it:

    <link rel="stylesheet" href="/ad-gallery/jquery.ad-gallery.css" />
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
    <script type="text/javascript" src="/ad-gallery/jquery.ad-gallery.js?rand=302"></script>
    <script type="text/javascript">
    $(function() {
      var galleries = $('.ad-gallery').adGallery({
        loader_image: '/ad-gallery/loader.gif',
        width: 640,
      });
    })
    </script>

## Todo

- handle fullscreen slideshow and use `urlOpened` image

## Inspiration

I've looked inside :

- [jekyll-flickr](https://github.com/cnunciato/jekyll-flickr)
- [Integrating Flickr and Jekyll](http://www.marran.com/tech/integrating-flickr-and-jekyll/)
