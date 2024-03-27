<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/statistic/DH1530"
           ,grid;

        function init() {
    		grid = EVF.C('grid');
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
    		grid.setProperty('panelVisible', ${panelVisible});
            if(${_gridType eq "RG"}) {
                grid.setColGroup([{
                    "groupName": '${DH1530_MSG_CUST_PUR_AMT}',
                    "columns": [ "CUST_PART_AMT", "CUST_RAW_AMT" ]
                }, {
                    "groupName": '${DH1530_MSG_VEND_PUR_AMT}',
                    "columns": [ "VEND_PART_AMT", "VEND_RAW_AMT" ]
                }, {
                    "groupName": '${DH1530_MSG_CM_AMT}',
                    "columns": [ "CM_PART_AMT", "CM_RAW_AMT", "CM_TOT_AMT" ]
                }, {
                    "groupName": '${DH1530_MSG_PURE_PUR_AMT}',
                    "columns": [ "PUR_PART_AMT", "PUR_RAW_AMT", "PUR_TOT_AMT", "SHARE_RATE" ]
                }]);
            } else {
                grid.setGroupCol(
                        [
                            {'colName' : 'CUST_PART_AMT', 'colIndex': 2, 'titleText' : '${DH1530_MSG_CUST_PUR_AMT}'},
                            {'colName' : 'VEND_PART_AMT', 'colIndex': 2, 'titleText' : '${DH1530_MSG_VEND_PUR_AMT}'},
                            {'colName' : 'CM_PART_AMT',   'colIndex': 3, 'titleText' : '${DH1530_MSG_CM_AMT}'},
                            {'colName' : 'PUR_PART_AMT',  'colIndex': 4, 'titleText' : '${DH1530_MSG_PURE_PUR_AMT}'}
                        ]
                );
            }


        }

        function doSearch() {

            var store = new EVF.Store();

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

    </script>
    <e:window id="DH1530" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
            <e:row>
                <e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="FROM_DATE" toDate="TO_DATE" name="FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}"/>
                    <e:text> ~ </e:text>
                    <e:inputDate id="TO_DATE" fromDate="FROM_DATE" name="TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}"/>
                </e:field>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}" />
				<e:field colSpan="3">
					<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
