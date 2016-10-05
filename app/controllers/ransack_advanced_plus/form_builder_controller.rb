module RansackAdvancedPlus
  class FormBuilderController < ApplicationController
    def index
      type = params[:type] || 'grouping'
      klass = params[:model].classify.constantize
      associations = params[:associations].present? ? params[:associations].split(',') : nil

      @ransack_object = klass.send :ransack
      @rap_associations = associations || @ransack_object.klass.ransackable_associations
      @rap_model_name = @ransack_object.context.klass.name.tableize

      group_index = params[:group_index]
      condition_index = params[:condition_index]

      form = self.view_context.search_form_for(@ransack_object){|frm| @f = frm}
      if type=='condition'
        if @f.grouping_fields.present?
          @builder = @f.grouping_fields
        else
          @f.send("grouping_fields", @f.object.send("build_grouping"), child_index: group_index){|g| @g=g}
          @builder = @g
        end
      elsif type=='value'
        if @f.condition_fields.present?
          @builder = @f.condition_fields
        else
          @f.send("grouping_fields", @f.object.send("build_grouping"), child_index: group_index){|g| @g=g}
          @g.send("condition_fields", @g.object.send("build_condition"), child_index: condition_index){|c| @c=c}
          @builder = @c

        end
      else
        @builder = @f
      end

      new_id = DateTime.now.strftime('%s')
      fields = @builder.send("#{type}_fields", @builder.object.send("build_#{type}"), child_index: new_id) do |ff|
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