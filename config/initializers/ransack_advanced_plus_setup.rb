Rails.application.config.i18n.fallbacks = [:en]

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'ransack_saved_search', 'ransack_saved_searches'
end