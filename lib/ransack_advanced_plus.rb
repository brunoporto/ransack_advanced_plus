require 'rails'
require 'ransack'

require 'ransack_advanced_plus/engine'
require 'ransack_advanced_plus/version'
require 'ransack_advanced_plus/service'
require 'ransack_advanced_plus/helpers/configuration'

module RansackAdvancedPlus
  extend Configuration

  define_setting :enable_saved_searches, false
end
