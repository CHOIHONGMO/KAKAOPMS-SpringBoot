<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
 <script type="text/javascript">

	var gridH, gridD;
	var baseUrl = "/evermp/BS01/BS0102/";
	var G_CUST_CD;
	var G_CUST_NM;

	function init(){
        gridH = EVF.C("gridH");
        gridD = EVF.C("gridD");

        gridH.setProperty('shrinkToFit', false);
        gridH.setProperty('multiSelect', false);
        gridD.setProperty('shrinkToFit', false);


        if ('${ses.userType}' != 'C') {
			EVF.C("CUST_CD_L").setDisabled(true);
			EVF.C("CUST_NM_L").setDisabled(true);
        } else {
			EVF.C("CUST_CD_L").setValue('');
			EVF.C("CUST_NM_L").setValue('');
        }

        gridH.cellClickEvent(function(rowId, colName, value) {
            /*if(colName === "CUST_NM") {

                var CUST_CD = gridH.getCellValue(rowId, "CUST_CD");
                var CUST_NM = gridH.getCellValue(rowId, "CUST_NM");

                G_CUST_CD = CUST_CD;
                G_CUST_NM = CUST_NM;
                EVF.C("CUST_CD_R").setValue(CUST_CD);
                EVF.C("CUST_NM_R").setValue(CUST_NM);

                doSearchD(CUST_CD);
            }*/

			if(colName === "PLANT_CD") {
				doClear();
				EVF.V('PLANT_CD',gridH.getCellValue(rowId,'PLANT_CD'));
				doSearchPlant(rowId);

			}
        });

        gridD.cellClickEvent(function(rowId, colName, value) {
        	if (colName == "CUST_CD") {
                var param = {
                    'CUST_CD': gridD.getCellValue(rowId, 'CUST_CD'),
                    'detailView': false,
                    'popupFlag': true
                };
                everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
            }

        });


        gridH.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        gridD.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        gridD.addRowEvent(function() {
        	var CUST_CD_R = EVF.C('CUST_CD_R').getValue();
        	var CUST_NM_R = EVF.C('CUST_NM_R').getValue();

    		if (CUST_CD_R == "") {
    			alert("${BS01_040_001 }");
    			return;
    		}

    		addParam = [{"CUST_CD": CUST_CD_R,"CUST_NM": CUST_NM_R,"USE_FLAG": '1'}];

        	gridD.addRow(addParam);
        });

        gridD.delRowEvent(function() {

            if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var delCnt = 0;
            var rowIds = gridD.getSelRowId();
            for(var i = rowIds.length -1; i >= 0; i--) {
                if(!EVF.isEmpty(gridD.getCellValue(rowIds[i], "COST_CENTER_SEQ"))) {
                    delCnt++;
                } else {
                	gridD.delRow(rowIds[i]);
                }
            }
            if(delCnt > 0) {
            	doDeleteDT();
            }
        });

        if ('${ses.userType}' != 'C') {
            doSearch();
        }
    }

    function searchCustCd() {
        var param = {
            callBackFunction : "selectCustCd"
        };
        everPopup.openCommonPopup(param, 'SP0067');
    }

    function selectCustCd(dataJsonArray) {
        EVF.C("CUST_CD_L").setValue(dataJsonArray.CUST_CD);
        EVF.C("CUST_NM_L").setValue(dataJsonArray.CUST_NM);
		EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
		EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
		EVF.C("ERP_IF_FLAG").setValue(dataJsonArray.ERP_IF_FLAG);
		doSearch();
    }

	function searchCustCd2() {
		var param = {
			callBackFunction : "selectCustCd2"
		};
		everPopup.openCommonPopup(param, 'SP0067');
	}

	function selectCustCd2(dataJsonArray) {
		EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
		EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
	}

	function doSearch() {

		if(EVF.V("CUST_CD_L") == ''){
			return EVF.alert("${BS01_040_001}");
		}

		var store = new EVF.Store();
		/*if (!store.validate()) { return; }*/
        store.setGrid([gridH]);
		store.load(baseUrl + "bs01040_doSearch", function () {
			doClear();

			if(gridH.getRowCount() === 0) {
				return alert('${msg.M0002}');
			}else{
				EVF.V('MANAGE_ID', gridH.getCellValue(0,'MANAGE_ID'));
			}
		});
	}

	//고객사 사업장 조회
	function doSearchPlant(rowId){
		var store = new EVF.Store();
		store.setParameter("CUST_CD", gridH.getCellValue(rowId,"CUST_CD"));
		store.setParameter("PLANT_CD", gridH.getCellValue(rowId,"PLANT_CD"));
		store.load(baseUrl + "bs01040_doSearchPlant", function () {
			var plantData = this.getParameter("formData");
			for(var i in plantData){
				if($('#' + i).length === 0) continue;
				if(plantData[i] == null){
					EVF.V(i, "");
				}else{
					EVF.V(i, plantData[i]);
				}
			}
		});
	}

    function doSearchDC(){
    	//var CUST_CD = EVF.C('CUST_CD_R').getValue();
    	//doSearchD(CUST_CD);
    }
	// 고객사 플랜트 조회
    function doSearchD(CUST_CD) {

        var store = new EVF.Store();
        if (!store.validate()) { return; }

        store.setGrid([gridD]);
        store.setParameter("CUST_CD", CUST_CD);
        store.setParameter("MNG_ID", EVF.C('MNG_ID').getValue());
        store.load(baseUrl + "bs01040_doSearchD", function () {
            if(gridD.getRowCount() === 0) {
                <%--return alert('${msg.M0002}');--%>
            }
        });
    }

    // 고객사플랜트 저장
    function doSaveDT() {
		if (EVF.C("ERP_IF_FLAG").getValue() == '1' ) {
			alert("${BS01_040_005}");
			return;
		}


    	var store = new EVF.Store();
		if (!store.validate()) { return; }





        /*기존 코드는 주석처리함.
        if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }


        if(!confirm("${BS01_040_002}")) { return; }

        store.setGrid([gridD]);
        store.getGridData(gridD, "sel");
        store.load(baseUrl + "bs01040_doSaveDT", function() {
            alert(this.getResponseMessage());
            //doSearch();
            //doSearchD(EVF.C('CUST_CD_R').getValue());
        });*/

		var alertMsg = EVF.V("PLANT_CD") === "" ? "${msg.M0011}" : "${msg.M0012}";
		if(!confirm(alertMsg)){
			return;
		}

		store.doFileUpload(function() {
			store.load(baseUrl + "bs01040_doSavePlantAndAcc", function() {
				alert("${msg.M0001}");
				doSearch();
			});
		});

    }

    // 고객사플랜트삭제
    function doDeleteDT() {
		if (EVF.C("ERP_IF_FLAG").getValue() == '1' ) {
			alert("${BS01_040_005}");
			return;
		}



		if(EVF.V("PLANT_CD") == ''){
			return EVF.alert("${BS01_040_004}");
		}

		if(!confirm("${msg.M0013}")) { return; }

        var store = new EVF.Store();

        //if (!store.validate()) { return; }
		//기존 그리드에서 선택하여 삭제하던 방식 주석처리.
        /*if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }



        store.setGrid([gridD]);
        store.getGridData(gridD, "sel");
        store.load(baseUrl + "bs01040_doDeleteDT", function() {
            alert(this.getResponseMessage());
            //doSearch();
            //doSearchD(EVF.C('CUST_CD_R').getValue());
        });*/

		store.load(baseUrl + "bs01040_doDeletePlantAndAcc", function() {
			EVF.alert("${msg.M0001}");
			doSearch();
			//doSearchD(EVF.C('CUST_CD_R').getValue());
		});


    }

	function searchZipCd() {
		var url = '/common/code/BADV_020/view';
		var param = {
			callBackFunction : "setZipCode",
			modalYn : false
		};
		everPopup.openWindowPopup(url, 700, 600, param);
	}

	function setZipCode(zipcd) {
		if (zipcd.ZIP_CD != "") {
			EVF.C("ZIP_CD").setValue(zipcd.ZIP_CD_5);
			EVF.C('ADDR1').setValue(zipcd.ADDR1);
			EVF.C('ADDR2').setValue(zipcd.ADDR2);
			EVF.C('ADDR2').setFocus();
		}
	}

	function searchZipCd2() {
		var url = '/common/code/BADV_020/view';
		var param = {
			callBackFunction : "setZipCode2",
			modalYn : false
		};
		everPopup.openWindowPopup(url, 700, 600, param);
	}

	function setZipCode2(zipcd) {
		if (zipcd.ZIP_CD != "") {
			EVF.C("CUBL_ZIP_CD").setValue(zipcd.ZIP_CD_5);
			EVF.C('CUBL_ADDR1').setValue(zipcd.ADDR1);
			EVF.C('CUBL_ADDR2').setValue(zipcd.ADDR2);
			EVF.C('CUBL_ADDR2').setFocus();
		}
	}

	function doClear(){
		EVF.V('PLANT_CD','');

		$('#formR').find('input').each(function(k,v){
			if($('#' + v.id).length !== 0 && v.id !== 'CUST_NM' && v.id !== 'CUST_CD'){
				EVF.V(v.id,"");
			}
		});

		$('#formB').find('input').each(function(k,v){
			if($('#' + v.id).length !== 0){
				EVF.V(v.id,"");
			}
		});
	}

	function checkIrsNum() {
		if( !isIrsNum(EVF.C("IRS_NUM").getValue()) ) {
			alert("${msg.M0126}");
			EVF.C("IRS_NUM").setValue("");
			EVF.C('IRS_NUM').setFocus();
		} else {
			var irs_no = EVF.V("IRS_NUM").replace(/-/gi, '');
			EVF.V('IRS_NUM', irs_no);

			// 사업자 등록번호 중복 여부 체크 일단 주석 처리
			/*var store = new EVF.Store();
			store.load('/evermp/BS01/BS0101/bs01002_checkIrsNum', function() {
				if(this.getParameter("POSSIBLE_FLAG") == "N") {
					EVF.C("IRS_NUM").setValue("");
					EVF.C('IRS_NUM').setFocus();
					return alert("${msg.M0127}");
				}
			}, false);*/
		}
	}

	function isIrsNum(str) {
		var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
		var chkSum = 0;
		var c2 = "";
		var remander;
		str = str.replace(/-/gi,'');

		for (var i = 0; i <= 7; i++) {
			chkSum += checkID[i] * str.charAt(i);
		}
		c2 = "0" + (checkID[8] * str.charAt(8));
		c2 = c2.substring(c2.length - 2, c2.length);
		chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
		remander = (10 - (chkSum % 10)) % 10 ;
		if (Math.floor(str.charAt(9)) == remander) {
			return true ; // OK!
		}
		return false;
	}


	function doCopy() {

		EVF.C("CUBL_CUST_NM").setValue(     EVF.C("PLANT_NM").getValue()    );
		EVF.C("CUBL_CEO_USER_NM").setValue(  EVF.C("CEO_USER_NM").getValue()   );
		EVF.C("CUBL_IRS_NUM").setValue(  EVF.C("IRS_NUM").getValue()   );
		EVF.C("CUBL_BUSINESS_TYPE").setValue(  EVF.C("BUSINESS_TYPE").getValue()   );
		EVF.C("CUBL_INDUSTRY_TYPE").setValue( EVF.C("INDUSTRY_TYPE").getValue()    );
		EVF.C("CUBL_ZIP_CD").setValue(  EVF.C("ZIP_CD").getValue()   );
		EVF.C("CUBL_ADDR1").setValue(  EVF.C("ADDR1").getValue()   );
		EVF.C("CUBL_ADDR2").setValue(  EVF.C("ADDR2").getValue()   );

	}

 </script>
 
	<e:window id="BS01_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:inputHidden id="MANAGE_ID" name="MANAGE_ID" />
		<e:panel id="panL" width="39%" height="100%">
			<e:searchPanel id="formL" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" useTitleBar="false" onEnter="doSearch">
				<e:row>
					<e:label for="CUST_CD_L" title="${formL_CUST_CD_N}"/>
					<e:field>
						<e:search id="CUST_CD_L" name="CUST_CD_L" value="${ses.companyCd}" width="40%" maxLength="${formL_CUST_CD_M}" onIconClick="searchCustCd" disabled="${formL_CUST_CD_D}" readOnly="${formL_CUST_CD_RO}" required="${formL_CUST_CD_R}" />
						<e:inputText id="CUST_NM_L" name="CUST_NM_L" value="${ses.companyNm}" width="60%" maxLength="${formL_CUST_NM_M}" disabled="${formL_CUST_NM_D}" readOnly="${formL_CUST_NM_RO}" required="${formL_CUST_NM_R}" />
						<e:inputHidden id="ERP_IF_FLAG" name="ERP_IF_FLAG" value="${ses.erpIfFlag}"/>
					</e:field>
				</e:row>
			</e:searchPanel>

			<e:buttonBar align="right" width="100%">
				<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
			</e:buttonBar>

			<e:gridPanel id="gridH" name="gridH" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridH.gridColData}" />
		</e:panel>

		<e:panel id="panBlank" width="1%">&nbsp;</e:panel>

		<e:panel id="panR" width="60%" height="100%">
			<e:buttonBar align="right" width="100%" title="사업장 정보">
				<e:button id="SaveDT" name="SaveDT" label="${SaveDT_N}" onClick="doSaveDT" disabled="${SaveDT_D}" visible="${SaveDT_V}"/>
				<e:button id="DeleteDT" name="DeleteDT" label="${DeleteDT_N}" onClick="doDeleteDT" disabled="${DeleteDT_D}" visible="${DeleteDT_V}"/>
				<e:button id="Clear" name="Clear" label="${Clear_N}" onClick="doClear" disabled="${Clear_D}" visible="${Clear_V}"/>
			</e:buttonBar>
			
			<e:searchPanel id="formR" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
				<e:row>
					<e:label for="PLANT_CD" title="${formR_PLANT_CD_N}" />
					<e:field>
						<e:inputText id="PLANT_CD" name="PLANT_CD" value="" width="${formR_PLANT_CD_W}" maxLength="${formR_PLANT_CD_M}" disabled="${formR_PLANT_CD_D}" readOnly="${formR_PLANT_CD_RO}" required="${formR_PLANT_CD_R}" />
					</e:field>
					<e:label for="CUST_NM" title="${formR_CUST_NM_N}" />
					<e:field>
						<e:search id="CUST_CD" name="CUST_CD" value="" width="35%" maxLength="${formR_CUST_CD_M}" onIconClick="${formR_CUST_CD_RO ? 'everCommon.blank' : 'searchCustCd2'}" disabled="${formR_CUST_CD_D}" readOnly="true" required="${formR_CUST_CD_R}" />
						<e:inputText id="CUST_NM" name="CUST_NM" value="" width="${formR_CUST_NM_W}" maxLength="${formR_CUST_NM_M}" disabled="${formR_CUST_NM_D}" readOnly="true" required="${formR_CUST_NM_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="PLANT_NM" title="${formR_PLANT_NM_N}" />
					<e:field>
						<e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="${formR_PLANT_NM_W}" maxLength="${formR_PLANT_NM_M}" disabled="${formR_PLANT_NM_D}" readOnly="${formR_PLANT_NM_RO}" required="${formR_PLANT_NM_R}" />
					</e:field>
					<e:label for="CEO_USER_NM" title="${formR_CEO_USER_NM_N}" />
					<e:field>
						<e:inputText id="CEO_USER_NM" name="CEO_USER_NM" value="" width="${formR_CEO_USER_NM_W}" maxLength="${formR_CEO_USER_NM_M}" disabled="${formR_CEO_USER_NM_D}" readOnly="${formR_CEO_USER_NM_RO}" required="${formR_CEO_USER_NM_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="IRS_NUM" title="${formR_IRS_NUM_N}" />
					<e:field>
						<e:inputText id="IRS_NUM" name="IRS_NUM" value="" width="${formR_IRS_NUM_W}" maxLength="${formR_IRS_NUM_M}" disabled="${formR_IRS_NUM_D}" readOnly="${formR_IRS_NUM_RO}" required="${formR_IRS_NUM_R}" onChange="checkIrsNum"/>
					</e:field>
					<e:label for="COMPANY_REG_NUM" title="${formR_COMPANY_REG_NUM_N}" />
					<e:field>
						<e:inputText id="COMPANY_REG_NUM" name="COMPANY_REG_NUM" value="" width="${formR_COMPANY_REG_NUM_W}" maxLength="${formR_COMPANY_REG_NUM_M}" disabled="${formR_COMPANY_REG_NUM_D}" readOnly="${formR_COMPANY_REG_NUM_RO}" required="${formR_COMPANY_REG_NUM_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="TEL_NUM" title="${formR_TEL_NUM_N}" />
					<e:field>
						<e:inputText id="TEL_NUM" name="TEL_NUM" value="" width="${formR_TEL_NUM_W}" maxLength="${formR_TEL_NUM_M}" disabled="${formR_TEL_NUM_D}" readOnly="${formR_TEL_NUM_RO}" required="${formR_TEL_NUM_R}" />
					</e:field>
					<e:label for="FAX_NUM" title="${formR_FAX_NUM_N}" />
					<e:field>
						<e:inputText id="FAX_NUM" name="FAX_NUM" value="" width="${formR_FAX_NUM_W}" maxLength="${formR_FAX_NUM_M}" disabled="${formR_FAX_NUM_D}" readOnly="${formR_FAX_NUM_RO}" required="${formR_FAX_NUM_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="EMAIL" title="${formR_EMAIL_N}" />
					<e:field>
						<e:inputText id="EMAIL" name="EMAIL" value="" width="${formR_EMAIL_W}" maxLength="${formR_EMAIL_M}" disabled="${formR_EMAIL_D}" readOnly="${formR_EMAIL_RO}" required="${formR_EMAIL_R}" />
					</e:field>
					<e:label for="FOUNDATION_DATE" title="${formR_FOUNDATION_DATE_N}"/>
					<e:field>
						<e:inputDate id="FOUNDATION_DATE" name="FOUNDATION_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${formR_FOUNDATION_DATE_R}" disabled="${formR_FOUNDATION_DATE_D}" readOnly="${formR_FOUNDATION_DATE_RO}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="BUSINESS_TYPE" title="${formR_BUSINESS_TYPE_N}" />
					<e:field>
						<e:inputText id="BUSINESS_TYPE" name="BUSINESS_TYPE" value="" width="${formR_BUSINESS_TYPE_W}" maxLength="${formR_BUSINESS_TYPE_M}" disabled="${formR_BUSINESS_TYPE_D}" readOnly="${formR_BUSINESS_TYPE_RO}" required="${formR_BUSINESS_TYPE_R}" />
					</e:field>
					<e:label for="INDUSTRY_TYPE" title="${formR_INDUSTRY_TYPE_N}" />
					<e:field>
						<e:inputText id="INDUSTRY_TYPE" name="INDUSTRY_TYPE" value="" width="${formR_INDUSTRY_TYPE_W}" maxLength="${formR_INDUSTRY_TYPE_M}" disabled="${formR_INDUSTRY_TYPE_D}" readOnly="${formR_INDUSTRY_TYPE_RO}" required="${formR_INDUSTRY_TYPE_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="ZIP_CD" title="${formR_ZIP_CD_N}"/>
					<e:field>
						<e:search id="ZIP_CD" name="ZIP_CD" value="" width="${formR_ZIP_CD_W}" maxLength="${formR_ZIP_CD_M}" onIconClick="${formR_ZIP_CD_RO ? 'everCommon.blank' : 'searchZipCd'}" disabled="${formR_ZIP_CD_D}" readOnly="true" required="${formR_ZIP_CD_R}" />
					</e:field>
					<e:label for="PAY_CONDITION" title="${formR_PAY_CONDITION_N}" />
					<e:field>
						<e:inputText id="PAY_CONDITION" name="PAY_CONDITION" value="" width="${formR_PAY_CONDITION_W}" maxLength="${formR_PAY_CONDITION_M}" disabled="${formR_PAY_CONDITION_D}" readOnly="${formR_PAY_CONDITION_RO}" required="${formR_PAY_CONDITION_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="ADDR1" title="${formR_ADDR1_N}" />
					<e:field colSpan="3">
						<e:inputText id="ADDR1" name="ADDR1" value="" width="${formR_ADDR1_W}" maxLength="${formR_ADDR1_M}" disabled="${formR_ADDR1_D}" readOnly="${formR_ADDR1_RO}" required="${formR_ADDR1_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="ADDR2" title="${formR_ADDR2_N}" />
					<e:field colSpan="3">
						<e:inputText id="ADDR2" name="ADDR2" value="" width="${formR_ADDR2_W}" maxLength="${formR_ADDR2_M}" disabled="${formR_ADDR2_D}" readOnly="${formR_ADDR2_RO}" required="${formR_ADDR2_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="ATTACH_FILE_NUM" title="${formR_ATTACH_FILE_NUM_N}"/>
					<e:field colSpan="3">
						<e:fileManager id="ATTACH_FILE_NUM" name="ATTACH_FILE_NUM" fileId="${formData.ATTACH_FILE_NUM}" downloadable="true" width="100%" bizType="CUST" height="" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${formR_ATTACH_FILE_NUM_R}" fileExtension="${fileExtension}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="USE_FLAG" title="${formR_USE_FLAG_N}"/>
					<e:field colSpan="3">
					<e:select id="USE_FLAG" name="USE_FLAG" value="${formData.USE_FLAG}" options="${useFlagOptions}" width="${formR_USE_FLAG_W}" disabled="${formR_USE_FLAG_D}" readOnly="${formR_USE_FLAG_RO}" required="${formR_USE_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
					</e:field>
				</e:row>
			</e:searchPanel>

			<e:searchPanel id="formC" title="담당자정보" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="true" onEnter="">
				<e:row>
					<e:label for="GR_PERSON" title="${formR_GR_PERSON_N}" />
					<e:field>
						<e:inputText id="GR_PERSON" name="GR_PERSON" value="" width="${formR_GR_PERSON_W}" maxLength="${formR_GR_PERSON_M}" disabled="${formR_GR_PERSON_D}" readOnly="${formR_GR_PERSON_RO}" required="${formR_GR_PERSON_R}" />
					</e:field>
					<e:label for="GR_PERSON_TEL_NUM" title="${formR_GR_PERSON_TEL_NUM_N}" />
					<e:field>
						<e:inputText id="GR_PERSON_TEL_NUM" name="GR_PERSON_TEL_NUM" value="" width="${formR_GR_PERSON_TEL_NUM_W}" maxLength="${formR_GR_PERSON_TEL_NUM_M}" disabled="${formR_GR_PERSON_TEL_NUM_D}" readOnly="${formR_GR_PERSON_TEL_NUM_RO}" required="${formR_GR_PERSON_TEL_NUM_R}" />
					</e:field>
					<e:label for="GR_PERSON_EMAIL" title="${formR_GR_PERSON_EMAIL_N}" />
					<e:field>
					<e:inputText id="GR_PERSON_EMAIL" name="GR_PERSON_EMAIL" value="" width="${formR_GR_PERSON_EMAIL_W}" maxLength="${formR_GR_PERSON_EMAIL_M}" disabled="${formR_GR_PERSON_EMAIL_D}" readOnly="${formR_GR_PERSON_EMAIL_RO}" required="${formR_GR_PERSON_EMAIL_R}" />
					</e:field>

				</e:row>
				<e:row>
					<e:label for="ACC_PERSON" title="${formR_ACC_PERSON_N}" />
					<e:field>
						<e:inputText id="ACC_PERSON" name="ACC_PERSON" value="" width="${formR_ACC_PERSON_W}" maxLength="${formR_ACC_PERSON_M}" disabled="${formR_ACC_PERSON_D}" readOnly="${formR_ACC_PERSON_RO}" required="${formR_ACC_PERSON_R}" />
					</e:field>
					<e:label for="ACC_PERSON_TEL_NUM" title="${formR_ACC_PERSON_TEL_NUM_N}" />
					<e:field>
						<e:inputText id="ACC_PERSON_TEL_NUM" name="ACC_PERSON_TEL_NUM" value="" width="${formR_ACC_PERSON_TEL_NUM_W}" maxLength="${formR_ACC_PERSON_TEL_NUM_M}" disabled="${formR_ACC_PERSON_TEL_NUM_D}" readOnly="${formR_ACC_PERSON_TEL_NUM_RO}" required="${formR_ACC_PERSON_TEL_NUM_R}" />
					</e:field>
					<e:label for="ACC_PERSON_EMAIL" title="${formR_ACC_PERSON_EMAIL_N}" />
					<e:field>
					<e:inputText id="ACC_PERSON_EMAIL" name="ACC_PERSON_EMAIL" value="" width="${formR_ACC_PERSON_EMAIL_W}" maxLength="${formR_ACC_PERSON_EMAIL_M}" disabled="${formR_ACC_PERSON_EMAIL_D}" readOnly="${formR_ACC_PERSON_EMAIL_RO}" required="${formR_ACC_PERSON_EMAIL_R}" />
					</e:field>
				</e:row>
			</e:searchPanel>


			<e:searchPanel id="formB" title="청구지 정보" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="true" onEnter="">
				<e:inputHidden id="CUBL_SQ" name="CUBL_SQ" />
				<e:row>
					<e:label for="CUBL_CUST_NM" title="${formB_CUBL_CUST_NM_N}" />
					<e:field colSpan="3">
						<e:inputText id="CUBL_CUST_NM" name="CUBL_CUST_NM" value="" width="${formB_CUBL_CUST_NM_W}" maxLength="${formB_CUBL_CUST_NM_M}" disabled="${formB_CUBL_CUST_NM_D}" readOnly="${formB_CUBL_CUST_NM_RO}" required="${formB_CUBL_CUST_NM_R}" />
						&nbsp;&nbsp;&nbsp;&nbsp;
						<e:button id="doCopy" name="doCopy" label="${doCopy_N}" onClick="doCopy" disabled="${doCopy_D}" visible="${doCopy_V}"/>
					</e:field>
				</e:row>
				<e:row>
					<e:label for="CUBL_CEO_USER_NM" title="${formB_CUBL_CEO_USER_NM_N}" />
					<e:field>
						<e:inputText id="CUBL_CEO_USER_NM" name="CUBL_CEO_USER_NM" value="" width="${formB_CUBL_CEO_USER_NM_W}" maxLength="${formB_CUBL_CEO_USER_NM_M}" disabled="${formB_CUBL_CEO_USER_NM_D}" readOnly="${formB_CUBL_CEO_USER_NM_RO}" required="${formB_CUBL_CEO_USER_NM_R}" />
					</e:field>
					<e:label for="CUBL_IRS_NUM" title="${formB_CUBL_IRS_NUM_N}" />
					<e:field>
						<e:inputText id="CUBL_IRS_NUM" name="CUBL_IRS_NUM" value="" width="${formB_CUBL_IRS_NUM_W}" maxLength="${formB_CUBL_IRS_NUM_M}" disabled="${formB_CUBL_IRS_NUM_D}" readOnly="${formB_CUBL_IRS_NUM_RO}" required="${formB_CUBL_IRS_NUM_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="CUBL_BUSINESS_TYPE" title="${formB_CUBL_BUSINESS_TYPE_N}" />
					<e:field>
						<e:inputText id="CUBL_BUSINESS_TYPE" name="CUBL_BUSINESS_TYPE" value="" width="${formB_CUBL_BUSINESS_TYPE_W}" maxLength="${formB_CUBL_BUSINESS_TYPE_M}" disabled="${formB_CUBL_BUSINESS_TYPE_D}" readOnly="${formB_CUBL_BUSINESS_TYPE_RO}" required="${formB_CUBL_BUSINESS_TYPE_R}" />
					</e:field>
					<e:label for="CUBL_INDUSTRY_TYPE" title="${formB_CUBL_INDUSTRY_TYPE_N}" />
					<e:field>
						<e:inputText id="CUBL_INDUSTRY_TYPE" name="CUBL_INDUSTRY_TYPE" value="" width="${formB_CUBL_INDUSTRY_TYPE_W}" maxLength="${formB_CUBL_INDUSTRY_TYPE_M}" disabled="${formB_CUBL_INDUSTRY_TYPE_D}" readOnly="${formB_CUBL_INDUSTRY_TYPE_RO}" required="${formB_CUBL_INDUSTRY_TYPE_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="CUBL_ZIP_CD" title="${formB_CUBL_ZIP_CD_N}"/>
					<e:field>
						<e:search id="CUBL_ZIP_CD" name="CUBL_ZIP_CD" value="" width="${formB_CUBL_ZIP_CD_W}" maxLength="${formB_CUBL_ZIP_CD_M}" onIconClick="${formB_CUBL_ZIP_CD_RO ? 'everCommon.blank' : 'searchZipCd2'}" disabled="${formB_CUBL_ZIP_CD_D}" readOnly="true" required="${formB_CUBL_ZIP_CD_R}" />
					</e:field>
					<e:label for="" />
					<e:field colSpan="1" />
				</e:row>
				<e:row>
					<e:label for="CUBL_ADDR1" title="${formB_CUBL_ADDR1_N}" />
					<e:field>
						<e:inputText id="CUBL_ADDR1" name="CUBL_ADDR1" value="" width="${formB_CUBL_ADDR1_W}" maxLength="${formB_CUBL_ADDR1_M}" disabled="${formB_CUBL_ADDR1_D}" readOnly="${formB_CUBL_ADDR1_RO}" required="${formB_CUBL_ADDR1_R}" />
					</e:field>
					<e:label for="CUBL_ADDR2" title="${formB_CUBL_ADDR2_N}" />
					<e:field>
						<e:inputText id="CUBL_ADDR2" name="CUBL_ADDR2" value="" width="${formB_CUBL_ADDR2_W}" maxLength="${formB_CUBL_ADDR2_M}" disabled="${formB_CUBL_ADDR2_D}" readOnly="${formB_CUBL_ADDR2_RO}" required="${formB_CUBL_ADDR2_R}" />
					</e:field>
				</e:row>
			</e:searchPanel>

			<div style="display:none">
			<e:gridPanel id="gridD" name="gridD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />
			</div>
		</e:panel>
	</e:window>
</e:ui>
