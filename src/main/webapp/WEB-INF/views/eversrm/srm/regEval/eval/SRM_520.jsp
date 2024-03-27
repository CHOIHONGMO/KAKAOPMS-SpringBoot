<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    var baseUrl = '/eversrm/srm/regEval/eval/SRM_520';
    var grid;
    var selRow;

    function init() {

        grid = EVF.C('grid');

        EVF.C('PROGRESS_CD').removeOption('100'); // 진행상태가 작성중인 건은 보이지 않도록 함
        grid.setProperty('panelVisible', ${panelVisible});
        grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			<%--셀 여러개 선택 방지--%>
        	if(selRow == undefined){
				selRow = rowid;
			}
			if (celname == "multiSelect") {
				if(selRow != rowid) {
					grid.checkRow(selRow, false);
					selRow = rowid;
				}
			}
			<%--관리번호 클릭시 개선조치요청 화면으로 이동--%>
			if (celname == "RH_NUM") {
	            var param = {
	                RH_NUM: grid.getCellValue(rowid, "RH_NUM")
	                   ,detailView    : "false"
	                   ,havePermission : false
	            };
	            everPopup.openPopupByScreenId('SRM_530', 950, 580, param);
		    }
        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            switch(colId) {
            case '':

            default:
        }});



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

        EVF.getComponent("VENDOR_NM").setValue('${ses.companyNm}');
    	EVF.getComponent("VENDOR_CD").setValue('${ses.companyCd}');
    }

    function doSearch() {
    	<%-- 날짜 체크--%>
        if(!everDate.checkTermDate('RH_DATE_FROM','RH_DATE_TO','${msg.M0073}')) {
            return;
        }
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }

   	function check_progress(){
   		var cd = this.getValue();
   		if(cd == '100'){
   			alert('${SRM_520_PROGRESS_CD}');
   			EVF.C('PROGRESS_CD').setValue('200');
   		}
   	}


    </script>
<e:window id="SRM_520" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="2" labelWidth="${labelWidth}" onEnter="doSearch">
    <%-- 평가일자 / 진행상태 --%>
    <e:row>
		<%-- 평가일자 --%>
		<e:label for="RH_DATE_FROM" title="${form_RH_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="RH_DATE_FROM" toDate="RH_DATE_TO" name="RH_DATE_FROM" value="${form.RH_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_RH_DATE_FROM_R}" disabled="${form_RH_DATE_FROM_D}" readOnly="${form_RH_DATE_FROM_RO}" />
		<e:text> ~ </e:text>
		<e:inputDate id="RH_DATE_TO" fromDate="RH_DATE_FROM" name="RH_DATE_TO" value="${form.RH_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_RH_DATE_TO_R}" disabled="${form_RH_DATE_TO_D}" readOnly="${form_RH_DATE_TO_RO}" />
		</e:field>

		<%-- 진행상태 --%>
		<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
		<e:field>
		<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" onChange="check_progress"/>
		</e:field>

    </e:row>
    <%-- 차종 / 제목 --%>
    <e:row>
		<%-- 차종 --%>
		<e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}" />
		<e:field>
		<e:inputText id="MAT_GROUP" style="ime-mode:inactive" name="MAT_GROUP" value="${form.MAT_GROUP}" width="100%" maxLength="${form_MAT_GROUP_M}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}"/>
		</e:field>

		<%-- 제목 --%>
		<e:label for="SUBJECT" title="${form_SUBJECT_N}" />
		<e:field>
		<e:inputText id="SUBJECT" style="ime-mode:auto" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
		</e:field>
    </e:row>
    <e:inputHidden id="VENDOR_NM" name="VENDOR_NM" value="${form.VENDOR_NM}"/>
    <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>
    </e:searchPanel>

    <e:buttonBar align="right">
    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>

	<%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />



</e:window>
</e:ui>
