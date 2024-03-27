<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/env/";
    	var currentRow;

    	function init() {
    		grid = EVF.C('grid');

    		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if( celname == 'GATE_NM' ) {
					currentRow = rowid;
					var param = {
						GATE_CD: "${ses.gateCd }",
						LANG_CD: "${ses.langCd }",
						DATABASE_CD: "${ses.databaseCd }",
						callBackFunction: 'setHouseCode'
					};

					everPopup.openEnvironmentHousePopup(param);
				} else if( celname == 'BUYER_NM' ) {
					currentRow = rowid;
					var param = {
						GATE_CD: "${ses.gateCd }",
						LANG_CD: "${ses.langCd }",
						DATABASE_CD: "${ses.databaseCd }",
						callBackFunction: 'setCompanyCode'
					};

					everPopup.openEnvironmentCompanyPopup(param);
				} else if( celname == 'PUR_ORG_NM' ) {
					currentRow = rowid;
					var param = {
						GATE_CD: "${ses.gateCd }",
						LANG_CD: "${ses.langCd }",
						DATABASE_CD: "${ses.databaseCd }",
						callBackFunction: 'setPurCode'

					};

					everPopup.openEnvPurOrgPopup(param);
				} else if( celname == 'PLANT_NM' ) {
					currentRow = rowid;
					var param = {
						GATE_CD: "${ses.gateCd }",
						LANG_CD: "${ses.langCd }",
						DATABASE_CD: "${ses.databaseCd }",
						callBackFunction: 'setPlantCode'
					};

					everPopup.openEnvironmentPlantPopup(param);
				} else ;
    		});

    		grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
    			if( celname == 'SYS_KEY' && (value != oldValue) ) {
    				grid.setRowValue(rowid, { 'SYS_SEQ' : '', 'INSERT_FLAG' : 'I' });
    			}
			});

			grid.addRowEvent(function(){
				grid.addRow([{'INSERT_FLAG' : 'I'}]);
			});

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
        	store.setGrid([grid]);
            store.load(baseUrl + 'environmentSetup/searchEnvironment', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
    	}

    	function doSave() {
    		var valid = grid.validate()
    			, rowDatas = grid.getAllRowValue()
    			, rowData = {};

    		if( !valid.flag ){
    			alert( valid.msg );
    			return ;
    		}

    		for( var i = 0, len = rowDatas.length; i < len; i++) {
    			rowData = rowDatas[i];

    			if( rowData.SETTING_TYPE == 'OSHU' && grid.isEmpty(rowData.GATE_NM) ) {
					return alert("${msg.M0014}" + " --> [Gate]");
    			} else if ( rowData.SETTING_TYPE == 'OSCM' ) {
    				if( grid.isEmpty(rowData.GATE_NM) || grid.isEmpty(rowData.BUYER_NM) ) {
	                    return alert("${msg.M0014}" + "[Gate/회사명]");
    				}
    			} else if ( rowData.SETTING_TYPE == 'OSPU' ) {
    				if( grid.isEmpty(rowData.GATE_NM) || grid.isEmpty(rowData.BUYER_NM) || grid.isEmpty(rowData.PUR_ORG_CD) ) {
    					return alert("${msg.M0014}" + "[Gate/회사명/구매조직]");
    				}
    			} else if ( rowData.SETTING_TYPE == 'OSPL' ) {
    				if( grid.isEmpty(rowData.GATE_NM) || grid.isEmpty(rowData.BUYER_NM) || grid.isEmpty(rowData.PLANT_NM) ) {
    					return alert("${msg.M0014}" + "[Gate/회사명/사업장]");
    				}
    			} else ;
    		}

    		if (!confirm("${msg.M0021}")) return;

        	var store = new EVF.Store();
        	store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + 'environmentSetup/saveEnvironment', function( data ) {
        		if( this.getResponseCode() ) {
        			alert(this.getResponseMessage());
        			doSearch();
        		} else {
        			alert(this.getResponseMessage());
        		}
            });
    	}

    	function doDelete() {

    		if( Object.keys(grid.getSelRowId()).length == 0 ){
    			alert('${msg.M0004 }');
    			return;
    		}

    		if (!confirm("${msg.M0013}")) return;

        	var store = new EVF.Store();
        	store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + 'environmentSetup/deleteEnvironment', function( data ) {
        		if( this.getResponseCode() ) {
        			alert(this.getResponseMessage());
        			doSearch();
        		} else {
        			alert(this.getResponseMessage());
        		}
            });
    	}

    	function onHouseNmClick() {
            var param = {
				GATE_CD: "${ses.gateCd }",
				callBackFunction: "setHouseToForm"
			};

    		everPopup.openEnvironmentHousePopup(param);
    	}

    	function onBuyerNmClick() {
            var param = {
				GATE_CD: EVF.C('GATE_CD').getValue()
				, callBackFunction: "setCompanyToForm"
			};

            everPopup.openEnvironmentCompanyPopup(param);
    	}

    	function onPurOrgNmClick() {
            var param = {
				GATE_CD: EVF.C("GATE_CD").getValue(),
				BUYER_CD: EVF.C("BUYER_CD").getValue(),
				callBackFunction: "setPurOrgToForm"
			};

			everPopup.openEnvPurOrgPopup(param);
    	}

    	function onPlantNmClick() {
            var param = {
   				GATE_CD: EVF.C("GATE_CD").getValue(),
   				BUYER_CD: EVF.C("BUYER_CD").getValue(),
				callBackFunction: "setPlantToForm"
			};

            everPopup.openEnvironmentPlantPopup(param);

    	}
    	function setHouseToForm( param ) {
    		EVF.C('HOUSE_NAME').setValue(param[0].GATE_NM);
    		EVF.C('GATE_CD').setValue(param[0].GATE_CD);
    	}

    	function setCompanyToForm( param ) {
    		EVF.C('BUYER_NAME').setValue(param[0].BUYER_NM);
    		EVF.C('BUYER_CD').setValue(param[0].BUYER_CD);
    	}

        function setPurOrgToForm( param ) {
            EVF.C("PUR_ORG_NAME").setValue(param[0].PUR_ORG_NM);
        }

        function setPlantToForm(param) {
        	EVF.C("PLANT_NAME").setValue(param[0].PLANT_NM);
        }

    	function setHouseCode( param ){
    		grid.setCellValue(currentRow, 'GATE_CD', param[0].GATE_CD);
    		grid.setCellValue(currentRow, 'GATE_NM', param[0].GATE_NM);
    	}

        function setCompanyCode( param ) {
        	grid.setCellValue(currentRow, 'GATE_CD', param[0].GATE_CD);
        	grid.setCellValue(currentRow, 'GATE_NM', param[0].GATE_NM);
        	grid.setCellValue(currentRow, 'BUYER_CD', param[0].BUYER_CD);
        	grid.setCellValue(currentRow, 'BUYER_NM', param[0].BUYER_NM);
        }

        function setPurCode( param ) {
        	grid.setCellValue(currentRow, 'GATE_CD', param[0].GATE_CD);
        	grid.setCellValue(currentRow, 'GATE_NM', param[0].GATE_NM);
        	grid.setCellValue(currentRow, 'BUYER_CD', param[0].BUYER_CD);
        	grid.setCellValue(currentRow, 'BUYER_NM', param[0].BUYER_NM);
        	grid.setCellValue(currentRow, 'PUR_ORG_CD', param[0].PUR_ORG_CD);
        	grid.setCellValue(currentRow, 'PUR_ORG_NM', param[0].PUR_ORG_NM);
        }

        function setPlantCode( param ) {
        	grid.setCellValue(currentRow, 'GATE_CD', param[0].GATE_CD);
        	grid.setCellValue(currentRow, 'GATE_NM', param[0].GATE_NM);
        	grid.setCellValue(currentRow, 'BUYER_CD', param[0].BUYER_CD);
        	grid.setCellValue(currentRow, 'BUYER_NM', param[0].BUYER_NM);
        	grid.setCellValue(currentRow, 'PLANT_CD', param[0].PLANT_CD);
        	grid.setCellValue(currentRow, 'PLANT_NM', param[0].PLANT_NM);
        }
    </script>

    <e:window id="BSYE_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" onEnter="doSearch" labelWidth="${labelWidth }">
        	<e:row>
        		<e:label for="SETTING_TYPE" title="${form_SETTING_TYPE_N}"/>
				<e:field>
					<e:select id="SETTING_TYPE" name="SETTING_TYPE" value="${form.SETTING_TYPE}" options="${refOrganizationScale }" width="${inputTextWidth}" disabled="${form_SETTING_TYPE_D}" readOnly="${form_SETTING_TYPE_RO}" required="${form_SETTING_TYPE_R}" placeHolder="" />
				</e:field>

				<e:label for="HOUSE_NAME" title="${form_HOUSE_NAME_N}"/>
				<e:field>
					<e:search id="HOUSE_NAME" name="HOUSE_NAME" value="" width="${inputTextWidth}" maxLength="${form_HOUSE_NAME_M}" onIconClick="${form_HOUSE_NAME_RO ? 'everCommon.blank' : 'onHouseNmClick'}" disabled="${form_HOUSE_NAME_D}" readOnly="${form_HOUSE_NAME_RO}" required="${form_HOUSE_NAME_R}" />
					<e:inputHidden id="GATE_CD" name="GATE_CD" value="" />
				</e:field>
            </e:row>

			<e:row>
				<e:label for="BUYER_NAME" title="${form_BUYER_NAME_N}"/>
				<e:field>
					<e:search id="BUYER_NAME" name="BUYER_NAME" value="" width="${inputTextWidth}" maxLength="${form_BUYER_NAME_M}" onIconClick="${form_BUYER_NAME_RO ? 'everCommon.blank' : 'onBuyerNmClick'}" disabled="${form_BUYER_NAME_D}" readOnly="${form_BUYER_NAME_RO}" required="${form_BUYER_NAME_R}" />
					<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="" />
				</e:field>

				<e:label for="PUR_ORG_NAME" title="${form_PUR_ORG_NAME_N}"/>
				<e:field>
					<e:search id="PUR_ORG_NAME" name="PUR_ORG_NAME" value="" width="${inputTextWidth}" maxLength="${form_PUR_ORG_NAME_M}" onIconClick="${form_PUR_ORG_NAME_RO ? 'everCommon.blank' : 'onPurOrgNmClick'}" disabled="${form_PUR_ORG_NAME_D}" readOnly="${form_PUR_ORG_NAME_RO}" required="${form_PUR_ORG_NAME_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="PLANT_NAME" title="${form_PLANT_NAME_N}"/>
				<e:field>
					<e:search id="PLANT_NAME" name="PLANT_NAME" value="" width="${inputTextWidth}" maxLength="${form_PLANT_NAME_M}" onIconClick="${form_PLANT_NAME_RO ? 'everCommon.blank' : 'onPlantNmClick'}" disabled="${form_PLANT_NAME_D}" readOnly="${form_PLANT_NAME_RO}" required="${form_PLANT_NAME_R}" />
				</e:field>

				<e:label for="KEY_COMBO" title="${form_KEY_COMBO_N}"/>
				<e:field>
					<e:select id="KEY_COMBO" name="KEY_COMBO" value="${form.KEY_COMBO}" options="" width="${inputTextWidth}" disabled="${form_KEY_COMBO_D}" readOnly="${form_KEY_COMBO_RO}" required="${form_KEY_COMBO_R}" placeHolder="">
						<e:option value="SYS_KEY" text="${BSYE_010_SYS_KEY }" />
						<e:option value="SYS_VALUE" text="${BSYE_010_SYS_VALUE }" />
						<e:option value="DESC" text="${BSYE_010_SYS_DESC }" />
					</e:select>
					<e:inputText id="KEY_TEXT" name="KEY_TEXT" value="${form.KEY_TEXT}" width="50%" maxLength="${form_KEY_TEXT_M}" disabled="${form_KEY_TEXT_D}" readOnly="${form_KEY_TEXT_RO}" required="${form_KEY_TEXT_R}" />
				</e:field>
			</e:row>
        </e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>