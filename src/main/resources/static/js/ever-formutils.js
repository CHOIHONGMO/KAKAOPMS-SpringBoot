/**
 * Object formUtil() Form 관련 Util을 제공 합니다.<br>
 * Form related Utilities
 * @constructor
 * @extends Object
 */
var formUtil = function () {
    {
    }
};

formUtil.customValid = function (component) {
    console.log('customValid start');
    if (component.componentIterator === undefined) {
        return;
    }
    component.componentIterator(function (comp) {
        var cmp = new formUtil.customValid.Component(comp);
        cmp.validate();
    }, true);
};

formUtil.customValid.Component = function (component) {
    this.component = component;
    this.componentId = component.getId();
    this.componentType = component.getCx();

    this.filter = function () {
        if (!(this.componentType === 'InputText' || this.componentType === 'Search'))
            return true;

        if (this.component.isReadOnly() === true || this.component.isDisabled() === true)
            return true;

        this.componentLabel = component.getLabel();
        for (var x in everValid.validationPostFix) {
            if (everValid.validationPostFix.hasOwnProperty(x)) {
                var subId = everValid.validationPostFix[x];
                if (everString.contains(this.componentId, subId)) {
                    this.subId = subId;
                    this.componentValue = this.component.getValue();
                    return false;
                }
            }
        }
        return true;
    };
};

formUtil.customValid.Component.prototype.validate = function () {
    if (this.filter() === true) return;
    if (this.componentValue === '') return;
    console.log('componentId: ' + this.componentId);
    console.log('componentType' + this.componentType);
    console.log('componentValue: ' + this.componentValue);
    console.log('componentLabel: ' + this.componentLabel);
    var componentLabel = this.componentLabel;

    if (everValid.regex[this.subId].test(this.componentValue) === false) {
        storeUtil.callStore('/everc/common/message/customValidationMessage.wu', {subId: this.subId}, null, function () {
                alert(everString.replaceAll(everString.format('[FORM][{0}] {1}', componentLabel, this.getResponseMessage()), '\\n', '\n'));
            }
        );
        formUtil.focusInvalidComponent(this.component);
        throw this.component;
    }
};

formUtil.trimRequiredValue = function (idArgs) {
    for (var x = 0, len = idArgs.length; x < len; x++) {
        var component = EVF.getComponent(idArgs[x]);

        if (component.componentIterator === undefined) {
            formUtil.trimRequiredValue.trim(component);
            continue;
        }

        component.componentIterator(function (comp) {
            formUtil.trimRequiredValue.trim(comp);
        }, true);
    }
};

formUtil.trimRequiredValue.trim = function (comp) {
    var componentType = comp.getCx();
    if ((componentType === 'InputText' || componentType === 'Search') && comp.isRequired() === true) {
        var originValue = comp.getValue();
        var trimmedValue = everString.lrTrim(originValue);
        comp.setValue(trimmedValue);

        if (originValue.length != trimmedValue.length) {
            console.log(comp.getId() + ' is trimmed');
        }
    }
};

/**
 * If data of required filed is null, then this function will be called by
 * everUX.
 *
 * @param {Object} -
 *            invalid.
 */
formUtil.validHandler = function (idArgs, msg) {
    formUtil.trimRequiredValue(idArgs);
    var invalids = null;
    for (var i = 0; i < idArgs.length; i++) {
        try {
            console.log('validating ' + idArgs[i] + ' ...');
            var component = EVF.getComponent(idArgs[i]);
            formUtil.customValid(component);
            //component.getBindingObject().getValueObject().mark();
            invalids = component.validate();
            console.log('validate result :' + idArgs[i]);
        } catch (e) {
            console.log('it\'s not valid item. ' + e);
            return false;
        }
        if (invalids != null) {
            formUtil.onEndValidate(invalids, msg);
            return false;
        } else {
            return true;
        }
    }
};

formUtil.onEndValidate = function (invalids, msg) {
    console.log('Starting formUtil.onEndValidate() ...');
    var invalidCmp = invalids[0].boundComponent;
    console.log('invalidated Component: ' + invalidCmp.getId());
    if (invalidCmp.label == '') {
        var invParentCmp = invalidCmp.getParent();
        if (invParentCmp.label != '') {
            console.log('Label found.');
            alert(everString.format('Please check [{0} : {1}]', invParentCmp.label, invalids[0].ruleName));
        } else {
            console.log('No label found.');
            alert(everString.format('Please check [{0}]', invalids[0].ruleName));
        }
    } else {
        alert(everString.format('Please check [{0} : {1}]', invalidCmp.label, invalids[0].ruleName));
    }

    formUtil.focusInvalidComponent(invalidCmp);
};

formUtil.focusInvalidComponent = function (invalidCmp) {
    switch (invalidCmp.getCx()) {
        case 'InputText':
            invalidCmp.focus();
            break;
        case 'InputNumber':
            invalidCmp.focus();
            break;
        case 'InputDate':
            invalidCmp.focus();
            break;
        case 'Select':
            invalidCmp.showList();
            break;
        case 'Search':
            invalidCmp.triggerEvent("onSearch");
            break;
        case 'TextArea':
            invalidCmp.focus();
            break;
    }
};

/**
 * If data of required filed is null, then this function will be called by everUX.
 * @param {Object} - invalid.
 */

/**
 * using onKeyDown Event on input Component
 * @param {Object}
 *            event value.
 */
formUtil.onFormKeyDown = function (e) {
    var ev = window.event || e;
    var key = ev.which ? ev.which : ev.keyCode;
    var userData = this.getUserData();
    var userFunctionCnt = 0;

    if (key == 13) {
        if (this.blur) {
            this.blur();
        }

        if (userData == null || userData == '') {
            doSearch();
        } else {
            var userArgs = userData.split(',');
            for (var i = 0; i < userArgs.length; i++) {
                if (typeof(window[userArgs[i]]) == 'function') {
                    window[userArgs[i]]();
                    userFunctionCnt++;
                }
            }
            if (userFunctionCnt == 0) {
                doSearch();
            }
        }
    }
};

/**
 * Combo Box 값이 바뀌었을 때, 지정한 Combo Box의 값을 Setting.<br>
 * change target combokey
 * @param param
 *        commonId 바뀌야 할 Combo Box의 commonId - [String]<br>
 *      tartget id
 * @param voName
 *        comboKey Data를 Setting 해야 할 Combo Box의 Key<br>
 *      target combo key value
 * @param returnFucLoc
 *        return Function Name (return Function이 필요없으면 null)
 * @param returnParam
 *        returnParam return Function에 전달 할 Parameter (return Function이 필요없으면 null)
 */
formUtil.setComboData = function (param, voName, returnFucLoc, returnParam) {

    var store = new EVF.data.Store();
    store.setProxy("/everc/common/commonCombo/getMultiComboValue.wu");
    store.setParameters(param);
    store.setValueObject(voName);
    store.setMask(false);
    store.load(function () {
        if (returnFucLoc != null) {
            window[returnFucLoc](returnParam);
        }
    });
};

/**
 * Form 전체 Component에 대한 Required를 Setting한다.<br>
 * set required on entire component in form
 * @param {Object}
 *            form
 * @param {Boolean}
 *            bool
 */
formUtil.setFormRequired = function (form, bool) {
    var fields = form.getFields();
    for (var i = 0; i < fields.length; i++) {
        fields[i].setRequired(bool);
    }
};

/**
 * Form 특정 Component에 대한 Required를 Setting한다.<br>
 * set Require to specific component in form
 * @param {Object}
 *            form
 * @param val
 * @param fieldIds
 */
formUtil.setComponentsRequired = function (fieldIds, val) {
    for (var i = 0; i < fieldIds.length; i++) {
        EVF.C(fieldIds[i]).setRequired(val);
    }
};

/**
 * Multi-Search Condition 필수 function. <, <=, >, >= 과 같은 조회조건시 글자를 입력하면 return. Param is null.<br>
 * empty hidden field
 */
//formUtil.cleanSearchTerms = function() {
//
//	if ($C(this.getId()).getValue() == "B" || $C(this.getId()).getValue() == "BE" || $C(this.getId()).getValue() == "S"
//			|| $C(this.getId()).getValue() == "SE") {
//		var formVal = $C(this.getId().replace("st_", "")).getValue();
//		for ( var i = 0; i < formVal.length; i++) {
//			if (!everString.isNumber(formVal)) {
//				if ("${ses.langCode}" == "KO") {
//					alert("숫자만 입력할 수 있습니다.");
//					$C(this.getId().replace("st_", "")).setValue('');
//					return;
//				} else {
//					alert("You must only enter Numbers.");
//					$C(this.getId().replace("st_", "")).setValue('');
//					return;
//				}
//			}
//		}
//	} else if ($C(this.getId()).getValue() == "IN" || $C(this.getId()).getValue() == "INN") {
//		$C(this.getId().replace("st_", "")).setValue('');
//	} else if ($C(this.getId()).getValue() == "") {
//		$C(this.getId().replace("st_", "")).setValue('');
//	}
//};

/**
 * Multi-Search Condition 사용시 Search Field에서 Popup을 띄우면 Hidden Field의 기존 값을 지운다.<br>
 * make empty hidden column when call popup
 * @param {Object}
 *            comp
 * @param {String}
 *            val Hidden Field의 component name.
 */
formUtil.cleanSearchHiddenField = function () {

    var userData = this.getUserData();

    if (userData != null || userData != '') {
        var userArgs = userData.split(',');
        for (var i = 0; i < userArgs.length; i++) {
            if (EVF.hasComponent(userArgs[i])) {
                EVF.getComponent(userArgs[i]).setValue('');
            }
        }
    }
    console.log('formUtil.cleanSearchHiddenField executed!');
};

/**
 * Search Field 사용시 Hidden Field에도 Multi-Search Condition를 사용하기 위한 Script.<br>
 * @param {String}
 *            val Hidden Field의 component name.
 */
formUtil.setSearchHiddenField = function () {
    //EVF.getComponent(this.getUserData()).setValue(EVF.getComponent(this.getId()).getValue());
};

formUtil.clearValue = function () {
    //EVF.getComponent(this.getUserData()).setValue('');
};

/**
 * Get UX Component's Value<br>
 *
 * @param {String}
 *            comp    component name
 */
formUtil.getUxValue = function (componentName) {
    return null; //EVF.getComponent(componentName).getValue();
};

/**
 * Get specified component(s) values as JSON.
 * @param componentName
 * @returns JSON
 */
formUtil.getValueAsJson = function (componentName) {
    var resultJson = {};
    if (componentName instanceof Array) {
        for (var x = 0; x < componentName.length; x++) {
            resultJson[componentName[x]] = EVF.getComponent(componentName[x]).getValue();
        }
    } else {
        resultJson[componentName] = EVF.getComponent(componentName).getValue();
    }
    return resultJson;
};

/**
 * Get specified component's children components values.
 *
 * @param {String}
 *            componentName
 * @returns JSON
 */
formUtil.getChildComponentValues = function (componentName) {
    var resultJson = {};
    EVF.getComponent(componentName).componentIterator(function (cmp) {
        var type = cmp.getCx();
        switch (type) {
            case 'InputText':
            case 'InputDate':
            case 'InputNumber':
            case 'Search':
            case 'Check':
            case 'Select':
                var id = cmp.getId();
                var value = cmp.getValue();
                resultJson[id] = value;
                break;
        }
    }, true);

    return resultJson;
};

/**
 * Set to value of UX Component<br>
 *
 * @param {String}
 *            comp    component name
 * @param {String}
 *            val    value
 */
formUtil.setUxValue = function (componentName, value) {
    EVF.getComponent(componentName).setValue(value);
};

formUtil.setValueWithJson = function (jsonObj) {
    if (jsonObj !== undefined) {
        for (var key in jsonObj) {
            if (jsonObj.hasOwnProperty(key)) {
                EVF.getComponent(key).setValue(jsonObj[key]);
            }

        }
    }
};

/**
 * Set Disabled attribute for UX Component<br>
 *
 * @param {String}/{Array}
 *            component    component name
 * @param {Boolean}
 *            boolean    true/false
 */
formUtil.setDisabled = function (component, boolean) {
    if (component instanceof Array) {
        for (var x = 0; x < component.length; x++) {
            EVF.getComponent(component[x]).setDisabled(boolean);
        }
    } else {
        EVF.getComponent(component).setDisabled(boolean);
    }
};

/**
 * Set Visible attribute for UX Component<br>
 *
 * @param {String}/{Array}
 *            component    component name
 * @param {Boolean}
 *            boolean    true/false
 */
formUtil.setVisible = function (component, boolean) {
    if (component instanceof Array) {
        for (var x = 0; x < component.length; x++) {
            EVF.getComponent(component[x]).setVisible(boolean);
        }
    } else {
        EVF.getComponent(component).setVisible(boolean);
    }
};

/**
 * Reset the components
 *
 * @param {String}/{Array}
 *              component component name
 */
formUtil.reset = function (component) {
    if (component instanceof Array) {
        for (var x = 0; x < component.length; x++) {
            EVF.getComponent(component[x]).reset();
        }
    } else {
        EVF.getComponent(component).reset();
    }
};

/**
 * Copy the text into clipboard.
 * @param {String}
 *               text  text to copy
 */
formUtil.copyIntoClipBoard = function (text) {
    window.clipboardData.setData('Text', text);
};

/**
 * Toggle components id in the w:Window object.
 */
formUtil.setFormDebug = function () {
    var windowObj = null;
    try {
        windowObj = EVF.getComponent('window');
    } catch (e) {
        return alert('Please specify window component id.');
    }

    windowObj.componentIterator(function (cmp) {
        var type = cmp.getCx();
        switch (type) {
            case 'InputText':
            case 'InputDate':
            case 'InputNumber':
            case 'Search':
            case 'Select':
            case 'Check':
                var id = cmp.getId();
                var offset = cmp.getBoxEl().offset();
                var top = offset.top;
                var left = offset.left;

                if (cmp.isVisible() === true) {
                    var divObj = "<div id='" + id + "_XX' style='display: none; padding-left: 2px; padding-right: 2px; font-weight: bold;background-color: #000000; border: 1px solid;font-family: consolas; font-size: 13px; color:#ffffff ; top:" + top + "px; left:" + left + "px; z-index: 15000; position: fixed;' onclick='formUtil.getComponentInformation(this)'>" + id + "</div>";
                    $('body').append(divObj);
                    $('#' + id + '_XX').toggle('fast');
                }
                break;
        }
    }, true);
};

formUtil.getComponentInformation = function (obj) {
    // alert($(obj));
};

formUtil.close = function () {
    window.open('', '_self').close();

    if (opener === undefined) {
//		EVF.close();
    } else {
        window.close();
    }
};

formUtil.getFormId = function () {
    var a = [];

    EVF.componentManager && EVF.componentManager.each(function (b) {
        b = EVF.C(b);

        var c = b.getName();

        if (b instanceof EVF.AbstractEditField) {
            a.push(c);
        }

        b instanceof EVF.FileManager && (c = b.getID(), a[c] = b.getFileId())
    });

    return a;
};


/*
 * form 전체 id, value 값을 가져온다.
 * form id별로 데이터를 가져 올 경우 아래 사용
 * EVF.getComponent("form4").iterator(function() {
 EVF.getComponent(this.getID()).setValue('');
 });
 */
formUtil.getFormData = function () {
    var a = {};

    EVF.componentManager && EVF.componentManager.each(function (b) {
        b = EVF.C(b);
        if (b instanceof EVF.AbstractEditField) {
            var c = b.getName();
            if (b instanceof EVF.Radio) b.isChecked() && (a[c] = b.getValue());
            else {
                var d = b instanceof EVF.CheckGroup ? b.getValue() : b._getRawValue();
                a[c] = d
            }
        }
        b instanceof EVF.FileManager &&
        (c = b.getID(), a[c] = b.getFileId())
    });

    return a;
};

/*
 * form 전체 id, value 값을 적용한다.
 */
formUtil.setFormData = function (formData) {
    formData = JSON.parse(formData);

    var formValue = formUtil.getFormData();
    var formKey = Object.keys(formValue);

    var formDataKey = Object.keys(formData);

    for (var i = 0; i < formKey.length; i++) {
        for (var j = 0; j < formDataKey.length; j++) {
            if (formKey[i] == formDataKey[j]) {
                if (formData[formDataKey[j]] != "") {
                    EVF.getComponent(formDataKey[j]).setValue(formData[formDataKey[j]]);
                }
            }
        }
    }
};


/*
 * form id에 대한 animate
 */
formUtil.animate = function (id, fg) {
    $("#" + id).css('color', '#fff').css('background-color', '#ff988c');

    setTimeout(function () {
        if (fg == "form") {
            $("#" + id).animate({backgroundColor: "#fff", color: "#333"}, 1000)
        } else {
            $("#" + id).animate({backgroundColor: "#ebf2f6", color: "#333"}, 1000)
        }

    }, 4000);
};

/*
 * 다중 form id에 대한 animate
 */
formUtil.animateFor = function (ids, fg) {
    var array = [];

    for (var idx in ids) {
        // select validation 추가
        var $buttonSel = $('#'+ids[idx]).siblings('button');
        if($buttonSel[0] != undefined) {
            array.push($buttonSel);
            $buttonSel.css('color', '#fff').css('background-color', '#ff988c');
        } else {
            array.push(ids[idx]);
            $("#" + ids[idx]).css('color', '#fff').css('background-color', '#ff988c');
        }
    }

    animateSetTime(array, fg);
};

function animateSetTime(array, fg) {
    setTimeout(function () {
        for (var idx in array) {
            if (fg == "form") {
                if(array[idx].constructor === jQuery) {
                    array[idx].animate({backgroundColor: "#fff", color: "#333"}, 1000)
                } else {
                    $("#" + array[idx]).animate({backgroundColor: "#fff", color: "#333"}, 1000)
                }
            } else {
                $("#" + array[idx]).animate({backgroundColor: "#ebf2f6", color: "#333"}, 1000)
            }
        }
    }, 4000);
}