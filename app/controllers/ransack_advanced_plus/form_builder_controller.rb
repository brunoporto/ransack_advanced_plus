module RansackAdvancedPlus
  class FormBuilderController < ApplicationController

    def index
      rap_service = RansackAdvancedPlus::Service.new(params[:model])
      rap_service.build_form_context(view_context)
      type = params[:type] || 'grouping'
      builder = rap_service.builder_by_type(type, params[:group_index], params[:condition_index])
      html = nil
      builder.send("#{type}_fields", builder.object.send("build_#{type}"), child_index: DateTime.now.strftime('%s')) do |ff|
        @rap_model_name = params[:model]
        @rap_associations_names = params[:associations_models].present? ? params[:associations_models].split(',') : rap_service.klass.ransackable_associations
        @rap_operators = {default: 'eq'}
        locals_params = {frm: ff}
        locals_params.merge!({frm_condition: builder}) if type=='value'
        html = render_to_string(partial: 'ransack_advanced_plus/' + type.to_s + "_fields", locals: locals_params)
      end
      render html: html
    end

    def operators
      rap_service = RansackAdvancedPlus::Service.new(params[:model])
      rap_service.build_form_context(view_context)
      operators = rap_service.attribute_operators(params[:attribute])
      @rap_operators = {only: operators}
      @f = rap_service.builder_condition
      render html: render_to_string(partial: 'ransack_advanced_plus/predicates', locals: {frm: @f})
    end

    def values
      rap_service = RansackAdvancedPlus::Service.new(params[:model])
      rap_service.build_form_context(view_context)
      @rap_operador = params[:operator]
      builder = rap_service.builder_condition(params[:group_index], params[:condition_index])
      values = params[:values].present? ? params[:values].split(',') : ['']
      attribute_type = params[:type].present? ? params[:type] : rap_service.attribute_type(params[:attribute])
      html = []
      values.each do |v|
        builder.value_fields(builder.object.build_value(v), child_index: DateTime.now.strftime('%s')) do |ff|
          html << render_to_string(partial: 'ransack_advanced_plus/value_fields', locals: {frm: ff, frm_condition: builder, attribute_type: attribute_type})
        end
      end
      render html: html.join.html_safe
    end

  end
end