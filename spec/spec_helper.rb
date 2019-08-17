# run test
# rspec -Iplugins/custom_tables/spec  plugins/glad_custom_tables/spec

ENV['RAILS_ENV'] ||= 'test'

#load simplecov
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails' do
    coverage_dir 'tmp/coverage'
###    require "pry"

#exclude core dirs coverage
    add_filter do |file|
      file.filename.include?('/lib/plugins/') ||
          !file.filename.include?('/plugins/')
    end
  end
end

#load rails/redmine
require File.expand_path('../../../../config/environment', __FILE__)

#test gems
require 'rspec/rails'
# require 'rspec/autorun'
require 'rspec/mocks'
require 'rspec/mocks/standalone'
require 'factory_bot'
require 'capybara/rspec'

# use phantom.js as js driver
require 'capybara/poltergeist'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
# Dir.glob(File.expand_path('./factories/*.rb', __FILE__)).each do |plugin_factory|
#   require plugin_factory
# end

require_relative 'factories/factories'
require_relative 'support/user'

# FactoryBot.definition_file_paths << File.expand_path('./factories', __FILE__)
# FactoryBot.find_definitions

module AssertSelectRoot
  def document_root_element
    html_document.root
  end
end

#rspec base config
RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.default_path = 'plugins/custom_tables/spec'
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.include AssertSelectRoot, :type => :request

  config.before(:each) do |ex|
    meta = ex.metadata
    unless meta[:null]

      allow( User ).to receive(:current).and_return case meta[:logged]
                                                    when :admin
                                                      FactoryBot.create(:admin_user, :language => 'en')
                                                    when true
                                                      FactoryBot.create(:user, :language => 'en')
                                                    else
                                                      User.anonymous
                                                    end
    end
  end

end