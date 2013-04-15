source 'http://rubygems.org'

gem 'rails'

gem 'activeadmin' # The main administrative interface.  Keep hardcoded until testing framework is in place.
gem 'activemessaging', :git => 'git://github.com/kookster/activemessaging.git'
gem 'ancestry' # Critical for hierarchical classes (i.e. Agency)
gem 'axlsx' # For creating Excel spreadsheets (only DL Manifest, NOT stats report).
gem 'browser' # Browser detection for request form HTML5 attributes
gem 'country-select'
gem 'daemons'
gem 'execjs' # Needed to resolve incompatability with Fedora 12+
gem 'exifr' # Extract information from TIFF images for creating ImageTechMeta
gem 'foreigner' # for creating foreign key constraints in the database
gem 'coveralls', require: false # testing coverage monitoring
gem 'hydraulics', :path => 'hydraulics' # Rails engine with base code for models
gem 'json'
gem 'nested_form', :git => 'git://github.com/ryanb/nested_form.git' # Used on request form
gem 'mysql2'
gem 'net-ldap' # 
gem 'nokogiri-pretty' # prettfying XML files (esp. MODS, but rarely TEI)
gem 'paper_trail' # To version our models
gem 'prawn' # creating PDF outputs (see Invoice class)
gem 'rest-client'
gem 'roadie' # for embedding CSS in request_form emails
gem 'rmagick', :require => false # for creating patron deliverables.  :require => false required to avoid loading this twice.  See http://stackoverflow.com/questions/3606190/rmagick-warning-while-running-server
gem 'rqrcode'
gem 'solr-ruby'
gem 'spreadsheet' # Still used for creating stats report, but NOT DL Manifest
gem 'sqlite3'
gem 'stomp'
gem "therubyracer", :require => 'v8' # Needed to resolve incompatability with Fedora 12+
gem 'tweet-button'
gem 'validates_timeliness'

group :development, :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'rspec-rails'
end

group :test do
  gem 'rspec-rails'
  gem "shoulda-matchers"
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'seed_dump', :git => 'git://github.com/zenprogrammer/seed_dump.git'
  gem 'travis-lint'
end

group :production do
  gem 'passenger'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'jquery-rails'
  gem 'jquery-ui-rails'
  gem 'sass-rails'
  gem 'uglifier'
end



