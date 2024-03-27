<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	 <script type="text/javascript">

	    var grid;
	    var baseUrl = "/evermp/SIT1/SIT101/";

	    function init() {

	        grid = EVF.C("grid");

			grid.cellClickEvent(function(rowId, colId, value) {
	        	// 품목상세설명
				if(colId == "ITEM_DETAIL_TEXT_FLAG") {
					var param = {
	                         rowId : rowId
	                        ,havePermission : true
	                        ,screenName : '품목 상세설명'
	                        ,callBackFunction : 'setItemDetailText'
	                        ,largeTextNum : grid.getCellValue(rowId, "ITEM_DETAIL_TEXT_NUM")
	                        ,detailView : false
	                    };
	                    everPopup.openPopupByScreenId('commonRichTextContents', 900, 600, param);
				}
	        	// 이미지 파일 업로드
	        	if(colId == 'IMG_ATT_FILE_NUM_IMG') {
	        		everPopup.fileAttachPopup('IMAGE',grid.getCellValue(rowId, 'IMG_ATT_FILE_NUM'),'setImgFile',rowId,false,'*');
	        	}
	        	// 첨부파일 업로드
	        	if(colId == 'ATT_FILE_NUM_IMG') {
	        		everPopup.fileAttachPopup('RP',grid.getCellValue(rowId, 'ATT_FILE_NUM'),'setAttFile',rowId,false,'*');
	        	}
	        	// 납품지역
	        	if(colId == 'AREA_NM') {
	        		var param = {
	                        rowId: rowId,
	                        callBackFunction: 'CT_setRegionNm',
	                        'REGION_CD': grid.getCellValue(rowId, 'AREA_CD'),
	                        'detailView': false
	                    };
	                    everPopup.im03_012open(param);
	        	}
			});

			grid.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
		        // 0보다 작은값 입력할 수 없음
				if (colId == 'RFP_UNIT_PRICE' || colId == 'MOQ_QTY' || colId == 'RV_QTY' || colId == 'LEAD_TIME') {
					if(value < 0) {
					    alert('${msg.M0168 }');
						grid.setCellValue(rowid, colId, oldValue);
						return;
					}
		    	}
            });

			grid.addRowEvent(function() {
                var rowId = grid.addRow([{
                	INSERT_FLAG : 'I',
                	VENDOR_CD : '${ses.companyCd}',
                	UNIT_CD : 'EA',
                	CUR : 'KRW',
                	ORIGIN_CD : 'KR',
                	TAX_CD : 'T1'
                }]);
            });

			grid.delRowEvent(function() {
				if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

				var delCnt = 0;
		        var rowIds = grid.getSelRowId();
		        for(var i = rowIds.length -1; i >= 0; i--) {
		            if(!EVF.isEmpty(grid.getCellValue(rowIds[i], "ITEM_DESC"))) {
		                delCnt++;
		            } else {
		                grid.delRow(rowIds[i]);
		            }
		        }

		        if(delCnt > 0){
		            return; // alert("TEST");
		            //grid.checkAll(false);
		        }
			});

			grid.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			});

			grid.excelImportEvent({
                'append': false
            }, function (msg, code) {
                if (code) {
                	grid.checkAll(true);
                	var allRowId = grid.getAllRowId();
                    for(var i in allRowId) {
                        var rowId = allRowId[i];
                        grid.setCellValue(rowId, 'INSERT_FLAG', 'I');
                        grid.setCellValue(rowId, 'VENDOR_CD', '${ses.companyCd}');
                        grid.setCellValue(rowId, 'IMG_ATT_FILE_NUM_IMG', '');
                        grid.setCellValue(rowId, 'ITEM_DETAIL_TEXT_FLAG', '');
                        grid.setCellValue(rowId, 'ATT_FILE_NUM_IMG', '');
                    }
                }
            });

			doSearch();
	    }

	    function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.setParameter("VENDOR_CD", "${ses.companyCd}");
            store.load(baseUrl + "SIT1_021/doSearch", function () {
                /* if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                } */
            });
        }

	    // 임시저장, 요청
	    function doSave() {
	    	if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var store = new EVF.Store();
            if(!store.validate()) { return;}

	    	// 100 : 임시저장, 200 : 요청
            var progressCd = this.data;
            if( progressCd == '200' ) {
            	msg = "${msg.M0053}";
            }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var msg = "${msg.M0021}";
            if(!confirm(msg)) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("PROGRESS_CD", progressCd);
            store.doFileUpload(function() {
                store.load(baseUrl + 'SIT1_021/doSave', function() {
                    alert(this.getResponseMessage());
                    doSearch();
                });
			});
	    }

	 	// 삭제
	    function doDelete() {
	    	if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var store = new EVF.Store();

            if(!confirm("${msg.M0013}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.doFileUpload(function() {
                store.load(baseUrl + 'SIT1_021/doDelete', function() {
                    alert(this.getResponseMessage());
                    doSearch();
                });
			});
	    }

	    function setItemDetailText(datum) {
            datum = JSON.parse(datum);
            if(EVF.isEmpty(datum)) {
                grid.setCellValue(datum.rowId, 'ITEM_DETAIL_TEXT_FLAG', '');
                grid.setCellValue(datum.rowId, 'ITEM_DETAIL_TEXT_NUM', datum.largeTextNum);
            } else {
                grid.setCellValue(datum.rowId, 'ITEM_DETAIL_TEXT_FLAG', 'Y');
                grid.setCellValue(datum.rowId, 'ITEM_DETAIL_TEXT_NUM', datum.largeTextNum);
            }
        }

	    function setImgFile(rowId, fileId, fileCnt) {
            grid.setCellValue(rowId, 'IMG_ATT_FILE_NUM', fileId);
            grid.setCellValue(rowId, 'IMG_ATT_FILE_NUM_IMG', fileCnt);
        }

        function setAttFile(rowId, fileId, fileCnt) {
            grid.setCellValue(rowId, 'ATT_FILE_NUM', fileId);
            grid.setCellValue(rowId, 'ATT_FILE_NUM_IMG', fileCnt);
        }

        // 차후 변경 필요
        function CT_setRegionNm(data){
            grid.setCellValue(data.rowId, "AREA_CD", data.REGION_CD);
            grid.setCellValue(data.rowId, "AREA_NM", data.REGION_NM);
        }

	</script>

	<e:window id="SIT1_021" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:buttonBar align="right" width="100%">
		    <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		    <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" data="100" /> <!-- 임시저장 -->
		    <e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doSave" disabled="${doRequest_D}" visible="${doRequest_V}" data="200" /> <!-- 요청 -->
		    <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>