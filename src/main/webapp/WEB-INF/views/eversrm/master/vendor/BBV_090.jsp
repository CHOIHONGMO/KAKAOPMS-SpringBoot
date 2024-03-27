<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 협력회사선택 화면 --%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var gridL;
    var gridR;
    var baseUrl = "/eversrm/master/vendor/";

    function init() {

        gridL = EVF.C("gridL");
        gridR = EVF.C("gridR");
        var json = ${empty param.candidateJson ? '[]' : param.candidateJson};

        if(json.length != 0) {
            var buyers = [];
            for(var v in json) {
                if(json.hasOwnProperty(v)){
                    buyers.push(json[v].BUYER_CD);
                }
            }
            var store = new EVF.Store();
            store.setGrid([gridR]);
            store.setParameter('selectedBuyers', JSON.stringify(buyers));
            store.load(baseUrl + "doSearchCandidate", function() {
                gridR.checkAll(true);
            });
        }

        gridL.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});
        gridR.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});
        gridL.setProperty('shrinkToFit', true);
        gridR.setProperty('shrinkToFit', true);
    }

    function doSearch() {

    	var store = new EVF.Store();
        store.setGrid([gridL, gridR]);
        store.load(baseUrl + "doSearchCandidate", function() {
            if (gridL.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
            if (gridL.getRowCount() == 1) {
            	gridL.checkAll(true);
            	doSendRight();
            }
        });
    }

    function doSendLeft() {
    	var selRowIdR = gridR.getSelRowId();
    	for(var x in selRowIdR) {
            var rowIdR = selRowIdR[x];
            gridR.delRow(rowIdR);
    	}
    }

	function doSendRight() {

		if(gridL.isEmpty(gridL.getSelRowId())) {
	        return alert("${msg.M0004}");
	    }

		gridR.checkAll(true);

        var selAllRowDataL = gridL.getSelRowValue();
        var selAllRowDataR = gridR.getSelRowValue();

        var buyers = [];
        for(var v in selAllRowDataL) {
            if(selAllRowDataL.hasOwnProperty(v)){
                buyers.push(selAllRowDataL[v].BUYER_CD);
            }
        }

        for(var v in selAllRowDataR) {
            if(selAllRowDataR.hasOwnProperty(v)){
                buyers.push(selAllRowDataR[v].BUYER_CD);
            }
        }

        var store = new EVF.Store();
        store.setGrid([gridR]);
        store.setParameter('selectedBuyers', JSON.stringify(buyers));
        store.load(baseUrl + "doSearchCandidate", function() {
            gridR.checkAll(true);
        });
	}

	function doSelect() {

        <%-- 초기화하고 싶을 때도 있을 것 같아서 무조건 하나 이상 선택해야하는 아래 로직은 일단 주석처리 --%>
        <%--if(!gridR.isExistsSelRow()) { return alert('${msg.M0004}'); }--%>

        var paramRowId = '${param.rowId}' || '${param.rowid}';
        var paramCallType = EVF.isEmpty("${param.callType}") ? "SINGLE" : "${param.callType}";
        var selAllRowDataR = gridR.getSelRowValue();

        if(selAllRowDataR.length == 0) {
        	return alert('${msg.M0004}');
        }
        if(paramCallType === "SINGLE" && selAllRowDataR.length > 1) {
        	return alert('${msg.M0006}');
        }

        opener.window['${param.callBackFunction}'](JSON.stringify(selAllRowDataR), paramRowId);
        doClose();
    }

	function doClose() {
        formUtil.close();
    }

    </script>

    <e:window id="BBV_090" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="135" onEnter="doSearchL" useTitleBar="false">
            <e:row>
                <e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
                <e:field>
                    <e:inputText id="BUYER_CD" style="${imeMode}" name="BUYER_CD" value="" width="${form_BUYER_CD_W}" maxLength="${form_BUYER_CD_M}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}"/>
                </e:field>
                <e:label for="BUYER_NM" title="${form_BUYER_NM_N}"/>
                <e:field>
                    <e:inputText id="BUYER_NM" style="${imeMode}" name="BUYER_NM" value="" width="${form_BUYER_NM_W}" maxLength="${form_BUYER_NM_M}" disabled="${form_BUYER_NM_D}" readOnly="${form_BUYER_NM_RO}" required="${form_BUYER_NM_R}"/>
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button id='Search' label='${Search_N }' disabled='${Search_D }' visible='${Search_V }' data='${Search_A }' onClick='doSearch' />
            <c:if test="${!param.detailView}">
                <e:button id='Select' label='${Select_N }' disabled='${Select_D }' visible='${Select_V }' data='${Select_A }' onClick='doSelect' />
            </c:if>
        </e:buttonBar>
        <e:panel height="fit" width="100%">
            <e:panel width="49%">
                <e:title title="${BBV_090_0002 }" />
                <e:gridPanel id="gridL" name="gridL" height="fit" width="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
            </e:panel>
            <e:panel width="2%" height="100%">
                <div style="width: 100%; margin-top: 200px; vertical-align: middle;" align="center">
                <c:if test="${param.VENDORSELTYPE != 'NOTSEL'}">
                    <div id="doSendRight" style="background: url(/images/eversrm/button/thumb_next.png) no-repeat; width: 13px; height: 22px; display: inline-block; cursor: pointer;" onclick="doSendRight();">&nbsp;</div>
				</c:if>
                    <div id="doSendLeft" style="background: url(/images/eversrm/button/thumb_prev.png) no-repeat; width: 13px; height: 22px; display: inline-block; margin-top: 10px; cursor: pointer;" onclick="doSendLeft();">&nbsp;</div>
                </div>
            </e:panel>
            <e:panel width="49%">
                <e:title title="${BBV_090_0001}" />
                <e:gridPanel id="gridR" name="gridR" height="fit" width="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />
            </e:panel>
        </e:panel>
    </e:window>
</e:ui>
