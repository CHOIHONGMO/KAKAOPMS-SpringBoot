var toggleComponentInfo = true;

$(document).ready(function() {
    /*
	 * 화면의 상단 아이콘 클릭 시 메뉴바 접기 / 펼치기
	 */
    $('.e-window-container-header-bullet').on('click', function() {
        top.$('.ui-layout-toggler').trigger('click');
        if ($(this).hasClass('off') === true) {
            $(this).removeClass('off');
        } else {
            $(this).addClass('off');
        }
    });

    shortcut.add("Ctrl+F2", function() {
        alert('Screen Height: '+$(this).outerHeight(true) + '/width: ' +$(this).outerWidth(true));
    });

    shortcut.add("Ctrl+M", function() {

        var $input = $("<input id='common_message' type='text' class='common_message' />");
        $input.on('keydown', function(e) {

            if(e.keyCode == 13) {
                var store = new EVF.Store();
                store.setParameter($(this).val());
                store.load('')
            }
        });
    });

    shortcut.add("CTRL+SHIFT+Z", function() {
        $('input, textarea, select').each(function(idx) {
            var id = $(this).attr('id');
            if(EVF.isNotEmpty(id) && EVF.isComponent(id)) {
                //console.log(id, EVF.isComponent(id), EVF.C(id).getValue());
                $.cookie(id, EVF.C(id).getValue()||'', {
                    expires: 10
                });
            }
        });

        alert('데이터가 임시저장되었습니다.');
    });

    shortcut.add("CTRL+F3", function() {

        var gridIds = $('.e-realgridpanel').map(function() {return this.id});
        if(toggleComponentInfo) {
            $('input, textarea, select').each(function(idx) {
                var id = $(this).attr('id');
                if(!$(this).parent().parent().hasClass('e-realgridpanel-bottom-panel')&&id!=undefined) {
                    var $infoDiv = $('<div class="componentInfoDiv" style="position: absolute; left: 0; top:0; font-size: 10px; color: #0000ff; font-family: Consolas;">' + id + '</div>');
                    $(this).parent().append($infoDiv);
                }
            });

            for(var i=0; i < gridIds.length; i++) {

                var _gridObj = EVF.C(gridIds[i]);
                var _gridView = _gridObj._gvo;

                var columns = _gridView.getColumns();
                for(var j in columns) {

                    /*
                    var subTextProperty = {
                        "subText": columns[j].fieldName,
                        "subTextGap": 1,
                        "subTextLocation": "lower",
                        "subStyles": {"foreground": "#0000ff", "fontSize": "9", "fontFamily": "Consolas"}
                    };
                    */
                    var subTextProperty = {
                            template : "${headerText}"
                                     + "<div style='line-height:1;font-family:Consolas;font-size:9px;color:#0000ff'>${subText}</div>",
                            values : { "headerText" : columns[j].header.text, "subText" : columns[j].fieldName}
                        }

                    _gridView.setColumnProperty(columns[j].fieldName, 'header', subTextProperty);
                }
            }

            toggleComponentInfo = false;
        } else {

            $('.componentInfoDiv').remove();

            for(var i=0; i < gridIds.length; i++) {
                var _gridObj = EVF.C(gridIds[i]);
                var _gridView = _gridObj._gvo;

                var columns = _gridView.getColumns();
                for (var j in columns) {

                    /*
                    var _prop = _gridView.getColumnProperty(columns[j].fieldName, 'header');
                    _prop.subText = null;
                    _prop.subTextGap = null;
                    _prop.subTextLocation = null;
                    _prop.subStyles = null;
                    _gridView.setColumnProperty(columns[j].fieldName, 'header', _prop);
                    */
                    var subTextProperty = {
                            template : "${headerText}",
                            values : { "headerText" : columns[j].header.text}
                        }

                    _gridView.setColumnProperty(columns[j].fieldName, "header", subTextProperty);
                }
            }

            toggleComponentInfo = true;
        }

        EVF.componentManager.getWindow().iterateAll(function() {

        });
    });

    shortcut.add("CTRL+SHIFT+X", function() {
        $('input, textarea, select').each(function(idx) {
            var id = $(this).attr('id');
            if(EVF.isNotEmpty(id) && EVF.isComponent(id)) {
                //console.log(id, $.cookie(id));
                if($.cookie(id) != undefined) {
                    EVF.C(id).setValue($.cookie(id));
                }
            }
        });
    });

	shortcut.add("F8", function() {
        var param = {
            "screenId" : EVF.componentManager.getWindow().getID()
        };
		everPopup.openMultiLanguageList(param);
	});
	
	shortcut.add("Ctrl+F8", function() {
        var param = {
            "screenId" : EVF.componentManager.getWindow().id
        };
        everPopup.openScreenActionManagement(param);
	});
	
	shortcut.add("Shift+F8", function() {
        var param = {
            "paramScreenId" : EVF.componentManager.getWindow().getID()
        };
        everPopup.createWindowPopup('/generator/source/view.so', '1000', '830', param, '', true);
	});
	
    shortcut.add("Alt+F8", function() {
        $('input, textarea, select').each(function(idx) {
            var id = $(this).attr('id');
            if($(this).width() !== 0 && id != undefined) {
                var $panel = $("<div class='e-debug-description-panel'><span>"+id+"</span></div>");
                $(this).append($panel);
            }
            // console.log($(this).attr('id'));
        });
    });
    
    shortcut.add("F9", function() {
        /*
        EVF.componentManager.each(function(id) {
            if(EVF.C(id) instanceof EVF.GridPanel) {
                var gridObj = EVF.C(id);
                var colId = gridObj.getColId();
                for(var i in colId) {
                    var ci = colId[i];
                    console.log(ci, EVF.C(id).getJqGrid());
                    EVF.C(id).getJqGrid().jqGrid('setColProp', ci, {"width": "120"});
                }
            }
        });
        */
        var param = {
            "screenId" : EVF.componentManager.getWindow().getID()
        };
        everPopup.openUserColumnList(param);
    });
    
//	// toggle components' ID
//	shortcut.add("Alt+F8", function() {
//		formUtil.setFormDebug();
//	});
    
//	// open current page as popup
//	shortcut.add("F9", function() {
//		wisePopup.openWindowPopup(location.href, 600, 600, {}, 'currentPage', true);
//	});
//
//	//  initiallize cache data
//	shortcut.add("Ctrl+F9", function() {
//		var store = new EVF.Store();
//		store.load('/common/util/eventNo9.so', function(){
//
//		});
//	});
//
//	//  initiallize cache data
//	shortcut.add("Ctrl+F7", function() {
//		storeUtil.callStore('/wisec/common/util/loadCacheData.wu');
//	});
//	//  dummy Alarm
//	shortcut.add("Alt+F9", function() {
//		storeUtil.callStore('/wisec/common/util/dummyAlarm.wu');
//	});
});