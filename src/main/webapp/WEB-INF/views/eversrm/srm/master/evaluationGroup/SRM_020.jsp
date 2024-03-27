<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = "/eversrm/srm/master/evaluationGroup/";
    var gridMgt;
    var gridSgn;
    var gridUs;
    function init() {
    	gridMgt = EVF.C("gridMgt");
    	gridSgn = EVF.C("gridSgn");
    	gridUs = EVF.C("gridUs");
    	gridMgt.setProperty('multiselect', false);
    	gridSgn.addRowEvent(function () {
    		if (EVF.getComponent('EG_NUM').getValue() == '' ) {
    			alert('${SRM_020_0005}');
    			return;
    		}

	        var param = {
	        		 EG_NUM : EVF.getComponent('EG_NUM').getValue()
	        		,callBackFunction : 'addEvalItem'
	        	    ,detailView : false
			};
		    everPopup.openPopupByScreenId('SRM_101', 1200, 800, param);


    	});

    	gridSgn.delRowEvent(function() {
	    });

    	gridUs.addRowEvent(function () {
    		doSelectUser();

    	});

    	gridMgt.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
        	EVF.getComponent('EG_NUM').setValue(gridMgt.getCellValue(rowid,"EG_NUM"));
        	doSearchMgt();
        	doSearchSg();
        	doSearchUs();
    	});
    }

    function doSelectUser() {
		if (EVF.getComponent('EG_NUM').getValue() == '' ) {
			alert('${SRM_020_0005}');
			return;
		}
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectUser'
        };
		everPopup.openCommonPopup(param,"SP0001");
    }
    function selectUser(data) {
    	var existUser = true;
    	if(data.USER_ID == ''){
    		return;
    	}
		for (var i = 0, length = gridUs.getRowCount(); i < length; i++) {
            if (gridUs.getCellValue(i,"USER_ID") == data.USER_ID) {
				existUser = false;
            }
	    }
	    if(existUser){
	    	addParam = [
    	            	{
    	            		 USER_ID : data.USER_ID
    	            		,USER_NM :    data.USER_NM
    	            		,DEPT_NM :    data.DEPT_NM
    	            		,REP_FLAG :   data.REP_FLAG != undefined ? data.REP_FLAG : ''
    	            		,EG_NUM : EVF.getComponent('EG_NUM').getValue()
    	            	}
    	            ];
	    	gridUs.addRow(addParam);
	    }
    }

    function doSearchMgt() {
        var store = new EVF.Store();
        store.load(baseUrl + "SRM_020/doSearchMgt", function() {
        	var mdata = JSON.parse(this.getParameter('frmMgt'));
        	EVF.getComponent('EG_NUM').setValue(mdata.EG_NUM);
        	EVF.getComponent('EG_NM').setValue(mdata.EG_NM);

        	EVF.getComponent('VALID_FROM_DATE').setValue(mdata.VALID_FROM_DATE);
        	EVF.getComponent('VALID_TO_DATE').setValue(mdata.VALID_TO_DATE);
        	EVF.getComponent('EG_TYPE_CD').setValue(mdata.EG_TYPE_CD);
        	EVF.getComponent('EG_KIND_CD').setValue(mdata.EG_KIND_CD);
        	EVF.getComponent('EG_DEF_TEXT_NUM').setValue(mdata.EG_DEF_TEXT_NUM);
        	EVF.getComponent('EG_DEF_TEXT_NUM_TEXT').setValue(mdata.EG_DEF_TEXT_NUM_TEXT);
        });

    }
    function doSearchSg() {
        var store = new EVF.Store();
        store.setGrid([gridSgn]);
        store.load(baseUrl + "SRM_020/doSearchSg", function() {
        });
    }
    function doSearchUs() {
        var store = new EVF.Store();
        store.setGrid([gridUs]);
        store.load(baseUrl + "SRM_020/doSearchUs", function() {
        });
    }
    function doCreate() {
		EVF.getComponent('EG_NUM').setValue( '' );
		EVF.getComponent('EG_NM').setValue( '' );
		EVF.getComponent('EG_KIND_CD').setValue( '' );
		EVF.getComponent('EG_TYPE_CD').setValue( '' );


		EVF.getComponent('VALID_FROM_DATE').setValue( '' );
		EVF.getComponent('VALID_TO_DATE').setValue( ''  );
		EVF.getComponent('EG_DEF_TEXT_NUM_TEXT').setValue( '' );
		EVF.getComponent('EG_DEF_TEXT_NUM').setValue( '' );

		gridSgn.delAllRow();
		gridUs.delAllRow();
    }

    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([gridMgt]);
        store.load(baseUrl + "SRM_020/doSearchLeft", function() {
            if (gridMgt.getRowCount() == 0) {
                alert("${msg.M0002 }");

            }
            //doCreate();
        });
    }
    function getContentTab(uu) {
    	return;
        if (uu == '1') {
        }
        if (uu == '2') {
        }
        if (uu == '3') {
        }
      }

    $(document.body).ready(function() {
        $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
                {
                  activate: function(event, ui) {
                    <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                    $(window).trigger('resize');
                  }
                }
        );
        $('#e-tabs').tabs('option', 'active', 0);
        //getContentTab('1');
      });


	function doDelete() {
		if (EVF.getComponent('EG_NUM').getValue() == '' ) {
			alert('${SRM_020_0005}');
			return;
		}
		var store = new EVF.Store();
        if(!store.validate()) return;
        if (!confirm("${msg.M0013}")) return;
        store.load(baseUrl + "SRM_020/doDeleteMgt", function() {
            alert(this.getResponseMessage());
	          doSearch();
	          doCreate();
        });
	}




	function doSave() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        if (!confirm("${msg.M0021}")) return;
        store.load(baseUrl + "SRM_020/doSave", function() {
            alert(this.getResponseMessage());
          doSearch();
      		EVF.getComponent('EG_NUM').setValue(this.getParameter('eg_num'));
        });
	}

	function doSaveUs() {
		var store = new EVF.Store();
		if (EVF.getComponent('EG_NUM').getValue() == '' ) {
			alert('${SRM_020_0005}');
			return;
		}

		gridUs.checkAll(true);
		if ((gridUs.jsonToArray(gridUs.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if(!gridUs.validate().flag) { return alert(gridUs.validate().msg); }

		store.setGrid([ gridUs ]);
		store.getGridData(gridUs, 'sel');
		if (!confirm("${msg.M0021}")) return;
		store.load(baseUrl + '/SRM_020/doSaveUs', function() {
			alert(this.getResponseMessage());
			doSearchUs();
		});
	}


	function doDeleteUs() {
		var store = new EVF.Store();
		if (EVF.getComponent('EG_NUM').getValue() == '' ) {
			alert('${SRM_020_0005}');
			return;
		}

		if ((gridUs.jsonToArray(gridUs.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

		if(!gridUs.validate().flag) { return alert(gridUs.validate().msg); }

		store.setGrid([ gridUs ]);
		store.getGridData(gridUs, 'sel');
		if (!confirm("${msg.M0013}")) return;
		store.load(baseUrl + '/SRM_020/doDeleteUs', function() {
			alert(this.getResponseMessage());
			doSearchUs();
		});
	}




	function doSaveSg() {
		var store = new EVF.Store();
		if (EVF.getComponent('EG_NUM').getValue() == '' ) {
			alert('${SRM_020_0005}');
			return;
		}

		gridSgn.checkAll(true);
		if ((gridSgn.jsonToArray(gridSgn.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

		if(!gridSgn.validate().flag) { return alert(gridSgn.validate().msg); }

		store.setGrid([ gridSgn ]);
		store.getGridData(gridSgn, 'sel');
		if (!confirm("${msg.M0021}")) return;
		store.load(baseUrl + '/SRM_020/doSaveSg', function() {
			alert(this.getResponseMessage());
			doSearchUs();
		});
	}


	function doDeleteSg() {
		var store = new EVF.Store();
		if (EVF.getComponent('EG_NUM').getValue() == '' ) {
			alert('${SRM_020_0005}');
			return;
		}

		if ((gridSgn.jsonToArray(gridSgn.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

		if(!gridSgn.validate().flag) { return alert(gridSgn.validate().msg); }

		store.setGrid([ gridSgn ]);
		store.getGridData(gridSgn, 'sel');
		if (!confirm("${msg.M0013}")) return;
		store.load(baseUrl + '/SRM_020/doDeleteSg', function() {
			alert(this.getResponseMessage());
			doSearchUs();
		});
	}




</script>

<e:window id="SRM_020" onReady="init" initData="${initData}" title="${fullScreenName}">

    <e:panel width="44%" height="100%">
        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearchTree">
            <e:row>
				<e:label for="EG_KIND_CD_S" title="${frmLeft_EG_KIND_CD_S_N}"/>
				<e:field>
				<e:select id="EG_KIND_CD_S" name="EG_KIND_CD_S" value="${form.EG_KIND_CD_S}" options="${refeg_kind_cd }" width="${inputTextWidth}" disabled="${frmLeft_EG_KIND_CD_S_D}" readOnly="${frmLeft_EG_KIND_CD_S_RO}" required="${frmLeft_EG_KIND_CD_S_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="EG_NM_S" title="${frmLeft_EG_NM_S_N}"/>
				<e:field>
				<e:inputText id="EG_NM_S" style="${imeMode}" name="EG_NM_S" value="${form.EG_NM_S}" width="100%" maxLength="${frmLeft_EG_NM_S_M}" disabled="${frmLeft_EG_NM_S_D}" readOnly="${frmLeft_EG_NM_S_RO}" required="${frmLeft_EG_NM_S_R}"/>
				</e:field>
            </e:row>
            <e:row>
				<e:label for="EG_TYPE_CD_S" title="${frmLeft_EG_TYPE_CD_S_N}"/>
				<e:field>
				<e:select id="EG_TYPE_CD_S" name="EG_TYPE_CD_S" value="${form.EG_TYPE_CD_S}" options="${refeg_type_cd }" width="${inputTextWidth}" disabled="${frmLeft_EG_TYPE_CD_S_D}" readOnly="${frmLeft_EG_TYPE_CD_S_RO}" required="${frmLeft_EG_TYPE_CD_S_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doCreate" name="doCreate" label="${doCreate_N}" onClick="doCreate" disabled="${doCreate_D}" visible="${doCreate_V}"/>
        </e:buttonBar>
		<e:gridPanel gridType="${_gridType}" id="gridMgt" name="gridMgt" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridMgt.gridColData}"/>

    </e:panel>
    <e:panel width="1%">&nbsp;</e:panel>
     <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
    <e:panel width="55%" height="fit">
        <tr><td><div>
          <ul>
            <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">평가그룹정의</a></li>
            <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">소싱그룹</a></li>
            <li id="tab3"><a href="#ui-tabs-3" onclick="getContentTab('3');">평가자</a></li>
          </ul>

          <div id="ui-tabs-1">
			<div style="height: auto;">
		        <e:buttonBar align="right">
					<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
					<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
		        </e:buttonBar>
		        <e:searchPanel id="form1" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearchTree">
		            <e:row>
						<e:label for="EG_NM" title="${frmMgt_EG_NM_N}"/>
						<e:field>
						<e:search id="EG_NM" style="${imeMode}" name="EG_NM" value="" width="${inputTextWidth}" maxLength="${frmMgt_EG_NM_M}" onIconClick="${frmMgt_EG_NM_RO ? 'everCommon.blank' : ''}" disabled="${frmMgt_EG_NM_D}" readOnly="${frmMgt_EG_NM_RO}" required="${frmMgt_EG_NM_R}" />
						<e:inputHidden id="EG_NUM" name="EG_NUM" value=""/>
						</e:field>
		            </e:row>
		            <e:row>
						<e:label for="EG_KIND_CD" title="${frmMgt_EG_KIND_CD_N}"/>
						<e:field>
						<e:select id="EG_KIND_CD" name="EG_KIND_CD" value="${form.EG_KIND_CD}" options="${refeg_kind_cd }" width="${inputTextWidth}" disabled="${frmMgt_EG_KIND_CD_D}" readOnly="${frmMgt_EG_KIND_CD_RO}" required="${frmMgt_EG_KIND_CD_R}" placeHolder="" />
						</e:field>
		            </e:row>
		            <e:row>
						<e:label for="EG_TYPE_CD" title="${frmMgt_EG_TYPE_CD_N}"/>
						<e:field>
						<e:select id="EG_TYPE_CD" name="EG_TYPE_CD" value="${form.EG_TYPE_CD}" options="${refeg_type_cd }" width="${inputTextWidth}" disabled="${frmMgt_EG_TYPE_CD_D}" readOnly="${frmMgt_EG_TYPE_CD_RO}" required="${frmMgt_EG_TYPE_CD_R}" placeHolder="" />
						</e:field>
		            </e:row>
		            <e:row>
						<e:label for="VALID_FROM_DATE" title="${frmMgt_VALID_FROM_DATE_N}"/>
						<e:field>
						<e:inputDate id="VALID_FROM_DATE" name="VALID_FROM_DATE" value="${form.VALID_FROM_DATE}" width="${inputTextDate}" datePicker="true" required="${frmMgt_VALID_FROM_DATE_R}" disabled="${frmMgt_VALID_FROM_DATE_D}" readOnly="${frmMgt_VALID_FROM_DATE_RO}" />
						<e:text> ~ </e:text>
						<e:inputDate id="VALID_TO_DATE" name="VALID_TO_DATE" value="${form.VALID_TO_DATE}" width="${inputTextDate}" datePicker="true" required="${frmMgt_VALID_TO_DATE_R}" disabled="${frmMgt_VALID_TO_DATE_D}" readOnly="${frmMgt_VALID_TO_DATE_RO}" />
						</e:field>
					</e:row>
		            <e:row>

					<e:label for="EG_DEF_TEXT_NUM" title="${frmMgt_EG_DEF_TEXT_NUM_N}"/>
					<e:field>
                	<e:richTextEditor id="EG_DEF_TEXT_NUM_TEXT" value="${form.EG_DEF_TEXT_NUM_TEXT }"  height="250px" name="EG_DEF_TEXT_NUM_TEXT" width="100%" required="${form_EG_DEF_TEXT_NUM_TEXT_R }" readOnly="${form_EG_DEF_TEXT_NUM_TEXT_RO }" disabled="${form_EG_DEF_TEXT_NUM_TEXT_D }" />
					<e:inputHidden id="EG_DEF_TEXT_NUM" name="EG_DEF_TEXT_NUM" value=""/>
					</e:field>


		            </e:row>
		        </e:searchPanel>

			</div>
          </div>

          <div id="ui-tabs-2">
			<div style="height: auto;">
		        <e:buttonBar align="right">
					<e:button id="doSaveSg" name="doSaveSg" label="${doSaveSg_N}" onClick="doSaveSg" disabled="${doSaveSg_D}" visible="${doSaveSg_V}"/>
					<e:button id="doDeleteSg" name="doDeleteSg" label="${doDeleteSg_N}" onClick="doDeleteSg" disabled="${doDeleteSg_D}" visible="${doDeleteSg_V}"/>
		        </e:buttonBar>
				<e:gridPanel gridType="${_gridType}" id="gridSgn" name="gridSgn" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridSgn.gridColData}"/>
			</div>
          </div>

          <div id="ui-tabs-3">
			<div style="height: auto;">
		        <e:buttonBar align="right">
					<e:button id="doSaveUs" name="doSaveUs" label="${doSaveUs_N}" onClick="doSaveUs" disabled="${doSaveUs_D}" visible="${doSaveUs_V}"/>
					<e:button id="doDeleteUs" name="doDeleteUs" label="${doDeleteUs_N}" onClick="doDeleteUs" disabled="${doDeleteUs_D}" visible="${doDeleteUs_V}"/>
		        </e:buttonBar>
				<e:gridPanel gridType="${_gridType}" id="gridUs" name="gridUs" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridUs.gridColData}"/>
			</div>
          </div>
		</div></td></tr>
    </e:panel>
 	</div>
</e:window>
</e:ui>