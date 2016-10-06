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
      html
      render html: html
    end

    def operators
      rap_service = RansackAdvancedPlus::Service.new(params[:model])
      operators = rap_service.attribute_operators(params[:attribute])
      @rap_operators = {only: operators}
      rap_service.build_form_context(view_context)
      @f = rap_service.builder_value
      html_operators = render_to_string(partial: 'ransack_advanced_plus/predicates', locals: {frm: @f})
      render html: html_operators
    end

  end
end