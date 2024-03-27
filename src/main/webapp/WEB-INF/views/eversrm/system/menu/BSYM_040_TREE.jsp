<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<link rel="StyleSheet" href="/js/dtree/dtree.css" type="text/css" />
	<script type="text/javascript" src="/js/dtree/dtree.js"></script>
    <script type="text/javascript">

    	var baseUrl = "/eversrm/system/menu/menuGroupCode/";
    	var grid = {};
    	var addParam = [];
    	var dl, dr;

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
        	store.load(baseUrl + 'loadDtree', function() {

				<%-- Left Tree --%>
				var lJsontree = JSON.parse(this.getParameter("mumsData"));
				dl = new dTree('dl');

				for (var k = 0; k < lJsontree.length; k++) {
					if (k == 0) {
						dl.add(0, -1, 'Root', '', '');
					}
					dl.add(lJsontree[k].TMPL_MENU_CD,
							lJsontree[k].HIGH_TMPL_MENU_CD,
							lJsontree[k].SCREEN_NM,
							lJsontree[k].TMPL_MENU_CD,
							JSON.stringify(lJsontree[k]));
				}

				document.getElementById("leftTree").innerHTML = dl;

				dl.openAll();

				<%-- Right Tree --%>
				var rJsontree = JSON.parse(this.getParameter("treeData"));
				dr = new dTree('dr');

				for (var i = 0; i < rJsontree.length; i++) {
					if (i == 0) {
						dr.add(0, -1, 'Root', '', '');
					}
					dr.add(rJsontree[i].TMPL_MENU_CD,
							rJsontree[i].HIGH_TMPL_MENU_CD,
							rJsontree[i].SCREEN_NM,
							rJsontree[i].TMPL_MENU_CD,
							JSON.stringify(rJsontree[i]));
				}

				document.getElementById("rightTree").innerHTML = dr;

				dr.openAll();
            });
        }

		function goTarget(nodeId, rootNode) {
			if(rootNode == "dr") {
				// 클릭 시 노드 저장
				var drSelData = JSON.parse(dr.aNodes[dr.selectedNode].data);

				for(var idx in dr.aNodes) {
					if(idx > 0) {
						var dtreeData = dr.aNodes[idx].data;

						if(dtreeData != "")
							dtreeData = JSON.parse(dtreeData);

						if(drSelData.TMPL_MENU_CD == dtreeData.TMPL_MENU_CD || drSelData.TMPL_MENU_CD == dtreeData.HIGH_TMPL_MENU_CD) {
							addParam = [{'MENU_CD': (dtreeData.MENU_CD == "undefined" ? "" : dtreeData.MENU_CD), 'TMPL_MENU_CD': dtreeData.TMPL_MENU_CD}];
							grid.addRow(addParam);
						}
					}
				}

				if (!confirm("${msg.M0105 }")) return;
					doSave();

			} else {
				// 클릭 시 노드 삭제
				var dlSelData = JSON.parse(dl.aNodes[dl.selectedNode].data);

				addParam = [{'MENU_CD': (dlSelData.MENU_CD == "undefined" ? "" : dlSelData.MENU_CD), 'TMPL_MENU_CD': dlSelData.TMPL_MENU_CD}];
				grid.addRow(addParam);

				if (!confirm("${msg.M0013 }")) return;
					doDelete();

			}
		}

        function doSaveAll() {
        	if (!confirm("${msg.M0021 }")) return;
        	doSave();
        }

        function doSave() {

			var allData = [];

			// Tree 데이터를 List화 한다.
			console.log(dl.aNodes);
			console.log(dr.aNodes);
			for(var idx in dl.aNodes) {
				if(idx > 0) {
					var dtreeData = dl.aNodes[idx].data;

					if(dtreeData != "")
						dtreeData = JSON.parse(dtreeData);

					var itemData = {};
					itemData.TMPL_MENU_CD = dtreeData.TMPL_MENU_CD;
					itemData.MENU_CD = dtreeData.MENU_CD;
					itemData.USE_FLAG = "1";
					allData.push(itemData);
				}
			}

			// Grid 데이터를 List화하여 Tree 데이터와 합친다.
			var rowIds = grid.jsonToArray(grid.getSelRowId()).value;
			for(var i = 0; i < rowIds.length; i++) {
				var selectedData = grid.getRowValue(rowIds[i]);
				var itemData = {};
				itemData.TMPL_MENU_CD = selectedData.TMPL_MENU_CD;
				itemData.MENU_CD = selectedData.MENU_CD;
				itemData.USE_FLAG = "1";
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

		function doDelete() {

			var allData = [];

			// Tree 데이터를 List화 한다.
			for(var idx in dl.aNodes) {
				if(idx > 0) {
					var dtreeData = dl.aNodes[idx].data;

					if(dtreeData != "")
						dtreeData = JSON.parse(dtreeData);

					var itemData = {};

					// Grid 데이터를 List화하여 Tree 데이터와 동일한 값이 있으면 제외.
					var rowIds = grid.jsonToArray(grid.getSelRowId()).value;
					for(var i = 0; i < rowIds.length; i++) {
						var selectedData = grid.getRowValue(rowIds[i]);
						var itemData = {};
						if(selectedData.TMPL_MENU_CD != dtreeData.TMPL_MENU_CD) {
							itemData.TMPL_MENU_CD = dtreeData.TMPL_MENU_CD;
							itemData.MENU_CD = dtreeData.MENU_CD;
							itemData.USE_FLAG = "1";

							if(selectedData.TMPL_MENU_CD == dtreeData.HIGH_TMPL_MENU_CD) {
								itemData.USE_FLAG = "0";
							}

							allData.push(itemData);
						} else {
							itemData.TMPL_MENU_CD = dtreeData.TMPL_MENU_CD;
							itemData.MENU_CD = dtreeData.MENU_CD;
							itemData.USE_FLAG = "0";
							allData.push(itemData);


						}
					}
				}
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
	    <%--<e:buttonBar id="buttonBar" align="right" width="100%" height="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSaveAll" />
        </e:buttonBar>--%>
		<%--grid로 값이 등록되면서 화면이 위로 올라가는 현상 수정--%>
		<e:panel id="leftPanel" width="50%" height="100%">
		<e:title title="사용자에게 보여지는 메뉴"></e:title>
			<e:searchPanel id="leftTreeForm" title="사용자에게 보여지는 메뉴" height="100%"  useTitleBar="false">
  				<e:row>
                    <e:field>
  					    <div id="leftTree" style="height:600px; overflow: auto;"> </div>
                    </e:field>
  				</e:row>
  			</e:searchPanel>
		</e:panel>
		<e:panel id="rightPanel" width="50%" height="100%">
		<e:title title="메뉴 템플릿"></e:title>
			<e:searchPanel id="rightTreeForm" height="100%" title="메뉴 템플릿" useTitleBar="false">
  				<e:row>
                    <e:field>
  					    <div id="rightTree" style="height:600px; overflow: auto;"> </div>
                    </e:field>
  				</e:row>
  			</e:searchPanel>
		</e:panel>
		<div style="display: none;">
		<e:gridPanel gridType="RG" id="grid" name="grid" width="0%" height="0" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		</div>
    </e:window>
</e:ui>