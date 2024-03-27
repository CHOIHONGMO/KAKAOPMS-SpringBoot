<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var grid2;
        var baseUrl = "/evermp/BOD1/BOD104/";

        function init() {
			
        	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
        	if('${param.detailView}' == 'true') {
        		$('#upload-button-ATTACH_FILE_NO').css('display','none');
        	}
        	
            grid = EVF.C("grid");
            grid2 = EVF.C("grid2");

            grid.setProperty('shrinkToFit', true);
            grid2.setProperty('shrinkToFit', true);

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
            });

            grid.showCheckBar(false);
            grid2.showCheckBar(false);

            var CPO_QTY = "${DATA.CPO_QTY}".split(".");
            EVF.V("CPO_QTY", CPO_QTY[0] + " ${DATA.UNIT_CD}");

            var PROGRESS_CD = "${DATA.PROGRESS_CD}";
            if(PROGRESS_CD === "10" || PROGRESS_CD === "20") {
                $("#order_f").hide();
                $("#order_n").show();
                $("#delivery_generation_f").hide();
                $("#delivery_generation_n").show();
                $("#delivery_completion_f").hide();
                $("#delivery_completion_n").show();
                $("#inbound_f").hide();
                $("#inbound_n").show();
            } else if(PROGRESS_CD === "30"||PROGRESS_CD === "36"||PROGRESS_CD === "38") {
                $("#order_f").show();
                $("#order_n").hide();
                $("#delivery_generation_f").hide();
                $("#delivery_generation_n").show();
                $("#delivery_completion_f").hide();
                $("#delivery_completion_n").show();
                $("#inbound_f").hide();
                $("#inbound_n").show();
            } else if(PROGRESS_CD === "40") {
                $("#order_f").show();
                $("#order_n").hide();
                $("#delivery_generation_f").show();
                $("#delivery_generation_n").hide();
                $("#delivery_completion_f").hide();
                $("#delivery_completion_n").show();
                $("#inbound_f").hide();
                $("#inbound_n").show();
            } else if(PROGRESS_CD === "50" || PROGRESS_CD === "65") {
                $("#order_f").show();
                $("#order_n").hide();
                $("#delivery_generation_f").show();
                $("#delivery_generation_n").hide();
                $("#delivery_completion_f").show();
                $("#delivery_completion_n").hide();
                $("#inbound_f").hide();
                $("#inbound_n").show();
            } else if(PROGRESS_CD === "60" || PROGRESS_CD === "70") {
                $("#order_f").show();
                $("#order_n").hide();
                $("#delivery_generation_f").show();
                $("#delivery_generation_n").hide();
                $("#delivery_completion_f").show();
                $("#delivery_completion_n").hide();
                $("#inbound_f").show();
                $("#inbound_n").hide();
            }
            $("#process_arrow_01").show();
            $("#process_arrow_02").show();
            $("#process_arrow_03").show();

            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid, grid2]);
            store.load(baseUrl + "bod1041_doSearch", function () {
                if(grid.getRowCount() == 0) {
                } else {
				}
            });
        }

        function onClickUserInfo(USER_TYPE, USER_ID) {
            var param = {
                callbackFunction: "",
                USER_ID: USER_ID,
                detailView : true
            };
            everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
		}

		function onClickVendorInfo(VENDOR_CD) {
			return;
            var param = {
                VENDOR_CD: VENDOR_CD,
                detailView: true,
                popupFlag: true
            };
            everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
		}

    </script>

    <e:window id="BOD1_041" onReady="init" initData="${initData}" title="${fullScreenName}">
		<e:panel id="panel" height="fit" width="30%">
			<e:title title="${BOD1_041_CAPTION01 }" depth="1"/>
		</e:panel>
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field colSpan="3">
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${DATA.ITEM_DESC}" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<e:label for="ITEM_STATUS" title="${form_ITEM_STATUS_N}"/>
				<e:field>
					<e:select id="ITEM_STATUS" name="ITEM_STATUS" value="${DATA.ITEM_STATUS}" options="${itemStatusOptions}" width="${form_ITEM_STATUS_W}" disabled="${form_ITEM_STATUS_D}" readOnly="${form_ITEM_STATUS_RO}" required="${form_ITEM_STATUS_R}" placeHolder="" />
				</e:field>
			</e:row>

            <e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="${DATA.ITEM_CD}" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="CUST_ITEM_CD" title="${form_CUST_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="CUST_ITEM_CD" name="CUST_ITEM_CD" value="${DATA.CUST_ITEM_CD}" width="${form_CUST_ITEM_CD_W}" maxLength="${form_CUST_ITEM_CD_M}" disabled="${form_CUST_ITEM_CD_D}" readOnly="${form_CUST_ITEM_CD_RO}" required="${form_CUST_ITEM_CD_R}" />
				</e:field>
				<e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
				<e:field>
					<e:inputText id="MAKER_NM" name="MAKER_NM" value="${DATA.MAKER_NM}" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
				</e:field>
            </e:row>

            <e:row>
				<e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
				<e:field colSpan="3">
					<e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="${DATA.ITEM_SPEC}" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
				</e:field>
				<e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}" />
				<e:field>
					<e:inputText id="MAKER_PART_NO" name="MAKER_PART_NO" value="${DATA.MAKER_PART_NO}" width="${form_MAKER_PART_NO_W}" maxLength="${form_MAKER_PART_NO_M}" disabled="${form_MAKER_PART_NO_D}" readOnly="${form_MAKER_PART_NO_RO}" required="${form_MAKER_PART_NO_R}" />
				</e:field>
            </e:row>

			<e:row>
				<e:label for="BRAND_NM" title="${form_BRAND_NM_N}" />
				<e:field>
					<e:inputText id="BRAND_NM" name="BRAND_NM" value="${DATA.BRAND_NM}" width="${form_BRAND_NM_W}" maxLength="${form_BRAND_NM_M}" disabled="${form_BRAND_NM_D}" readOnly="${form_BRAND_NM_RO}" required="${form_BRAND_NM_R}" />
				</e:field>
				<e:label for="ORIGIN_NM" title="${form_ORIGIN_NM_N}" />
				<e:field>
					<e:inputText id="ORIGIN_NM" name="ORIGIN_NM" value="${DATA.ORIGIN_NM}" width="${form_ORIGIN_NM_W}" maxLength="${form_ORIGIN_NM_M}" disabled="${form_ORIGIN_NM_D}" readOnly="${form_ORIGIN_NM_RO}" required="${form_ORIGIN_NM_R}" />
				</e:field>
				<e:label for="SG_CTRL_USER_NM" title="${form_SG_CTRL_USER_NM_N}" />
				<e:field>
					<e:inputHidden id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${DATA.SG_CTRL_USER_ID}"/>
					<e:text><a href="javascript:onClickUserInfo('C', '${DATA.SG_CTRL_USER_ID}');">${DATA.SG_CTRL_USER_NM}</a></e:text>
				</e:field>
			</e:row>
        </e:searchPanel>

		<e:panel id="panel2" height="fit" width="30%">
			<e:title title="${BOD1_041_CAPTION02 }" depth="1"/>
		</e:panel>
		<e:searchPanel id="form2" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
					<e:inputHidden id="CPO_NO" name="CPO_NO" value="${DATA.CPO_NO}"/>
					<e:inputHidden id="CPO_SEQ" name="CPO_SEQ" value="${DATA.CPO_SEQ}"/>
					<e:text>${DATA.CPO_NO}  / ${DATA.PROGRESS_NM}</e:text>
				</e:field>
				<e:label for="DEPT_NM" title="${form_DEPT_NM_N}" />
				<e:field>
					<e:inputText id="DEPT_NM" name="DEPT_NM" value="${DATA.DEPT_NM}" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
				</e:field>
				<e:label for="CPO_USER_NM" title="${form_CPO_USER_NM_N}" />
				<e:field>
					<e:inputHidden id="CPO_USER_ID" name="CPO_USER_ID" value="${DATA.CPO_USER_ID}"/>
					<e:text><a href="javascript:onClickUserInfo('B', '${DATA.CPO_USER_ID}');">${DATA.CPO_USER_NM}</a></e:text>
				</e:field>
			</e:row>

			<e:row>
				<e:label for="BUDGET_FLAG" title="${form_BUDGET_FLAG_N}" />
				<e:field>
					<e:inputText id="BUDGET_FLAG" name="BUDGET_FLAG" value="${DATA.BUDGET_FLAG}" width="${form_BUDGET_FLAG_W}" maxLength="${form_BUDGET_FLAG_M}" disabled="${form_BUDGET_FLAG_D}" readOnly="${form_BUDGET_FLAG_RO}" required="${form_BUDGET_FLAG_R}" />
				</e:field>
				<e:label for="BD_DEPT_NM" title="${form_BD_DEPT_NM_N}" />
				<e:field>
					<e:inputText id="BD_DEPT_NM" name="BD_DEPT_NM" value="${DATA.BD_DEPT_NM}" width="${form_BD_DEPT_NM_W}" maxLength="${form_BD_DEPT_NM_M}" disabled="${form_BD_DEPT_NM_D}" readOnly="${form_BD_DEPT_NM_RO}" required="${form_BD_DEPT_NM_R}" />
				</e:field>
				<e:label for="APPROVE_FLAG" title="${form_APPROVE_FLAG_N}" />
				<e:field>
					<e:inputText id="APPROVE_FLAG" name="APPROVE_FLAG" value="${DATA.APPROVE_FLAG}" width="${form_APPROVE_FLAG_W}" maxLength="${form_APPROVE_FLAG_M}" disabled="${form_APPROVE_FLAG_D}" readOnly="${form_APPROVE_FLAG_RO}" required="${form_APPROVE_FLAG_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="ACCOUNT_CD" title="${form_ACCOUNT_CD_N}" />
				<e:field>
					<e:inputText id="ACCOUNT_CD" name="ACCOUNT_CD" value="${DATA.ACCOUNT_CD}" width="${form_ACCOUNT_CD_W}" maxLength="${form_ACCOUNT_CD_M}" disabled="${form_ACCOUNT_CD_D}" readOnly="${form_ACCOUNT_CD_RO}" required="${form_ACCOUNT_CD_R}" />
				</e:field>
				<e:label for="ACCOUNT_NM" title="${form_ACCOUNT_NM_N}" />
				<e:field>
					<e:inputText id="ACCOUNT_NM" name="ACCOUNT_NM" value="${DATA.ACCOUNT_NM}" width="${form_ACCOUNT_NM_W}" maxLength="${form_ACCOUNT_NM_M}" disabled="${form_ACCOUNT_NM_D}" readOnly="${form_ACCOUNT_NM_RO}" required="${form_ACCOUNT_NM_R}" />
				</e:field>
				<e:label for="PRIOR_GR_FLAG" title="${form_PRIOR_GR_FLAG_N}" />
				<e:field>
					<e:inputText id="PRIOR_GR_FLAG" name="PRIOR_GR_FLAG" value="${DATA.PRIOR_GR_FLAG}" width="${form_PRIOR_GR_FLAG_W}" maxLength="${form_PRIOR_GR_FLAG_M}" disabled="${form_PRIOR_GR_FLAG_D}" readOnly="${form_PRIOR_GR_FLAG_RO}" required="${form_PRIOR_GR_FLAG_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="COST_CENTER_CD" title="${form_COST_CENTER_CD_N}" />
				<e:field>
					<e:inputText id="COST_CENTER_CD" name="COST_CENTER_CD" value="${DATA.COST_CENTER_CD}" width="${form_COST_CENTER_CD_W}" maxLength="${form_COST_CENTER_CD_M}" disabled="${form_COST_CENTER_CD_D}" readOnly="${form_COST_CENTER_CD_RO}" required="${form_COST_CENTER_CD_R}" />
				</e:field>
				<e:label for="COST_CENTER_NM_KOR" title="${form_COST_CENTER_NM_KOR_N}" />
				<e:field>
					<e:inputText id="COST_CENTER_NM_KOR" name="COST_CENTER_NM_KOR" value="${DATA.COST_CENTER_NM_KOR}" width="${form_COST_CENTER_NM_KOR_W}" maxLength="${form_COST_CENTER_NM_KOR_M}" disabled="${form_COST_CENTER_NM_KOR_D}" readOnly="${form_COST_CENTER_NM_KOR_RO}" required="${form_COST_CENTER_NM_KOR_R}" />
				</e:field>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}" />
				<e:field>
					<e:inputText id="PLANT_CD" name="PLANT_CD" value="${DATA.PLANT_CD}" width="${form_PLANT_CD_W}" maxLength="${form_PLANT_CD_M}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="REF_MNG_NO" title="${form_REF_MNG_NO_N}" />
				<e:field>
					<e:inputText id="REF_MNG_NO" name="REF_MNG_NO" value="${DATA.REF_MNG_NO}" width="${form_REF_MNG_NO_W}" maxLength="${form_REF_MNG_NO_M}" disabled="${form_REF_MNG_NO_D}" readOnly="${form_REF_MNG_NO_RO}" required="${form_REF_MNG_NO_R}" />
				</e:field>
				<e:label for="CPO_QTY" title="${form_CPO_QTY_N}"/>
				<e:field>
					<e:text id="CPO_QTY" style="float:right;"></e:text>
					<%--<e:inputNumber id="CPO_QTY" name="CPO_QTY" value="${DATA.CPO_QTY}" width="${form_CPO_QTY_W}" maxValue="${form_CPO_QTY_M}" decimalPlace="${form_CPO_QTY_NF}" disabled="${form_CPO_QTY_D}" readOnly="${form_CPO_QTY_RO}" required="${form_CPO_QTY_R}" />--%>
				</e:field>
				<e:label for="CPO_UNIT_PRICE" title="${form_CPO_UNIT_PRICE_N}"/>
				<e:field>
					<e:inputNumber id="CPO_UNIT_PRICE" name="CPO_UNIT_PRICE" value="${DATA.CPO_UNIT_PRICE}" width="${form_CPO_UNIT_PRICE_W}" maxValue="${form_CPO_UNIT_PRICE_M}" decimalPlace="${form_CPO_UNIT_PRICE_NF}" disabled="${form_CPO_UNIT_PRICE_D}" readOnly="${form_CPO_UNIT_PRICE_RO}" required="${form_CPO_UNIT_PRICE_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="CPO_DATE" title="${form_CPO_DATE_N}" />
				<e:field>
					<e:inputText id="CPO_DATE" name="CPO_DATE" value="${DATA.CPO_DATE}" width="${form_CPO_DATE_W}" maxLength="${form_CPO_DATE_M}" disabled="${form_CPO_DATE_D}" readOnly="${form_CPO_DATE_RO}" required="${form_CPO_DATE_R}" />
				</e:field>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
				<e:field>
					<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${DATA.VENDOR_CD}"/>
			<c:choose>
				<c:when test="${ses.userType == 'C'}">
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${DATA.VENDOR_NM}" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
<%--					<e:text><a href="javascript:onClickVendorInfo('${DATA.VENDOR_CD}');">${DATA.VENDOR_NM}</a></e:text>--%>
				</c:when>
				<c:otherwise>
					<e:text>${ses.manageComNm}</e:text>
				</c:otherwise>
			</c:choose>
				</e:field>
				<e:label for="CPO_ITEM_AMT" title="${form_CPO_ITEM_AMT_N}"/>
				<e:field>
					<e:inputNumber id="CPO_ITEM_AMT" name="CPO_ITEM_AMT" value="${DATA.CPO_ITEM_AMT}" width="${form_CPO_ITEM_AMT_W}" maxValue="${form_CPO_ITEM_AMT_M}" decimalPlace="${form_CPO_ITEM_AMT_NF}" disabled="${form_CPO_ITEM_AMT_D}" readOnly="${form_CPO_ITEM_AMT_RO}" required="${form_CPO_ITEM_AMT_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="LEAD_TIME_DATE" title="${form_LEAD_TIME_DATE_N}" />
				<e:field>
					<e:inputText id="LEAD_TIME_DATE" name="LEAD_TIME_DATE" value="${DATA.LEAD_TIME_DATE}" width="${form_LEAD_TIME_DATE_W}" maxLength="${form_LEAD_TIME_DATE_M}" disabled="${form_LEAD_TIME_DATE_D}" readOnly="${form_LEAD_TIME_DATE_RO}" required="${form_LEAD_TIME_DATE_R}" />
				</e:field>
				<e:label for="RECIPIENT_NM" title="${form_RECIPIENT_NM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_NM" name="RECIPIENT_NM" value="${DATA.RECIPIENT_NM}" width="${form_RECIPIENT_NM_W}" maxLength="${form_RECIPIENT_NM_M}" disabled="${form_RECIPIENT_NM_D}" readOnly="${form_RECIPIENT_NM_RO}" required="${form_RECIPIENT_NM_R}" />
				</e:field>
				<e:label for="CSDM_SEQ" title="${form_CSDM_SEQ_N}" />
				<e:field>
					<e:inputText id="CSDM_SEQ" name="CSDM_SEQ" value="${DATA.CSDM_SEQ} / ${DATA.DELY_NM} " width="${form_CSDM_SEQ_W}" maxLength="${form_CSDM_SEQ_M}" disabled="${form_CSDM_SEQ_D}" readOnly="${form_CSDM_SEQ_RO}" required="${form_CSDM_SEQ_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}" />
				<e:field>
					<e:inputText id="HOPE_DUE_DATE" name="HOPE_DUE_DATE" value="${DATA.HOPE_DUE_DATE}" width="${form_HOPE_DUE_DATE_W}" maxLength="${form_HOPE_DUE_DATE_M}" disabled="${form_HOPE_DUE_DATE_D}" readOnly="${form_HOPE_DUE_DATE_RO}" required="${form_HOPE_DUE_DATE_R}" />
				</e:field>
				<e:label for="RECIPIENT_TEL_NUM" title="${form_RECIPIENT_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM" value="${DATA.RECIPIENT_TEL_NUM}" width="${form_RECIPIENT_TEL_NUM_W}" maxLength="${form_RECIPIENT_TEL_NUM_M}" disabled="${form_RECIPIENT_TEL_NUM_D}" readOnly="${form_RECIPIENT_TEL_NUM_RO}" required="${form_RECIPIENT_TEL_NUM_R}" />
				</e:field>
				<e:label for="RECIPIENT_CELL_NUM" title="${form_RECIPIENT_CELL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" value="${DATA.RECIPIENT_CELL_NUM}" width="${form_RECIPIENT_CELL_NUM_W}" maxLength="${form_RECIPIENT_CELL_NUM_M}" disabled="${form_RECIPIENT_CELL_NUM_D}" readOnly="${form_RECIPIENT_CELL_NUM_RO}" required="${form_RECIPIENT_CELL_NUM_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="RECIPIENT_DEPT_NM" title="${form_RECIPIENT_DEPT_NM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_DEPT_NM" name="RECIPIENT_DEPT_NM" value="${DATA.RECIPIENT_DEPT_NM}" width="${form_RECIPIENT_DEPT_NM_W}" maxLength="${form_RECIPIENT_DEPT_NM_M}" disabled="${form_RECIPIENT_DEPT_NM_D}" readOnly="${form_RECIPIENT_DEPT_NM_RO}" required="${form_RECIPIENT_DEPT_NM_R}" />
				</e:field>
				<e:label for="RECIPIENT_FAX_NUM" title="${form_RECIPIENT_FAX_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_FAX_NUM" name="RECIPIENT_FAX_NUM" value="${DATA.RECIPIENT_FAX_NUM}" width="${form_RECIPIENT_FAX_NUM_W}" maxLength="${form_RECIPIENT_FAX_NUM_M}" disabled="${form_RECIPIENT_FAX_NUM_D}" readOnly="${form_RECIPIENT_FAX_NUM_RO}" required="${form_RECIPIENT_FAX_NUM_R}" />
				</e:field>
				<e:label for="RECIPIENT_EMAIL" title="${form_RECIPIENT_EMAIL_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_EMAIL" name="RECIPIENT_EMAIL" value="${DATA.RECIPIENT_EMAIL}" width="${form_RECIPIENT_EMAIL_W}" maxLength="${form_RECIPIENT_EMAIL_M}" disabled="${form_RECIPIENT_EMAIL_D}" readOnly="${form_RECIPIENT_EMAIL_RO}" required="${form_RECIPIENT_EMAIL_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="DELY_ZIP_CD" title="${form_DELY_ZIP_CD_N}" />
				<e:field>
					<e:inputText id="DELY_ZIP_CD" name="DELY_ZIP_CD" value="${DATA.DELY_ZIP_CD}" width="${form_DELY_ZIP_CD_W}" maxLength="${form_DELY_ZIP_CD_M}" disabled="${form_DELY_ZIP_CD_D}" readOnly="${form_DELY_ZIP_CD_RO}" required="${form_DELY_ZIP_CD_R}" />
				</e:field>
				<e:label for="DELY_ADDR_1" title="${form_DELY_ADDR_1_N}" />
				<e:field colSpan="3">
					<e:inputText id="DELY_ADDR_1" name="DELY_ADDR_1" value="${DATA.DELY_ADDR_1}, ${DATA.DELY_ADDR_2}" width="${form_DELY_ADDR_1_W}" maxLength="${form_DELY_ADDR_1_M}" disabled="${form_DELY_ADDR_1_D}" readOnly="${form_DELY_ADDR_1_RO}" required="${form_DELY_ADDR_1_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="REQ_TEXT" title="${form_REQ_TEXT_N}"/>
				<e:field colSpan="5">
					<e:textArea id="REQ_TEXT" name="REQ_TEXT" value="${DATA.REQ_TEXT}" height="100px" width="${form_REQ_TEXT_W}" maxLength="${form_REQ_TEXT_M}" disabled="${form_REQ_TEXT_D}" readOnly="${form_REQ_TEXT_RO}" required="${form_REQ_TEXT_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="ATTACH_FILE_NO" title="${form_ATTACH_FILE_NO_N}" />
				<e:field colSpan="5">
					<e:fileManager id="ATTACH_FILE_NO" name="ATTACH_FILE_NO" readOnly="${form_ATTACH_FILE_NO_RO}"  fileId="${DATA.ATTACH_FILE_NO}" downloadable="true" width="100%" bizType="MP" height="90px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:panel id="panel3" height="fit" width="30%">
			<e:title title="${BOD1_041_CAPTION03 }" depth="1"/>
		</e:panel>


		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="100px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

		<e:panel id="panel4" height="fit" width="30%">
			<e:title title="${BOD1_041_CAPTION04 }" depth="1"/>
		</e:panel>

		<e:gridPanel gridType="${_gridType}" id="grid2" name="grid2" width="100%" height="100px" readOnly="${param.detailView}" columnDef="${gridInfos.grid2.gridColData}" />
    </e:window>
</e:ui>