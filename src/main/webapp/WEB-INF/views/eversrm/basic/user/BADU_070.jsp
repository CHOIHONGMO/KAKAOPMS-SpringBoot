<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
        var grid1 = {};
        var addParam = [];
        var baseUrl = "/eversrm/basic/user/";

        function init() {
            grid1 = EVF.C('grid1');
            grid1.setProperty('multiSelect', false);
            grid1.excelExportEvent({
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

        function search() {
            var store = new EVF.Store();
            if(!store.validate()) return;
            store.setGrid([grid1]);
            store.load(baseUrl + 'badu070_doSearch', function() {
                if(grid1.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }


	</script>
	<e:window id="BADU_070" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" onEnter="search" useTitleBar="false">
			<e:row>
				<e:label for="ADD_DATE_FROM" title="${form_ADD_DATE_FROM_N }" />
				<e:field>
					<e:inputDate id="ADD_DATE_FROM" name="ADD_DATE_FROM" value="${fromDate }" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_FROM_R}" disabled="${form_ADD_DATE_FROM_D}" readOnly="${form_ADD_DATE_FROM_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="ADD_DATE_TO" name="ADD_DATE_TO" value="${toDate }" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_TO_R}" disabled="${form_ADD_DATE_TO_D}" readOnly="${form_ADD_DATE_TO_RO}" />
				</e:field>
				<e:label for="JOB_TYPE" title="${form_JOB_TYPE_N }" />
				<e:field>
					<e:select id="JOB_TYPE" name="JOB_TYPE"  value="" readOnly="${form_JOB_TYPE_RO }"  options="${refJobType}" width="${form_JOB_TYPE_W }" required="${form_JOB_TYPE_R }" disabled="${form_JOB_TYPE_D }" onFocus="onFocus"   placeHolder="" usePlaceHolder="false" useMultipleSelect="true" />
				</e:field>
				<e:label for="JOB_DESC" title="${form_JOB_DESC_N }" />
				<e:field>
					<e:inputText id="JOB_DESC" name="JOB_DESC"  value=""  readOnly="${form_JOB_DESC_RO }"   maxLength="${form_JOB_DESC_M}"  width="${form_JOB_DESC_W }" required="${form_JOB_DESC_N }" disabled="${form_JOB_DESC_N }" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="USER_TYPE" title="${form_USER_TYPE_N }" />
				<e:field>
					<e:select id="USER_TYPE" name="USER_TYPE" value="" readOnly="${form_USER_TYPE_RO }" options="${refUserType}" width="${form_USER_TYPE_W }" required="${form_USER_TYPE_R }" disabled="${form_USER_TYPE_D }" onFocus="onFocus"  placeHolder=""/>
				</e:field>
				<e:label for="USER_ID" title="${form_USER_ID_N }" />
				<e:field>
					<e:inputText id="USER_ID" name="USER_ID"  maxLength="${form_USER_ID_M}" readOnly="${form_USER_ID_RO }" value="" width="${form_USER_ID_W }" required="${form_USER_ID_N }" disabled="${form_USER_ID_D }" />
				</e:field>
				<e:label for="IP_ADDR" title="${form_IP_ADDR_N }" />
				<e:field>
					<e:inputText id="IP_ADDR" name="IP_ADDR" value=""   readOnly="${form_IP_ADDR_RO }"   maxLength="${form_IP_ADDR_M}"  width="${form_IP_ADDR_W }" required="${form_IP_ADDR_R }" disabled="${form_IP_ADDR_D }" onFocus="onFocus" />
				</e:field>

			</e:row>
		</e:searchPanel>
		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="search" />
		</e:buttonBar>
		<e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}" />
	</e:window>
</e:ui>