module RansackAdvancedPlusHelper

  def ransack_advanced_plus_form(object, url, *args)
    arguments = args.inject(:merge)
    @ransack_object = object
    @ransack_object.build_grouping unless @ransack_object.groupings.any?
    @rap_model_name = @ransack_object.context.klass.name.tableize.singularize
    rap_service = RansackAdvancedPlus::Service.new(@rap_model_name)
    if arguments.present?
      associations = arguments[:associations]
      @rap_values = arguments[:values]
    else
      associations = nil
      @rap_values = nil
    end
    @rap_associations = build_associations(associations)
    render partial: 'ransack_advanced_plus/advanced_search', locals: {search_url: url, redirect_path: url}
  end

  def build_associations(associations_by_user=nil)
    @klass = @ransack_object.context.klass
    associations_by_user = @klass.ransackable_associations unless associations_by_user.present?
    new_associations = []
    if associations_by_user.is_a?(Array)
      associations = [''] + associations_by_user
      associations.each do |model_name|
        new_associations << build_attributes_from_model(model_name)
      end
    elsif associations_by_user.is_a?(Hash)
      associations = associations_by_user.keys
      associations.each do |model_name|
        new_associations << build_attributes_from_model(model_name.to_s, associations_by_user[model_name.to_sym])
      end
    end
    new_associations.flatten.inject(:merge)
  end

  def build_attributes_from_model(model_name, default_attributes={})
    new_attributes = []
    ransack_model_name = model_name.to_s==@rap_model_name ? '' : model_name
    default_attributes = attribute_array_to_hash(default_attributes)
    @ransack_object.context.traverse(ransack_model_name).columns_hash.each do |field, attributes|
      next if default_attributes.present? && !default_attributes.key?(field.to_sym)
      default = default_attributes.present? ? default_attributes[field.to_sym] : attributes.default
      limit = attributes.cast_type.present? ? attributes.cast_type.limit : nil
      type = default.is_a?(Array) || default =~ URI::regexp ? 'collection' : attributes.type
      new_attributes << {"#{model_name}_#{field}" => {type: type, limit: limit, default: default}}
    end
    {"#{model_name}" => new_attributes}
  end

  def attribute_array_to_hash(attributes)
    attributes.reduce(Hash.new){|a, h| a.merge( h.is_a?(Hash) ? {h.keys.first.to_sym => h.values.first} : {h.to_sym => nil} ) }
  end

end