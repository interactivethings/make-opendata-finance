###
# Compass
###

# Susy grids in Compass
# First: gem install compass-susy-plugin
# require 'susy'
require 'rgbapng'
require 'compass-css-arrow'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

page "*", :layout => "layouts/default"

# Per-page layout changes:
#
# With no layout
# page "index.html", :layout => false

# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
# 
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do

end

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :js_dir, 'assets/javascripts'
set :css_dir, 'assets/stylesheets'
set :images_dir, 'assets/images'

# Add Bower components to Sprockets/SASS
set :js_assets_paths, ["#{root}/components"]
set :sass_assets_paths, ["#{root}/lib/assets/stylesheets", "#{root}/components"]

set :template_dir, 'assets/javascripts/templates'

configure :development do
  activate :livereload

  # Debugging assets has a big speed impact, so only enable it when needed
  # set :debug_assets, true
end

# Build-specific configuration
configure :build do
  # Disable asset debugging since Middleman doesn't do it automatically as of 3.0.11
  set :debug_assets, false

  # For example, change the Compass output style for deployment
  activate :minify_css
  
  # Minify Javascript on build
  activate :minify_javascript
  
  # Enable cache buster
  activate :cache_buster
  
  # Use relative URLs
  activate :relative_assets
  
  # Compress PNGs after build
  # First: gem install middleman-smusher
  require "middleman-smusher"
  activate :smusher
  
  # Or use a different image path
  # set :http_path, "/Content/images/"
end
