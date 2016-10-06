module RansackAdvancedPlus
  class FormBuilderController < ApplicationController

    def index
      rap_service = RansackAdvancedPlus::Service.new(params[:model])
      new_id = DateTime.now.strftime('%s')
      type = params[:type] || 'grouping'
      rap_service.build_form_context(view_context)
      builder = rap_service.builder_by_type(type, params[:group_index], params[:condition_index])
      html = nil
      builder.send("#{type}_fields", builder.object.send("build_#{type}"), child_index: new_id) do |ff|
        @rap_model_name = params[:model]
        @rap_associations = params[:associations].present? ? params[:associations].split(',') : rap_service.klass.ransackable_associations
        @rap_operators = {default: 'eq'}
        locals_params = {frm: ff}
        locals_params.merge!({frm_condition: builder}) if type=='value'
        html = render_to_string(partial: 'ransack_advanced_plus/' + type.to_s + "_fields", locals: locals_params)
      end
      render html: html
    end

    def operators
      rap_service = RansackAdvancedPlus::Service.new(params[:model])
      operators = rap_service.attribute_operators(params[:attribute])
      @rap_operators = {only: operators}
      rap_service.build_form_context(view_context)
      @f = rap_service.builder_condition
      render html: render_to_string(partial: 'ransack_advanced_plus/predicates', locals: {frm: @f})
    end

    def values
      rap_service = RansackAdvancedPlus::Service.new(params[:model])
      @rap_operators = {only: [params[:operator]]}
      rap_service.build_form_context(view_context)
      builder = rap_service.builder_condition(params[:group_index], params[:condition_index])
      html = nil
      builder.send("value_fields", builder.object.send("build_value"), child_index: DateTime.now.strftime('%s')) do |ff|
        html = render_to_string(partial: 'ransack_advanced_plus/value_fields', locals: {frm: ff, frm_condition: builder})
      end
      render html: html
    end

  end
end