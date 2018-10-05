activate :external_pipeline,
         name: :webpack,
         command: if build?
                    './node_modules/webpack/bin/webpack.js --bail -p'
                  else
                    './node_modules/webpack/bin/webpack.js --watch -d --color'
                  end,
         source: 'build',
         latency: 1

activate :breadcrumbs do
end

activate :blog do |blog|
  blog.prefix = '/posts'
  blog.permalink = ':title.html'
  blog.sources = ':year-:month-:day-:title.html'
  blog.layout = 'post'
  blog.summary_generator = proc { |post| post.data.description }
  blog.paginate = true
  blog.taglink = 'tag/{tag}.html'
  blog.tag_template = 'posts/tag.html'
  blog.calendar_template = "posts/calendar.html"
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
page '/posts/calendar.html', layout: :blog
page '/posts/author/template.html', layout: :author
page '/jobs', layout: :job
page '/newsletter-signup'
page '/feed.xml', layout: false


data.authors.collect {|author| author.keys.first }.each do |author_slug|
  proxy "/posts/author/#{author_slug.gsub(/\s/,'-').downcase}/index.html",
    '/posts/author/template.html',
        locals: { author_slug: author_slug },
        ignore: true
end
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

# Methods defined in the helpers block are available in templates

helpers do
  def author_path(author)
    @name = author.keys.first.gsub(/\s/,'-').downcase
    "/posts/author/#{@name}/"
  end
end

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
  config[:host] = 'http://localhost:4567'
end


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
  config[:host] = 'https://cultivatehq.com'
end

activate :syntax, line_numbers: false

# The below will override .html on blog posts as well!!
activate :directory_indexes

# Activate the alias(redirect) plugin
activate :alias
