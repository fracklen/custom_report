require 'active_support/dependencies'

module CustomReport

  mattr_accessor :app_root

  def self.setup
    yield self
  end
end

require 'custom_report/engine'
