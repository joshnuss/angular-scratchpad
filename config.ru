# CREDIT: https://gist.github.com/stas/3344092
require 'bundler/setup'
require 'haml'
require 'sass'
require 'coffee_script'

# Do not buffer output
$stdout.sync = true
# Get working dir, fixes issues when rackup is called outside app's dir
root_path = Dir.pwd

use Rack::Static,
  :urls => ['/stylesheets', '/images', '/javascripts', '/fonts'],
  :root => root_path

run lambda { |env|
  request = Rack::Request.new(env)

  path = request.path_info[1..-1]
  path = 'index' if path.empty?

  page_html = File.expand_path(path + '.html', root_path)
  page_haml = File.expand_path(path + '.haml', root_path)

  page = 'Not Found.'
  code = 404

  if File.exist?( page_html )
    page = File.read(page_html)
    code = 200
  end

  if File.exist?( page_haml )
    template = File.read(page_haml)
    page = Haml::Engine.new(template).render()
    code = 200
  end

  [ code, {
    'Content-Type'  => 'text/html',
    'Cache-Control' => 'public, max-age=86400'
  },
  [page] ]
}
