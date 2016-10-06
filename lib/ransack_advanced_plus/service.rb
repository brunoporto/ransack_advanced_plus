module RansackAdvancedPlus
  class Service

    attr_accessor :klass, :ransack_object, :form

    def initialize(model)
      @klass = model.classify.constantize
      @ransack_object = @klass.send :ransack
      @form = nil
      @view_context
    end

    def build_form_context(view_context)
      @view_context = view_context
      @view_context.search_form_for(@ransack_object){|frm| @form = frm}
    end

    #REQUIRE CALL build_form_context BEFORE USE THIS
    def builder_by_type(type, group_index=0, condition_index=0)
      if type=='condition'
        builder_condition(group_index)
      elsif type=='value'
        builder_value(group_index, condition_index)
      else
        @form
      end
    end

    #REQUIRE CALL build_form_context BEFORE USE THIS
    def builder_condition(group_index=0)
      if @form.grouping_fields.present?
        @form.grouping_fields
      else
        @form.send("grouping_fields", @form.object.send("build_grouping"), child_index: group_index){|g| @g=g}
        @g
      end
    end

    #REQUIRE CALL build_form_context BEFORE USE THIS
    def builder_value(group_index=0, condition_index=0)
      if @form.condition_fields.present?
        @form.condition_fields
      else
        @form.send("grouping_fields", @form.object.send("build_grouping"), child_index: group_index){|g| @g=g}
        @g.send("condition_fields", @g.object.send("build_condition"), child_index: condition_index){|c| @c=c}
        @c
      end
    end

    def build_fields
      builder.send("#{type}_fields", builder.object.send("build_#{type}"), child_index: new_id) do |ff|

      end
    end

    def attributes(attribute=nil)
      bases = [''] + @ransack_object.klass.ransackable_associations
      fields_type = Hash.new
      bases.each do |model|
        model_name = model.present? ? "#{model}_" : ""
        @ransack_object.context.traverse(model).columns_hash.each do |field, attributes|
          attr_name = "#{model_name}#{field}"
          next if attribute.present? && attr_name!=attribute.to_s
          fields_type[attr_name] = attributes.type
        end
      end
      fields_type
    end

    def attribute_operators(attribute)
      attr = self.attributes(attribute)
      operators_by_type(attr.values.first)
    end

    def operators_by_type(type)
      case type.to_sym
        when :string
          [:eq, :not_eq, :cont, :matches, :does_not_match]
        when :integer, :float
          [:eq, :not_eq, :lt, :lteq, :gt, :gteq, :in, :not_in]
        when :date, :time, :datetime
          [:eq, :not_eq, :lt, :lteq, :gt, :gteq]
        when :boolean
          [:eq, :not_eq]
        else
          [:eq, :not_eq]
      end
    end

  end
end
