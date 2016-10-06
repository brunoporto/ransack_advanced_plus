
function filter_attributes_to_show(element) {
    var $form = $(element).closest('form[data-rap-attributes]');
    var attributes_to_show = $form.attr('data-rap-attributes').split(',');
    var object_name = $form.attr('data-rap-object');
    $('select.ransack-attribute-select option').each(function(i,o) {
        if ($.inArray($(o).val(), attributes_to_show) === -1 && $.inArray(object_name+"_"+$(o).val(), attributes_to_show) === -1) {
            var $parent = $(o).parent();
            if ($parent.prop("tagName")=='OPTGROUP' && $parent.children().length==1) {
                $(o).parent().remove();
            } else {
                $(o).remove();
            }
        }
    });
}


$(document).on('click','.ransack_advanced_plus_add_button',function(ev){
    ev.preventDefault();

    var $el = $(this);
    var model_name = $el.attr('data-model-name');
    var model_type = $el.attr('data-model-type');
    var group_index = $el.attr('data-group-index');
    var condition_index = $el.attr('data-condition-index');
    var associations = $el.closest('form').attr('data-rap-associations');
    var attributes = $el.closest('form').attr('data-rap-attributes');

    $.ajax({
        url: '/ransack_advanced_plus/form_builder/'+model_name,
        data: {type: model_type, group_index: group_index, condition_index: condition_index, attributes: attributes, associations: associations},
        method: 'get',
        success: function(data){
            $el.before(data);
            filter_attributes_to_show($el);
        },
        error: function(error){

        }
    });

});



$(document).on('click','.ransack_advanced_plus_remove_button',function(ev){
    ev.preventDefault();

    var $el = $(this);
    $el.closest('.fields').remove()

});

// $(document).ready(function(){
//
//     $('select.ransack-attribute-select').each(function(e) {
//         fieldName = $(this).find('option:selected')[0].value;
//         search.changeValueInputsType(this, fieldName, search);
//     });
//
// });
//
// $(document).on("click", "i.add_fields", function() {
//     search.add_fields(this, $(this).data('fieldType'), $(this).data('content'));
//     if($(this).hasClass('ransack-add-attribute')) {
//         fieldName = $(this).parents('.ransack-condition-field').find('select.ransack-attribute-select').find('option:selected')[0].value;
//         search.changeValueInputsType(this, fieldName, search);
//     }
//     return false;
// });
// $(document).on('change', 'select.ransack-attribute-select', function(e) {
//     fieldName = $(this).find('option:selected')[0].value;
//     search.changeValueInputsType(this, fieldName, search);
// });
// $(document).on("click", "i.remove_fields", function() {
//     search.remove_fields(this);
//     return false;
// });
// $(document).on("click", "button.nest_fields", function() {
//     search.nest_fields(this, $(this).data('fieldType'));
//     return false;
// });
//
//
//
// (function() {
//   this.Search = (function() {
//     function Search(templates) {
//       this.templates = templates != null ? templates : {};
//     }
//
//     Search.prototype.remove_fields = function(button) {
//       return $(button).closest('.fields').remove();
//     };
//
//     Search.prototype.add_fields = function(button, type, content) {
//       var new_id, regexp;
//       new_id = new Date().getTime();
//       regexp = new RegExp('new_' + type, 'g');
//       return $(button).before(content.replace(regexp, new_id));
//     };
//
//     Search.prototype.nest_fields = function(button, type) {
//       var id_regexp, new_id, object_name, sanitized_object_name, template;
//       new_id = new Date().getTime();
//       id_regexp = new RegExp('new_' + type, 'g');
//       template = this.templates[type];
//       object_name = $(button).closest('.fields').attr('data-object-name');
//       sanitized_object_name = object_name.replace(/\]\[|[^-a-zA-Z0-9:.]/g, '_').replace(/_$/, '');
//       template = template.replace(/new_object_name\[/g, object_name + "[");
//       template = template.replace(/new_object_name_/, sanitized_object_name + '_');
//       return $(button).before(template.replace(id_regexp, new_id));
//     };
//
//     Search.prototype.convertFieldType = function (fieldType) {
//       var fieldTypeToHtmlType = {
//         'default': 'text',
//         'integer': 'number',
//         'date' : 'date',
//         'datetime' : 'date'
//       };
//       return (fieldTypeToHtmlType[fieldType] || fieldTypeToHtmlType['default']);
//     };
//
//     Search.prototype.changeValueInputsType = function(element, fieldName, search) {
//       fieldType = search.fieldsType[fieldName];
//       conditionValueInputs = $(element).parents('.ransack-condition-field').find('.ransack-attribute-value');
//       conditionValueInputs.attr('type', search.convertFieldType(fieldType));
//     };
//
//     return Search;
//
//   })();
//
// }).call(this);
