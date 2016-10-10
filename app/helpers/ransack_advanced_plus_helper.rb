module RansackAdvancedPlusHelper

  def ransack_advanced_plus_form(object, url, *args)
    arguments = args.inject(:merge)
    @ransack_object = object
    @ransack_object.build_grouping unless @ransack_object.groupings.any?
    @rap_model_name = @ransack_object.context.klass.name.tableize.singularize
    rap_service = RansackAdvancedPlus::Service.new(@rap_model_name)
    if arguments.present?
      associations = arguments[:associations]
    else
      associations = nil
    end
    @rap_operators = {default: :eq}
    @rap_associations = rap_service.build_associations(associations)
    @rap_associations_names = @rap_associations.keys
    render partial: 'ransack_advanced_plus/advanced_search', locals: {search_url: url, redirect_path: url}
  end

end