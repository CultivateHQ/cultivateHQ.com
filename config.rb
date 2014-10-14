activate :blog do |blog|
  blog.prefix = "/posts"
  blog.permalink = ":title.html"
  blog.sources = ":year-:month-:day-:title.html"
  blog.layout = "post"
  blog.summary_generator = Proc.new {|post| post.data.description }
  #blog.tag_template = "tag.html"
  #blog.calendar_template = "calendar.html"
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
  # Optional Settings
  deploy.remote   = 'git@github.com:CultivateHQ/cultivatehq.github.io.git'
  deploy.branch   = 'master'
  # deploy.strategy = :submodule      # commit strategy: can be :force_push or :submodule, default: :force_push
  # deploy.commit_message = 'custom-message'      # commit message (can be empty), default: Automated commit at `timestamp` by middleman-deploy `version`
end

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
page "index.html", :layout => :home
page "/posts/index.html", :layout => :post
page "/key_place.html", :layout => :product
page "/newsletter-signup"
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

after_configuration do
  # Ensure bower is run before building
  puts "** Running bower install"
  unless system('bower install')
    puts "*** ERROR running bower install ***"
    exit(1)
  end

  # Add bower's directory to sprockets asset path
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  sprockets.append_path File.join "#{root}", @bower_config["directory"]
end

set :images_dir, 'images'

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end


activate :syntax, :line_numbers => false

# The below will override .html on blog posts as well!!
activate :directory_indexes
