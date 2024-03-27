<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/basic/qna/";

		function init() {

            var $datepickerContainer = $('<div id="griddatepicker-container" style="width:0px; height:0px; position: absolute; z-index:999; background-color: transparent;"><input type="text" /></div>').hide();
            $('body').append($datepickerContainer);

			grid = EVF.C('grid');
			//grid.setProperty('shrinkToFit', true);
			grid.setProperty('panelVisible', ${panelVisible});
			//grid.setProperty('singleSelect', true);
			grid.setProperty('multiSelect', false);
			//grid.setImageTextUnderLine(false);
			grid.setProperty('panelVisible', ${panelVisible});
            grid.setColIconify("ATT_FILE_CNT", "ATT_FILE_CNT", "file", false);


            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.cellClickEvent(function(rowId, colId, value) {
                switch(colId) {
                    case 'SUBJECT':
                        if(grid.getCellValue(rowId,'REG_USER_ID')=="${ses.userId}"){

                            var popupUrl = baseUrl + "writeQna/view";
                            var param = {
                                GATE_CD : grid.getCellValue(rowId,'GATE_CD'),
                                QNA_NUM:  grid.getCellValue(rowId,'QNA_NUM'),
                                onClose: 'closePopup',
                                POPUPFLAG : 'Y',
                                detailView: false
                            };
                            everPopup.openWindowPopup(popupUrl, 1000, 600, param, "modify");
                        }else{
                            var popupUrl = baseUrl + "replyQna/view";
                            var param = {
                                GATE_CD : grid.getCellValue(rowId,'GATE_CD'),
                                QNA_NUM:  grid.getCellValue(rowId,'QNA_NUM') ,
                                onClose: 'closePopup',
                                detailView: true
                            };
                            everPopup.openWindowPopup(popupUrl, 1000, 600, param, "everSrmreplyQna");
                        }

                        break;
                    case 'ATT_FILE_CNT':
                        if(value=='1'){
                            var param = {
                                havePermission: false,
                                attFileNum: grid.getCellValue(rowId, 'ATT_FILE_NUM'),
                                rowId: rowId,
                                callBackFunction: 'setFileAttachCnt',
                                bizType: 'BBON',
                                fileExtension: '*'
                            };
                            everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);

                        }else{
                            alert("${BSN_140_MSG1 }");
                        }
                        break;
                    case 'MOD_DATE':

                        console.log(grid.getGridViewObj().getCellBounds(grid.getIndex(rowId), colId, true));
                        var positionInfo = grid.getGridViewObj().getCellBounds(grid.getIndex(rowId), colId, true);
                        $('#griddatepicker-container').css({
                            "left": positionInfo.x,
                            "top": positionInfo.y,
                            "display": "block",
                            "background-color": "transparent"
                        });
                        $('#griddatepicker-container input').css({
                            "width": "1px",
                            "height": "1px",
                            "background-color": "transparent"
                        });
                        $('#griddatepicker-container input').datepicker({
                            autoclose: true,
                            beforeShowDay: function() {

                            },
                            daysOfWeekHighlighted: [0,6],
                            enableOnReadonly: true,
                            // format
                            keyboardNavigation: false,
                            language: 'kr'
                        }).datepicker('show');

                        break;
                }
            });

            grid.setColIconify('ATT_FILE_CNT', 'ATT_FILE_CNT', 'file', false);
	        search();
        }

        function search() {
        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'qnaList/doSearchQnaList', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        function write() {
            var popupUrl = baseUrl + "writeQna/view";
            var param = {
                onClose: 'closePopup',
                detailView: false
            };
            everPopup.openWindowPopup(popupUrl, 1000, 600, param, "writeQna");
        }


        function modify() {

        	var rowIds = grid.jsonToArray(grid.getSelRowId()).value;

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

  			if ((grid.jsonToArray(grid.getSelRowId()).value).length != 1) {
	            alert("${msg.M0006}");
	            return;
	        }

  			var selectedData = grid.getRowValue(rowIds[0]);

  			if(! ("${ses.superUserFlag}" == "1" && "${ses.userType}" == "C")) {
	  			if("${ses.userId}" != selectedData.REG_USER_ID && "${ses.userType}" == "S") {
					alert("${msg.M0008}");
		            return;
				}

				if("${ses.userId}" != selectedData.REG_USER_ID && "${ses.superUserFlag}" == "0") {
					alert("${msg.M0008}");
		            return;
				}
  			}

        	//alert(grid.jsonToArray(grid.getSelRowId()).value);
            var popupUrl = baseUrl + "writeQna/view";
            var param = {
                	GATE_CD : grid.getCellValue(grid.getSelRowId(),'GATE_CD'),
                	QNA_NUM:  grid.getCellValue(grid.getSelRowId(),'QNA_NUM') ,
                onClose: 'closePopup',
                detailView: false
            };
            everPopup.openWindowPopup(popupUrl, 1000, 600, param, "modify");
        }

        function onChangeDate(a, b, c, d) {
		    console.log('onChangeDate: ', 'a:"',a, '"/ b: "',b, '"/ c:"',c, '"/ d:"', d, '"');
        }

    </script>
    <e:window id="BSN_140" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" labelWidth="${longLabelWidth }" onEnter="search" useTitleBar="false">
        	<e:row>
                <e:label for="QNA_TYPE" title="${form_QNA_TYPE_N}"/>
                <e:field>
                    <e:select id="QNA_TYPE" name="QNA_TYPE" value="${formData.QNA_TYPE }" options="${qnaTypeOptions}" width="${form_QNA_TYPE_W}" disabled="${form_QNA_TYPE_D}" readOnly="${form_QNA_TYPE_RO}" required="${form_QNA_TYPE_R}" placeHolder="" />
                </e:field>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
				<e:field>
                    <e:inputText id="SUBJECT" style="${imeMode}" name="SUBJECT" value="${form.SUBJECT}" width="${form_SUBJECT_W}" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="START_DATE" title="${form_START_DATE_N }" />
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${formData.START_DATE }" width="${inputDateWidth }" required="${form_START_DATE_R }" readOnly="${form_START_DATE_RO }" disabled="${form_START_DATE_D }" datePicker="true" onChange="onChangeDate" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${formData.END_DATE }" width="${inputDateWidth }" required="${form_END_DATE_R }" readOnly="${form_END_DATE_RO }" disabled="${form_END_DATE_D }" datePicker="true" />
                </e:field>
                <e:label for="TEXT_CONTENTS" title="${form_TEXT_CONTENTS_N}"/>
                <e:field>
                    <e:inputText id="TEXT_CONTENTS" style="${imeMode}" name="TEXT_CONTENTS" value="${form.TEXT_CONTENTS}" width="${form_TEXT_CONTENTS_W}" maxLength="${form_TEXT_CONTENTS_M}" disabled="${form_TEXT_CONTENTS_D}" readOnly="${form_TEXT_CONTENTS_RO}" required="${form_TEXT_CONTENTS_R}" />
                </e:field>
            </e:row>

        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="search" />
            <e:button id="doWrite" name="doWrite" label="${doWrite_N }" disabled="${doWrite_D }" onClick="write" />
            <%--<e:button id="doModify" name="doModify" label="${doModify_N }" disabled="${doModify_D }" onClick="modify" />--%>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>