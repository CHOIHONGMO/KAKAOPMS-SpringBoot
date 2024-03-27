<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<style type="text/css">
		.eval_item_category {
											font-weight:bold;
											color:blue;
										}
		.eval_item_weight {
											font-weight:bold;
											color:red;
										}
		.eval_item_subject {
											font-weight:bold;
											color:blue;
										}
		.eval_item_contents {
											font-weight:bold;
										}

	</style>

	<script type="text/javascript">

	var grid = {};
	var addParam = [];
	var baseUrl = "/eversrm/srm/regEval/eval/";
	var readOnly = "";

	function init() {

		<%-- 조회용 화면 호출시 --%>
		if( '${param.detailView}' == 'true' ) {
			readOnly = "disabled";
		} else {
			readOnly = "";
		}

		doSearch();


    }

    <%-- 조회 --%>
    function doSearch() {


        var store = new EVF.Store();
        //if(!store.validate()) return;

        store.load(baseUrl + 'SRM_196/doSearch', function() {
        	<%--// Map 형태의 Key 값을 받아서 --%>
           var formValue = JSON.parse(this.getParameter("form2"));
           //var formValue =  JSON.stringify("${form2}") ;
           //var formValue = JSON.parse(form2);
           //var formValue = this.getParameter("form2");

           if( formValue != null  ) {
           //alert( JSON.stringify(formValue) );

           		$("#item_body tr").remove();

           		var html			= "";

        	   var ev_type 		= formValue.ev_type;		<%--평가구분--%>
        	   var ev_subject	= formValue.ev_subject;   <%--평가제목--%>
        	   var ev_item 		= formValue.ev_item;        <%--평가항목--%>

        	   var evvu 			= formValue.evvu;

        	   var eval_score;
        	   var att_file_num;
        	   var rmk;

        	   if( evvu != null ) {
	        	   eval_score		= evvu.EVAL_SCORE;
	        	   //att_file_num		= evvu.ATT_FILE_NUM;
	        	   //rmk					= evvu.RMK;
	        	   if( eval_score != null && eval_score != -1 ) {              <%--  기 점수가 존재하면 점수를 세팅. --%>
	        		   EVF.getComponent("EVAL_SCORE").setValue(eval_score);
	        	   }
	        	   <%--
	        	   if( att_file_num != null && att_file_num != "" ) {               기 점수가 존재하면 점수를 세팅.
	        		   EVF.getComponent("ATT_FILE_NUM").setValue(att_file_num);
	        	   }
	        	   if( rmk != null && rmk != "" ) {               기 점수가 존재하면 점수를 세팅.
	        		   EVF.getComponent("RMK").setValue(rmk);
	        	   }
	        	    --%>
        	   }

        	   $.each(ev_type,function(key,type) {

            		var item_type 					= type.EV_ITEM_TYPE_CD;
            		var item_type_nm				= type.EV_ITEM_TYPE_NM;

            			html +="<tr>";
            			html +="		<td width='30px;'></td>";
            			html +="		<td colspan='98'><div class='e-window-container-header-bullet'></div>&nbsp;<span class='eval_item_category'>"+ item_type_nm  +"</span></td>";
            			html +="</tr>";

		        	   $.each(ev_subject,function(key,subject) {

	            		var item_type2 					= subject.EV_ITEM_TYPE_CD;
	            		var item_subject				= subject.EV_ITEM_SUBJECT;
	            		var item_contents			= subject.EV_ITEM_CONTENTS;
	            		var item_weight				= subject.WEIGHT;

	            		if( item_type == item_type2 ) { <%-- EV_ITEM_TYPE_CD 가 같을 경우에만 화면에 표시 --%>

	            			html +="<tr>";
	            			html +="		<td width='30px;'></td>";
	            			html +="		<td width='30px;'></td>";
	            			html +="		<td colspan='97'>";
	            			<%--
	            			//가중치 표시하지 않도록 수정 2015.11.10
	            			html +="		<div class='e-window-container-header-bullet'></div>&nbsp;<span class='eval_item_weight'>["+ item_weight  +"%]</span>";
	            			--%>
	            			html +="		&nbsp;&nbsp;&nbsp;&nbsp;";
	            			html +="		&nbsp;&nbsp;<span class='eval_item_subject'> "+ item_subject  +"</span>";
	            			html +="		&nbsp;&nbsp;<span class='eval_item_contents'> "+ item_contents  +"</span>";
	            			html +="		</td>";
	            			html +="</tr>";

	            			var item_cnt = 1;
	            			var m_type_cnt = 0;
	            			var str_checked = "";

	            			html +="<tr>";
	            			html +="		<td width='30px;'></td>";
	            			html +="		<td width='30px;'></td>";
	            			html +="		<td width='30px;'></td>";
            				html +="		<td colspan='96'>";
            				html +="		<table style='width:100%;' border='0'>";

            				$.each(ev_item,function(key,item) {
			            		var item_type3 					= item.EV_ITEM_TYPE_CD;
			            		var item_subject3				= item.EV_ITEM_SUBJECT;
			            		var item_contents3			= item.EV_ITEM_CONTENTS;
			            		var item_num					= item.EV_ITEM_NUM;
			            		var item_id_sq					= item.EV_ID_SQ;
			            		var item_id_contents		= item.EV_ID_CONTENTS;
			            		var item_id_score			= item.EV_ID_SCORE;
			            		var item_id_score2			= item.EV_ID_SCORE2;
			            		var scale_type					= item.SCALE_TYPE_CD;

			            		var item_id_sq2				= item.EV_ID_SQ2;
			            		var item_id_remark			= item.EV_REMARK;

			            		if( item_type2 == item_type3 && item_subject == item_subject3 ) {

		            				//if(item_cnt == 1) {
		            				//	html += "<tr>";
		            				//}

			            			if(scale_type == "A") { //선택형
			            				if( item_id_sq == item_id_sq2 ) {
			            					str_checked = "checked";
			            				}else{
			            					str_checked = "";
			            				}
				            			html +="	<tr>";
				            			html +="		<td width='5%'></td>";
				            			html +="		<td width='95%'><input type='radio' name='item_"+item_num+"' id_sq='"+item_id_sq+"' score='"+item_id_score+"' weight='"+item_weight+"' "+str_checked+" "+readOnly+">&nbsp;&nbsp;"+ item_id_contents+"</td>";
				            			html +="	</tr>";
			            			} else if(scale_type == "M") { //직접입력
				            			html +="	<tr>";
				            			html +="		<td width='5%'></td>";
				            			html +="		<td width='95%'>"+ item_id_contents+"&nbsp;:&nbsp;<input type='text' name='item_"+item_num+"' id_sq='"+item_id_sq+"' score='"+item_id_score+"' weight='"+item_weight+"' style='width:50px;text-align:right;' value='"+item_id_score2+"' maxLength='3' "+readOnly+">&nbsp;&nbsp;<span class='font-form' style='vertical-align:top;color:red;'>배점 ["+item_id_score+"]</span></td>";
				            			html +="	</tr>";
				            			html +="	<tr>";
				            			html +="		<td width='5%'></td>";
				            			html +="		<td width='95%'><span class='font-form' style='vertical-align:top;'>평가의견</span>&nbsp;:&nbsp;<input type='text' name='remark_"+item_num+"' style='width:80%;' value='"+item_id_remark+"' maxLength='1000' "+readOnly+"></td>";
				            			html +="	</tr>";
				            			m_type_cnt++;
			            			}

			            			//if( item_cnt > 1 && item_cnt % 2 == 0) {
			            			//	html += "</tr>";
			            			//}

			            			item_cnt++;

			            		}

			        	   });
            				html +="		</table>";
            				html +="		</td>";
	            			html +="</tr>";

	            		}

		        	   });

            			html += "<tr><td colspan='99'></td></tr>";
        		});

	            $("#item_body").append(html);

            }

        });



    }

    <%-- 저장 --%>
    function doSave() {


    	var totalScore  = 0;
    	var itemCount  = 0;
    	var chkCount  = 0;

    	var queryString = "";
    	var old_item_num = "";

    	var is_ok = true;

    	<%-- 평가의견 및 첨부파일이 없으면 저장 불가 --%>
    	var store = new EVF.Store();
    	if (!store.validate()) {
			return;
    	}
		/*
    	var rmk = EVF.C("RMK").getValue();
		var att =$(".plupload_total_file_size").text();
		var att2 =$(".plupload_file_size").text();
		var idx = att.indexOf("k");
		var idx2 = att2.indexOf("k");
		if( idx == -1 ) idx = att.indexOf("b");
		if( idx2 == -1 ) idx2 = att2.indexOf("b");
		att = att.substring(0,idx).trim();
		att2 = att2.substring(0,idx2).trim();
		if( att == "0" && att2 == "0") {
			alert("${SRM_196_0008}");
			 EVF.C("ATT_FILE_NUM").setFocus();
			return ;
		}
		if( rmk == null || rmk == "") {
			alert("${SRM_196_0007}");
			 EVF.C("RMK").setFocus();
			return ;
		}
		*/

        if (confirm("${msg.M8888}")) {

        	$("input[name*=item_]").each(function(){

   				var name 	= $(this).attr("name");
   				var weight 	= $(this).attr("weight");
   				var score 	= $(this).attr("score");
   				var id_sq 	= $(this).attr("id_sq");
   				var info 		= name.split("_");

   				if( $(this).attr("type") == "radio" ) { <%--선택형--%>

        			if( $(this).is(":checked") ) {

        				<%--/* var item_score =  everMath.round_float( parseFloat(score) * ( parseFloat(weight) / 100 ) , 2); // 항목점수 * 가중치(%) */--%>
        				var item_score =  score; // 항목점수

        				queryString += info[1];  //item_num
        				queryString += "@@";
        				queryString += id_sq;    //item_id_sq
        				queryString += "@@";
        				queryString += item_score; //id_score
        				queryString += "@@";
        				queryString += "_"; //평가의견
        				queryString += "##";

        				totalScore += parseFloat(item_score);

        				chkCount++;
        			}

	        		if( info[1] != old_item_num ) {
	        			itemCount++;
	        			old_item_num = info[1];
	        		}

        		} else if( $(this).attr("type") == "text" ) { <%--직접입력일 경우--%>

        				var item_score2 = $(this).val();

        				var item_remark =  $("input[name='remark_"+info[1]+"']").val();
    					if( item_remark == null || item_remark == "" ) item_remark = "_";

        				<%--/* var item_score =  everMath.round_float( parseFloat(item_score2) * ( parseFloat(weight) / 100 ) , 2); // 항목점수 * 가중치(%) */--%>
        				var item_score =  item_score2;// 항목점수
        				if( isNaN(item_score2) ) {
        					<%--alert('숫자만 입력가능 합니다.');--%>
        					alert('${SRM_196_0003}');
        					$(this).select();
        					$(this).focus();
        					is_ok = false;
        				}

        				if( parseFloat(item_score2) > 100 ) {
        					<%--alert('입력값이 100을 초과합니다. ');--%>
        					alert('${SRM_196_0004}');
        					$(this).focus();
        					is_ok = false;
        				}


        				queryString += info[1];  //item_num
        				queryString += "@@";
        				queryString += id_sq;    //item_id_sq
        				queryString += "@@";
        				queryString += item_score2; //직접입력은 계산시에만 가중치적용(?) 재 조회시 원래 입력값 표시(?)
        				queryString += "@@";
        				queryString += item_remark; //평가의견
        				queryString += "##";

        				totalScore += parseFloat(item_score);

        				chkCount++;

	        		if( info[1] != old_item_num ) {
	        			itemCount++;
	        			old_item_num = info[1];
	        		}
        		}



        	});

        	//alert(itemCount +":"+chkCount);
        	queryString = queryString.substring(0, queryString.length-2);<%-- 끝부분 ## 제거 --%>

        	if( itemCount != chkCount ) {
        		<%--alert("누락된 항목이 존재합니다."); --%>
				alert('${SRM_196_0006}');
        		return;
        	}

        	if( parseFloat(totalScore) > 100 ) {
        		<%--alert('총점은  100점을 초과할 수 없습니다. ');--%>
				alert('${SRM_196_0005} ['+totalScore+']');
				$(this).focus();
				is_ok = false;
			}

        	if( !is_ok ) {
        		return;
        	}

        	EVF.getComponent("QUERY_STR").setValue(queryString);
        	EVF.getComponent("EVAL_SCORE").setValue(totalScore);


			store.doFileUpload(function() {
		            store.load(baseUrl + 'SRM_196/doSave', function() {
		            	alert(this.getResponseMessage());

		            	if (opener) {
							opener.doSearch();
						} else if (parent.doSearch != undefined) {
							parent.doSearch();
						}
		            	doSearch();
		            });
			});

        }

    }

    <%-- 닫기 --%>
     function doClose() {

			self.close();

    }

    $(function(){
    	<%-- div_sub 높이 자동 세팅 --%>
    	$(window).resize( function(){
    		$.fn.div_resize();
    	});
    	<%-- 조회조건 접거나 펼칠때 평가항목 div 높이 조절 --%>
    	$(".e-panel-button").click(function(){
    		$.fn.div_resize();
    	});

    	$.fn.div_resize = function() {
    		var form_class = $("table[id='form']").attr("class");
    		var winHeight = $(window).height();
    		if( form_class.indexOf("e-panel-collapsed") != -1 ) {
    		 	diff = winHeight - 90;
    			//var subHeight = $("#div_sub").height();
    			$("#div_sub").height(diff);
    		} else {
    		 	diff = winHeight - 380;
	    		$("#div_sub").height(diff);
    		}
    	};

    });

    </script>
    <e:window id="SRM_195" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="General Information" columnCount="2" labelWidth="${labelWidth }" onEnter="doSearch">
        	<e:row>
                <%--협력회사명--%>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
				<e:inputText id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="${form.VENDOR_CD}" width="${inputTextWidth}" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}"/>

				<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
				</e:field>

                <%--평가번호--%>
                <e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
				<e:field>
				<e:inputText id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="${form.EV_NUM}" width="${inputTextWidth}" maxLength="${form_EV_NUM_M}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}"/>
				<e:inputHidden id="EV_TPL_NUM" name="EV_TPL_NUM" value="${form.EV_TPL_NUM }"/>
				</e:field>

			</e:row>
            <e:row>
                <%--평가자명--%>
                <e:label for="EV_USER_NM" title="${form_EV_USER_NM_N}"/>
				<e:field>
				<e:inputText id="EV_USER_NM" style="${imeMode}" name="EV_USER_NM" value="${form.EV_USER_NM}" width="${inputTextWidth}" maxLength="${form_EV_USER_NM_M}" disabled="${form_EV_USER_NM_D}" readOnly="${form_EV_USER_NM_RO}" required="${form_EV_USER_NM_R}"/>
				<e:inputHidden id="EV_USER_ID" name="EV_USER_ID" value="${form.EV_USER_ID }"/>
				</e:field>

                <%--평가점수--%>
                <e:label for="EVAL_SCORE" title="${form_EVAL_SCORE_N}"/>
				<e:field>
				<e:inputNumber id="EVAL_SCORE" name="EVAL_SCORE" value="${form.EVAL_SCORE}"  width="${inputTextWidth}" maxValue="${form_EVAL_SCORE_M}" decimalPlace="${form_EVAL_SCORE_NF}" disabled="${form_EVAL_SCORE_D}" readOnly="${form_EVAL_SCORE_RO}" required="${form_EVAL_SCORE_R}" />
				<e:inputHidden id="QUERY_STR" name="QUERY_STR" value=""/>
				</e:field>
            </e:row>
            <e:row>
                <%--첨부파일--%>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
				<e:field colSpan="3">
				<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView ? true : false}"  fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="EV" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="${form_ATT_FILE_NUM_R}" />				</e:field>
            </e:row>
            <e:row>
                <%--평가의견--%>
            	<e:label for="RMK" title="${form_RMK_N}"/>
				<e:field colSpan="3">
				<e:textArea id="RMK" style="ime-mode:auto" name="RMK" height="100px" value="${form.RMK}" width="100%" maxLength="${form_RMK_M}" disabled="${form_RMK_D}" readOnly="${form_RMK_RO}" required="${form_RMK_R}" />
				</e:field>
            </e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>




		<div id="div_man" style="width:100%;" >
			<div id="div_sub" style="width:100%;height:340px;overflow-x:hidden;overflow-y:auto;">
			<table id="tb_item" style="width:100%;" class="font-form">
				<tbody id="item_body"></tbody>
			</table>
			</div>
		</div>

	</e:window>
</e:ui>