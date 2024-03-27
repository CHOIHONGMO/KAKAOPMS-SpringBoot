<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

    	var baseUrl = "/eversrm/system/menu/menuGroupCode/";
    	var grid = {};
    	var addParam = [];
    	
		function init() {
			grid = EVF.C('grid');
			doSearch();
        }

        function doSearch() {
		
			var store = new EVF.Store();
			store.setGrid([grid]);
			store.setParameter("MENU_GROUP_CD", "${param.MENU_GROUP_CD }");
			store.setParameter("TMPL_MENU_GROUP_CD", "${param.TMPL_MENU_GROUP_CD }");
			store.setParameter("MODULE_TYPE", "${param.MODULE_TYPE }");
        	store.load(baseUrl + 'loadTree', function() {
        		
        		<%-- grid.checkAll(true); --%>
				
				<%-- Right Tree --%>
				var treeData = JSON.parse(this.getParameter("treeData"));

				for(var i = 0; i < treeData.length; i++) {

					if(treeData[i].childs != undefined) {

						var childrenL1 = JSON.parse(treeData[i].childs);
						treeData[i].children = childrenL1;

						for(var j = 0; j < childrenL1.length; j++) {
						
							if(childrenL1[j].childs != undefined) {

								var childrenL2 = JSON.parse(childrenL1[j].childs);
								childrenL1[j].children = childrenL2;

								for(var k = 0; k < childrenL2.length; k++) {
								
									if(childrenL2[k].childs != undefined) {
									
										var childrenL3 = JSON.parse(childrenL2[k].childs);
										childrenL2[k].children = childrenL3;
									}
									childrenL2[k].isFolder = (childrenL2[k].isFolder == 'false' ? false : true);
								}
							}
							childrenL1[j].isFolder = (childrenL1[j].isFolder == 'false' ? false : true);
						}
					}
					treeData[i].isFolder = (treeData[i].isFolder == 'false' ? false : true);
				}
				
				<%-- Left Tree --%>
				var mumsData = JSON.parse(this.getParameter("mumsData"));

				for(var i= 0, dataOfL1 = mumsData.length; i < dataOfL1; i++) {

					if(mumsData[i].childs != undefined) {

						var childrenL1 = JSON.parse(mumsData[i].childs);
						mumsData[i].children = childrenL1;

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
								}
							}
							childrenL1[j].isFolder = (childrenL1[j].isFolder === 'false' ? false : true);
						}
					}
					mumsData[i].isFolder = (mumsData[i].isFolder === 'false' ? false : true);
				}
				$(function(){
					
					<%-- Right Tree --%>
					$("#rightTree").dynatree({
		
						persist: false,
						selectMode: 3,
						children: treeData,
						minExpandLevel: 3,
						
						onActivate: function(node) {
						
							// 최상위 Depth를 선택했을 때에는 전체 데이터를 왼쪽 Tree로 옮긴다.
							if(node.getParent().data.key == "_1")
							{
								$("#leftTree").dynatree("getRoot").addChild(node.data);
							}
							else {

								var parentsArg = node.getKeyPath().split('/');

								for(var i = 1; i < parentsArg.length; i++) {
								
									var pNode = $("#rightTree").dynatree("getTree").getNodeByKey(parentsArg[i]).data;

									// 마지막(클릭한) Depth의 데이터는 전부 왼쪽 Tree로 옮긴다.
									if((eval(i)+1) == parentsArg.length) {

										$("#leftTree").dynatree("getRoot").addChild(pNode);

									}
									else { // 부모가 존재하면 부모의 Key만 grid에 넣는다.
										addParam = [{'MENU_CD': (pNode.menuCd == "undefined" ? "" : pNode.menuCd), 'TMPL_MENU_CD': pNode.key}];
										grid.addRow(addParam);
									}
								}
							}
							// 저장로직 실행.
							if (!confirm("${msg.M0105 }")) return;
							doSave();
						}
					});
					$("#rightTree").dynatree("getTree").reload();
					
					<%-- Left Tree --%>
					$("#leftTree").dynatree({
		
						persist: false,
						children: mumsData,
						minExpandLevel: 3,
						
						onActivate: function(nodeL) {

							if (!confirm("${msg.M0013 }")) return;

							var activeNode = $("#leftTree").dynatree("getTree").getActiveNode();
			                activeNode.remove();
						}
					});
					$("#leftTree").dynatree("getTree").reload();
				});
            });
        }
        
        function doSaveAll() {
        	if (!confirm("${msg.M0021 }")) return;
        	doSave();
        }
        
        function doSave() {
        
        	var allData = [];

			// Tree 데이터를 List화 한다.
        	$("#leftTree").dynatree("getTree").visit(function(node) {

				var itemData = {};
		        itemData.TMPL_MENU_CD = node.data.key;
		        itemData.MENU_CD = node.data.menuCd;
		        allData.push(itemData);
		    });
		    
		    // Tree 데이터를 List화하여 Tree 데이터와 합친다.
		    var rowIds = grid.jsonToArray(grid.getSelRowId()).value;
		    for(var i = 0; i < rowIds.length; i++) {
		    	var selectedData = grid.getRowValue(rowIds[i]);
		    	var itemData = {};
		        itemData.TMPL_MENU_CD = selectedData.TMPL_MENU_CD;
		        itemData.MENU_CD = selectedData.MENU_CD;
		        allData.push(itemData);
		    }

	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
	        store.setParameter("treeData", JSON.stringify(allData));
	        store.setParameter("MENU_GROUP_CD", "${param.MENU_GROUP_CD }");
			store.setParameter("MODULE_TYPE", "${param.MODULE_TYPE }");
        	store.load(baseUrl + 'doSaveMenuGroupCode', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
		}
		
		function doClose() {
			window.close();
		}
	    
    </script>
    <e:window id="BSYM_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
	    <e:buttonBar id="buttonBar" align="right" width="100%" height="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSaveAll" />
            <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" />
        </e:buttonBar>
		<%--grid로 값이 등록되면서 화면이 위로 올라가는 현상 수정--%>
		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="0%" height="0px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		<e:panel id="leftPanel" width="50%" height="100%">
			<e:searchPanel id="leftTreeForm" title="사용자에게 보여지는 메뉴" height="100%"  useTitleBar="true">
  				<e:row>
                    <e:field>
  					    <div id="leftTree" style="height:600px;"> </div>
                    </e:field>
  				</e:row>
  			</e:searchPanel>
		</e:panel>
		<e:panel id="rightPanel" width="50%" height="100%">
			<e:searchPanel id="rightTreeForm" height="100%" title="메뉴 템플릿" useTitleBar="true">
  				<e:row>
                    <e:field>
  					    <div id="rightTree" style="height:600px;"> </div>
                    </e:field>
  				</e:row>
  			</e:searchPanel>
		</e:panel>
    </e:window>
</e:ui>