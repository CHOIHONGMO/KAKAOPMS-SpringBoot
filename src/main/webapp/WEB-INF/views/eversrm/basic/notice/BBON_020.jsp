<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid = {};
        var grid2 = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/board/notice/";

		function init() {
			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});
			//grid.setProperty('singleSelect', true);
			grid.setProperty('multiSelect', false);
            grid.setColIconify("ATT_FILE_CNT", "ATT_FILE_CNT", "file", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

	        grid.cellClickEvent(function(rowid, colId, value) {
                switch(colId) {
                    case 'SUBJECT':
                        if(grid.getCellValue(rowid,'REG_USER_ID')=="${ses.userId}"){
                            var param = {
                                NOTICE_NUM : grid.getCellValue(rowid,'NOTICE_NUM')
                                ,popupFlag   : true
                                ,READONLY    : "N"
                                ,detailView  : false
                            };
                        }else if (${havePermission}) {
                            var param = {
                                NOTICE_NUM : grid.getCellValue(rowid,'NOTICE_NUM')
                                ,popupFlag   : true
                                ,READONLY    : "N"
                                ,detailView  : false
                            };
                        } else{
                            var param = {
                                NOTICE_NUM : grid.getCellValue(rowid,'NOTICE_NUM')
                                ,popupFlag   : true
                                ,READONLY    : "N"
                                ,detailView  : true
                            };
                        }

                        everPopup.openPopupByScreenId('BBON_010', 950, 670, param);
                        break;

                    case 'ATT_FILE_CNT':
                        if(value=='1'){
                            var param = {
                                havePermission: false,
                                attFileNum: grid.getCellValue(rowid, 'ATT_FILE_NUM'),
                                rowId: rowid,
                                callBackFunction: 'setFileAttachCnt',
                                bizType: 'BBON',
                                fileExtension: '*'
                            };
                            everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);

                        }else{
                            alert("${BBON_020_MSG1 }");
                        }
                        break;
                    case 'multiSelect' :
                        //grid.checkAll(false);
                        //grid.checkRow([rowid], true);
                        break;

                }
			});

			//grid.setProperty('shrinkToFit', true);

		<c:if test="${not empty param.loginNoticeType or ses.userType == 'S' or ses.userType == 'B'}">
			grid.setProperty('multiselect', false);
			grid.hideCol('USER_TYPE', true);
		</c:if>

		<c:if test="${not empty param.loginNoticeType}">
			grid.setProperty('multiselect', false);
			grid.hideCol('NOTICE_TYPE', true);
			grid.hideCol('USER_TYPE', true);
		</c:if>

			search();


		}

        function search() {
            var store = new EVF.Store();

            if(!store.validate()) return;
        	store.setGrid([grid]);
            store.load(baseUrl + 'noticeList/selectNoticeList', function() {
    			if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }


         function delete2() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			var rowIds =  grid.getSelRowId();
			for(var i = 0; i < rowIds.length; i++) {
				var selectedData = grid.getRowValue(rowIds[i]);
				if("${ses.userId  }" != selectedData.REG_USER_ID) {
					alert("${msg.M0008}");
		            return;
				}
			}

        	if (!confirm("${msg.M0013 }")) return;
	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + '/noticeList/deleteNoticeList', function(){
        		alert(this.getResponseMessage());
        		search();
        	});
        }


		function update() {

			var rowIds = grid.getSelRowId();
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
  			if (grid.getSelRowCount()> 1) { return alert("${msg.M0006}");}

			var selectedData = grid.getRowValue(rowIds[0]);

			if("${ses.userId  }" != selectedData.REG_USER_ID && ! ${havePermission}) {
				alert("${msg.M0008}");
	            return;
			}
	        var param = {
	             NOTICE_NUM : grid.getCellValue(grid.getSelRowId()[0],'NOTICE_NUM')
	            ,popupFlag   : true
	            ,READONLY    : "N"
	            ,detailView : false
		    };

	        everPopup.openPopupByScreenId('BBON_010', 950, 670, param);
		}

		//신규등록
        function write() {
            var popupUrl = baseUrl + "BBON_010/view";
            var param = {
                onClose: 'closePopup',
                detailView: false
            };
            everPopup.openWindowPopup(popupUrl, 950, 670, param, "writeNotice");
        }

		//등록자명 차직
        function doSelectUser() {
            var param = {
                GATE_CD:  '${ses.gateCd}'
                , callBackFunction: 'selectUser'
            };
            everPopup.openCommonPopup(param,"SP0011");
        }

        function selectUser(dataJsonArray) {
            EVF.C("REG_USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("REG_USER_NM").setValue(dataJsonArray.USER_NM);
        }

        function doClose() {
        	window.close();
        }

    </script>
    <e:window id="BBON_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" onEnter="search" useTitleBar="false">

			<e:inputHidden id="FROM_LOGIN_NOTICE_TYPE" name="FROM_LOGIN_NOTICE_TYPE" value="${param.loginNoticeType}"/>

			<c:if test="${empty param.loginNoticeType and ses.userType == 'C' }">
	           <e:row>
					<e:label for="NOTICE_TYPE" title="${form_NOTICE_TYPE_N}"/>
					<e:field>
					    <e:select id="NOTICE_TYPE" name="NOTICE_TYPE" value="" options="${noticeTypeOptions}" width="${form_NOTICE_TYPE_W}" disabled="${form_NOTICE_TYPE_D}" readOnly="${form_NOTICE_TYPE_RO}" required="${form_NOTICE_TYPE_R}" placeHolder="" />
					</e:field>
					<e:label for="USER_TYPE" title="${form_USER_TYPE_N}"/>
					<e:field>
					    <e:select id="USER_TYPE" name="USER_TYPE" value="" options="${userTypeOptions}" width="${form_USER_TYPE_W}" disabled="${form_USER_TYPE_D}" readOnly="${form_USER_TYPE_RO}" required="${form_USER_TYPE_R}" placeHolder="" />
					</e:field>
                   <e:label for="SUBJECT" title="${form_SUBJECT_N }" />
                   <e:field>
                       <e:inputText id="SUBJECT" style="${imeMode}"  maxLength="${form_SUBJECT_M}"  readOnly="${form_SUBJECT_RO }"  name="SUBJECT" value=""  width="${form_SUBJECT_W}" required="${form_SUBJECT_R }" disabled="${form_SUBJECT_D }"  onFocus="onFocus" />
                   </e:field>
	 			</e:row>
	 		</c:if>

			<c:if test="${not empty param.loginNoticeType or ses.userType == 'S' or ses.userType == 'B'}">
				<e:inputHidden id="NOTICE_TYPE" name="NOTICE_TYPE"/>
				<e:inputHidden id="USER_TYPE" name="USER_TYPE"/>
			</c:if>

           <e:row>

               <e:label for="START_DATE" title="${form_START_DATE_N}"></e:label>
               <e:field>
                   <e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                   <e:text>~</e:text>
                   <e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
               </e:field>

               <e:label for="REG_USER_ID" title="${form_REG_USER_ID_N}"/>
               <e:field>
                   <e:search id="REG_USER_ID" name="REG_USER_ID" value="" width="40%" maxLength="${form_REG_USER_ID_M}" onIconClick="doSelectUser" disabled="${form_REG_USER_ID_D}" readOnly="${form_REG_USER_ID_RO}" required="${form_REG_USER_ID_R}" />
                   <e:inputText id="REG_USER_NM" style="${imeMode}"  maxLength="${form_REG_USER_NM_M}" readOnly="${form_REG_USER_NM_RO }" name="REG_USER_NM"  value="${fromDate }" width="60%" required="${form_REG_USER_NM_N }" disabled="${form_REG_USER_NM_N }"/>
               </e:field>

                <e:label for="TEXT_CONTENTS" title="${form_TEXT_CONTENTS_N }" />
                <e:field>
                    <e:inputText id="TEXT_CONTENTS" style="${imeMode}"  maxLength="${form_TEXT_CONTENTS_M}" readOnly="${form_TEXT_CONTENTS_RO }" name="TEXT_CONTENTS"  value="${fromDate }" width="100%" required="${form_TEXT_CONTENTS_N }" disabled="${form_TEXT_CONTENTS_N }"/>
                </e:field>
 			</e:row>
		</e:searchPanel>

         <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="search" />

            <c:if test='${param.POPUPFLAG != "Y" and ses.userType == "C"}'>
            	<%--<e:button id="doUpdate" name="doUpdate" label="${doUpdate_N }" disabled="${doUpdate_D }" onClick="update" />--%>
                <e:button id="doInsert" name="doInsert" label="${doInsert_N }" disabled="${doInsert_D }" onClick="write" />
            </c:if>

            <c:if test='${param.POPUPFLAG == "Y"}'>
            	<e:button id="doClose" name="doClose" label="Close" onClick="doClose" />
            </c:if>

            <%-- <e:button id="doDelete" name="doDelete" label="${doDelete_N }" disabled="${doDelete_D }" onClick="delete2" /> --%>
        </e:buttonBar>

    	<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit"  readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>