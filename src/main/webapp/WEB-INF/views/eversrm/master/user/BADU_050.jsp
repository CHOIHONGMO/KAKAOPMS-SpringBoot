<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
        var multiYN = '${param.multiYN}';
    	var baseUrl = "/eversrm/master/user/";

		function init() {


			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});

            if(multiYN == 'true'){
                grid.showCheckBar(true);
            } else if (multiYN == 'false') {
                grid.showCheckBar(false);
            }

            grid.cellClickEvent(function(rowId, cellName, value, iRow, iCol) {
				if (cellName == 'USER_NM') {
					selectedData = grid.getRowValue(rowId);
					selectedData["rowId"] = "${param.nRow}";
					parent.${param.callBackFunction}(selectedData);
					new EVF.ModalWindow().close(null);
				}
			});

			if ('${ses.userType}' == 'B' || '${param.userNm}' == 'B') {
				EVF.V('USER_TYPE', 'B');
				EVF.C('USER_TYPE').setDisabled(true);
			} else if ('${ses.userType}' == 'S') {
				EVF.V('USER_TYPE', 'S');
				EVF.C('USER_TYPE').setDisabled(true);
            }

			if('${param.mode}' == "approval") {
				EVF.C('USER_TYPE').removeOption('S');
				EVF.V('USER_TYPE', '${ses.userType}');
			}

			if("${param.userNm}" > " ") {
				Search();
			}
        }

        function Search() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
        	store.setParameter("mode", '${param.mode}');
        	store.setParameter("buyerCd", '${param.buyerCd}');
            store.load(baseUrl + '/BADU_050/selectUserSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        function Close() {
        	new EVF.ModalWindow().close(null);
        }

        function doSave() {

        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
			if (!grid.validate().flag) { return alert(grid.validate().msg); }

			if (!confirm("${msg.M0021 }")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doSave', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

		function doDelete() {

			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }

			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doDelete', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

        function doChoice() {
			
			var selectedData = grid.getSelRowValue();
            if( grid.isEmpty(selectedData) ) { return; }
            
            if(opener != null){opener['${param.callBackFunction}'](selectedData);}
            else{parent['${param.callBackFunction}'](selectedData);}
        }

    </script>
    
    <e:window id="BADU_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" labelWidth="${labelWidth}" width="100%" useTitleBar="false" onEnter="Search">
            <e:row>
                <c:if test="${ses.userType == 'C'}">
                    <e:label for="BUYER_NM" title="${form_BUYER_NM_N}"/>
                    <e:field colSpan="3">
                        <e:select id="USER_TYPE" name="USER_TYPE" value="C" options="${refUSER_TYPE}" width="20%" disabled="${form_USER_TYPE_D}" readOnly="${form_USER_TYPE_RO}" required="${form_USER_TYPE_R}" placeHolder="" usePlaceHolder="false"/>
                        <e:inputText id="BUYER_NM" name="BUYER_NM" value="${ses.companyNm}" width="80%" maxLength="${form_BUYER_NM_M}" disabled="${form_BUYER_NM_D}" readOnly="${form_BUYER_NM_RO}" required="${form_BUYER_NM_R}" />
                    </e:field>
                </c:if>
                <c:if test="${ses.userType == 'B'}">
                    <e:label for="BUYER_NM" title="${form_BUYER_NM_N}"/>
                    <e:field colSpan="3">
                        <e:select id="USER_TYPE" name="USER_TYPE" value="B" options="${refUSER_TYPE}" width="20%" disabled="${form_USER_TYPE_D}" readOnly="${form_USER_TYPE_RO}" required="${form_USER_TYPE_R}" placeHolder="" usePlaceHolder="false"/>
                        <e:inputText id="BUYER_NM" name="BUYER_NM" value="${ses.companyNm}" width="80%" maxLength="${form_BUYER_NM_M}" disabled="true" readOnly="${form_BUYER_NM_RO}" required="${form_BUYER_NM_R}" />
                    </e:field>
                </c:if>
            </e:row>
            <e:row>
				<e:label for="USER_NM" title="${form_USER_NM_N}"/>
				<e:field>
				<e:inputText id="USER_NM" name="USER_NM" value="${param.userNm eq 'B' ? '' : param.userNm}" width="100%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
				 </e:field>
				<e:label for="DEPT_NM" title="${form_DEPT_NM_N}"/>
				<e:field>
				<e:inputText id="DEPT_NM" name="DEPT_NM" value="${form.DEPT_NM}" width="100%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
				 </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <c:if test="${param.multiYN == 'true'}">
                <e:button id="Choice" name="Choice" label="${Choice_N}" onClick="doChoice" disabled="${Choice_D}" visible="${Choice_V}"/>
            </c:if>
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="Search" />
            <e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="Close" />
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>