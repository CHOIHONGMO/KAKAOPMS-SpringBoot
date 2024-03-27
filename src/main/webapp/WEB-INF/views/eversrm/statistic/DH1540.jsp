<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/statistic/DH1540"
            ,refUrl = "/eversrm/master/bom/DH0521"
            ,grid
			,selRow;

        function init() {
    		grid = EVF.C('grid');
    		grid.setProperty('panelVisible', ${panelVisible});
		    grid.cellClickEvent(function (rowId, celName, value, iRow, iCol) {

	        	var itemDesc = grid.getCellValue(rowId, "ITEM_DESC");
	        	if (itemDesc == '${DH1540_TOTAL}') {
	        		return;
	        	}

		    	switch (celName) {
                case 'EQUIP_BID_AMT':
                case 'EQUIP_EST_AMT':
                case 'EQUIP_EXE_AMT':
                	var itemCd = grid.getCellValue(rowId, "ITEM_CD");
                	var equipRev = grid.getCellValue(rowId, "EQUIP_REV");

                	if (itemCd == '' || equipRev == '') {
                		break;
                	}
		            var params = {
		            		itemCd: itemCd,
		            		equipRev: equipRev,
			                popupFlag: true,
			                detailView : true
			        };

		            everPopup.openPopupByScreenId("DH1550", 1600, 800, params);

                    break;

                case 'MOLD_BID_AMT':
                case 'MOLD_EXE_AMT':
                	var itemCd = grid.getCellValue(rowId, "ITEM_CD");
                	var moldRev = grid.getCellValue(rowId, "MOLD_REV");

                	if (itemCd == '' || moldRev == '') {
                		break;
                	}
		            var params = {
		            		itemCd: itemCd,
		            		moldRev: moldRev,
			                popupFlag: true,
			                detailView : true
			        };

		            everPopup.openPopupByScreenId("DH1560", 1600, 800, params);

                    break;

				case 'multiSelect':
					if(selRow == undefined) selRow = rowId;

					if (celName == 'multiSelect') {
						if(selRow != rowId) {
							grid.checkRow(selRow, false);
							selRow = rowId;
						}
					}
					break;
                default:
                    return;
            	}
		    });

    		grid.excelExportEvent({
    			allCol : "${excelExport.allCol}",
    			selRow : "${excelExport.selRow}",
    			fileType : "${excelExport.fileType }",
    			fileName : "${screenName }",
    		    excelOptions : {
    				 imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
    				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
    				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
    				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
    		        ,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
    		    }
    		});

			if(${_gridType eq "RG"}) {
				grid.setColGroup([{
					"groupName": '${DH1540_EQUIP_AMT}',
					"columns": [ "EQUIP_REV", "EQUIP_BID_AMT", "EQUIP_EST_AMT", "EQUIP_EXE_AMT" ]
				}, {
					"groupName": '${DH1540_MOLD_AMT}',
					"columns": [ "MOLD_REV", "MOLD_BID_AMT", "MOLD_EXE_AMT" ]
				}]);
			} else {
				grid.setGroupCol(
						  [
							{'colName' : 'EQUIP_REV',  'colIndex': 4, 'titleText' : '${DH1540_EQUIP_AMT}'},
							{'colName' : 'MOLD_REV',   'colIndex': 3, 'titleText' : '${DH1540_MOLD_AMT}'}
						  ]
				);
			}

	        EVF.getComponent('ITEM_CLS1').setValue('01');
        }

        function doSearch() {

        	if ('${ses.finCtrlCd}' != 'EM00') { //전체권한
        		return;
        	}

            var store = new EVF.Store();

            if(!store.validate()) return;

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

		// 설비
		function doEquip() {

			var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

			var itemCd = "";
			var equipRev = "";

			if (selRowId != '') {
				itemCd = grid.getCellValue(selRowId, "ITEM_CD");
				equipRev = grid.getCellValue(selRowId, "EQUIP_REV");
			}

			var params = {
				itemCd: itemCd,
				equipRev: equipRev,
				popupFlag: true,
				detailView : false
			};

			everPopup.openPopupByScreenId("DH1550", 1600, 800, params);
		}

		// 금형
		function doMold() {

			var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

			var itemCd = "";
			var moldRev = "";

			if (selRowId != '') {
				itemCd = grid.getCellValue(selRowId, "ITEM_CD");
				moldRev = grid.getCellValue(selRowId, "MOLD_REV");
			}

			var params = {
				itemCd: itemCd,
				moldRev: moldRev,
				popupFlag: true,
				detailView : false
			};

			everPopup.openPopupByScreenId("DH1560", 1600, 800, params);
		}

	    function getitem_cls() {
	        var store = new EVF.Store();

	        var cls_type = this.getData();
	        var item_cls = '';
	        if (cls_type=='2') {
	          item_cls= EVF.getComponent("ITEM_CLS1").getValue();
	          clearX('3');
	        }
	        if (cls_type=='3') {
	          item_cls= EVF.getComponent("ITEM_CLS2").getValue();
	        }
	        if (cls_type=='4') {
	          item_cls= EVF.getComponent("ITEM_CLS3").getValue();
	        }

	        store.load(refUrl + '/getItem_Cls.so?CLS_TYPE='+cls_type+'&ITEM_CLS='+item_cls, function() {
	          EVF.C('ITEM_CLS'+ cls_type ).setOptions(this.getParameter("item_cls"));
	        });
	    }

		function clearX( cls_typef ) {
			EVF.C('ITEM_CLS'+ cls_typef ).setOptions( JSON.parse('[]') );
		}

	    function searchVendorCode() {
	        var param = {
	            callBackFunction: "selectVendorCode"
	        };
	        everPopup.openCommonPopup(param, 'SP0013');
        }
        function selectVendorCode(dataJsonArray) {
	        EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }

    </script>
    <e:window id="DH1540" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
	    <e:inputHidden id='VENDOR_CD' name="VENDOR_CD" value="${form.VENDOR_CD}" />
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
            <e:row>
		        <e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}"/>
        		<e:field>
        		  <e:select id="MAT_GROUP" name="MAT_GROUP" value="${form.MAT_GROUP}" options="${matGroupOptions}" width="${inputTextWidth}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" placeHolder="" />
		        </e:field>
		        <e:label for="ITEM_CLS" title="${form_ITEM_CLS_N}" />
        		<e:field colSpan="3">
        			<e:select id="ITEM_CLS1" name="ITEM_CLS1" data="2" onChange="getitem_cls" value="${form.ITEM_CLS1}" options="${refITEM_CLASS1 }" width="${inputTextWidth}" disabled="${form_ITEM_CLS1_D}" readOnly="${form_ITEM_CLS1_RO}" required="${form_ITEM_CLS1_R}" placeHolder="" />
        			<e:text>&nbsp;</e:text>
        			<e:select id="ITEM_CLS2" name="ITEM_CLS2" data="3" onChange="getitem_cls" value="${form.ITEM_CLS2}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
        			<e:text>&nbsp;</e:text>
        			<e:select id="ITEM_CLS3" name="ITEM_CLS3" data="4" value="${form.ITEM_CLS3}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
        		</e:field>
            </e:row>
			<e:row>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}" />
				<e:field>
					<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
				<e:field>
					<e:search id="VENDOR_NM" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'searchVendorCode'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" style="${imeMode}"/>
				</e:field>
				<e:label for="PRODUCTION_DIV" title="${form_PRODUCTION_DIV_N}"/>
				<e:field>
					<e:select id="PRODUCTION_DIV" name="PRODUCTION_DIV" value="${form.PRODUCTION_DIV}" options="${productionDivOptions}" width="${inputTextWidth}" disabled="${form_PRODUCTION_DIV_D}" readOnly="${form_PRODUCTION_DIV_RO}" required="${form_PRODUCTION_DIV_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
			<c:if test="${ses.finCtrlCd == 'EM00'}">
	            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			</c:if>
			<%--
			<e:button id="doEquip" name="doEquip" label="${doEquip_N}" onClick="doEquip" disabled="${doEquip_D}" visible="${doEquip_V}"/>
			<e:button id="doMold" name="doMold" label="${doMold_N}" onClick="doMold" disabled="${doMold_D}" visible="${doMold_V}"/>
			 --%>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
