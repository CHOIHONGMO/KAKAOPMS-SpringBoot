<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
    var baseUrl = "/eversrm/srm/master/evalTemplate/";
    var leftGrid   = {};
    var rightGrid   = {};

    function init() {
        leftGrid = EVF.getComponent("leftGrid");
        rightGrid = EVF.getComponent("rightGrid");
        leftGrid.setProperty('shrinkToFit', true);
        rightGrid.setProperty('shrinkToFit', true);
        doSearchR();
    }

    function doSearchL() {
		var store = new EVF.Store();	// formL
		store.setGrid([leftGrid]);
		store.load(baseUrl + '/SRM_101/doSearch', function() {
		});

    }

    function doSearchR() {
		var data = opener.rightGrid.getSelRowValue();
        for (k = 0; k < data.length; k++) {
	   	    	addParam = [
	       	            	{
	       	        	    	 "EV_ITEM_KIND_CD" : data[k].EV_ITEM_KIND_CD
	       	        	    	,"EV_ITEM_KIND_CD_NM" : data[k].EV_ITEM_KIND_CD_NM
	       	        	    	,"EV_ITEM_METHOD_CD" : data[k].EV_ITEM_METHOD_CD
	       	        	    	,"EV_ITEM_NUM" : data[k].EV_ITEM_NUM
	       	        	    	,"GATE_CD" : data[k].GATE_CD
	       	        	    	,"SCALE_TYPE_CD" : data[k].SCALE_TYPE_CD
	       	        	    	,"EV_ITEM_SUBJECT" : data[k].EV_ITEM_SUBJECT
	       	        	    	,"EV_ITEM_TYPE_CD" : data[k].EV_ITEM_TYPE_CD
	       	        	    	,"EV_ITEM_METHOD_CD_NM" : data[k].EV_ITEM_METHOD_CD_NM
	       	        	    	,"SCALE_TYPE_CD_NM" : data[k].SCALE_TYPE_CD_NM
	       	            	}
	       	            ];
	   	    	rightGrid.addRow(addParam);
        }
    }

    function doSendLeft() {

    	var kkk = rightGrid.jsonToArray(rightGrid.getSelRowId()).value;
    	 for (var i = kkk.length - 1; i > -1; i--) {
    		 rightGrid.delRow(kkk[i]);

    	 }
    }
    function doSendRight() {

    	if( leftGrid.isEmpty( leftGrid.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        var kkk = leftGrid.jsonToArray(leftGrid.getSelRowId()).value;
        for (var i = kkk.length - 1; i > -1; i--) {
                var EV_ITEM_NUM       = leftGrid.getCellValue(kkk[i], "EV_ITEM_NUM");
                var rightRowCount = rightGrid.getRowCount();
                var addOk = "ok";

                for (var j = rightRowCount - 1; j > -1; j--) {
                    if (rightGrid.getCellValue(j, "EV_ITEM_NUM") == EV_ITEM_NUM) {
                        addOk = "fail";
                       break;
                    }
                }

                if (addOk == "ok") {
            		rightGrid.addRow([{
    	 						   'EV_ITEM_KIND_CD'     : leftGrid.getCellValue(kkk[i], "USEREV_ITEM_KIND_CD_ID")
        	 					 , 'EV_ITEM_KIND_CD_NM'     : leftGrid.getCellValue(kkk[i], "EV_ITEM_KIND_CD_NM")
        	 					 , 'EV_ITEM_METHOD_CD'     : leftGrid.getCellValue(kkk[i], "EV_ITEM_METHOD_CD")
        	 					 , 'EV_ITEM_NUM'     : leftGrid.getCellValue(kkk[i], "EV_ITEM_NUM")
        	 					 , 'GATE_CD'     : leftGrid.getCellValue(kkk[i], "GATE_CD")
        	 					 , 'SCALE_TYPE_CD'     : leftGrid.getCellValue(kkk[i], "SCALE_TYPE_CD")
        	 					 , 'EV_ITEM_SUBJECT'     : leftGrid.getCellValue(kkk[i], "EV_ITEM_SUBJECT")
        	 					 , 'EV_ITEM_TYPE_CD'     : leftGrid.getCellValue(kkk[i], "EV_ITEM_TYPE_CD")
        	 					 , 'EV_ITEM_METHOD_CD_NM'     : leftGrid.getCellValue(kkk[i], "EV_ITEM_METHOD_CD_NM")
        	 					 , 'SCALE_TYPE_CD_NM'     : leftGrid.getCellValue(kkk[i], "SCALE_TYPE_CD_NM")

            		}]);
                }
        }
    }
    function doApply() {
    	rightGrid.checkAll(true);
    	var data = rightGrid.getSelRowValue();
    	opener['${param.callBackFunction}'](data);

    	doClose();
    }

	function doClose() {
        window.close();
    }

	</script>

    <e:window id="SRM_101" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
	<e:panel id="pnl1" width="100%">
    	<e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" onEnter="doSearchL" useTitleBar="false">
        	<e:row>
			<e:label for="EVAL_KIND_CB" title="${form_EVAL_KIND_CB_N}"/>
			<e:field>
			<e:select id="EVAL_KIND_CB" name="EVAL_KIND_CB" value="${param.evalKind}" options="${evalKind }" width="${inputTextWidth}" disabled="true" readOnly="${form_EVAL_KIND_CB_RO}" required="${form_EVAL_KIND_CB_R}" placeHolder="" />
			</e:field>
			<e:label for="EVAL_TYPE_CB" title="${form_EVAL_TYPE_CB_N}"/>
			<e:field>
			<e:select id="EVAL_TYPE_CB" name="EVAL_TYPE_CB" value="${form.EVAL_TYPE_CB}" options="${evalType }" width="100%" disabled="${form_EVAL_TYPE_CB_D}" readOnly="${form_EVAL_TYPE_CB_RO}" required="${form_EVAL_TYPE_CB_R}" placeHolder="" />
			</e:field>
            </e:row>
        	<e:row>
				<e:label for="EVAL_METHOD_CB" title="${form_EVAL_METHOD_CB_N}"/>
				<e:field>
				<e:select id="EVAL_METHOD_CB" name="EVAL_METHOD_CB" value="${form.EVAL_METHOD_CB}" options="${evalMethod }" width="${inputTextWidth}" disabled="${form_EVAL_METHOD_CB_D}" readOnly="${form_EVAL_METHOD_CB_RO}" required="${form_EVAL_METHOD_CB_R}" placeHolder="" />
				</e:field>
				<e:label for="EVAL_ITEM_TXT" title="${form_EVAL_ITEM_TXT_N}" />
				<e:field>
				<e:inputText id="EVAL_ITEM_TXT" style="ime-mode:auto" name="EVAL_ITEM_TXT" value="${form.EVAL_ITEM_TXT}" width="100%" maxLength="${form_EVAL_ITEM_TXT_M}" disabled="${form_EVAL_ITEM_TXT_D}" readOnly="${form_EVAL_ITEM_TXT_RO}" required="${form_EVAL_ITEM_TXT_R}"/>
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="a" width="100%"  align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearchL" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doChoose" name="doChoose" label="${doChoose_N}" onClick="doApply" disabled="${doChoose_D}" visible="${doChoose_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

    	<e:panel id="x1" width="49%">
        <e:gridPanel gridType="${_gridType}" id="leftGrid" name="leftGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.leftGrid.gridColData}" />
    	</e:panel>

		<e:panel id="x3" width="2%" height="100%">
	        <div ><BR><BR><BR><BR><BR><BR><BR><BR><BR>
	        	&nbsp;<img src="/images/icon/thumb_next.png" width="11" height="22" onClick="doSendRight()" style="cursor: pointer;">
	        	<BR><BR>
				&nbsp;<img src="/images/icon/thumb_prev.png" width="11" height="22" onClick="doSendLeft()" style="cursor: pointer;">
	        </div>
		</e:panel>
			<e:panel id="x2" width="49%">
	         <e:gridPanel gridType="${_gridType}" id="rightGrid" name="rightGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.rightGrid.gridColData}" />
		</e:panel>
	</e:panel>

    </e:window>
</e:ui>

