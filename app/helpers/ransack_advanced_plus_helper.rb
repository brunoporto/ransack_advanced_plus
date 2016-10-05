module RansackAdvancedPlusHelper

  def ransack_advanced_plus_form(object, url, *args)

    arguments = args.inject(:merge)
    associations = arguments[:conditions].present? ? arguments[:conditions].keys : nil

    @ransack_object = object
    @ransack_object.build_grouping unless @ransack_object.groupings.any?
    @rap_model_name = @ransack_object.context.klass.name.tableize
    @rap_associations = associations || @ransack_object.klass.ransackable_associations

    render partial: 'ransack_advanced_plus/advanced_search', locals: {search_url: url, redirect_path: url}
  end

  # def setup_search_form(builder, search_object)
  #   fields = builder.grouping_fields builder.object.new_grouping,
  #     object_name: 'new_object_name', child_index: "new_grouping" do |f|
  #     render('ransack_advanced_plus/grouping_fields', f: f)
  #   end
  #   %Q{
  #     var search = new Search({grouping: "#{escape_javascript(fields)}"});
  #     search.fieldsType = #{get_fields_data_type(search_object).to_json.html_safe}
  #   }
  # end
  #
  # def get_fields_data_type(search)
  #   bases = [''] + search.klass.ransackable_associations
  #   fields_type = Hash.new
  #   bases.each do |model|
  #     model_name = model.present? ? "#{model}_" : ""
  #     search.context.traverse(model).columns_hash.each do |field, attributes|
  #       fields_type["#{model_name}#{field}"] = attributes.type
  #     end
  #   end
  #   fields_type
  # end
  #
  # def button_to_remove_fields
  #   content_tag :i, nil, class: 'remove_fields glyphicon glyphicon-minus-sign text-danger'
  # end
  #
  # def button_to_add_fields(name, f, type, custom_class='')
  #   new_object = f.object.send "build_#{type}"
  #   fields = f.send("#{type}_fields", new_object, child_index: "new_#{type}") do |builder|
  #     render('ransack_advanced_plus/' + type.to_s + "_fields", f: builder)
  #   end
  #   content_tag :i, name, :class => custom_class + ' add_fields glyphicon glyphicon-plus-sign text-success', :type => 'button', 'data-field-type' => type, 'data-content' => "#{fields}"
  # end
  #
  # def button_to_nest_fields(name, type)
  #   content_tag :button, name, :class => 'nest_fields', 'data-field-type' => type
  # end
end
