module RansackAdvancedPlus
  class Service

    attr_accessor :klass, :ransack_object, :form

    def initialize(model)
      @model_name = model
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
        builder_grouping(group_index)
      elsif type=='value'
        builder_condition(group_index, condition_index)
      else
        @form
      end
    end

    #REQUIRE CALL build_form_context BEFORE USE THIS
    def builder_grouping(group_index=0)
      if @form.grouping_fields.present?
        @form.grouping_fields
      else
        @form.send("grouping_fields", @form.object.send("build_grouping"), child_index: group_index){|g| @g=g}
        @g
      end
    end

    #REQUIRE CALL build_form_context BEFORE USE THIS
    def builder_condition(group_index=0, condition_index=0)
      if @form.condition_fields.present?
        @form.condition_fields
      else
        @form.send("grouping_fields", @form.object.send("build_grouping"), child_index: group_index){|g| @g=g}
        @g.send("condition_fields", @g.object.send("build_condition"), child_index: condition_index){|c| @c=c}
        @c
      end
    end

    def attributes(attribute=nil)
      bases = [''] + @klass.ransackable_associations
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

    def attribute_type(attribute)
      if attribute_is_collection?(attribute)
        :collection
      else
        attributes(attribute).values.first
      end
    end

    def attribute_operators(attribute)
      operators_by_type(attribute_type(attribute))
    end

    def association_klass_from_attribute(attribute)
      klass = nil
      attribute_name = nil
      @klass.ransackable_associations.each do |association|
        if attribute =~ /^#{association}_/
          klass = association.classify.constantize
          attribute_name = attribute.gsub("#{association}_",'')
        end
      end
      return klass, attribute_name
    end

    def attribute_is_collection?(attribute)
      association_klass, attribute_name = association_klass_from_attribute(attribute)
      (association_klass && association_klass.respond_to?("#{attribute_name}_collection"))
    end

    def operators_by_type(type)
      case type.to_sym
        when :string
          [:eq, :not_eq, :matches, :does_not_match]
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

    def filter_associations(associations_by_user=nil)
      if associations_by_user.present?
        if associations_by_user.is_a?(Hash)
          associations_by_user.keys.reject{|m| @model_name==m}
        else
          associations_by_user
        end
      else
        @klass.ransackable_associations
      end
    end

    def filter_attributes(associations_by_user=nil)
      attributes = []
      if associations_by_user.present?
        associations_by_user.map do |m, attrs|
          attrs.map do |a|
            attributes << {"#{m.to_s}_#{(a.is_a?(Hash) ? a.keys.first : a)}" => (a.is_a?(Hash) ? a.values.first : nil)}
          end
        end
      end
      attributes.flatten.inject(:merge)
    end
  end






end
