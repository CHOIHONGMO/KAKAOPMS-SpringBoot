<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var baseUrl = "/eversrm/system/org/";
    var saveCode;
    var grid = {};

    function init() {
		grid = EVF.C('grid');
		grid.setProperty('multiselect', false);
		grid.setProperty('shrinkToFit', true);

		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			if(celname == "DEPT_CD") {
				setFormData(rowid);
            }
		});
		grid.setProperty('panelVisible', ${panelVisible});
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

		doSearch();
	}

    function doSearch() {
    	var store = new EVF.Store();
    	store.setGrid([grid]);
        store.load(baseUrl + 'BSYO_060/doSearchGrid', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            } else {
            	if (saveCode != null) {
            		var rowIds = grid.jsonToArray(grid.getAllRowId()).value;
            		for (var i = 0, length = rowIds.length; i < length; i++) {
                        if (grid.getCellValue(rowIds[i], "DEPT_CD") == saveCode) {
                            setFormData(rowIds[i]);
                            return;
                        }
                    }
                }
            	setFormData(0);
            }
        });
    }

	function setFormData(rowid) {
		var deptCd = grid.getCellValue(rowid, "DEPT_CD");
		var buyerCd = grid.getCellValue(rowid, "BUYER_CD");
		var store = new EVF.Store();

		store.setParameter("DEPT_CD", deptCd);
		store.setParameter("BUYER_CD", buyerCd);
		
		store.load(baseUrl + 'BSYO_060/doSearchDeptINFO', function() {
			var ogdpdata = JSON.parse(this.getParameter("deptInfo"));
			EVF.C("BUYER_CD").setValue(ogdpdata[0].BUYER_CD,false);
			EVF.C("DEPT_CD").setValue(ogdpdata[0].DEPT_CD,false);
			EVF.C("DEPT_NM").setValue(ogdpdata[0].DEPT_NM);
			EVF.C("DEPT_NM_ENG").setValue(ogdpdata[0].DEPT_NM_ENG);
			EVF.C("DEPT_CHIEF_NM").setValue(ogdpdata[0].DEPT_CHIEF_NM);
			EVF.C("PARENT_DEPT_CD").setValue(ogdpdata[0].PARENT_DEPT_CD);
			EVF.C("ADDR").setValue(ogdpdata[0].ADDR);
			EVF.C("ADDR_ENG").setValue(ogdpdata[0].ADDR_ENG);
			EVF.C("TEL_NUM").setValue(ogdpdata[0].TEL_NUM);
			EVF.C("FAX_NUM").setValue(ogdpdata[0].FAX_NUM);
			EVF.C("REG_DATE").setValue(ogdpdata[0].REG_DATE);
			EVF.C("USER_NM").setValue(ogdpdata[0].USER_NM);
			EVF.C("GATE_CD").setValue(ogdpdata[0].GATE_CD);
			EVF.C("BUYER_CD_ORI").setValue(ogdpdata[0].BUYER_CD_ORI);
			EVF.C("DEPT_CD_ORI").setValue(ogdpdata[0].DEPT_CD_ORI);
			EVF.C("INSERT_FLAG").setValue(ogdpdata[0].INSERT_FLAG);
		});
	}

    function doSave() {
		if (!confirm("${msg.M0021 }")) return;

        EVF.C('INSERT_FLAG').setValue('S');
        saveCode = EVF.C('DEPT_CD').getValue();

		var store = new EVF.Store();
		store.load(baseUrl + 'BSYO_060/doSave', function(){
			alert(this.getResponseMessage());
            doSearch();
        });
    }

    function doDelete() {
		if (!confirm("${msg.M0013 }")) return;

        EVF.C('INSERT_FLAG').setValue('D');

		var store = new EVF.Store();
		store.load(baseUrl + 'BSYO_060/doDelete', function(){
			alert(this.getResponseMessage());
            doSearch();
            doReset();
        });
    }

    function doReset() {
    	EVF.C("BUYER_CD").setValue("");
    	EVF.C("DEPT_CD").setValue("");
    	EVF.C("DEPT_NM").setValue("");
    	EVF.C("DEPT_NM_ENG").setValue("");
    	EVF.C("DEPT_CHIEF_NM").setValue("");
    	EVF.C("PARENT_DEPT_CD").setValue("");
    	EVF.C("ADDR").setValue("");
    	EVF.C("ADDR_ENG").setValue("");
    	EVF.C("TEL_NUM").setValue("");
    	EVF.C("FAX_NUM").setValue("");
    	EVF.C("REG_DATE").setValue("");
    	EVF.C("USER_NM").setValue("");
    }

    function doSearchParent() {
        if ((EVF.C("BUYER_CD").getValue() == "") || (EVF.C("DEPT_CD").getValue() == "")) {
            alert("${BSYO_060_MSG_001 }");
            return;
        }

        var param = {
            callBackFunction: 'selectParentDept',
            "GATE_CD": EVF.C("GATE_CD").getValue(),
            "BUYER_CD": EVF.C("BUYER_CD").getValue(),
            "DEPT_CD_CHILD": EVF.C("DEPT_CD").getValue()
        };
        //everPopup.openDeptInHierarchy(param);


        var param = {
                callBackFunction: "selectParentDept",
                BUYER_CD: EVF.C("BUYER_CD").getValue()
            };
        everPopup.openCommonPopup(param, 'SP0002');


    }

    function selectParentDept(data) {
        EVF.C('PARENT_DEPT_CD').setValue(data.DEPT_CD);
    }

    function deptCodeChange() {
        var deptCd = EVF.C('DEPT_CD').getValue();
        deptCd.setValue(deptCd.getValue().replace(/ /g, ''));
    }

    </script>

    <e:window id="BSYO_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <e:button id="Reset" name="Reset" label="${Reset_N }" disabled="${Reset_D }" onClick="doReset" />
        </e:buttonBar>

    	<e:panel id="leftPanel" height="fit" width="35%">
    		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="98%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    	</e:panel>


		<e:panel id="rightPanel" height="100%" width="65%">
		<e:searchPanel id="form" useTitleBar="false" title="${form_caption_form_N}" labelWidth="${labelWidth}" width="100%" columnCount="2">
	        <e:row>

				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
				<e:select id="BUYER_CD" name="BUYER_CD" style='ime-mode:inactive' value="${form.BUYER_CD}" options="${refBuyerCd}"   width="100%" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder=""  onChange="doRequeryTree"/>
				</e:field>




                <e:label for="DEPT_CD" title="${form_DEPT_CD_N}"></e:label>
                <e:field>
					<e:inputText id="DEPT_CD" name="DEPT_CD" style='ime-mode:inactive' width="100%" maxLength="${form_DEPT_CD_M }" required="${form_DEPT_CD_R }" readOnly="${form_DEPT_CD_RO }" disabled="${form_DEPT_CD_D}" visible="${form_DEPT_CD_V}" onChange="deptCodeChange"></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N}"></e:label>
                <e:field>
					<e:inputText id="DEPT_NM" name="DEPT_NM" style="${imeMode}" width="100%" maxLength="${form_DEPT_NM_M }" required="${form_DEPT_NM_R }" readOnly="${form_DEPT_NM_RO }" disabled="${form_DEPT_NM_D}" visible="${form_DEPT_NM_V}" ></e:inputText>
                </e:field>
                <e:label for="DEPT_NM_ENG" title="${form_DEPT_NM_ENG_N}"></e:label>
                <e:field>
					<e:inputText id="DEPT_NM_ENG" style='ime-mode:inactive' name="DEPT_NM_ENG" width="100%" maxLength="${form_DEPT_NM_ENG_M }" required="${form_DEPT_NM_ENG_R }" readOnly="${form_DEPT_NM_ENG_RO }" disabled="${form_DEPT_NM_ENG_D}" visible="${form_DEPT_NM_ENG_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="DEPT_CHIEF_NM" title="${form_DEPT_CHIEF_NM_N}"></e:label>
                <e:field>
					<e:inputText id="DEPT_CHIEF_NM" name="DEPT_CHIEF_NM" style="${imeMode}" width="100%" maxLength="${form_DEPT_CHIEF_NM_M }" required="${form_DEPT_CHIEF_NM_R }" readOnly="${form_DEPT_CHIEF_NM_RO }" disabled="${form_DEPT_CHIEF_NM_D}" visible="${form_DEPT_CHIEF_NM_V}" ></e:inputText>
                </e:field>



					<e:label for="PARENT_DEPT_CD" title="${form_PARENT_DEPT_CD_N}"/>
					<e:field>
					<e:search id="PARENT_DEPT_CD" name="PARENT_DEPT_CD" style='ime-mode:inactive' value="" width="100%" maxLength="${form_PARENT_DEPT_CD_M}" onIconClick="doSearchParent" disabled="true" readOnly="true" required="${form_PARENT_DEPT_CD_R}" />
					</e:field>



	        </e:row>
	        <e:row>
                <e:label for="ADDR" title="${form_ADDR_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="ADDR" name="ADDR" style="${imeMode}" width="100%" maxLength="${form_ADDR_M }" required="${form_ADDR_R }" readOnly="${form_ADDR_RO }" disabled="${form_ADDR_D}" visible="${form_ADDR_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="ADDR_ENG" title="${form_ADDR_ENG_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="ADDR_ENG" name="ADDR_ENG" style='ime-mode:inactive' width="100%" maxLength="${form_ADDR_ENG_M }" required="${form_ADDR_ENG_R }" readOnly="${form_ADDR_ENG_RO }" disabled="${form_ADDR_ENG_D}" visible="${form_ADDR_ENG_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="TEL_NUM" title="${form_TEL_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="TEL_NUM" name="TEL_NUM" width="100%" maxLength="${form_TEL_NUM_M }" required="${form_TEL_NUM_R }" readOnly="${form_TEL_NUM_RO }" disabled="${form_TEL_NUM_D}" visible="${form_TEL_NUM_V}" ></e:inputText>
                </e:field>
                <e:label for="FAX_NUM" title="${form_FAX_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="FAX_NUM" name="FAX_NUM" width="100%" maxLength="${form_FAX_NUM_M }" required="${form_FAX_NUM_R }" readOnly="${form_FAX_NUM_RO }" disabled="${form_FAX_NUM_D}" visible="${form_FAX_NUM_V}" ></e:inputText>
                </e:field>
	        </e:row>
 	        <e:row>
                <e:label for="REG_DATE" title="${form_REG_DATE_N}"></e:label>
                <e:field>
                	<e:inputDate id="REG_DATE" name="REG_DATE" value='${REG_DATE}'  width='${inputDateWidth }' required='${form_REG_DATE_R }' readOnly='${form_REG_DATE_RO }' disabled='${form_REG_DATE_D }' visible='${form_REG_DATE_V }' datePicker='false'/>
                </e:field>
                <e:label for="USER_NM" title="${form_REG_USER_NM_N}"></e:label>
                <e:field>
					<e:inputText id="USER_NM" name="USER_NM" style="${imeMode}" width="100%" maxLength="${form_REG_USER_NM_M }" required="${form_REG_USER_NM_R }" readOnly="${form_REG_USER_NM_RO }" disabled="${form_REG_USER_NM_D}" visible="${form_REG_USER_NM_V}" ></e:inputText>
                </e:field>
	        </e:row>
        </e:searchPanel>

		<e:inputHidden id="GATE_CD"        name="GATE_CD"/>
		<e:inputHidden id="BUYER_CD_ORI"   name="BUYER_CD_ORI"/>
		<e:inputHidden id="DEPT_CD_ORI"    name="DEPT_CD_ORI"/>
		<e:inputHidden id="INSERT_FLAG"    name="INSERT_FLAG"/>

		</e:panel>

    </e:window>
</e:ui>
