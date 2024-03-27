<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 협력회사선택 화면 --%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var gridL;
    var gridR;
    var baseUrl = "/eversrm/purchase/rfiMgt/";
    var conFlag = "${empty param.CON_FLAG ? "Y" : param.CON_FLAG}";

    function init() {

        gridL = EVF.C("gridL");
        gridR = EVF.C("gridR");
        gridL.setProperty('panelVisible', ${panelVisible});
        gridR.setProperty('panelVisible', ${panelVisible});
        var json = ${empty param.candidateJson ? '[]' : param.candidateJson};
        var callType = "${empty param.callType ? "" : param.callType}";

        if(json.length != 0) {
            var vendors = [];
            for(var v in json) {
                if(json.hasOwnProperty(v)){
                    vendors.push(json[v].VENDOR_CD);
                }
            }
            var store = new EVF.Store();
            store.setGrid([gridR]);
            store.setParameter('selectedVendors', JSON.stringify(vendors));
            store.load(baseUrl + "BPRI_020/doSearch", function() {
                gridR.checkAll(true);
            });
        }

        gridL.excelExportEvent({
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

        gridR.excelExportEvent({
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

        // 견적요청에서 예가가 500만원 미만인 경우 N/W전문업체 3개를 시스템에서 random으로 자동 지정.
        if(callType === "RFX") {
        	if(json.length == 0) {
        		doSearchForRFX();
        	}
        }
    }

    function doSearch() {

    	var store = new EVF.Store();
        store.setGrid([gridL, gridR]);
        store.setParameter("CON_FLAG", conFlag);
        store.load(baseUrl + "BPRI_020/doSearch", function() {
            if (gridL.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
            if (gridL.getRowCount() == 1) {
            	gridL.checkAll(true);
            	doSendRight();
            }
        });
    }

    function doSearchForRFX() {

    	var store = new EVF.Store();
        store.setGrid([gridL, gridR]);
        store.setParameter("CON_FLAG", conFlag);
        store.load(baseUrl + "BPRI_020/doSearchForRFX", function() {
            if (gridL.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
            else {
            	gridL.checkAll(true);
            	var data = gridL.getSelRowValue();
            	gridR.addRow(data);
            	gridL.delRow();
            }
        });
    }

    function searchVendorCode() {
        var param = {
            callBackFunction: "selectVendorCode"
        };
        everPopup.openCommonPopup(param, 'SP0025');
    }

    function selectVendorCode(dataJsonArray) {
        EVF.C("VENDOR_CD").setValue(dataJsonArray['VENDOR_CD']);
        EVF.C("VENDOR_NM").setValue(dataJsonArray['VENDOR_NM']);
    }

/*
    function doSendLeft() {

        if(!gridR.isExistsSelRow()) { return alert('${msg.M0004}'); }

        var selRowIdR = gridR.getSelRowId();
        for(var x in selRowIdR) {
            var rowIdR = selRowIdR[x];
            var rowDataR = gridR.getRowValue(rowIdR);
            delete rowDataR['CREDIT_RATING'];

            var addPossible = true;
            var vendorCodeR = rowDataR['VENDOR_CD'];

            var rowDataL = gridL.getAllRowValue();
            for(var y in rowDataL) {
                var vendorCodeL = rowDataL[y]['VENDOR_CD'];
                if(vendorCodeL === vendorCodeR) {
                    addPossible = false;
                }
            }

            if(addPossible) {
                gridL.addRow([rowDataR]);
                gridR.delRow(rowIdR);
            }
        }
    };
*/
    function doSendLeft() {
		var selRowIdR = gridR.getSelRowId();
		for(var x = selRowIdR.length - 1; x >= 0; x--) {
	        gridR.delRow(selRowIdR[x]);
		}
    }

	function doSendRight() {
		if( gridL.isEmpty( gridL.getSelRowId() ) ) {
	        alert("${msg.M0004}");
	        return;
	    }

		gridR.checkAll(true);

        var selAllRowDataL = gridL.getSelRowValue();
        var selAllRowDataR = gridR.getSelRowValue();

        var vendors = [];
        for(var v in selAllRowDataL) {
            if(selAllRowDataL.hasOwnProperty(v)){
                vendors.push(selAllRowDataL[v].VENDOR_CD);
            }
        }

        for(var v in selAllRowDataR) {
            if(selAllRowDataR.hasOwnProperty(v)){
                vendors.push(selAllRowDataR[v].VENDOR_CD);
            }
        }

        var store = new EVF.Store();
        store.setGrid([gridR]);
        store.setParameter('selectedVendors', JSON.stringify(vendors));
        store.load(baseUrl + "BPRI_020/doSearch", function() {
            gridR.checkAll(true);
        });
	}

	function doClose() {
        formUtil.close();
    }

	function doSelect() {

        <%-- 초기화하고 싶을 때도 있을 것 같아서 무조건 하나 이상 선택해야하는 아래 로직은 일단 주석처리 --%>
        <%--if(!gridR.isExistsSelRow()) { return alert('${msg.M0004}'); }--%>

        var paramRowId = '${param.rowId}' || '${param.rowid}';
        var selAllRowDataR = gridR.getSelRowValue();

        if (selAllRowDataR.length == 0) {
        	return alert('${msg.M0004}');
        }

        if(!EVF.isEmpty("${param.SELTYPE}") && "${param.SELTYPE}" == "S") {
        	if (selAllRowDataR.length > 1) {
            	return alert('${BPRI_020_0003}');
            }
        }
        opener.window['${param.callBackFunction}'](JSON.stringify(selAllRowDataR), paramRowId);
        doClose();
    }

    function searchVendorCd() {
        var param = {
            callBackFunction : "selectVendorCd"
        };
        everPopup.openCommonPopup(param, (conFlag == "Y" ? "SP0013" : "SP0063"));
    }

    function selectVendorCd(dataJsonArray) {
        EVF.getComponent("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
        EVF.getComponent("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
    }

    function chSg() {
        var store = new EVF.Store;
        var sg_type = this.getData();

        if (sg_type=='2') {
            store.setParameter('PARENT_SG_NUM',EVF.getComponent('CLS01').getValue());
            clearY('3');
            clearY('4');
        }
        if (sg_type=='3') {
            store.setParameter('PARENT_SG_NUM',EVF.getComponent('CLS02').getValue());
            clearY('4');
        }
        if (sg_type=='4') {
            store.setParameter('PARENT_SG_NUM',EVF.getComponent('CLS03').getValue());
        }
        store.load('/eversrm/srm/master/sgItemClass' + '/SRM_030/chSg', function() {
            EVF.getComponent('CLS0'+sg_type).setOptions(this.getParameter("sgData"));
        });
    }

    function clearY( cls_typef ) {
        EVF.C('CLS0'+ cls_typef ).setOptions( JSON.parse('[]')    );
    }

    function _getSGClsNm()<%--소싱그룹 조회 --%>{
        var popupUrl = "/eversrm/srm/master/sourcing/SRM_010_TREEP/view";
        var param = {
            callBackFunction: '_setSg',
            'multiYN' : false,
            'ModalPopup' : true,
            'searchYN' : true
        };
        everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
    }

    function _setSg(data) {
        if(data!=null){
            data = JSON.parse(data);
            EVF.C("SG_NUM1").setValue(data.ITEM_CLS1);
            if(data.ITEM_CLS2=="*"){EVF.C("SG_NUM2").setValue("");}else{EVF.C("SG_NUM2").setValue(data.ITEM_CLS2);}
            if(data.ITEM_CLS3=="*"){EVF.C("SG_NUM3").setValue("");}else{EVF.C("SG_NUM3").setValue(data.ITEM_CLS3);}
            if(data.ITEM_CLS4=="*"){EVF.C("SG_NUM4").setValue("");}else{EVF.C("SG_NUM4").setValue(data.ITEM_CLS4);}
            EVF.C("SG_NUM").setValue(data.ITEM_CLS_PATH_NM);
        } else {
            EVF.C("SG_NUM1").setValue("");
            EVF.C("SG_NUM2").setValue("");
            EVF.C("SG_NUM3").setValue("");
            EVF.C("SG_NUM4").setValue("");
            EVF.C("SG_NUM").setValue("");
        }
    }

    function cleanSGClass() {
    	EVF.C("SG_NUM1").setValue("");
        EVF.C("SG_NUM2").setValue("");
        EVF.C("SG_NUM3").setValue("");
        EVF.C("SG_NUM4").setValue("");
        EVF.C("SG_NUM").setValue("");
    }

    </script>

    <e:window id="BPRI_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form1" title="${msg.M9999 }" columnCount="2" labelWidth="135" onEnter="doSearch" useTitleBar="false">
            <e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="SG_NUM" title="${form_SG_NUM_N}"/>
                <e:field>
                    <e:search id="SG_NUM" name="SG_NUM" value="" width="100%" maxLength="${form_SG_NUM_M}" onIconClick="_getSGClsNm" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" onBlur="cleanSGClass" onChange="cleanSGClass" onClear="cleanSGClass" />
                </e:field>
                <e:inputHidden id="SG_NUM1" name="SG_NUM1" value="" />
                <e:inputHidden id="SG_NUM2" name="SG_NUM2" value="" />
                <e:inputHidden id="SG_NUM3" name="SG_NUM3" value="" />
                <e:inputHidden id="SG_NUM4" name="SG_NUM4" value="" />
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button label='${doSearch_N }' id='doSearch' onClick='doSearch' disabled='${doSearch_D }' visible='${doSearch_V }' data='${doSearch_A }'/>
            <c:if test="${!param.detailView}">
                <e:button label='${doSelect_N }' id='doSelect' onClick='doSelect' disabled='${doSelect_D }' visible='${doSelect_V }' data='${doSelect_A }'/>
            </c:if>
            <%-- <e:button label='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' data='${doClose_A }'/> --%>
        </e:buttonBar>
        <e:panel height="fit" width="100%">
            <e:panel width="49%">
                <e:title title="${BPRI_020_0002 }" />
                <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" height="fit" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}"/>
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
                <e:title title="${BPRI_020_0001}" />
                <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" height="fit" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}"/>
            </e:panel>
        </e:panel>
    </e:window>
</e:ui>
