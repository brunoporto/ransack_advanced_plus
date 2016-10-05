module RansackAdvancedPlus
  class FormBuilderController < ApplicationController
    def index
      type = params[:type] || 'grouping'
      klass = params[:model].classify.constantize
      @search = klass.send :ransack

      child_index = params[:child_index] || Time.now.to_i

      form = self.view_context.search_form_for(@search){|frm| @f = frm}
      if type=='condition'
        if @f.grouping_fields.present?
          @f = @f.grouping_fields
        else
          @f.send("grouping_fields", @f.object.send("build_grouping"), child_index: "new_grouping"){|g| @g=g}
          @f = @g
        end
      elsif type=='value'
        if @f.condition_fields.present?
          @f = @f.condition_fields
        else
          @f.send("condition_fields", @f.object.send("build_condition"), child_index: "new_condition"){|c| @c=c}
          @f = @c
        end
      end

      new_object = @f.object.send "build_#{type}"
      fields = @f.send("#{type}_fields", new_object, child_index: child_index) do |ff|
        @ff = ff
        render_to_string partial: 'ransack_advanced_plus/' + type.to_s + "_fields", locals: {frm: ff}
      end

      # raise @ff.inspect

      # bases = [''] + @search.klass.ransackable_associations
      # fields_type = Hash.new
      # bases.each do |model|
      #   model_name = model.present? ? "#{model}_" : ""
      #   @search.context.traverse(model).columns_hash.each do |field, attributes|
      #     fields_type["#{model_name}#{field}"] = attributes.type
      #   end
      # end
      # raise fields_type.inspect

      render html: fields
    end
  end
end