<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<link rel="StyleSheet" href="/js/dtree/dtree.css" type="text/css" />
	<script type="text/javascript" src="/js/dtree/dtree.js"></script>
    <script type="text/javascript">

    	var baseUrl = "/eversrm/system/menu/menuTemplateDetail/";
    	var dynaTree;
    	var reload;
    	var grid = {};

		function init() {
			
			grid = EVF.C('grid');
			<%-- Grid 제외
			grid.addRowEvent(function() {
            	grid.addRow();
			});
			grid.delRowEvent(function() {
				if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
		            alert("${msg.M0004}");
		            return;
		        }
				grid.delRow();
			});
			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
			    excelOptions : {
					 imgWidth      : 0.12       // 이미지의 너비.
					,imgHeight     : 0.26      	// 이미지의 높이.
					,colWidth      : 20        	// 컬럼의 넓이.
					,rowSize       : 500       	// 엑셀 행에 높이 사이즈.
			        ,attachImgFlag : false      // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부
			    }
			}); --%>
			$("#panel_hide").hide();

			doSearch();
        }

        function doSearch() {

			var store = new EVF.Store();
			store.setParameter("MODULE_TYPE", "${param.MODULE_TYPE }");
			store.setParameter("TMPL_MENU_GROUP_CD", "${param.TMPL_MENU_GROUP_CD }");
			store.load(baseUrl + 'listMenuTemplateDtree', function() {
				var treeData = this.getParameter("treeData");
				var jsontree = JSON.parse(treeData);
				d = new dTree('d');

				for (var k = 0; k < jsontree.length; k++) {
					if (k == 0) {
						d.add(0, -1, 'Root', '', '');
					}
					var trimParentid = jsontree[k].PARENTID.trim();
					d.add(jsontree[k].TMPL_MENU_CD,
							trimParentid,
							jsontree[k].USE_FLAG == 1 ? jsontree[k].SCREEN_NM : "<strike><font color='#BDBDBD'>" + jsontree[k].SCREEN_NM + "</font></strike>",
							jsontree[k].TMPL_MENU_CD,
							JSON.stringify(jsontree[k]));
				}
				document.getElementById("tree").innerHTML = d;

				d.openAll();
			});
        }

		function goTarget() {

			var nodeData = JSON.parse(d.aNodes[d.selectedNode].data);
			if (nodeData == null) return;

			EVF.C('MENU_NM').setValue((nodeData.MENU_NM == null || nodeData.MENU_NM == '') ? nodeData.SCREEN_NM : nodeData.SCREEN_NM);
			EVF.C('SCREEN_NM').setValue((nodeData.IS_FOLDER) == true ? '' : nodeData.SCREEN_NM);
			EVF.C('USE_FLAG').setValue(nodeData.USE_FLAG);
			EVF.C('SCREEN_ID').setValue($.trim(nodeData.SCREEN_ID));
			EVF.C('TMPL_MENU_CD').setValue(nodeData.TMPL_MENU_CD);
			EVF.C('HIGH_TMPL_MENU_CD').setValue(nodeData.PARENTID);
			EVF.C('HIDDEN_SORT_SQ').setValue(nodeData.SORT_SQ);

			if(nodeData.IS_FOLDER == true) {
				EVF.C('LEAF_FLAG').setChecked('leafFlag1');
			} else {
				EVF.C('LEAF_FLAG').setChecked('leafFlag2');
			}
			
			/**
			 * 2022.10.31 제외
			 * 직무유형별 권한은 "권한관리"에서 처리하도록 함
			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + 'doSearchStocmuba', function() {
			}); */
		}

        function doSave() {
        	grid.checkAll(true);

        	if(!formValidate()) {
				return;
			}

			if (!confirm("${msg.M0011 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
       		store.load(baseUrl + 'createMenuTemplateTree', function() {
                alert(this.getResponseMessage());
                var params = {
                    multi_cd: 'MT',
                    screen_id: EVF.C('SCREEN_ID').getValue() == "" ? "-" : EVF.C('SCREEN_ID').getValue(),
                    tmpl_menu_cd: this.getParameter("tmplMenuCd"),
                    popupFlag :  'true',
                    choose_button_visibility: false
                };
                everPopup.openMultiLanguagePopup(params);
            });
        }

        function doUpdate() {
        	grid.checkAll(true);

        	if(!formValidate()) {
				return;
			}

			if (!confirm("${msg.M0012 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
       		store.load(baseUrl + 'updateMenuTemplateDetail', function() {
                alert(this.getResponseMessage());
                var params = {
                    multi_cd: 'MT',
                    screen_id: EVF.C('SCREEN_ID').getValue() == "" ? "-" : EVF.C('SCREEN_ID').getValue(),
                    tmpl_menu_cd: this.getParameter("tmplMenuCd"),
                    popupFlag :  'true',
                    choose_button_visibility: false
                };
                everPopup.openMultiLanguagePopup(params);
            });
        }

        function doDelete() {

        	if(!formValidate()) {
				return;
			}

			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
       		store.load(baseUrl + 'deleteMenuTemplateDetail', function() {
                alert(this.getResponseMessage());
                doSearch();
	        	$("#tree").dynatree("getTree").reload();
	        	$("#tree").dynatree("getTree").visit(function(node){
				    node.expand(true);
				});
				EVF.C('MENU_NM').setValue('');
				EVF.C('SCREEN_NM').setValue('');
				EVF.C('USE_FLAG').setValue('');
				EVF.C('SCREEN_ID').setValue('');
				EVF.C('TMPL_MENU_CD').setValue('');
				EVF.C('HIGH_TMPL_MENU_CD').setValue('');
				EVF.C('HIDDEN_SORT_SQ').setValue('');
                EVF.C('LEAF_FLAG').setChecked('leafFlag1');
            });
        }

        function multiLanguagePopupCallBack(returnData) {
        	doSearch();
        }

        function searchScreenId() {
            var popupUrl = "/eversrm/system/screen/BSYS_030/view";
            everPopup.openWindowPopup(popupUrl, 1000, 500, {
                onSelect: 'selectScreen'
            }, 'screenIdPopup');

        }

	    function selectScreen(data) {
	        EVF.C("SCREEN_ID").setValue(data.SCREEN_ID);
	        EVF.C("SCREEN_NM").setValue(data.SCREEN_NM);
        }
        function formValidate() {

	        var useFlag = EVF.C("USE_FLAG").getValue();
	        var menuNm = EVF.C('MENU_NM').getValue();
	        var leafFlag = EVF.C('LEAF_FLAG').getCheckedValue();
	        var depthRadio = EVF.C('DEPTH').getCheckedValue();
	        var sortSeqRadio = EVF.C('SORT_SQ').getCheckedValue();

	        if (useFlag == "") {
	            alert("${BSYM_020_0004}");
	            return;
	        }
	        if (menuNm == "") {
	            alert("${BSYM_020_0005}");
	            return;
	        }
	        if (leafFlag == "") {
	            alert("${BSYM_020_0006}");
	            return;
	        }
	        if (depthRadio == "") {
	            alert("${BSYM_020_0007}");
	            return;
	        }
	        if (sortSeqRadio == "") {
	            alert("{BSYM_020_0008}");
	            return;
	        }

	        return true;
        }
        function doClose() {
	    	window.close();
	    }

    </script>
    <e:window id="BSYM_020_TREE" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
	    <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Update" name="Update" label="${Update_N }" disabled="${Update_D }" onClick="doUpdate" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
<%--             <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" /> --%>
        </e:buttonBar>
		<e:panel id="leftPanel" height="100%" width="60%">
			<e:searchPanel id="form" useTitleBar="false" columnCount="1" labelWidth="${longLabelWidth }">
  				<e:row>
	        		<e:label for="TMPL_MENU_GROUP_CD" title="${form_TMPL_MENU_GROUP_CD_N }" />
	                <e:field>
	                    <e:inputText id="TMPL_MENU_GROUP_CD" name="TMPL_MENU_GROUP_CD" width="100%" maxLength="${form_TMPL_MENU_GROUP_CD_M }" readOnly="${form_TMPL_MENU_GROUP_CD_RO }" required="${form_TMPL_MENU_GROUP_CD_R }" disabled="${form_TMPL_MENU_GROUP_CD_D }" value="${param.TMPL_MENU_GROUP_CD }" />
	                    <e:inputHidden id="MODULE_TYPE" name="MODULE_TYPE" value="${param.MODULE_TYPE }" />
	                    <e:inputHidden id="GATE_CD" name="GATE_CD" value="${formData.GATE_CD }" />
	                    <e:inputHidden id="TOP_TMPL_MENU_CD" name="TOP_TMPL_MENU_CD" value="${formData.TOP_TMPL_MENU_CD }" />
	                    <e:inputHidden id="HIGH_TMPL_MENU_CD" name="HIGH_TMPL_MENU_CD" value="${formData.HIGH_TMPL_MENU_CD }" />
	                    <e:inputHidden id="TMPL_MENU_CD" name="TMPL_MENU_CD" value="" />
	                    <e:inputHidden id="STANDARD_DEPTH" name="STANDARD_DEPTH" value="0" />
	                    <e:inputHidden id="HIDDEN_SORT_SQ" name="HIDDEN_SORT_SQ" value="" />
	                </e:field>
	            </e:row>
	            <e:row>
	            	<e:label for="MENU_NM" title="${form_MENU_NM_N }" />
	                <e:field>
	                    <e:inputText id="MENU_NM" name="MENU_NM" width="100%" required="${form_MENU_NM_R }" disabled="${form_MENU_NM_D }" value="${formData.MENU_NM }" readOnly="${form_MENU_NM_RO }" maxLength="${form_MENU_NM_M}" />
	                </e:field>
	            </e:row>
	            <e:row>
	            	<e:label for="USE_FLAG" title="${form_USE_FLAG_N }" />
	                <e:field>
	                    <e:select id="USE_FLAG" name="USE_FLAG" value="${formData.USE_FLAG }" options="${refYN}" width="${inputTextWidth }" required="${form_USE_FLAG_R }" disabled="${form_USE_FLAG_D }" readOnly="${form_USER_FLAG_RO }"/>
	                </e:field>
	            </e:row>
	            <e:row>
	                <e:label for="SCREEN_ID" title="${form_SCREEN_ID_N }" />
	                <e:field>
	                    <e:search id="SCREEN_ID" name="SCREEN_ID" width="100%" required="${form_SCREEN_ID_R }" disabled="${form_SCREEN_ID_D }" value="${formData.SCREEN_ID }"  onIconClick="searchScreenId" readOnly="${form_SCREEN_ID_RO }" maxLength="${form_SCREEN_ID_M}" />
	                </e:field>
	            </e:row>
	            <e:row>
	            	<e:label for="SCREEN_NM" title="${form_SCREEN_NM_N }" />
	                <e:field>
	                    <e:inputText id="SCREEN_NM" name="SCREEN_NM" width="100%" required="${form_SCREEN_NM_R }" disabled="${form_SCREEN_NM_D }" value="${formData.SCREEN_NM }" readOnly="${form_SCREEN_NM_RO }" maxLength="${form_SCREEN_NM_M}" />
	                </e:field>
	            </e:row>
	            <e:row>
	                <e:label for="LEAF_FLAG" title="${form_LEAF_FLAG_N }" />
	                <e:field>
	                	<e:radioGroup id="LEAF_FLAG" name="LEAF_FLAG" disabled="" required="" readOnly="">
	                        <e:radio id="leafFlag1" name="leafFlag1" label="${form_LEAF_FLAG_1_N }" value="0" onClick="doChooseLeafFlag" checked="true"/>
	                        <span class="e-text-wrapper">&nbsp;</span>
	                        <e:radio id="leafFlag2" name="leafFlag2" label="${form_LEAF_FLAG_2_N }" value="1" onClick="doChooseLeafFlag"/>
	                    </e:radioGroup>
	                </e:field>
	            </e:row>
	            <e:row>
	                <e:label for="DEPTH" title="${form_DEPTH_N }" />
	                <e:field>
	                	<e:radioGroup id="DEPTH" name="DEPTH" disabled="" required="" readOnly="">
	                        <e:radio id="depth1" name="depth1" label="${form_DEPTH_1_N }" value="0" onClick="doChooseDepth" checked="true"/>
	                        <span class="e-text-wrapper">&nbsp;</span>
	                        <e:radio id="depth2" name="depth2" label="${form_DEPTH_2_N }" value="1" onClick="doChooseDepth"/>
	                    </e:radioGroup>
	                </e:field>
	            </e:row>
	            <e:row>
	                <e:label for="SORT_SQ" title="${form_SORT_SQ_N }" />
	                <e:field>
	                	<e:radioGroup id="SORT_SQ" name="SORT_SQ" disabled="" readOnly="" required="">
	                        <e:radio id="sortSeq1" name="sortSeq1" label="${form_SORT_SQ_1_N }" value="0" onClick="doChooseSortSeq"/>
	                        <span class="e-text-wrapper">&nbsp;</span>
	                        <e:radio id="sortSeq2" name="sortSeq2" label="${form_SORT_SQ_2_N }" value="1" onClick="doChooseSortSeq" checked="true"/>
	                    </e:radioGroup>
	                </e:field>
	            </e:row>
      		</e:searchPanel>
			
      		<e:panel id="panel_hide">
				<p style="font-family: '맑은 고딕'; font-size:13px; font-weight:bold; color:blue;">▣ 직무유형별 메뉴권한 </p>
				<p style="font-family: '맑은 고딕'; font-size:12px; ">직무유형을 입력하지 않으시면 모든 사용자에게 권한이 부여됩니다.</p>
	      		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
      		</e:panel>
		</e:panel>
		<e:panel id="treePanel" height="490px" width="40%">
			<e:searchPanel id="treeForm" useTitleBar="false">
  				<e:row>
                    <e:field>
  					    <div id="tree" style="height: 480px; overflow: auto;"> </div>
                    </e:field>
  				</e:row>
  			</e:searchPanel>
		</e:panel>
    </e:window>
</e:ui>