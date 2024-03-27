<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var baseUrl = "/eversrm/system/menu/menuTemplateDetail/";
    	var dynaTree;
    	var reload;
    	var grid = {};
    	
		function init() {

			grid = EVF.C('grid');
						
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
					 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
					,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
			        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
			    }
			});
		
			doSearch();
        }

        function doSearch() {
		
			var store = new EVF.Store();
			store.setParameter("MODULE_TYPE", "${param.MODULE_TYPE }");
			store.setParameter("TMPL_MENU_GROUP_CD", "${param.TMPL_MENU_GROUP_CD }");
        	store.load(baseUrl + 'listMenuTemplateTree', function() {
				
				var treeData = JSON.parse(this.getParameter("treeData"));

				for(var i= 0, dataOfL1 = treeData.length; i < dataOfL1; i++) {

					if(treeData[i].childs != undefined) {

						var childrenL1 = JSON.parse(treeData[i].childs);
						treeData[i].children = childrenL1;

						for(var j= 0, dataOfL2 = childrenL1.length; j < dataOfL2; j++) {
						
							if(childrenL1[j].childs != undefined) {

								var childrenL2 = JSON.parse(childrenL1[j].childs);
								childrenL1[j].children = childrenL2;

								for(var k= 0, dataOfL3 = childrenL2.length; k < dataOfL3; k++) {
								
									if(childrenL2[k].childs != undefined) {
									
										var childrenL3 = JSON.parse(childrenL2[k].childs);
										childrenL2[k].children = childrenL3;
									}
									childrenL2[k].isFolder = (childrenL2[k].isFolder === 'false' ? false : true);
									childrenL2[k].title = (childrenL2[k].useFlag === '1' ? childrenL2[k].title : "<strike><font color='#BDBDBD'>" + childrenL2[k].title + "</font></strike>");
								}
							}
							childrenL1[j].isFolder = (childrenL1[j].isFolder === 'false' ? false : true);
							childrenL1[j].title = (childrenL1[j].useFlag === '1' ? childrenL1[j].title : "<strike><font color='#BDBDBD'>" + childrenL1[j].title + "</font></strike>");
						}
					}
					treeData[i].isFolder = (treeData[i].isFolder === 'false' ? false : true);
					treeData[i].title = (treeData[i].useFlag === '1' ? treeData[i].title : "<strike><font color='#BDBDBD'>" + treeData[i].title + "</font></strike>");
				}
				$(function(){
					<%-- Attach the dynatree widget to an existing <div id="tree"> element --%>
					<%-- and pass the tree options as an argument to the dynatree() function: --%>
					
					$("#tree").dynatree({
		
						persist: false,
						keyboard: true,
						children: treeData,
						minExpandLevel: 3,
						
						onActivate: function(node) {
							<%-- A DynaTreeNode object is passed to the activation handler --%>
							<%-- Note: we also get this event, if persistence is on, and the page is reloaded. --%>
							<%-- alert("You activated " + node.data.title + ", " + node.data.key + ", " + node.data.isLazy + ", " + node.data.isFolder); --%>
							<%--  EVF.C('MENU_NM').setValue((node.data.menuNm == null || node.data.menuNm == '') ? node.data.title : node.data.menuNm); --%>
							EVF.C('MENU_NM').setValue((node.data.menuNm == null || node.data.menuNm == '') ? node.data.title : node.data.title);
							EVF.C('SCREEN_NM').setValue((node.data.isFolder) == true ? '' : node.data.title);
							EVF.C('USE_FLAG').setValue(node.data.useFlag);
							EVF.C('SCREEN_ID').setValue(node.data.screenId);
							EVF.C('TMPL_MENU_CD').setValue(node.data.key);
							EVF.C('HIGH_TMPL_MENU_CD').setValue(node.data.parentid);
							EVF.C('HIDDEN_SORT_SQ').setValue(node.data.sortSq);
		                   
							if(node.data.isFolder == true) {
								EVF.C('LEAF_FLAG').setChecked('leafFlag1');
							} else {
								EVF.C('LEAF_FLAG').setChecked('leafFlag2');
							}
							
							var store = new EVF.Store();
							store.setGrid([grid]); 
				            store.load(baseUrl + 'doSearchStocmuba', function() {
				            });							
						}
					});
					$("#tree").dynatree("getTree").reload();
				});
            });
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
    <e:window id="BSYM_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
	    <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Update" name="Update" label="${Update_N }" disabled="${Update_D }" onClick="doUpdate" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" />
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
			<p style="font-family: '맑은 고딕'; font-size:13px; font-weight:bold; color:blue;">▣ 직무유형별 메뉴권한 </p>
			<p style="font-family: '맑은 고딕'; font-size:12px; ">직무유형을 입력하지 않으시면 모든 사용자에게 권한이 부여됩니다.</p>
      		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
      		
		</e:panel>
		<e:panel id="treePanel" height="490px" width="40%">
			<e:searchPanel id="treeForm" useTitleBar="false">
  				<e:row>
                    <e:field>
  					    <div id="tree" style="height: 490px;"> </div>
                    </e:field>
  				</e:row>
  			</e:searchPanel>
		</e:panel>
    </e:window>
</e:ui>