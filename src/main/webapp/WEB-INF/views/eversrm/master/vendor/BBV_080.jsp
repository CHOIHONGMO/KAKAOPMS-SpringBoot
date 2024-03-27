<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
	String devYn = PropertiesManager.getString("eversrm.system.developmentFlag");
%>

<c:set var="devYn" value="<%=devYn%>" />

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<!-- 전자인증 모듈 기본으로 설정 //-->
	<link rel="stylesheet" type="text/css" href="/ccc-sample_v1/unisignweb/rsrc/css/certcommon.css?v=1" />
	<script type="text/javascript" src="/ccc-sample_v1/unisignweb/js/unisignwebclient.js?v=1"></script>
	<!-- 전자인증 모듈 기본으로 설정 //-->

	<script type="text/javascript">

	var grid = {};
	var baseUrl = "/eversrm/master/vendor/";

	function init() {

		grid = EVF.getComponent('grid');
		grid.setProperty('panelVisible', ${panelVisible});
		grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
				,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
				,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {

	        switch (celname) {
            case 'SUBJECT':
            	doVerify(rowid);
                break;

            	default:
	        }
		});

		grid.setProperty('multiselect', false);
		grid.setProperty('shrinkToFit', true);

		if ('${summaryFlag}' == 'Y') {
			EVF.C('PROGRESS_CD').setValue('${progressCd}');

			doSearch();
		}
    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'BBV_080/doSearch', function() {
        	<%--
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
            --%>
        });
    }

    function doVerify(rowid) {

        var docNum     = grid.getCellValue(rowid,'DOC_NUM');
        var progressCd = grid.getCellValue(rowid,'PROGRESS_CD');
        if (progressCd == 'E') {

			// 개발서버인 경우 사업자번호 :
			var ssn;
			if ('${devYn}' == 'true') {
				ssn = '1234567890';
			} else {
				ssn = grid.getCellValue(rowid,'IRS_NUM');
			}

            // 전자서명 ==========
			//var textBox       = grid.getCellValue(rowid,'BLSM_HTML');
			var textBox       = grid.getCellValue(rowid,'DOC_TEXT');
			var signedTextBox = document.getElementById('SIGN_VALUE');

			unisign.SignDataNVerifyVID( textBox, null, ssn,
				function(rv, signedText) {

					signedTextBox.value = signedText;
					if ((null === signedTextBox.value || '' === signedTextBox.value || false === rv )) {
						unisign.GetLastError(
							function(errCode, errMsg) {
								if (errCode == "43050000") {
					            	alert("${msg.M0116 }"); //인증서 본인확인에 실패했습니다.
								} else {
									alert('Error code : ' + errCode + '\n\nError Msg : ' + errMsg);
								}
							}
						);
					} else {
			            grid.checkAll(false);
			            grid.checkRow(rowid, true);

			            var store = new EVF.Store();
			            store.setGrid([grid]);
			        	store.getGridData(grid, 'sel');
			    		store.load(baseUrl + 'BBV_080/doVerify', function() {

			    			if(this.getResponseCode() != 0001) {
			    				alert(this.getResponseMessage());
			    			} else {
				    			doSearch();
				    			doCallDoc(docNum);
			    			}
			    		});
					}

				}
			);
            // ===================

        } else {
        	doCallDoc(docNum);
        }
    }

    function doCallDoc(docNum) {
        var params = {
        		docNum     : docNum,
                popupFlag  : true,
                detailView : true
            };
		everPopup.openOFDetailInfoForVendor(params);
    }

    </script>

	<e:window id="BBV_080" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:inputHidden id="SIGN_VALUE" name="SIGN_VALUE" value="" />
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelNarrowWidth }" onEnter="doSearch">
			<e:row>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}" />
				<e:field colSpan="3">
					<e:inputText id="SUBJECT" name="SUBJECT" value="" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" style="${imeMode}"/>
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}" />
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${refProgressCd }" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
		</e:buttonBar>
		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>
<script type="text/javascript" src="/ccc-sample_v1/UniSignWeb_Multi_Init_Nim.js?v=1"></script>