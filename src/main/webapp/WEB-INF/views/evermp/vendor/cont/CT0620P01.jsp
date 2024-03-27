<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		var baseUrl = "/evermp/vendor/cont/CT0620P01/";
		function init() {
			$("#CONT_GUAR_TYPE").change();
			$("#ADV_GUAR_TYPE").change();
			$("#WARR_GUAR_TYPE").change();

		}
		//보증구분 체인지 이벤트
		function changeGuarType(data){

			//공급사
			if("${ses.userType}"=="S"){
				//전자가 아닌것은 SGI 전송버튼 파기 숨김
				EVF.C(data.data+"_INSU_NUM").setDisabled(true)
				EVF.C(data.data+"_INSU_BILL_FLAG").setDisabled(true);
				$("#upload-button-ATT_FILE_NUM").hide();
				if(EVF.V(data.id)=="EL" && EVF.V(data.data+"_INSU_BILL_FLAG")=="1"){

					EVF.C(data.data+"_INSU_ORG_CD").setDisabled(true);
					EVF.C(data.data+"_INSU_NUM").setDisabled(true);
					EVF.V(data.data+"_INSU_ORG_CD",'10')
					$("#"+data.data+"_SEND").show()
					$("#"+data.data+"_CANCEL").show()
				}else{
					EVF.C(data.data+"_INSU_ORG_CD").setDisabled(false);
					$("#"+data.data+"_SEND").hide()
					$("#"+data.data+"_CANCEL").hide()
				}
				if(EVF.V(data.data+"_INSU_STATUS") == "SA" || EVF.V(data.data+"_INSU_STATUS")== "TA"){
					 $("#"+data.data+"_SEND").hide();
					 if(EVF.V(data.data+"_INSU_STATUS") == "SA" ){
						 //수용일시 버튼네임 보증취소->보증파기
						 $("#"+data.data+"_CANCEL").children('div').find(".e-button-text").text('${CT0620P01_0005}')
					 }

				}
				//보증 상태값이 취소/파기 보증전송전일시 취소버튼숨김.
				if(EVF.V(data.data+"_INSU_STATUS") == "DE" || EVF.V(data.data+"_INSU_STATUS")== "DD" ||EVF.V(data.data+"_INSU_STATUS") == "" || EVF.V(data.data+"_INSU_STATUS") == null){
					 $("#"+data.data+"_CANCEL").hide()
				}

			}else if("${ses.userType}"=="C"){
				//운영사
				$("#"+data.data+"_SEND").hide()
 				EVF.V(data.data+"_INSU_STATUS") != "SA" ? $("#"+data.data+"_CANCEL").hide() : ""
				EVF.C(data.data+"_INSU_ORG_CD").setDisabled(true);
 				//수용완료 됬거나. 보증번호들어왔을시 수정금지. 전송 안보냈을시에도 금지.
 				if(EVF.V(data.data+"_INSU_STATUS") == "SA"  || EVF.V(data.data+"_INSU_NUM").length>0 || EVF.V(data.data+"_INSU_STATUS") == "" || EVF.V(data.data+"_INSU_STATUS") == null){
 					EVF.C(data.data+"_INSU_NUM").setDisabled(true);
 				}

			}else if("${ses.userType}"=="B"){
				//고객사 버튼숨김
				$("#"+data.data+"_SEND").hide()
				$("#"+data.data+"_CANCEL").hide()
				$("#doSave").hide();
			}
			//보증전송 됬거나 수용이 됬을시 수정금지.
			if(EVF.V(data.data+"_INSU_STATUS") == "SA" || EVF.V(data.data+"_INSU_STATUS")== "TA"){
				EVF.C(data.data+"_GUAR_TYPE").setDisabled(true);
				EVF.C(data.data+"_INSU_RMK").setDisabled(true);
				EVF.C(data.data+"_INSU_BILL_FLAG").setDisabled(true);

			}


		}
		//저장
		function doSave(){
			var msg = "";
			var arr =[];
			if(EVF.V("CONT_USER_ID")!="${ses.userId}" && "${ses.userType}"=="C"){
				return alert("${CT0620P01_0006}")
			}
			if(EVF.V("CONT_INSU_NUM")!='${form.CONT_INSU_NUM}'){
				EVF.V("CONT_INSU_STATUS","SA");
				arr.push("${CT0620P01_0001}");
				msg = "${CT0620P01_0007}"
			}
			if(EVF.V("ADV_INSU_NUM")!='${form.ADV_INSU_NUM}'){
				EVF.V("ADV_INSU_STATUS","SA");
				arr.push("${CT0620P01_0002}");
				msg = "${CT0620P01_0007}"
			}
			if(EVF.V("WARR_INSU_NUM")!='${form.WARR_INSU_NUM}'){
				EVF.V("WARR_INSU_STATUS","SA");
				arr.push("${CT0620P01_0003}");
				msg = "${CT0620P01_0007}"
			}
			store = new EVF.Store();
			EVF.confirm(arr.join(",")+" "+msg+"${msg.M0021}", function () {
				store.doFileUpload(function() {
					store.load(baseUrl + 'doSave', function() {
						EVF.alert(this.getResponseMessage(), function() {
							location.href=baseUrl+'view.so?popupFlag=true&CONT_NUM='+EVF.V("CONT_NUM")+'&CONT_CNT='+EVF.V("CONT_CNT")
							opener.doSearch();
						});

					});
				});

			});
		}
		//SGI 전송
		function doSend(val){
			var gubn= val.currentTarget.id;

			store = new EVF.Store();
			var contEndDate 	 = EVF.V("CONT_END_DATE");
			var date			 = new Date(contEndDate.substr(0,4),contEndDate.substr(4,2),contEndDate.substr(6,2))
			date.setDate(date.getDate()+1);
			store.setParameter('SGI_GUBUN'			 	,'CONINF') 				//통보서[CONINF], 최종응답서[RBONGU] 구분
			store.setParameter('RBONGU_STATUS'		 	, 'TA')  			    //통보서 : 접수(TA), 거부(TR)
			store.setParameter('MENGEL_START_DATE_SGI'	,getToday(date))	    //하자보증 시작일자(=계약종료일자)
			date.setMonth(date.getMonth()+(Number(EVF.V('WARR_GUAR_QT'))|| 0)); //마감일
			store.setParameter('MENGEL_END_DATE_SGI'      ,getToday(date))  			 //하자보증 완료일자(=계약종료일자+하자보증기간)
			store.setParameter('CONT_NUM_SGI'             , EVF.V("CONT_NUM"))  		 //계약번호
			store.setParameter('CONT_CNT_SGI'             , EVF.V("CONT_CNT"))  		 //계약차수
			store.setParameter('CONT_TITLE_SGI'           , EVF.V("CONT_DESC"))  	     //계약명
			store.setParameter('CONT_DATE_SGI'            , EVF.V('CONT_DATE')) 		 //계약체결일자
			store.setParameter('SORDER_AMT_SGI'           , EVF.V('SUPPLY_AMT'))  	     //매입금액
			store.setParameter('CONT_START_DATE_SGI'      , EVF.V('CONT_START_DATE'))    //계약시작일자
			store.setParameter('CONT_END_DATE_SGI'        , EVF.V('CONT_END_DATE'))      //계약완료일자
			store.setParameter('IRS_NO_VENDOR'		      , EVF.V('IRS_NO'))  		     //공급사 사업자번호
			store.setParameter('VENDOR_NAME_LOC'	      , EVF.V('VENDOR_NM'))  	     //기관명
			store.setParameter('CEO_NAME_LOC'		      , EVF.V('CEO_USER_NM'))        //대표자명
			store.setParameter('CONT_ISU_BILL_FLAG_SGI'	  , flagChange('CONT'))  		//계약이행보증 발급여부
			store.setParameter('FIRST_ISU_BILL_FLAG_SGI'  , flagChange('ADV'))  		//선급보증 발급여부
			store.setParameter('MENGEL_ISU_BILL_FLAG_SGI' , flagChange('WARR')) 		 //하자이행보증 발급여부

			if(gubn=="CONT_SEND"){
				store.setParameter('CONT_WARRANTY_AMT_SGI'			, EVF.V('CONT_GUAR_AMT'))  		//계약이행 보증금액
				store.setParameter('CONT_WARRANTY_AMT_RATE_SGI'		, EVF.V('CONT_GUAR_PERCENT'))   //계약이행 보증율(%)

				store.setParameter('INSU_STATUS'					, EVF.V("CONT_INSU_STATUS"))  	//게약상태값 I/F
				store.setParameter('GUBN'		 					, "CONT")  			    		//구분값
			}else if(gubn=="ADV_SEND"){
				store.setParameter('FIRST_SECURITIES_AMT_SGI'		, EVF.V('ADV_GUAR_AMT'))  		//선급이행보증금액
				store.setParameter('FIRST_SECURITIES_AMT_RATE_SGI'	, EVF.V('ADV_GUAR_PERCENT'))  	//선급이행 보증율(%)

				store.setParameter('INSU_STATUS'					, EVF.V("ADV_INSU_STATUS"))  	//게약상태값 I/F
				store.setParameter('GUBN'		 					, "ADV")  			    		 //구분값

			}else if(gubn=="WARR_SEND"){
				store.setParameter('CONT_WARRANTY_AMT_SGI'			, EVF.V('CONT_GUAR_AMT'))  		//계약이행 보증금액
				store.setParameter('MENGEL_WARRANTY_AMT_SGI'		, EVF.V('WARR_GUAR_AMT'))  		//하자이행 보증금액
				store.setParameter('MENGEL_WARRANTY_AMT_RATE_SGI'	, EVF.V('WARR_GUAR_PERCENT'))  	//하자이행 보증율(%)

				store.setParameter('INSU_STATUS'					, EVF.V("WARR_INSU_STATUS"))  	//게약상태값 I/F
				store.setParameter('GUBN'		 					, "WARR")  			    		//구분값
			}

			store.load(baseUrl+'SendSevlet', function() {

				EVF.alert(this.getResponseMessage(),function(){
					store.load(baseUrl + 'doSave', function() {
						location.href=baseUrl+'view.so?popupFlag=true&CONT_NUM='+EVF.V("CONT_NUM")+'&CONT_CNT='+EVF.V("CONT_CNT")
						opener.doSearch();
					});

		        });
			});
		}
		// 취소/거부
		function doCancel(val){
			var gubn = val.currentTarget.id;
			store = new EVF.Store();
			var contEndDate 	 = EVF.V("CONT_END_DATE");
			var date = new Date(contEndDate.substr(0,4),contEndDate.substr(4,2),contEndDate.substr(6,2))
			date.setDate(date.getDate()+1);
			store.setParameter('SGI_GUBUN'			 	  ,'RBONGU') 				//통보서[CONINF], 최종응답서[RBONGU] 구분
			store.setParameter('CONT_NUM_SGI'             , EVF.V("CONT_NUM"))  		//계약번호
			store.setParameter('CONT_CNT_SGI'             , EVF.V("CONT_CNT"))  		//계약차수
			store.setParameter('CONT_TITLE_SGI'           , EVF.V("CONT_DESC"))  	//계약명
			store.setParameter('IRS_NO_VENDOR'		      , EVF.V('IRS_NO'))  		//공급사 사업자번호
			store.setParameter('VENDOR_NAME_LOC'	      , EVF.V('VENDOR_NM'))  	//기관명
			store.setParameter('CEO_NAME_LOC'		      , EVF.V('CEO_USER_NM'))    //대표자명
			store.setParameter('CONT_START_DATE_SGI'      , EVF.V('CONT_START_DATE'))    //계약시작일자
			store.setParameter('CONT_END_DATE_SGI'        , EVF.V('CONT_END_DATE'))      //계약완료일자
			store.setParameter('MENGEL_START_DATE_SGI'	  , getToday(date))	    //하자보증 시작일자(=계약종료일자)
			date.setMonth(date.getMonth()+(Number(EVF.V('WARR_GUAR_QT'))|| 0)); //마감일
			store.setParameter('MENGEL_END_DATE_SGI' 	  , getToday(date))  			 //하자보증 완료일자(=계약종료일자+하자보증기간)
			store.setParameter('RBONGU_STATUS'		 	  , 'RBONGU_RE')  			//통보서 : 접수(TA), 거부(TR),취소(DA)
			store.setParameter('CONT_ISU_BILL_FLAG_SGI'	  , flagChange('CONT'))  		//계약이행보증 발급여부
			store.setParameter('FIRST_ISU_BILL_FLAG_SGI'  , flagChange('ADV'))  		//선급보증 발급여부
			store.setParameter('MENGEL_ISU_BILL_FLAG_SGI' , flagChange('WARR')) 		 //하자이행보증 발급여부

			if(gubn=="CONT_CANCEL"){
				if(EVF.V("CONT_INSU_STATUS")== "TA"){
					store.setParameter('CONT_INSU_NUM'					, EVF.V("CONT_INSU_INFORM_SEQ"))  		//계약이행보증번호 I/F
				}else if(EVF.V("CONT_INSU_STATUS")== "SA"){
					store.setParameter('CONT_INSU_NUM'					, EVF.V("CONT_INSU_NUM"))  		//계약이행보증번호 I/F
				}
				store.setParameter('INSU_STATUS'  , EVF.V("CONT_INSU_STATUS"))  	//게약상태값 I/F

				store.setParameter('GUBN' 		  , "CONT")   //구분값
			}else if(gubn=="ADV_CANCEL"){
				if(EVF.V("ADV_INSU_STATUS")== "TA"){
					store.setParameter('AMT_INSU_NUM'					, EVF.V("ADV_INSU_INFORM_SEQ"))  		//계약이행보증번호 I/F
				}else if(EVF.V("ADV_INSU_STATUS")== "SA"){
					store.setParameter('AMT_INSU_NUM'					, EVF.V("ADV_INSU_NUM"))  		//계약이행보증번호 I/F
				}
				store.setParameter('INSU_STATUS'  , EVF.V("ADV_INSU_STATUS"))  	//게약상태값 I/F
				store.setParameter('GUBN' 	      , "ADV")  	//구분값
			}else{
				if(EVF.V("WARR_INSU_STATUS")== "TA"){
					store.setParameter('AS_INSU_NUM'					, EVF.V("WARR_INSU_INFORM_SEQ"))  		//계약이행보증번호 I/F
				}else if(EVF.V("WARR_INSU_STATUS")== "SA"){
					store.setParameter('AS_INSU_NUM'					, EVF.V("WARR_INSU_NUM"))  		//계약이행보증번호 I/F
				}
				store.setParameter('INSU_STATUS' , EVF.V("WARR_INSU_STATUS"))  	//게약상태값 I/F
				store.setParameter('GUBN' 		 , "WARR")  	//구분값
			}

			store.load(baseUrl+'SendSevlet', function() {

				EVF.alert(this.getResponseMessage(),function(){
					store.load(baseUrl + 'doSave', function() {
					   opener.doSearch();
					   window.close();
					});
		            });

			});
		}
		//날짜계산
		function getToday(date){
		    var year  = date.getFullYear();
		    var month = ("0" + (date.getMonth())).slice(-2);
		    var day   = ("0" + date.getDate()).slice(-2);
		    return year + month + day;
		}
		//플래그 변환
		function flagChange(gubn){
		    var billFlag = EVF.V(gubn+"_INSU_BILL_FLAG") == "1" ? "O" : "X";
		    var numFlag="";
		    if(EVF.V(gubn+"_INSU_STATUS") != 'TA' && EVF.V(gubn+"_INSU_STATUS") != 'SA'){
		    	numFlag="X";
		    }else{
		    	numFlag="O";
		    }
		    return billFlag+"/"+numFlag;
		}

	</script>
	<e:window id="CT0620P01" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id='CONT_NUM' name="CONT_NUM" value="${form.CONT_NUM}" />
        <e:inputHidden id='CONT_CNT' name="CONT_CNT" value="${form.CONT_CNT}" />
        <e:inputHidden id='CONT_DESC' name="CONT_DESC" value="${form.CONT_DESC}" />
        <e:inputHidden id='CONT_DATE' name="CONT_DATE" value="${form.CONT_DATE}" />
        <e:inputHidden id='SUPPLY_AMT' name="SUPPLY_AMT" value="${form.SUPPLY_AMT}" />
        <e:inputHidden id='CONT_AMT' name="CONT_AMT" value="${form.CONT_AMT}" />
        <e:inputHidden id='CONT_START_DATE' name="CONT_START_DATE" value="${form.CONT_START_DATE}" />
        <e:inputHidden id='CONT_END_DATE' name="CONT_END_DATE" value="${form.CONT_END_DATE}" />
        <e:inputHidden id='IRS_NO' name="IRS_NO" value="${form.IRS_NO}" />
        <e:inputHidden id='CEO_USER_NM' name="CEO_USER_NM" value="${form.CEO_USER_NM}" />
        <e:inputHidden id='VENDOR_NM' name="VENDOR_NM" value="${form.VENDOR_NM}" />
        <e:inputHidden id='CONT_INSU_STATUS' name="CONT_INSU_STATUS" value="${form.CONT_INSU_STATUS}" />
        <e:inputHidden id='ADV_INSU_STATUS' name="ADV_INSU_STATUS" value="${form.ADV_INSU_STATUS}" />
        <e:inputHidden id='WARR_INSU_STATUS' name="WARR_INSU_STATUS" value="${form.WARR_INSU_STATUS}" />
        <e:inputHidden id='CONT_USER_ID' name="CONT_USER_ID" value="${form.CONT_USER_ID}" />

		<e:buttonBar id="buttonBar" align="right" width="100%" height="fit">

			<e:button id="doSave"   name="doSave"   label="${doSave_N}" 	onClick="doSave" 	disabled="${doSave_D}" 		visible="${doSave_V}"/>
		</e:buttonBar>


        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="6" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
			<e:row>
			   <e:label for="11" title="${CT0620P01_0001}" />
			   <e:field colSpan="3" >
					<e:inputText id="CONT_INSU_NUM" name="CONT_INSU_NUM"  value="${form.CONT_INSU_NUM}" width="${form_CONT_INSU_NUM_W}" maxLength="${form_CONT_INSU_NUM_M}" disabled="${form_CONT_INSU_NUM_D}" readOnly="${form_CONT_INSU_NUM_RO}" required="${form_CONT_INSU_NUM_R}" />
			   		<e:button id="CONT_CANCEL" name="CONT_CANCEL" label="${ses.userType =='S' ? CT0620P01_0004 : CT0620P01_0005}" align="right"  onClick="doCancel" disabled="${CONT_CANCEL_D}" visible="${CONT_CANCEL_V}"/>
			  		<e:button id="CONT_SEND" name="CONT_SEND" label="${CONT_SEND_N}" align="right"  onClick="doSend" disabled="${CONT_SEND_D}" visible="${CONT_SEND_V}"/>

			   </e:field>
			   <e:label for="11" title="${CT0620P01_0002}" />
			   <e:field colSpan="3" >
					<e:inputText id="ADV_INSU_NUM" name="ADV_INSU_NUM" value="${form.ADV_INSU_NUM}" width="${form_ADV_INSU_NUM_W}" maxLength="${form_ADV_INSU_NUM_M}" disabled="${form_ADV_INSU_NUM_D}" readOnly="${form_ADV_INSU_NUM_RO}" required="${form_ADV_INSU_NUM_R}" />
					<e:button id="ADV_CANCEL" name="ADV_CANCEL" label="${ses.userType =='S' ? CT0620P01_0004 : CT0620P01_0005}" align="right"  onClick="doCancel" disabled="${ADV_CANCEL_D}" visible="${ADV_CANCEL_V}"/>
			   		<e:button id="ADV_SEND" name="ADV_SEND" label="${ADV_SEND_N}" align="right"  onClick="doSend" disabled="${ADV_SEND_D}" visible="${ADV_SEND_V}"/>
			   </e:field>
			    <e:label for="11" title="${CT0620P01_0003}" />
			   <e:field colSpan="3" >
					<e:inputText id="WARR_INSU_NUM" name="WARR_INSU_NUM" value="${form.WARR_INSU_NUM}" width="${form_WARR_INSU_NUM_W}" maxLength="${form_WARR_INSU_NUM_M}" disabled="${form_WARR_INSU_NUM_D}" readOnly="${form_WARR_INSU_NUM_RO}" required="${form_WARR_INSU_NUM_R}" />
					<e:button id="WARR_CANCEL" name="WARR_CANCEL" label="${ses.userType =='S' ? CT0620P01_0004 : CT0620P01_0005}" align="right"  onClick="doCancel" disabled="${WARR_CANCEL_D}" visible="${WARR_CANCEL_V}"/>
					<e:button id="WARR_SEND" name="WARR_SEND" label="${WARR_SEND_N}" align="right"  onClick="doSend" disabled="${WARR_SEND_D}" visible="${WARR_SEND_V}"/>
			   </e:field>
			</e:row>
			<e:row>
                 <!-- 이행보증서통보번호 -->
				<e:label for="CONT_INSU_INFORM_SEQ" title="${form_CONT_INSU_INFORM_SEQ_N}"/>
				<e:field>
					<e:inputText id="CONT_INSU_INFORM_SEQ" name="CONT_INSU_INFORM_SEQ" value="${form.CONT_INSU_INFORM_SEQ}" width="${form_CONT_INSU_INFORM_SEQ_W}" maxLength="${form_CONT_INSU_INFORM_SEQ_M}" disabled="${form_CONT_INSU_INFORM_SEQ_D}" readOnly="${form_CONT_INSU_INFORM_SEQ_RO}" required="${form_CONT_INSU_INFORM_SEQ_R}" />
				</e:field>
				 <!-- 이행유무 -->
				<e:label for="CONT_INSU_BILL_FLAG" title="${form_CONT_INSU_BILL_FLAG_N}"/>
				<e:field>
					<e:select id="CONT_INSU_BILL_FLAG" name="CONT_INSU_BILL_FLAG" value="${form.CONT_INSU_BILL_FLAG}" options="${contInsuBillFlagOptions}" width="${form_CONT_INSU_BILL_FLAG_W}" disabled="${form_CONT_INSU_BILL_FLAG_D}" readOnly="${form_CONT_INSU_BILL_FLAG_RO}" required="${form_CONT_INSU_BILL_FLAG_R}" placeHolder="" />
				</e:field>

				 <!-- 선급보증서통보번호 -->
				<e:label for="ADV_INSU_INFORM_SEQ" title="${form_ADV_INSU_INFORM_SEQ_N}"/>
				<e:field>
					<e:inputText id="ADV_INSU_INFORM_SEQ" name="ADV_INSU_INFORM_SEQ" value="${form.ADV_INSU_INFORM_SEQ }" width="${form_ADV_INSU_INFORM_SEQ_W}" maxLength="${form_ADV_INSU_INFORM_SEQ_M}" disabled="${form_ADV_INSU_INFORM_SEQ_D}" readOnly="${form_ADV_INSU_INFORM_SEQ_RO}" required="${form_ADV_INSU_INFORM_SEQ_R}" />
				</e:field>
				 <!-- 선급유무 -->
				<e:label for="ADV_INSU_BILL_FLAG" title="${form_ADV_INSU_BILL_FLAG_N}"/>
				<e:field>
					<e:select id="ADV_INSU_BILL_FLAG" name="ADV_INSU_BILL_FLAG" value="${form.ADV_INSU_BILL_FLAG}" options="${advInsuBillFlagOptions}" width="${form_ADV_INSU_BILL_FLAG_W}" disabled="${form_ADV_INSU_BILL_FLAG_D}" readOnly="${form_ADV_INSU_BILL_FLAG_RO}" required="${form_ADV_INSU_BILL_FLAG_R}" placeHolder="" />
				</e:field>
				 <!-- 하자보증서통보번호 -->
				<e:label for="WARR_INSU_INFORM_SEQ" title="${form_WARR_INSU_INFORM_SEQ_N}"/>
				<e:field>
					<e:inputText id="WARR_INSU_INFORM_SEQ" name="WARR_INSU_INFORM_SEQ" value="${form.WARR_INSU_INFORM_SEQ}" width="${form_WARR_INSU_INFORM_SEQ_W}" maxLength="${form_WARR_INSU_INFORM_SEQ_M}" disabled="${form_WARR_INSU_INFORM_SEQ_D}" readOnly="${form_WARR_INSU_INFORM_SEQ_RO}" required="${form_WARR_INSU_INFORM_SEQ_R}" />
				</e:field>
				 <!-- 하자유무 -->
				<e:label for="WARR_INSU_BILL_FLAG" title="${form_WARR_INSU_BILL_FLAG_N}"/>
				<e:field>
					<e:select id="WARR_INSU_BILL_FLAG" name="WARR_INSU_BILL_FLAG" value="${form.WARR_INSU_BILL_FLAG}" options="${warrInsuBillFlagOptions}" width="${form_WARR_INSU_BILL_FLAG_W}" disabled="${form_WARR_INSU_BILL_FLAG_D}" readOnly="${form_WARR_INSU_BILL_FLAG_RO}" required="${form_WARR_INSU_BILL_FLAG_R}" placeHolder="" />
				</e:field>

			</e:row>
			<e:row>
				 <!-- 이행보증타입 -->
				<e:label for="CONT_GUAR_TYPE" title="${form_CONT_GUAR_TYPE_N}"/>
				<e:field>
					<e:select id="CONT_GUAR_TYPE" name="CONT_GUAR_TYPE" value="${form.CONT_GUAR_TYPE}" options="${contGuarTypeOptions}" width="${form_CONT_GUAR_TYPE_W}" disabled="${form_CONT_GUAR_TYPE_D}" readOnly="${form_CONT_GUAR_TYPE_RO}" required="${form_CONT_GUAR_TYPE_R}" placeHolder="" onChange="changeGuarType" data="CONT"/>
				</e:field>
				<!-- 이행보증기관 -->
				<e:label for="CONT_INSU_ORG_CD" title="${form_CONT_INSU_ORG_CD_N}"/>
				<e:field>
					<e:select id="CONT_INSU_ORG_CD" name="CONT_INSU_ORG_CD" value="${form.CONT_INSU_ORG_CD}" options="${contInsuOrgCdOptions}" width="${form_CONT_INSU_ORG_CD_W}" disabled="${form_CONT_INSU_ORG_CD_D}" readOnly="${form_CONT_INSU_ORG_CD_RO}" required="${form_CONT_INSU_ORG_CD_R}" placeHolder="" />
				</e:field>
				 <!-- 선급보증타입 -->
				<e:label for="ADV_GUAR_TYPE" title="${form_ADV_GUAR_TYPE_N}"/>
				<e:field>
					<e:select id="ADV_GUAR_TYPE" name="ADV_GUAR_TYPE" value="${form.ADV_GUAR_TYPE}" options="${advGuarTypeOptions}" width="${form_ADV_GUAR_TYPE_W}" disabled="${form_ADV_GUAR_TYPE_D}" readOnly="${form_ADV_GUAR_TYPE_RO}" required="${form_ADV_GUAR_TYPE_R}" placeHolder="" onChange="changeGuarType" data="ADV"/>
				</e:field>
				<!-- 선급보증기관 -->
				<e:label for="ADV_INSU_ORG_CD" title="${form_ADV_INSU_ORG_CD_N}"/>
				<e:field>
					<e:select id="ADV_INSU_ORG_CD" name="ADV_INSU_ORG_CD" value="${form.ADV_INSU_ORG_CD}" options="${advInsuOrgCdOptions}" width="${form_ADV_INSU_ORG_CD_W}" disabled="${form_ADV_INSU_ORG_CD_D}" readOnly="${form_ADV_INSU_ORG_CD_RO}" required="${form_ADV_INSU_ORG_CD_R}" placeHolder="" />
				</e:field>
				 <!-- 하자보증타입 -->
				<e:label for="WARR_GUAR_TYPE" title="${form_WARR_GUAR_TYPE_N}"/>
				<e:field>
					<e:select id="WARR_GUAR_TYPE" name="WARR_GUAR_TYPE" value="${form.WARR_GUAR_TYPE}" options="${warrGuarTypeOptions}" width="${form_WARR_GUAR_TYPE_W}" disabled="${form_WARR_GUAR_TYPE_D}" readOnly="${form_WARR_GUAR_TYPE_RO}" required="${form_WARR_GUAR_TYPE_R}" placeHolder="" onChange="changeGuarType" data="WARR"/>
				</e:field>
				<!-- 하자보증기관 -->
				<e:label for="WARR_INSU_ORG_CD" title="${form_WARR_INSU_ORG_CD_N}"/>
				<e:field>
					<e:select id="WARR_INSU_ORG_CD" name="WARR_INSU_ORG_CD" value="${form.WARR_INSU_ORG_CD}" options="${warrInsuOrgCdOptions}" width="${form_WARR_INSU_ORG_CD_W}" disabled="${form_WARR_INSU_ORG_CD_D}" readOnly="${form_WARR_INSU_ORG_CD_RO}" required="${form_WARR_INSU_ORG_CD_R}" placeHolder="" />
				</e:field>

			</e:row>
			<e:row>
				<!-- 이행보증금 -->
				<e:label for="CONT_GUAR_AMT" title="${form_CONT_GUAR_AMT_N}"/>
				<e:field>
					<e:inputNumber id="CONT_GUAR_AMT" name="CONT_GUAR_AMT" value="${form.CONT_GUAR_AMT}" width="${form_CONT_GUAR_AMT_W}" maxValue="${form_CONT_GUAR_AMT_M}" decimalPlace="${form_CONT_GUAR_AMT_NF}" disabled="${form_CONT_GUAR_AMT_D}" readOnly="${form_CONT_GUAR_AMT_RO}" required="${form_CONT_GUAR_AMT_R}" />
				</e:field>
				<!-- 이행보증율 -->
				<e:label for="CONT_GUAR_PERCENT" title="${form_CONT_GUAR_PERCENT_N}"/>
				<e:field>
					<e:inputNumber id="CONT_GUAR_PERCENT" name="CONT_GUAR_PERCENT" value="${form.CONT_GUAR_PERCENT}" width="${form_CONT_GUAR_PERCENT_W}" maxValue="${form_CONT_GUAR_PERCENT_M}" decimalPlace="${form_CONT_GUAR_PERCENT_NF}" disabled="${form_CONT_GUAR_PERCENT_D}" readOnly="${form_CONT_GUAR_PERCENT_RO}" required="${form_CONT_GUAR_PERCENT_R}" />
				</e:field>
				<!-- 선급보증금 -->
				<e:label for="ADV_GUAR_AMT" title="${form_ADV_GUAR_AMT_N}"/>
				<e:field>
					<e:inputNumber id="ADV_GUAR_AMT" name="ADV_GUAR_AMT" value="${form.ADV_GUAR_AMT}" width="${form_ADV_GUAR_AMT_W}" maxValue="${form_ADV_GUAR_AMT_M}" decimalPlace="${form_ADV_GUAR_AMT_NF}" disabled="${form_ADV_GUAR_AMT_D}" readOnly="${form_ADV_GUAR_AMT_RO}" required="${form_ADV_GUAR_AMT_R}" />
				</e:field>
				<!-- 선급보증율 -->
				<e:label for="ADV_GUAR_PERCENT" title="${form_ADV_GUAR_PERCENT_N}"/>
				<e:field>
					<e:inputNumber id="ADV_GUAR_PERCENT" name="ADV_GUAR_PERCENT" value="${form.ADV_GUAR_PERCENT}" width="${form_ADV_GUAR_PERCENT_W}" maxValue="${form_ADV_GUAR_PERCENT_M}" decimalPlace="${form_ADV_GUAR_PERCENT_NF}" disabled="${form_ADV_GUAR_PERCENT_D}" readOnly="${form_ADV_GUAR_PERCENT_RO}" required="${form_ADV_GUAR_PERCENT_R}" />
				</e:field>
				<!-- 하자보증금 -->
				<e:label for="WARR_GUAR_AMT" title="${form_WARR_GUAR_AMT_N}"/>
				<e:field>
					<e:inputNumber id="WARR_GUAR_AMT" name="WARR_GUAR_AMT" value="${form.WARR_GUAR_AMT}" width="${form_WARR_GUAR_AMT_W}" maxValue="${form_WARR_GUAR_AMT_M}" decimalPlace="${form_WARR_GUAR_AMT_NF}" disabled="${form_WARR_GUAR_AMT_D}" readOnly="${form_WARR_GUAR_AMT_RO}" required="${form_WARR_GUAR_AMT_R}" />
				</e:field>
				<!-- 하자보증율 -->
				<e:label for="WARR_GUAR_PERCENT" title="${form_WARR_GUAR_PERCENT_N}"/>
				<e:field>
					<e:inputNumber id="WARR_GUAR_PERCENT" name="WARR_GUAR_PERCENT" value="${form.WARR_GUAR_PERCENT}" width="${form_WARR_GUAR_PERCENT_W}" maxValue="${form_WARR_GUAR_PERCENT_M}" decimalPlace="${form_WARR_GUAR_PERCENT_NF}" disabled="${form_WARR_GUAR_PERCENT_D}" readOnly="${form_WARR_GUAR_PERCENT_RO}" required="${form_WARR_GUAR_PERCENT_R}" />
				</e:field>


			</e:row>
			<e:row>
				<!--이행사유 -->
				<e:label for="CONT_INSU_RMK" title="${form_CONT_INSU_RMK_N}" />
				<e:field colSpan="3">
					<e:inputText id="CONT_INSU_RMK" name="CONT_INSU_RMK" value="${form.CONT_INSU_RMK}" width="${form_CONT_INSU_RMK_W}" maxLength="${form_CONT_INSU_RMK_M}" disabled="${form_CONT_INSU_RMK_D}" readOnly="${form_CONT_INSU_RMK_RO}" required="${form_CONT_INSU_RMK_R}" />
				</e:field>
				  <!--선급사유 -->
				<e:label for="ADV_INSU_RMK" title="${form_ADV_INSU_RMK_N}" />
				<e:field colSpan="3">
					<e:inputText id="ADV_INSU_RMK" name="ADV_INSU_RMK" value="${form.ADV_INSU_RMK}" width="${form_ADV_INSU_RMK_W}" maxLength="${form_ADV_INSU_RMK_M}" disabled="${form_ADV_INSU_RMK_D}" readOnly="${form_ADV_INSU_RMK_RO}" required="${form_ADV_INSU_RMK_R}" />
				</e:field>
				<!--하자사유 -->
				<e:label for="WARR_INSU_RMK" title="${form_WARR_INSU_RMK_N}" />
				<e:field colSpan="3">
					<e:inputText id="WARR_INSU_RMK" name="WARR_INSU_RMK" value="${form.WARR_INSU_RMK}" width="${form_WARR_INSU_RMK_W}" maxLength="${form_WARR_INSU_RMK_M}" disabled="${form_WARR_INSU_RMK_D}" readOnly="${form_WARR_INSU_RMK_RO}" required="${form_WARR_INSU_RMK_R}" />
				</e:field>
			</e:row>
			 <e:row>
			    <!--이행첨부파일  -->
             	<e:label for="CONT_ATT_FILE_NUM" title="${form_CONT_ATT_FILE_NUM_N}"/>
                <e:field colSpan="3">
                	<e:fileManager id="CONT_ATT_FILE_NUM" height="50" width="100%" fileId="${form.CONT_ATT_FILE_NUM}" readOnly="false" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                </e:field>
                <!--선급첨부파일  -->
             	<e:label for="ADV_ATT_FILE_NUM" title="${form_ADV_ATT_FILE_NUM_N}"/>
                <e:field colSpan="3">
                	<e:fileManager id="ADV_ATT_FILE_NUM" height="50" width="100%" fileId="${form.ADV_ATT_FILE_NUM}" readOnly="false" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                </e:field>
                <!--하자첨부파일  -->
             	<e:label for="WARR_ATT_FILE_NUM" title="${form_WARR_ATT_FILE_NUM_N}"/>
                <e:field colSpan="3">
                	<e:fileManager id="WARR_ATT_FILE_NUM" height="50" width="100%" fileId="${form.WARR_ATT_FILE_NUM}" readOnly="false" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                </e:field>
             </e:row>
			<e:row>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
				 <e:field colSpan="3">
                	<e:fileManager id="ATT_FILE_NUM" height="50" width="100%" fileId="${form.ATT_FILE_NUM}" readOnly="${ATT_FILE_FLAG}" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                </e:field>
                <e:label for="dummy" />
				<e:field colSpan="3" />
				<e:label for="dummy" />
				<e:field colSpan="3" />

			</e:row>
             <e:row>
		  	<!-- 하자(월) -->
				<e:label for="WARR_GUAR_QT" title="${form_WARR_GUAR_QT_N}"/>
				<e:field>
					<e:inputNumber id="WARR_GUAR_QT" name="WARR_GUAR_QT" value="${form.WARR_GUAR_QT}" width="${form_WARR_GUAR_QT_W}" maxValue="${form_WARR_GUAR_QT_M}" decimalPlace="${form_WARR_GUAR_QT_NF}" disabled="${form_WARR_GUAR_QT_D}" readOnly="${form_WARR_GUAR_QT_RO}" required="${form_WARR_GUAR_QT_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>



	</e:window>
</e:ui>