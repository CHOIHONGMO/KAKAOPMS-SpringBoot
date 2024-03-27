<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
	var addParam = [];
	var baseUrl = "/eversrm/master/item/";

    function init() {
		grid = EVF.C('grid');
		grid.setProperty('panelVisible', ${panelVisible});
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

		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
	        if (celname == "VENDOR_CD") {
	            var params = {
	                VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
	                paramPopupFlag: true,
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
	        }

	        if (celname == "EXEC_NUM") {
	        	if (grid.getCellValue(rowid, "EXEC_NUM") == '') {
	        		return;
	        	}


                var param = {
                        gateCd: grid.getCellValue(rowid, "GATE_CD"),
                        EXEC_NUM: grid.getCellValue(rowid, "EXEC_NUM"),
                        popupFlag: true,
                        detailView: true
                    };

                    var exec_type = grid.getCellValue(rowid,'EXEC_TYPE');

                    var screenId='';
                    if(exec_type == "G") {
                    	screenId='BFAR_020';
            		} else if(exec_type == "C") {
                    	screenId='DH0630';
            		} else if(exec_type == "O") {
                    	screenId='DH0600';
            		} else if(exec_type == "S") {
                    	screenId='DH0540';
            		} else if(exec_type == "U") {
                    	screenId='DH0550';
            		} else {
                    	screenId='BFAR_020';
            		}

                    everPopup.openPopupByScreenId(screenId, 1200, 800, param);



	        }
		});

		doSearch();
    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'BBM_090/doSearch', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }
    function doClose() {
    	window.close();
    }

    </script>
    <e:window id="BBM_090" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:inputHidden id="PLANT_CD" name="PLANT_CD" value="${param.PLANT_CD}" />
		<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${param.BUYER_CD}" />
        <e:searchPanel id="form" title="" useTitleBar="false" columnCount="2" labelWidth="${labelWidth }" onEnter="doSearch">
        	<e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="${param.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${param.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
			</e:row>

		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>
