require 'active_support/dependencies'
require 'custom_report/settings'

module CustomReport
  mattr_accessor :app_root
  mattr_accessor :layout
  mattr_accessor :includes
  mattr_accessor :before_filters
  mattr_accessor :admin_class

  def self.setup
    yield self
  end
end

require 'custom_report/engine'
