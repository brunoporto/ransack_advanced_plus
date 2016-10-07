var localCache = {
    data: {},
    remove: function (url) {
        delete localCache.data[url];
    },
    exist: function (url) {
        return localCache.data.hasOwnProperty(url) && localCache.data[url] !== null;
    },
    get: function (url) {
        console.log('Getting in cache for url' + url);
        return localCache.data[url];
    },
    set: function (url, cachedData, callback) {
        localCache.remove(url);
        localCache.data[url] = cachedData;
        if ($.isFunction(callback)) callback(cachedData);
    }
};

function getModels(){
    return Object.keys(document.rap_associations_dictionary);
}
function getModelsNames() {
    return getModels().join();
}
function getAttributes() {
    var attributes = [];
    $.each(document.rap_associations_dictionary, function(i,m){
        $.each(m, function(ii,o) {
            attributes.push(o);
        });
    });
    return attributes;
}
function getAttributesNames() {
    var attributes = getAttributes();
    //Flatten
    if (attributes.length > 0) {
        attributes = $.map(attributes, function(n){ return Object.keys(n); });
    }
    return attributes;
}

function getAttribute(model_name, attribute_name) {
    var attribute = {};
    $.each(getAttributes(), function(ii,o) {
        var tmp_attribute = o[model_name+'_'+attribute_name] || o[attribute_name];
        if (tmp_attribute != undefined) {
            attribute = tmp_attribute;
        }
    });
    return attribute;
}

function isUrl(s) {
    var regexp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
    return regexp.test(s);
}

function resolveValuesToArray(values) {
    return new Promise(function(resolve, reject) {
        try {
            if (values == undefined || values == null) {
                values = ''
            }
            if (isUrl(values)) {
                //VERIFICA SE É URL (CARREGAR AJAX)
                $.ajax({
                    url: values,
                    dataType: 'json',
                    success: function (_values) {
                        console.log(_values);
                        if (typeof _values == 'array' || typeof _values == 'object') {
                            resolveValuesToArray(_values).then(function (__values) {
                                resolve(__values);
                            });
                        } else {
                            reject(__values);
                        }
                    },
                    error: function (error) {
                        reject(error);
                    }
                });
            } else if (values[0] != undefined && values[0][0] != undefined) {
                resolve(values);
            } else {
                resolve([[values, values]]);
            }
        } catch(error) {
            reject(error);
        }
    });
}

function setValuesElements(values, elements) {
    $(elements).each(function(i,el){
        var $el = $(el);
        var current_value = $el.val();
        if ($el.prop("tagName")=='SELECT') {
            $el.find('option[value!=""]').remove();
        } else {
            $el.val('');
        }
        resolveValuesToArray(values).then(function(_values){
            $.each(_values, function(i, v){
                if ($el.prop("tagName")=='SELECT' && _values.length>0) {
                    $el.append($('<option value="'+v[1]+'">'+v[0]+'</option>'));
                    if (current_value!='') {$el.val(current_value);}
                } else {
                    if (current_value=='') {
                        $el.val(v[0]);
                    } else {
                        $el.val(current_value);
                    }
                }
            });
        })
    });
}

function loadAttributes(element, cb) {
    var $el = $(element);
    var $form = getFormElement($el);
    var model_name = $form.attr('data-rap-model');
    var associations = getModelsNames();
    var $conditionFields = getConditionFields(element);
    var $groupingFields = getGroupingFields(element);
    var group_index = $groupingFields.attr('data-rap-group-index');
    var condition_index = $conditionFields.attr('data-rap-condition-index');
    var model_type = $el.attr('data-rap-type');
    var url = build_url('/ransack_advanced_plus/form_builder/'+model_name, {type: model_type, group_index: group_index, condition_index: condition_index, associations_models: associations});
    $.ajax({
        url: url,
        method: 'get',
        cache: true,
        beforeSend: function () {
            // TODO: Usar o cache para os campos não está atualizando o ID, verificar possibilidade de atualização do ID via javascript
            // if (localCache.exist(url)) {
            //     $el.before(localCache.get(url));
            //     return false;
            // }
            // return true;
        },
        success: function(data){
            $el.before(data);
            // localCache.set(url, data);
            if (typeof cb === "function") { cb(data); }
        },
        error: function(error){},
        complete: function (jqXHR, textStatus) {
            if (model_type=='condition') {
                filterAttributes($el);
            }
        }
    });
}

function loadPredicates(element, cb) {
    var $el = $(element);
    var $form = getFormElement($el);
    var model_name = $form.attr('data-rap-model');
    var attribute = $el.val();
    var $predicateEl = getPredicateElement(element);
    var current_value = $predicateEl.val();
    if (attribute != undefined && attribute != '') {
        var url = build_url('/ransack_advanced_plus/operators/' + model_name + '/' + attribute);
        $.ajax({
            url: url,
            method: 'get',
            cache: true,
            beforeSend: function () {
                if (localCache.exist(url)) {
                    $predicateEl.html($(localCache.get(url)).html()).val(current_value);
                    $predicateEl.trigger('change');
                    return false;
                }
                return true;
            },
            success: function (data) {
                $predicateEl.html($(data).html()).val(current_value);
                localCache.set(url, data);
                $predicateEl.trigger('change');
                if (typeof cb === "function") { cb(data); }
            },
            error: function (error) {},
            complete: function (jqXHR, textStatus) {}
        });
    } else {
        $predicateEl.html('<option value=""></option>');
    }
}

function loadValues(element, cb) {
    var $el = $(element);
    var $form = getFormElement($el);
    var model_name = $form.attr('data-rap-model');
    var $predicateEl = getPredicateElement(element);
    var $conditionFields = getConditionFields(element);
    var group_index = $conditionFields.attr('data-rap-group-index');
    var condition_index = $conditionFields.attr('data-rap-condition-index');
    var $attributeElement = getAttributeElement(element);
    var $valueElement = getValueElement(element);
    var $valueFields = getValueFields(element);
    var attribute_name = $attributeElement.val();
    var operator = $predicateEl.val();
    var attribute = getAttribute(model_name, attribute_name);
    var values = $valueElement.map(function(){return $(this).val();}).get().join();
    var url = build_url('/ransack_advanced_plus/values/'+model_name+'/'+attribute_name+'/'+operator, {group_index: group_index, condition_index: condition_index, values: values, type: attribute['type']});
    $.ajax({
        url: url,
        method: 'get',
        cache: true,
        beforeSend: function () {
            if (localCache.exist(url)) {
                $valueFields.find('.fields_content').html(localCache.get(url));
                setValuesElements(attribute['default'], $valueFields.find('.ransack-value-select'));
                return false;
            }
            return true;
        },
        success: function(data){
            $valueFields.find('.fields_content').html(data);
            setValuesElements(attribute['default'], $valueFields.find('.ransack-value-select'));
            localCache.set(url, data);
            if (typeof cb === "function") { cb(data); }
        },
        error: function(error){},
        complete: function (jqXHR, textStatus) {}
    });
}

function removeAttributes(element) {
    $(element).closest('.fields').remove()
}

function build_url(url, params) {
    if (params!=undefined) {
        url += "?"+$.param(params);
    }
    return url;
}

function filterAttributes(element) {
    var $form = getFormElement(element);
    var attributes_to_show = getAttributesNames();
    var model_name = $form.attr('data-rap-model');
    $('select.ransack-attribute-select option').each(function(i,o) {
        if (attributes_to_show.length > 0 && $(o).val()!="" && $.inArray($(o).val(), attributes_to_show) === -1 && $.inArray(model_name+"_"+$(o).val(), attributes_to_show) === -1) {
            var $parent = $(o).parent();
            if ($parent.prop("tagName")=='OPTGROUP' && $parent.children().length==1) {
                $(o).parent().remove();
            } else {
                $(o).remove();
            }
        }
    });
}

function getFormElement(element) {
    return $(element).closest('.ransack-form');
}

function getGroupingFields(element) {
    return $(element).closest('.ransack-grouping-fields');
}

function getConditionFields(element) {
    return $(element).closest('.ransack-condition-fields');
}

function getValueFields(element) {
    return getConditionFields(element).find('.ransack-value-fields');
}

function getAttributeElement(element) {
    return getConditionFields(element).find('.ransack-attribute-select');
}

function getPredicateElement(element) {
    return getConditionFields(element).find('.ransack-predicate-select');
}

function getValueElement(element) {
    return getConditionFields(element).find('.ransack-value-select');
}

$(document).on('change','.ransack-attribute-select', function(ev) {
    getConditionFields(this).find('.ransack-value-select').val('');
    loadPredicates(this);
});

$(document).on('change','.ransack-predicate-select', function(ev) {
    loadValues(this);
});

$(document).on('click','.ransack_advanced_plus_add_button',function(ev){
    ev.preventDefault();
    loadAttributes(this);
});

$(document).on('click','.ransack_advanced_plus_remove_button',function(ev){
    ev.preventDefault();
    removeAttributes(this);
});

$(document).ready(function(){
    $('.ransack-attribute-select').each(function(i,o){
        filterAttributes(o);
        loadPredicates(o);
    });

    //TESTE
    getAttributesNames();
});
