<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var grid = {};
        var addParam = [];
        var baseUrl = "/eversrm/master/bom/";
        var currentRow;

        function init() {
            grid = EVF.getComponent('grid');

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


        }

        function doSearch() {
            var store = new EVF.Store();
            if(!store.validate()) return;

            store.setGrid([grid]);
            store.load(baseUrl + 'DH1251/searchBomItem', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSearchItemCd() {
                var param = {
                    callBackFunction: 'selectItemCd'
                };
                everPopup.openCommonPopup(param, 'SP0018');
        }

        function selectItemCd(dataJsonArray) {
            EVF.getComponent("ITEM_CD").setValue(dataJsonArray.ITEM_CD);
            EVF.getComponent("ITEM_NM").setValue(dataJsonArray.ITEM_DESC);
        }

        function doChoice () {
            var resultData = grid.getSelRowValue();
            if (resultData.length==0) {
            	alert('${msg.M0004}');
            	return;
            }

            opener.window['${param.callBackFunction}'](JSON.stringify(resultData));
            grid.checkAll(false);
        }
        function doClose() {

        	window.close();
        }
    </script>

    <e:window id="DH1251" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    	<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}"/>
    	<e:inputHidden id="PUR_ORG_CD" name="PUR_ORG_CD" value="${param.PUR_ORG_CD}"/>
    	<e:inputHidden id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${param.PURCHASE_TYPE}"/>
    	<e:inputHidden id="SCREEN_OPEN_TYPE" name="SCREEN_OPEN_TYPE" value="${param.SCREEN_OPEN_TYPE}"/>

        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" labelWidth="${labelNarrowWidth }" onEnter="doSearch">
            <e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
				<e:field>
					<e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'doSearchItemCd'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${form.ITEM_NM}" width="60%" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
				</e:field>
                <e:label for="MAT_CD" title="${form_MAT_CD_N}"/>
                <e:field>
                    <e:select id="MAT_CD" name="MAT_CD" value="${form.MAT_CD}" options="${matCdOptions}" width="${inputTextWidth}" disabled="${form_MAT_CD_D}" readOnly="${form_MAT_CD_RO}" required="${form_MAT_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doChoice" name="doChoice" label="${doChoice_N}" onClick="doChoice" disabled="${doChoice_D}" visible="${doChoice_V}"/>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>