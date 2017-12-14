require "lib/webpack_asset_helpers"

page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false


activate :breadcrumbs do
end

activate :blog do |blog|
  blog.prefix = '/posts'
  blog.permalink = ':title.html'
  blog.sources = ':year-:month-:day-:title.html'
  blog.layout = 'post'
  blog.summary_generator = proc { |post| post.data.description }
  blog.paginate = true
  blog.tag_template = 'posts/tag.html'
  # blog.calendar_template = "calendar.html"
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.deploy_method = :git
  # Optional Settings
  deploy.remote   = 'git@github.com:CultivateHQ/cultivatehq.github.io.git'
  deploy.branch   = 'master'

  # commit strategy: can be :force_push or :submodule, default: :force_push
  #
  # deploy.strategy = :submodule

  # commit message (can be empty),
  # default: Automated commit at `timestamp` by middleman-deploy `version`
  #
  # deploy.commit_message = 'custom-message'
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
page 'index.html', layout: :home
page '/posts/index.html', layout: :blog
page '/posts/tag.html', layout: :blog
page '/newsletter-signup'
page '/feed.xml', layout: false

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

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

set :markdown_engine, :redcarpet
set :markdown, tables: true,
               autolink: true,
               gh_blockcode: true,
               fenced_code_blocks: true

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


activate :syntax, line_numbers: false

#Activate the alias(redirect) plugin
activate :alias

activate :directory_indexes

helpers WebpackAssetHelper
