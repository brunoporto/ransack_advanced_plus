module RansackAdvancedPlus
  class FormBuilderController < ApplicationController

    def index
      rap_service = RansackAdvancedPlus::Service.new(params[:model])
      @rap_model_name = params[:model]
      @rap_associations = params[:associations].present? ? params[:associations].split(',') : rap_service.klass.ransackable_associations
      @rap_operators = {}
      render html: rap_service.build_form_html(self)
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