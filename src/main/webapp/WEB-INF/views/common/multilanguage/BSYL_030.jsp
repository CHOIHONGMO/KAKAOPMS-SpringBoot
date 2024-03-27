<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/multiLang/multiLanguagePopup/";
    	var flag = "";

		function init() {

			grid = EVF.C('grid');

			grid.addRowEvent(function() {
				grid.addRow([{"LANG_CD":"KO"}]);
			});
			var choose_button_visibility = '${param.choose_button_visibility}';
	        if (choose_button_visibility === 'false') {
	            EVF.C('Choose').setVisible(false);
	        }

	        grid.setProperty('shrinkToFit', true);
	        doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
        	store.setParameter('multi_cd', EVF.C('multi_cd').getValue());
	        store.setParameter('screen_id', EVF.C('screen_id').getValue());
	        store.setParameter('tmpl_menu_group_cd', EVF.C('tmpl_menu_group_cd').getValue());
	        store.setParameter('auth_cd', EVF.C('auth_cd').getValue());
	        store.setParameter('menu_group_cd', EVF.C('menu_group_cd').getValue());
	        store.setParameter('action_cd', EVF.C('action_cd').getValue());
	        store.setParameter('action_profile_cd', EVF.C('action_profile_cd').getValue());
	        store.setParameter('tmpl_menu_cd', EVF.C('tmpl_menu_cd').getValue());
	        store.setParameter('common_id', EVF.C('common_id').getValue());

	        if (EVF.C('screen_id').getValue() == "" && EVF.C('tmpl_menu_group_cd').getValue() == "" && EVF.C('auth_cd').getValue() == "" && EVF.C('menu_group_cd').getValue() == "" && EVF.C('action_cd').getValue() == "" && EVF.C('action_profile_cd').getValue() == "" && EVF.C('tmpl_menu_cd').getValue() == "" && EVF.C('common_id').getValue() == "") {
	            alert("There is not exists parameter value. Please enter parameter value.");
	            return;
	        }

            store.load(baseUrl + 'doSearch', function() {
                if(grid.getRowCount() == 0){
                //	alert("${msg.M0002 }");
                }

                grid.checkAll(true);
            });
        }

        function doSave() {

			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
			if (!grid.validate().flag) { return alert(grid.validate().msg); }

			var rowIds = grid.jsonToArray(grid.getSelRowId()).value;
			var rowData1 = {};
			var rowData2 = {};

			for(var i in rowIds) {

				rowData1 = grid.getRowValue(rowIds[i]);

				for(var j in rowIds) {
					if(rowIds[i] == rowIds[j]) { continue; }

					rowData2 = grid.getRowValue(rowIds[j]);

					if (rowData1.LANG_CD == rowData2.LANG_CD) {
                        alert("${msg.M0086 }");
                        return;
	                }
				}
			}

			if (!confirm("${msg.M0021 }")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doSave', function(){
        		alert(this.getResponseMessage());
        		flag = 1;
        		doSearch();
        		if('${param.choose_button_visibility}' == 'false') {
        			parent['${param.callBackFunction}']();
		    		doClose();
		    	}
        	});
        }

		function doDelete() {

			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }

			if (!confirm("${msg.M0013 }")) {
	            return;
	        }
			var store = new EVF.Store();
			store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doDelete', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

        function doChoose() {

	        var multi_cd = EVF.C('multi_cd').getValue();
	        var checkRowId = grid.jsonToArray(grid.getSelRowId()).value;
	        var chkRowIdLen = checkRowId.length;
	        var rowData = {};
	        var multiNm = "";

	        if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }
			if (chkRowIdLen > 1) {
	            alert("${msg.M0006}");
	            return;
	        }

			for(var i = 0; i < chkRowIdLen; i++) {
	        	rowData = grid.getRowValue(checkRowId[i]);
	        	multiNm = rowData.MULTI_NM;
	        	multi_Desc = rowData.MULTI_DESC;
	        	if (rowData.INSERT_FLAG !== 'U') {
		            alert('${msg.M0007}');
		            return;
		        }
	        }

	        var multiLanguagePopupReturn = {
	            rowid: '${param.rowid}',
	            multiNm: multiNm,
	            multi_Desc : multi_Desc
	        };

	        parent['${param.callBackFunction}'](multiLanguagePopupReturn);
		    doClose();
	    }

		function doClose() {
	        new EVF.ModalWindow().close(null);
	    }

    </script>
    <e:window id="BSYL_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="multi_nm" name="multi_nm" value="${searchParam.multi_nm }"/>
        <e:inputHidden id="multi_cd" name="multi_cd" value="${searchParam.multi_cd }"/>
        <e:inputHidden id="screen_id" name="screen_id" value="${searchParam.screen_id }"/>
        <e:inputHidden id="tmpl_menu_group_cd" name="tmpl_menu_group_cd" value="${searchParam.tmpl_menu_group_cd }"/>
        <e:inputHidden id="auth_cd" name="auth_cd" value="${searchParam.auth_cd }"/>
        <e:inputHidden id="menu_group_cd" name="menu_group_cd" value="${searchParam.menu_group_cd }"/>
        <e:inputHidden id="action_cd" name="action_cd" value="${searchParam.action_cd }"/>
        <e:inputHidden id="action_profile_cd" name="action_profile_cd" value="${searchParam.action_profile_cd }"/>
        <e:inputHidden id="tmpl_menu_cd" name="tmpl_menu_cd" value="${searchParam.tmpl_menu_cd }"/>
        <e:inputHidden id="common_id" name="common_id" value="${searchParam.common_id }"/>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Choose" name="Choose" label="${Choose_N }" disabled="${Choose_D }" onClick="doChoose" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <%-- <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" /> --%>
        </e:buttonBar>

	    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>