<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		var baseUrl = "/evermp/buyer/bd";

		function init() {

// 			EVF.C('CTRL_NM').setReadOnly(true);
// 			EVF.C('PLANT_NM').setReadOnly(true);
// 			EVF.C('WH_NM').setReadOnly(true);

			var selected = '${param.selected}';
			var selObject = JSON.parse(selected);
			for(var i in Object.keys(selObject)){
				if($('#' + Object.keys(selObject)[i]).length === 0) continue;
				if(Object.values(selObject)[i] !== ''){
					EVF.V(Object.keys(selObject)[i], Object.values(selObject)[i]);
					if($('#' + Object.keys(selObject)[i] + '_FLAG').length !== 0){
						EVF.C(Object.keys(selObject)[i] + '_FLAG').setChecked(true);
					}
				}
			}

			$(':input').change(function(){
				if($('#' + $(this)[0].id + '_FLAG').length === 0) return;
				if(EVF.V($(this)[0].id) === ''){
					EVF.C($(this)[0].id + '_FLAG').setChecked(false);
				}else{
					EVF.C($(this)[0].id + '_FLAG').setChecked(true);
				}
			});


			/*납품장소 입력 후 input 박스의  x 표시 보이지 않도록 설정(x를 누르면 onChange 반영이 안됨)*/
			$('.e-input-clear-btn').css('display','none');

			$('#PR_BUYER_CD').change(function(){
				$('#CTRL_NM').val('');
				$('#CTRL_CD').val('');
// 				$('#CTRL_NM_FLAG').attr("checked", false);
			});

		}

		//전체선택 체크박스
		function doselectAll(){
			if(EVF.C('selectAll').isChecked(true)){
				$('input[type="checkBox"]').each(function(k, v) {
					var eachCheck = v.id;
					EVF.C(eachCheck).setChecked(true);
				});
			}else{
				$('input[type="checkBox"]').each(function(k, v) {
					var eachCheck = v.id;
					EVF.C(eachCheck).setChecked(false);
				});
			}
		}


		function doApply(){

// 			if(EVF.V('CTRL_NM_FLAG') === 'on' && EVF.V('PR_BUYER_CD_FLAG') !== 'on'){
// 				return EVF.alert('${BD0310P01_003}');
// 			}

// 			if(EVF.V('WH_NM_FLAG') === 'on' && EVF.V('PLANT_NM_FLAG') !== 'on'){
// 				return EVF.alert('${BD0310P01_004}');
// 			}

			var paramData = [];
			$(':input').each(function(i, v){
				var vid = v.id;
				if(vid.indexOf('_FLAG') !== -1 && EVF.V(vid) === 'on'){
					var enm = vid.substring(0, vid.indexOf('_FLAG'));
					var enmValue = EVF.V(enm);
					paramData.push([enm, enmValue]);
					if(enm.indexOf('_NM') !== -1){
						var ecd = enm.substring(0, enm.indexOf('_NM')) + '_CD';
						if($('#' + ecd).length !== 0){
							var ecdValue = EVF.V(ecd);
							paramData.push([ecd, ecdValue]);
						}
// 						if(ecd === 'PLANT_CD'){
// 							paramData.push(['LOC_BUYER_CD', EVF.V('LOC_BUYER_CD')]);
// 						}
					}
				}
			});

			opener.window['${param.callBackFunction}'](paramData);
			doClose();

		}

		function doClose(){
			window.close();
		}


		function selectCtrl(){
// 			if($('#PR_BUYER_CD').val()===''){
// 				return EVF.alert('${RQ0310P01_001}');
// 			}
			var param = {
				callBackFunction: "callback_setCTRL",
				BUYER_CD: EVF.V('PR_BUYER_CD')
			};
			everPopup.openCommonPopup(param, "SP0031");
		}

		function callback_setCTRL(data) {
// 			EVF.V("CTRL_CD", data.CODE);
// 			EVF.V("CTRL_NM", data.CODE_DESC);
// 			setAutoCheck(data.CODE_DESC, "CTRL_NM");

		}


		function selectPlant(){
			var param = {
				 CUST_CD : $('#PR_BUYER_CD').val()
				,callBackFunction : 'callback_setPlant'
			}
			everPopup.openCommonPopup(param, 'SP0005');
		}

		function callback_setPlant(data){
// 			EVF.V("PLANT_NM", data.PLANT_NM);
// 			EVF.V("PLANT_CD", data.PLANT_CD);
// 			EVF.V("LOC_BUYER_CD", data.BUYER_CD);
// 			setAutoCheck(data.PLANT_CD, "PLANT_NM");

			$('#WH_NM').val('');
			$('#WH_CD').val('');
// 			$('#WH_NM_FLAG').attr("checked", false);
		}


		function selectWH(){
// 			if(EVF.V('PLANT_NM') === '') {
// 				return EVF.alert('${RQ0310P01_002}');
// 			}
			var param = {
// 				PLANT_CD : EVF.V("PLANT_CD"),
// 				PLANT_NM : EVF.V("PLANT_NM"),
				BUYER_CD : EVF.V("LOC_BUYER_CD"),
				callBackFunction: "callback_setWH"
			};
			everPopup.openCommonPopup(param, "SP0501");
		}

		function callback_setWH(data){
			EVF.V("WH_CD", data.WH_CD);
			EVF.V("WH_NM", data.WH_NM);
			setAutoCheck(data.WH_NM, "WH_NM");
		}

		function setAutoCheck(data, id){
			if(data !== ''){
				EVF.C(id + '_FLAG').setChecked(true);
			}else {
				EVF.C(id + '_FLAG').setChecked(false);
			}
		}

	</script>
	<e:window id="BD0310P01" onReady="init" initData="${initData}" title="${fullScreenName}">

		<e:buttonBar id="buttonBar" align="right" width="100%" height="fit">
			<e:check id="selectAll" name="selectAll" onClick="doselectAll" label="전체선택"/>
			<e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>


		<e:searchPanel id="form" columnCount="1" labelWidth="120" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<%--수량--%>
				<e:label for="RFX_QT" title="${form_RFX_QT_N}"/>
				<e:field>
					<e:text>&nbsp;</e:text>
					<e:check id="RFX_QT_FLAG" name="RFX_QT_FLAG" />
					<e:text>&nbsp;</e:text>
					<e:inputNumber id="RFX_QT" name="RFX_QT" value="" width="${form_RFX_QT_W}" maxValue="${form_RFX_QT_M}" decimalPlace="${form_RFX_QT_NF}" disabled="${form_RFX_QT_D}" readOnly="${form_RFX_QT_RO}" required="${form_RFX_QT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--예상 단가--%>
				<e:label for="UNIT_PRC" title="${form_UNIT_PRC_N}"/>
				<e:field>
					<e:text>&nbsp;</e:text>
					<e:check id="UNIT_PRC_FLAG" name="UNIT_PRC_FLAG" />
					<e:text>&nbsp;</e:text>
					<e:inputNumber id="UNIT_PRC" name="UNIT_PRC" value="" width="${form_UNIT_PRC_W}" maxValue="${form_UNIT_PRC_M}" decimalPlace="${form_UNIT_PRC_NF}" disabled="${form_UNIT_PRC_D}" readOnly="${form_UNIT_PRC_RO}" required="${form_UNIT_PRC_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--납기일자--%>
				<e:label for="DELY_DATE" title="${form_DELY_DATE_N}"/>
				<e:field>
					<e:text>&nbsp;</e:text>
					<e:check id="DELY_DATE_FLAG" name="DELY_DATE_FLAG" />
					<e:text>&nbsp;</e:text>
					<e:inputDate id="DELY_DATE" name="DELY_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_DELY_DATE_R}" disabled="${form_DELY_DATE_D}" readOnly="${form_DELY_DATE_RO}" />
				</e:field>
			</e:row>
<%-- 			<e:row> --%>
<%-- 				구매요청회사 --%>
<%-- 				<e:label for="PR_BUYER_CD" title="${form_PR_BUYER_CD_N}"/> --%>
<%-- 				<e:field> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:check id="PR_BUYER_CD_FLAG" name="PR_BUYER_CD_FLAG" /> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:select id="PR_BUYER_CD" name="PR_BUYER_CD" value="" options="${prBuyerCdOptions}" width="${form_PR_BUYER_CD_W}" disabled="${form_PR_BUYER_CD_D}" readOnly="${form_PR_BUYER_CD_RO}" required="${form_PR_BUYER_CD_R}" placeHolder="" /> --%>
<%-- 				</e:field> --%>
<%-- 			</e:row> --%>
<%-- 			<e:row> --%>
<%-- 				구매그룹 --%>
<%-- 				<e:label for="CTRL_NM" title="${form_CTRL_NM_N}"/> --%>
<%-- 				<e:field> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:check id="CTRL_NM_FLAG" name="CTRL_NM_FLAG" /> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:search id="CTRL_NM" name="CTRL_NM" value="" width="${form_CTRL_NM_W}" maxLength="${form_CTRL_NM_M}" onIconClick="${form_CTRL_NM_RO ? 'everCommon.blank' : 'selectCtrl'}" disabled="${form_CTRL_NM_D}" readOnly="${form_CTRL_NM_RO}" required="${form_CTRL_NM_R}" /> --%>
<%-- 					<e:inputHidden id="CTRL_CD" name="CTRL_CD" /> --%>
<%-- 				</e:field> --%>
<%-- 			</e:row> --%>
<%-- 			<e:row> --%>
<%-- 				플랜트명 --%>
<%-- 				<e:label for="PLANT_NM" title="${form_PLANT_NM_N}"/> --%>
<%-- 				<e:field> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:check id="PLANT_NM_FLAG" name="PLANT_NM_FLAG" /> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:search id="PLANT_NM" name="PLANT_NM" value="" width="${form_PLANT_NM_W}" maxLength="${form_PLANT_NM_M}" onIconClick="${form_PLANT_NM_RO ? 'everCommon.blank' : 'selectPlant'}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" /> --%>
<%-- 					<e:inputHidden id="PLANT_CD" name="PLANT_CD" /> --%>
<%-- 					<e:inputHidden id="LOC_BUYER_CD" name="LOC_BUYER_CD" /> --%>
<%-- 				</e:field> --%>
<%-- 			</e:row> --%>
<%-- 			<e:row> --%>
<%-- 				저장위치 --%>
<%-- 				<e:label for="WH_NM" title="${form_WH_NM_N}"/> --%>
<%-- 				<e:field> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:check id="WH_NM_FLAG" name="WH_NM_FLAG" /> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:search id="WH_NM" name="WH_NM" value="" width="${form_WH_NM_W}" maxLength="${form_WH_NM_M}" onIconClick="${form_WH_NM_RO ? 'everCommon.blank' : 'selectWH'}" disabled="${form_WH_NM_D}" readOnly="${form_WH_NM_RO}" required="${form_WH_NM_R}" /> --%>
<%-- 					<e:inputHidden id="WH_CD" name="WH_CD" /> --%>
<%-- 				</e:field> --%>
<%-- 			</e:row> --%>
<%-- 			<e:row> --%>
<%-- 				납품장소 --%>
<%-- 				<e:label for="DELY_PLACE_NM" title="${form_DELY_PLACE_NM_N}" /> --%>
<%-- 				<e:field> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:check id="DELY_PLACE_NM_FLAG" name="DELY_PLACE_NM_FLAG" /> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:inputText id="DELY_PLACE_NM" name="DELY_PLACE_NM" value="" width="${form_DELY_PLACE_NM_W}" maxLength="${form_DELY_PLACE_NM_M}" disabled="${form_DELY_PLACE_NM_D}" readOnly="${form_DELY_PLACE_NM_RO}" required="${form_DELY_PLACE_NM_R}" /> --%>
<%-- 				</e:field> --%>
<%-- 			</e:row> --%>
<%-- 			<e:row> --%>
<%-- 				적용시작일 --%>
<%-- 				<e:label for="VALID_FROM_DATE" title="${form_VALID_FROM_DATE_N}"/> --%>
<%-- 				<e:field> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:check id="VALID_FROM_DATE_FLAG" name="VALID_FROM_DATE_FLAG" /> --%>
<%-- 					<e:text>&nbsp;</e:text> --%>
<%-- 					<e:inputDate id="VALID_FROM_DATE" name="VALID_FROM_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_VALID_FROM_DATE_R}" disabled="${form_VALID_FROM_DATE_D}" readOnly="${form_VALID_FROM_DATE_RO}" /> --%>
<%-- 				</e:field> --%>
<%-- 			</e:row> --%>
		</e:searchPanel>



	</e:window>
</e:ui>