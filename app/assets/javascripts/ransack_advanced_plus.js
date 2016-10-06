var ransack_advanced_plus_ajax = [];
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

function loadAttributes(element) {
    var $el = $(element);
    var $form = getFormElement($el);
    var model_name = $form.attr('data-rap-model');
    var model_type = $el.attr('data-rap-type');
    var group_index = $el.attr('data-rap-group-index');
    var condition_index = $el.attr('data-rap-condition-index');
    var associations = $el.closest('form').attr('data-rap-associations');
    // var attributes = $el.closest('form').attr('data-rap-attributes');
    var url = build_url('/ransack_advanced_plus/form_builder/'+model_name, {type: model_type, group_index: group_index, condition_index: condition_index, associations: associations});
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
        },
        error: function(error){},
        complete: function (jqXHR, textStatus) {
            if (model_type=='condition') {
                filterAttributes($el);
            }
        }
    });
}

function loadPredicates(element) {
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
                    return false;
                }
                return true;
            },
            success: function (data) {
                $predicateEl.html($(data).html()).val(current_value);
                localCache.set(url, data);
            },
            error: function (error) {},
            complete: function (jqXHR, textStatus) {}
        });
    } else {
        $predicateEl.html('<option value=""></option>');
    }
}

function loadValues(element) {
    console.log('carregando valores');
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
    var attributes_to_show = $form.attr('data-rap-attributes').split(',').filter(Boolean);
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

function getPredicateElement(element) {
    return $(element).closest('.ransack-condition-fields').find('.ransack-predicate-select');
}

$(document).on('change','.ransack-attribute-select', function(ev) {
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