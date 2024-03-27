<%@page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

		var grid;	    var grid1;        var gridCONT;
		var addParam = [];
		var baseUrl = "/eversrm/master/vendor/";

		function init() {

            grid = EVF.C("grid");
            grid1 = EVF.C("grid1");
            gridCONT = EVF.C("gridCONT");

            grid1.showCheckBar(false);
            gridCONT.showCheckBar(false);

            grid1.setProperty('shrinkToFit', true);
            gridCONT.setProperty('shrinkToFit', true);
            grid.setProperty('panelVisible', ${panelVisible});
            grid.setProperty('singleSelect', true);
            grid1.setColIconify("SCRE_EV_TPL_NUM", "SCRE_EV_TPL_NUM", "detail", false);


			grid.cellClickEvent(function(rowid, colId, value) {
				//if (colId == "VENDOR_CD") {
				  if (colId == "VENDOR_NM") {
					grid.checkAll(false);
	        		grid.checkRow(rowid,true);
                    doSearchButton(rowid);
//                    var store = new EVF.Store();
//                    if(!store.validate()) return;
//                    store.setGrid([grid1]);
//                    store.setParameter("VENDOR_CD", grid.getCellValue(rowid, "VENDOR_CD"));
//                    store.load('/siis/M03/m03003_doSearchSGVN', function() {
//                        store.setGrid([gridCONT]);
//                        store.setParameter("VENDOR_CD", grid.getCellValue(rowid, "VENDOR_CD"));
//                        store.load('/siis/M03/m03003_doSearchECCT', function() {
//
//                        });
//                    });
				}
			});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

		}

		function doSearch() {

			if(!everDate.checkTermDate('START_DATE','END_DATE','${msg.M0073}')) {
				return;
			}

			var store = new EVF.Store();
			if(!store.validate()) return;
			store.setGrid([grid]);
			store.load(baseUrl + 'BBV_050/doSearch', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
                    doClear();
				}else{
                    doSearchButton(0);
                }
			});
		}

		function doSearchButton(rowid) {

            var store = new EVF.Store();
            if(!store.validate()) return;
            store.setGrid([grid1]);
            store.setParameter("VENDOR_CD", grid.getCellValue(rowid, "VENDOR_CD"));
            store.load('/siis/M03/m03003_doSearchSGVN', function() {
                store.setGrid([gridCONT]);
                store.setParameter("VENDOR_CD", grid.getCellValue(rowid, "VENDOR_CD"));
                store.load('/siis/M03/m03003_doSearchECCT', function() {

                });
            });
        }

		//수정
		function doUpdate() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var vendorCd = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                vendorCd = grid.getCellValue(rowIds[i], 'VENDOR_CD');
            }
            var param = {
                'VENDOR_CD': vendorCd,
                'detailView': false,
                'popupFlag': true
            };

            everPopup.openPopupByScreenId("M03_003", 1100, 750, param);

		}

        function doInsert() {
            var param = {
                'VENDOR_CD': "",
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("M03_003", 1100, 750, param);
        }

        function doClear(){
            grid1.delAllRow();
            gridCONT.delAllRow();
        }



        function doSendConf() {
            var	selectFormNnum = this.getData();

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            var store = new EVF.Store();

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {

                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD')!="E"){
                    return alert('${BBV_050_0008}');
                }

                if(grid.getCellValue(rowIds[i], 'EVVM_PROGRESS')>0){
                    return alert('${BBV_050_0009}');
                }

                EVF.V("VENDOR_PIC_USER_NM",selectFormNnum);
                EVF.V("VENDOR_CD",grid.getCellValue(rowIds[i], 'VENDOR_CD'));
                EVF.V("VENDOR_NM",grid.getCellValue(rowIds[i], 'VENDOR_NM'));
                EVF.V("VENDOR_PROGRESS_CD",grid.getCellValue(rowIds[i], 'PROGRESS_CD'));
            }

            EVF.V("SELECT_FORM_NUM",'');
            var contractFormJson = store._getFormDataAsJson();
            EVF.V("contractForm",contractFormJson.replace(/"/gi, '\''));
            if(selectFormNnum=='FORM2017080100001'){
                EVF.C("mainForm").setValue("[{'FORM_GUBUN':'TBA','FORM_NM':'${BBV_050_CAPTION3}','GATE_CD':'100','FORM_NUM':'FORM2017080100001','FORM_TYPE':'100','DEPT_NM':''}]");
                EVF.V("CONT_DESC","${BBV_050_CAPTION4}["+EVF.V("VENDOR_NM")+"]");
            }else if(selectFormNnum=='FORM2017080300004'){
                EVF.C("mainForm").setValue("[{'FORM_GUBUN':'TBA','FORM_NM':'${BBV_050_CAPTION5}','GATE_CD':'100','FORM_NUM':'FORM2017080300004','FORM_TYPE':'100','DEPT_NM':''}]");
                EVF.V("CONT_DESC","${BBV_050_CAPTION6}["+EVF.V("VENDOR_NM")+"]");
            }else{
                EVF.C("mainForm").setValue("[{}]");
            }

            EVF.V("additionalForm",[]);
            EVF.V("baseDataType","contract");
            EVF.V("contractEditable",true);
            EVF.V("detailView",false);



            var param = {
                'GATE_CD'  : '${ses.gateCd}'
                ,'EXEC_NUM' : EVF.V("EXEC_NUM")
                ,'EXEC_CNT' : ""
                //,'RFXTYPE' :rfxType
                ,'SELECT_FORM_NUM': EVF.V("SELECT_FORM_NUM")
                ,'contractForm': EVF.V("contractForm")
                ,'mainForm': EVF.V("mainForm")
                ,'additionalForm': EVF.V("additionalForm")
                ,'baseDataType':EVF.V("baseDataType")
                ,'contractEditable':EVF.V("contractEditable")
                ,'detailView': EVF.V("detailView")
                ,'contReqFlag': EVF.V("contReqFlag")
                ,'VENDOR_PIC_USER_NM': EVF.V("VENDOR_PIC_USER_NM")
                ,'CONT_WT_NUM': EVF.V("CONT_WT_NUM")
                ,'openerCallBackFunction': ""
                ,'CONT_PLACE': ""
                ,'CONT_DESC': EVF.V("CONT_DESC")
                ,'CONT_DATE': EVF.V("CONT_DATE")
                ,'CONT_USER_ID':EVF.V("CONT_USER_ID")
                ,'CONT_AMT': ""
                ,'VENDOR_CD': EVF.V("VENDOR_CD")
                ,'VENDOR_NM' : EVF.V("VENDOR_NM")
                ,'VENDOR_PROGRESS_CD' : EVF.V("VENDOR_PROGRESS_CD")
                ,'st_CONT_REQ_CD': "L"
                ,'CONT_REQ_CD': "01"
                ,'MANUAL_CONT_FLAG': "0"
                ,'PLANT_CD': ""
                ,'BUYER_CD': '${ses.companyCd}'
                ,'CONT_REQ_RMK':  ""
                ,'VENDOR_CONF_Y' :"Y"
                ,'DATATYPEFLAG': EVF.V("DATATYPEFLAG")
            };

            //console.log(param);
            var url ='/eversrm/eContract/eContractMgt/BECM_030/view.so?';
            //window.location.href = url + $.param(param);
            everPopup.openWindowPopup(url, 1200, 800, param);


            EVF.V("contractForm","");
            EVF.V("mainForm","");
        }


		function searchVendorCd() {
			var param = {
				callBackFunction : "selectVendorCd"
			};
			everPopup.openCommonPopup(param, 'SP0063');
		}

		function selectVendorCd(dataJsonArray) {
			EVF.C("S_VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
			EVF.C("S_VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
		}

        </script>
        <e:window id="BBV_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
            <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
                <e:row>

                    <e:label for="S_VENDOR_CD" title="${form_S_VENDOR_CD_N}"/>
                    <e:field>
                        <e:search id="S_VENDOR_CD" style="ime-mode:inactive" name="S_VENDOR_CD" value="" width="40%" maxLength="${form_S_VENDOR_CD_M}" onIconClick="${form_S_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_S_VENDOR_CD_D}" readOnly="${form_S_VENDOR_CD_RO}" required="${form_S_VENDOR_CD_R}" />
                        <e:inputText id="S_VENDOR_NM" style="${imeMode}" name="S_VENDOR_NM" value="" width="60%" maxLength="${form_S_VENDOR_NM_M}" disabled="${form_S_VENDOR_NM_D}" readOnly="${form_S_VENDOR_NM_RO}" required="${form_S_VENDOR_NM_R}" />
                        <e:inputHidden id="approvalFormData" name="approvalFormData"/>
                        <e:inputHidden id="approvalGridData" name="approvalGridData"/>
                        <e:inputHidden id="APPROVAL_FLAG" name="APPROVAL_FLAG"/>
                    </e:field>

                    <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                    <e:field>
                        <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions }" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                    </e:field>
                    <e:label for="CONT_TYPE" title="${form_CONT_TYPE_N}"/>
                    <e:field>
                        <e:select id="CONT_TYPE" name="CONT_TYPE" value="${form.CONT_TYPE}" options="${contTypeOptions }" width="${form_CONT_TYPE_W}" disabled="${form_CONT_TYPE_D}" readOnly="${form_CONT_TYPE_RO}" required="${form_CONT_TYPE_R}" placeHolder="" />
                    </e:field>

                </e:row>
                <e:row>
                    <e:label for="IRS_NUM" title="${form_IRS_NUM_N}"/>
                    <e:field>
                        <e:inputText id="IRS_NUM" name="IRS_NUM" value="${form.IRS_NUM}" width="${form_IRS_NUM_W}"  maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" style='ime-mode:inactive'/>
                    </e:field>
                    <e:label for="PAY_CD" title="${form_PAY_CD_N}"/>
                    <e:field>
                        <e:inputText id="PAY_CD" name="PAY_CD" value="${form.PAY_CD}" width="${form_PAY_CD_W}" maxLength="${form_PAY_CD_M}" disabled="${form_PAY_CD_D}" readOnly="${form_PAY_CD_RO}" required="${form_PAY_CD_R}" style='ime-mode:inactive'/>
                    </e:field>
                    <e:label for="START_DATE" title="${form_START_DATE_N}"/>
                    <e:field>
                        <e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${form.START_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                        <e:text>~</e:text>
                        <e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${form.END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                    </e:field>
                </e:row>


                <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>
                <e:inputHidden id="GATE_CD" name="GATE_CD" value="${ses.gateCd}" />
                <e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="" />
                <e:inputHidden id="SELECT_FORM_NUM" name="SELECT_FORM_NUM" value="" />
                <e:inputHidden id="contractForm" name="contractForm"  value=""/>
                <e:inputHidden id="mainForm" name="mainForm"  value=""/>
                <e:inputHidden id="additionalForm" name="additionalForm"/>
                <e:inputHidden id="baseDataType" name="baseDataType" />
                <e:inputHidden id="contractEditable" name="contractEditable"/>
                <e:inputHidden id="detailView" name="detailView" />
                <e:inputHidden id="contReqFlag" name="contReqFlag" value="01"/>
                <e:inputHidden id="VENDOR_PIC_USER_NM" name="VENDOR_PIC_USER_NM" value="" />
                <e:inputHidden id="CONT_WT_NUM" name="CONT_WT_NUM" value="" />
                <e:inputHidden id="openerCallBackFunction" name="openerCallBackFunction" value="" />
                <e:inputHidden id="CONT_PLACE" name="CONT_PLACE" value="" />
                <e:inputHidden id="CONT_DESC" style="${imeMode}" name="CONT_DESC" value="" />
                <e:inputHidden id="CONT_DATE" name="CONT_DATE" value="${toDate }"/>
                <%--
                <e:inputHidden id="CONT_START_DATE" name="CONT_START_DATE" value="" />
                <e:inputHidden id="CONT_END_DATE"  name="CONT_END_DATE" value=""  />
                --%>
                <e:inputHidden id="CONT_USER_ID" name="CONT_USER_ID" value="${ses.userId }" />
                <e:inputHidden id="CONT_AMT" name="CONT_AMT"  value="" />
                <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}"  />
                <e:inputHidden id="VENDOR_NM" name="VENDOR_NM" value="${param.VENDOR_NM}"  />
                <e:inputHidden id="VENDOR_PROGRESS_CD" name="VENDOR_PROGRESS_CD" value="${param.VENDOR_PROGRESS_CD}"  />
                <e:inputHidden id="st_CONT_REQ_CD" name="st_CONT_REQ_CD" value="L"  />
                <e:inputHidden id="CONT_REQ_CD" name="CONT_REQ_CD" value="01"  />
                <e:inputHidden id="MANUAL_CONT_FLAG" name="MANUAL_CONT_FLAG" value="0"/>
                <e:inputHidden id="PLANT_CD" name="PLANT_CD" onChange="getBuyerCd" value="" />
                <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${ses.companyCd}" />
                <e:inputHidden id="CONT_REQ_RMK"  name="CONT_REQ_RMK"  value=""/>
                <e:inputHidden id="DATATYPEFLAG"  name="DATATYPEFLAG"  value="manual"/>

            </e:searchPanel>

            <e:buttonBar id="buttonBar" align="right" width="100%">
				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
				<c:if test="${ses.ctrlCd != null && ses.ctrlCd != '' }">
					<e:button id="Insert" name="Insert" label="${Insert_N}" onClick="doInsert" disabled="${Insert_D}" visible="${Insert_V}"/>
					<e:button id="doUpdate" name="doUpdate" label="${doUpdate_N}" onClick="doUpdate" disabled="${doUpdate_D}" visible="${doUpdate_V}"/>
                    <e:button id="doSendConf" name="doSendConf" label="${doSendConf_N}" onClick="doSendConf" data="FORM2017080100001" disabled="${doSendConf_D}" visible="${doSendConf_V}"/>
                    <e:button id="doSendConf2" name="doSendConf2" label="${doSendConf2_N}" onClick="doSendConf" data="FORM2017080300004" disabled="${doSendConf2_D}" visible="${doSendConf2_V}"/>

					<%--<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>--%>
					<%--<e:button id="doDealClose" name="doDealClose" label="${doDealClose_N}" onClick="doDealClose" disabled="${doDealClose_D}" visible="${doDealClose_V}"/>--%>
					<%-- <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/> --%>
					<%--<e:button id="doSapSend" name="doSapSend" label="${doSapSend_N}" onClick="doSapSend" disabled="${doSapSend_D}" visible="${doSapSend_V}"/>--%>
				</c:if>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="250px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

		<e:panel id="leftPanel" height="100%" width="50%">
			<div class="e-component e-title-container" data-uuid="Title-541-391-560">
				<div class="e-title-bullet-h1"></div>
				<div class="e-title-text">${BBV_050_CAPTION1 }</div>
			</div>
			<e:gridPanel id="grid1" name="grid1" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}" />
		</e:panel>
		<e:panel id="nullPanel" height="100%" width="1%">&nbsp;</e:panel>
		<e:panel id="rightPanel" height="100%" width="49%">
			<div class="e-component e-title-container" data-uuid="Title-541-391-560">
				<div class="e-title-bullet-h1"></div>
				<div class="e-title-text">${BBV_050_CAPTION2 }</div>
			</div>
			<e:gridPanel id="gridCONT" name="gridCONT" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridCONT.gridColData}" />
		</e:panel>

	</e:window>
</e:ui>