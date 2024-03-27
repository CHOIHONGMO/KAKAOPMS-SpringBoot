<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<style type="text/css">
		.eval_item_category {font-weight:bold; color:blue;}
		.eval_item_weight 	{font-weight:bold; color:red;}
		.eval_item_subject 	{font-weight:bold; color:blue;}
		.eval_item_contents {font-weight:bold;}
	</style>
    <script type="text/javascript">

    var baseUrl = '/eversrm/srm/execEval/eval/SRM_250';
    var leftgrid;
    var selRow;
    var readOnly = "";

	var formValue = '${form2}';
	formValue = JSON.parse(formValue);

    function init() {

        leftgrid = EVF.C('leftgrid');
        leftgrid.setProperty('shrinkToFit', true);
        leftgrid.setProperty('multiselect', false);
        <%--EVF.C('doSave') .setVisible(false); --%><%-- 셀클릭시 보여짐, 첫로드시와 조회시 숨김 --%>
        EVF.C('RMK')	.setDisabled(true);
    	<%-- 조회용 화면 호출시 --%>
    	if( '${param.detailView}' == 'true' || '${leftform.detailView}' == 'true') {
    		readOnly = "disabled";
    		doSearch();

			EVF.C('doSearch')		.setVisible(false);
			EVF.C('doSave')			.setVisible(false);
			EVF.C('DETAIL_VIEW')	.setValue('true');
			EVF.C('REG_STATUS_L')	.setDisabled(true);
			EVF.C('VENDOR_NM_L')	.setDisabled(true);
			EVF.C('EV_USER_NM_L')	.setDisabled(true);
			EVF.C('ATT_FILE_NUM')	.setReadOnly(true);
    	} else{
    		doSearch();
    		readOnly = "";
			EVF.C('doSearch').setVisible(true);
			EVF.C('DETAIL_VIEW').setValue('false');
    	}
        leftgrid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
            if(colId == 'REG_STATUS'){
				EVF.C('EV_USER_NM_R').setValue(leftgrid.getCellValue(rowId, "EV_USER"));
				EVF.C('EV_USER_ID')	 .setValue(leftgrid.getCellValue(rowId, "EV_USER_ID"));
				EVF.C('VENDOR_NM_R') .setValue(leftgrid.getCellValue(rowId, "VENDOR_NM"));
				EVF.C('VENDOR_CD')   .setValue(leftgrid.getCellValue(rowId, "VENDOR_CD"));
				EVF.C('EV_SCORE_R')  .setValue(leftgrid.getCellValue(rowId, "EV_SCORE"));
				EVF.C('EV_TPL_NUM')  .setValue(leftgrid.getCellValue(rowId, "EV_TPL_NUM"));
				EVF.C('SEL_ROW')	 .setValue(rowId);
				doSelectRight();

            }
        });

        leftgrid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
        	switch(colId) {
            case '':

            default:
            }
        });

        leftgrid.excelExportEvent({
			allCol : 	"${excelExport.allCol}",
			selRow :	"${excelExport.selRow}",
			fileType :	"${excelExport.fileType }",
			fileName :	"${screenName }",
		    excelOptions : {
				 imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }

		});
    	if( "${gbn}" == "right" ) {
    		if( "${leftform.detailView}" == "true" ){
	    		EVF.getComponent('doSave').setVisible(false);
	    		EVF.getComponent('RMK')	  .setDisabled(true);
	    		EVF.C('ATT_FILE_NUM')	  .setReadOnly(true);
    		}else{
    			<%--if(EVF.C("EV_USER_ID").getValue() == "${ses.userId}"){EVF.getComponent('doSave').setVisible(true);}--%>
    			var formValue = '${form2}';
    	    	formValue = JSON.parse(formValue);
    			if(formValue.ev_type != null && formValue.ev_type != ""){
    				EVF.getComponent('doSave').setVisible(true);
    			}else{
    				EVF.getComponent('doSave').setVisible(false);
    			}
    			EVF.getComponent('RMK')	  .setDisabled(false);
    			EVF.C('ATT_FILE_NUM')	  .setReadOnly(false);
    		}
    		drawingTable();
    	}else{
    		EVF.getComponent('doSave').setVisible(false);
    	}

    }
    function btnSearch(){ <%-- 조회버튼 클릭 --%>
    	<%--EVF.getComponent('doSave').setVisible(false); --%><%-- 셀클릭시 보여짐, 첫로드시와 조회시 숨김 --%>
    	EVF.getComponent('doSave').setVisible(false);
    	$('#file_container_ATT_FILE_NUM_filelist').remove();
    	$('#div_man').remove();
    	EVF.C("EV_USER_NM_R")	.setValue("");
    	EVF.C("VENDOR_NM_R")	.setValue("");
    	EVF.C("EV_SCORE_R")		.setValue("");
    	EVF.C("RMK")			.setValue("");
    	EVF.C('RMK')	  		.setDisabled(true);
    	doSearch();
    }


    function doSearch() { <%-- 그리드만 조회 --%>
        var store = new EVF.Store();
        store.setGrid([leftgrid]);
        store.load(baseUrl + '/doSearch', function() {
            if(leftgrid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            } else {
            	leftgrid.checkRow(parseFloat("${leftform.SEL_ROW}"),true);
				EVF.C('EV_SCORE_R').setValue(leftgrid.getCellValue('${leftform.SEL_ROW}', 'EV_SCORE'));
            }
        });
    }

    <%-- 항목부분 크기 자동변경 --%>
    $(window).resize( function(){
    	var docHeight =  $(window).height();
   		var docWidth  =  $(window).width();
   		var pnlHeight = $("#rightTopPanel").height();
   		var pnlWidth  = $("#rightTopPanel").width();

   		$("#div_sub").css("height", Number(docHeight) - Number(pnlHeight) - 40);
   		$("#div_sub").css("width", docWidth*0.49);
    }).resize();

    <%-- 항목그리기 --%>
    function drawingTable(){

    	<%--테이블 영역 크기조절 --%>
    	var docHeight =  $(window).height();
   		var docWidth  =  $(window).width();
   		var pnlHeight =  $("#rightTopPanel").height();
   		var pnlWidth  =  $("#rightTopPanel").width();
   		$("#div_sub").css("height", Number(docHeight) - Number(pnlHeight) - 40);
   		$("#div_sub").css("width", docWidth*0.49);

    	if( formValue != null  ) {

    		$("#item_body tr").remove();
    		var html		= "";
            if(formValue.ev_type == "" || formValue.ev_type == null){alert('${SRM_250_noItem}');}
			var ev_type 	= formValue.ev_type;		<%--평가구분--%>
			var ev_subject	= formValue.ev_subject;     <%--평가제목--%>
			var ev_item 	= formValue.ev_item;        <%--평가항목--%>

			var eveu 		= formValue.eveu;

			var ev_score;
			var att_file_num;
			var rmk;

			if( eveu != null ) {
				ev_score		= eveu.EV_SCORE;
				if( ev_score != null && ev_score != -1 ) {              <%--  기 점수가 존재하면 점수를 세팅. --%>
					EVF.getComponent("EV_SCORE").setValue(ev_score);
				}
			}

			$.each(ev_type,function(key,type) {

        		var item_type 					= type.EV_ITEM_TYPE_CD;
        		var item_type_nm				= type.EV_ITEM_TYPE_NM;

        			html +="<tr>";
        			html +="	<td colspan='98'><div class='e-window-container-header-bullet'></div>&nbsp;<span class='eval_item_category'>"+ item_type_nm  +"</span></td>";
        			html +="</tr>";

	        	   $.each(ev_subject,function(key,subject) {

            		var item_type2 					= subject.EV_ITEM_TYPE_CD;
            		var item_subject				= subject.EV_ITEM_SUBJECT;
            		var item_contents				= subject.EV_ITEM_CONTENTS;
            		var item_weight					= subject.WEIGHT;

            		if( item_type == item_type2 ) { <%-- EV_ITEM_TYPE_CD 가 같을 경우에만 화면에 표시 --%>

            			html +="<tr>";
            			html +="		<td width='10px;'></td>";
            			html +="		<td colspan='97'>";
            			<%-- 가중치 삭제
            			html +="		<div class='e-window-container-header-bullet'></div>&nbsp;<span class='eval_item_weight'>["+ item_weight  +"%]</span>";
            			--%>
            			html +="		<span class='eval_item_subject'> " + item_subject   +"</span>";
            			html +="		<span class='eval_item_contents'> "+ item_contents  +"</span>";
            			html +="		</td>";
            			html +="</tr>";

            			var item_cnt = 1;
            			var m_type_cnt = 0;
            			var str_checked = "";

            			html +="<tr>";
            			html +="		<td width='10px;'></td>";
            			html +="		<td width='10px;'></td>";
        				html +="		<td colspan='96'>";
        				html +="		<table style='width:100%;' border='0'>";

        				$.each(ev_item,function(key,item) {
		            		var item_type3 				= item.EV_ITEM_TYPE_CD;
		            		var item_subject3				= item.EV_ITEM_SUBJECT;
		            		var item_contents3			= item.EV_ITEM_CONTENTS;
		            		var item_num					= item.EV_ITEM_NUM;
		            		var item_id_sq					= item.EV_ID_SQ;
		            		var item_id_contents		= item.EV_ID_CONTENTS;
		            		var item_id_score				= item.EV_ID_SCORE;
		            		var item_id_score2				= item.EV_ID_SCORE2;
		            		var scale_type					= item.SCALE_TYPE_CD;

		            		var item_id_sq2				= item.EV_ID_SQ2;
		            		var item_id_remark			= item.EV_REMARK;

		            		if( item_type2 == item_type3 && item_subject == item_subject3 ) {

		            			if(scale_type == "A") { <%--선택형--%>
		            				if( item_id_sq == item_id_sq2 ) {
		            					str_checked = "checked";
		            				}else{
		            					str_checked = "";
		            				}
			            			html +="	<tr>";
			            			html +="		<td width='95%'><input type='radio' name='item_"+item_num+"' id_sq='"+item_id_sq+"' score='"+item_id_score+"' weight='"+item_weight+"' "+str_checked+" "+readOnly+">&nbsp;&nbsp;"+ item_id_contents+"</td>";
			            			html +="	</tr>";
		            			} else if(scale_type == "M") { <%--직접입력--%>
			            			html +="	<tr>";
			            			html +="		<td width='95%'>";
			            			html +="		"+ item_id_contents+"&nbsp;:&nbsp;<input type='text' name='item_"+item_num+"' id_sq='"+item_id_sq+"' score='"+item_id_score+"' weight='"+item_weight+"' style='width:50px;text-align:right;' value='"+item_id_score2+"' maxLength='3' "+readOnly+"> &nbsp;&nbsp;<span class='font-form' style='vertical-align:top;color:red;'>배점 ["+item_id_score+"]</span>";
			            			html +="		</td>";
			            			html +="	</tr>";
			            			html +="	<tr>";
			            			html +="		<td width='95%'>";
			            			html +="		<span class='font-form' style='vertical-align:top;'>평가의견</span>&nbsp;:&nbsp;<input type='text' name='remark_"+item_num+"' style='width:80%;' value='"+item_id_remark+"' maxLength='1000' "+readOnly+">";
			            			html +="		</td>";
			            			html +="	</tr>";
			            			m_type_cnt++;
		            			}

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
    }

    <%-- 셀클릭 --%>
    function doSelectRight(){
    	location.href = baseUrl+"/view.so?gbn=doSearchRight&"+$("input").serialize();
    	var store = new EVF.Store();
    }

    <%-- 저장 --%>
    function doSave() {

		var totalScore   = 0;
		var itemCount    = 0;
		var chkCount     = 0;

		var queryString  = "";
		var old_item_num = "";

		var is_ok		 = true;

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
			alert("${SRM_250_emptyAttach}");
			 EVF.C("ATT_FILE_NUM").setFocus();
			return ;
		}
		if( rmk == null || rmk == "") {
			alert("${SRM_250_emptyRemark}");
			 EVF.C("RMK").setFocus();
			return ;
		}
		*/


		if(confirm("${msg.M8888}")){

			$("input[name*=item_]").each(function(){
				var name 	= $(this).attr("name");
				var weight 	= $(this).attr("weight");
				var score 	= $(this).attr("score");
				var id_sq 	= $(this).attr("id_sq");
				var info 	= name.split("_");

				if($(this).attr("type") == "radio") {<%-- 선택형 --%>
					if($(this).is(":checked")){
						<%-- var item_score =  everMath.round_float( parseFloat(score) * ( parseFloat(weight) / 100 ) , 2); // 항목점수 * 가중치(%) --%>
						var item_score =  score; <%-- 항목점수 --%>
						queryString += info[1]; <%--item_num--%>
						queryString += "@@";
						queryString += id_sq;	<%--item_id_sq--%>
						queryString += "@@";
						queryString += item_score; <%--id_score--%>
						queryString += "@@";
						queryString += "_"; <%--평가의견--%>
						queryString += "##";
						totalScore  += parseFloat(item_score);

						chkCount++;
					}

					if( info[1] != old_item_num){
						itemCount++;
						old_item_num = info[1];
					}

				} else if( $(this).attr("type") == "text" ){ <%-- 직접입력일 경우 --%>
					var item_score2 = $(this).val();
					var item_id_score = $(this).attr("score");
					var item_remark =  $("input[name='remark_"+info[1]+"']").val();
					if( item_remark == null || item_remark == "" ) item_remark = "_";
					<%-- var item_score =  everMath.round_float( parseFloat(item_score2) * ( parseFloat(weight) / 100 ) , 2); // 항목점수 * 가중치(%) --%>
					var item_score =  item_score2;<%-- 항목점수 --%>
					if( isNaN(item_score2)){
						alert('${SRM_250_onlyNumber}');
						$(this).select();
						$(this).focus();
						is_ok = false;
					}
					if(parseFloat(item_score2) > parseFloat(item_id_score)){
						alert(item_id_score+'${SRM_250_item_id_score}');
						$(this).focus();
						is_ok = false;
					}
					queryString += info[1]; <%--item_num--%>
					queryString += "@@";
					queryString += id_sq; 	<%--item_id_sq--%>
					queryString += "@@";
					queryString += item_score2; <%--직접입력 항목점수--%>
					queryString += "@@";
					queryString += item_remark; <%--평가의견--%>
					queryString += "##";
					totalScore  += parseFloat(item_score);

					chkCount++;

					if(info[1] != old_item_num){
						itemCount++;
						old_item_num = info[1];
					}
				}
			});

			queryString = queryString.substring(0, queryString.length-2); <%-- 끝부분 ## 제거 --%>

			if( itemCount != chkCount ){
				alert('${SRM_250_emptyGrid}');
				return;
			}

			if(${not rightform.OVER_100_FLAG eq '1'} && parseFloat(totalScore) > 100 && is_ok;) {
				alert('${SRM_250_overHundred} '+totalScore);
				$(this).focus();
				is_ok = false;
			}
			if(!is_ok){
				return;
			}

			EVF.getComponent("QUERY_STR") .setValue(queryString);
			EVF.getComponent("TOTAL_SCORE").setValue(totalScore);
//			EVF.getComponent("EV_SCORE_R").setValue(totalScore);

			store.doFileUpload(function(){
				store.load(baseUrl + '/doSave', function(){
					alert(this.getResponseMessage());
					doSearch();
				});
			});

		}

    }

    <%-- 닫기 --%>
    function doClose(){
    	opener.doSearch();
    	self.close();
    }

    $(window).on('beforeunload', function() {
    	opener.doSearch();
    });

		function checkFirstRadio() {
			$('table tr td input[type=radio]').removeProp('checked');
			$('table tr:first-child td input[type=radio]').prop('checked', 'checked');
		}

		function checkLastRadio() {
			$('table tr td input[type=radio]').removeProp('checked');
			$('table tr:last-child td input[type=radio]').prop('checked', 'checked');
		}

    </script>
<e:window id="SRM_250" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" >

	<e:inputHidden id="TOTAL_SCORE" name="TOTAL_SCORE" value="${rightform.EV_SCORE_R}" />

	<e:panel width="49%" height="100%">
		<e:searchPanel id="leftform" title="${msg.M9999}" columnCount="2" labelWidth="${labelWidth}" onEnter="btnSearch">
		    <e:row>
		    <%-- 평가번호 --%>
		    <e:label for="EV_NUM_L" title="${leftform_EV_NUM_L_N}"/>
			<e:field>
			<e:inputText id="EV_NUM_L" style="ime-mode:inactive" name="EV_NUM_L" value="${leftform.EV_NUM_L}" width="99%" maxLength="${leftform_EV_NUM_L_M}" disabled="${leftform_EV_NUM_L_D}" readOnly="${leftform_EV_NUM_L_RO}" required="${leftform_EV_NUM_L_R}"/>
			</e:field>
			<e:inputHidden id="EV_TPL_NUM" name="EV_TPL_NUM" value="${leftform.EV_TPL_NUM}"/>
			<e:inputHidden id="SEL_ROW" name="SEL_ROW" value="${leftform.SEL_ROW}"/>
			<e:inputHidden id="DETAIL_VIEW" name="DETAIL_VIEW" value="${leftform.DETAIL_VIEW}"/>
		    <%-- 등록여부 --%>
			<e:label for="REG_STATUS_L" title="${leftform_REG_STATUS_L_N}"/>
			<e:field>
			<e:select id="REG_STATUS_L" name="REG_STATUS_L" value="${leftform.REG_STATUS_L}" options="${regStatusLOptions}" width="99%" disabled="${leftform_REG_STATUS_L_D}" readOnly="${leftform_REG_STATUS_L_RO}" required="${leftform_REG_STATUS_L_R}" placeHolder="" />
			</e:field>
		    </e:row>
	        <e:row>
	        <%-- 협력회사명 --%>
	        <e:label for="VENDOR_NM_L" title="${leftform_VENDOR_NM_L_N}"/>
			<e:field>
			<e:inputText id="VENDOR_NM_L" style="${imeMode}" name="VENDOR_NM_L" value="${leftform.VENDOR_NM_L}" width="99%" maxLength="${leftform_VENDOR_NM_L_M}" disabled="${leftform_VENDOR_NM_L_D}" readOnly="${leftform_VENDOR_NM_L_RO}" required="${leftform_VENDOR_NM_L_R}"/>
			</e:field>
	        <%-- 평가자 --%>
			<e:label for="EV_USER_NM_L" title="${leftform_EV_USER_NM_L_N}"/>
			<e:field>
			<e:select id="EV_USER_NM_L" name="EV_USER_NM_L" value="${leftform.EV_USER_NM_L}" options="${evUserNmLOptions}" width="99%" disabled="${leftform_EV_USER_NM_L_D}" readOnly="${leftform_EV_USER_NM_L_RO}" required="${leftform_EV_USER_NM_L_R}" placeHolder="" />
			</e:field>
		    </e:row>
	    </e:searchPanel>

	    <e:buttonBar align="right">
	    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="btnSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
	    </e:buttonBar>

	    <%-- 그리드 창 켜줌 --%>
	    <e:gridPanel gridType="${_gridType}" id="leftgrid" name="leftgrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.leftgrid.gridColData}" />
	</e:panel>
	<e:panel width="1%" height="100%">
		&nbsp;
	</e:panel>

	<%-- -----------------------------[ RIGHT GRID ]----------------------------------- --%>
	<e:panel width="50%" height="100%">
		<div id="rightTopPanel" style="padding:0;margin:0;">
		<e:searchPanel id="rightform" title="${rightform_RIGHT_TITLE_N}" columnCount="2" labelWidth="${labelWidth}" onEnter="btnSearch" useTitleBar="true">
		    <e:row>
			    <%-- 평가자명 --%>
			    <e:label for="EV_USER_NM_R" title="${rightform_EV_USER_NM_R_N}"/>
				<e:field>
				<e:inputText id="EV_USER_NM_R" style="${imeMode}" name="EV_USER_NM_R" value="${rightform.EV_USER_NM_R}" width="99%" maxLength="${rightform_EV_USER_NM_R_M}" disabled="${rightform_EV_USER_NM_R_D}" readOnly="${rightform_EV_USER_NM_R_RO}" required="${rightform_EV_USER_NM_R_R}"/>
				<e:inputHidden id="EV_USER_ID" name="EV_USER_ID" value="${rightform.EV_USER_ID}"/>
				</e:field>
			    <%-- 협력회사명 --%>
				<e:label for="VENDOR_NM_R" title="${rightform_VENDOR_NM_R_N}"/>
				<e:field>
				<e:inputText id="VENDOR_NM_R" style="${imeMode}" name="VENDOR_NM_R" value="${rightform.VENDOR_NM_R}" width="99%" maxLength="${rightform_VENDOR_NM_R_M}" disabled="${rightform_VENDOR_NM_R_D}" readOnly="${rightform_VENDOR_NM_R_RO}" required="${rightform_VENDOR_NM_R_R}"/>
				<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${rightform.VENDOR_CD}"/>
				</e:field>
		    </e:row>
		    <e:row>
				<%-- 점수 --%>
				<e:label for="EV_SCORE_R" title="${rightform_EV_SCORE_R_N}"/>
				<e:field colSpan="3">
				<e:inputNumber id="EV_SCORE_R" name="EV_SCORE_R" value="${rightform.EV_SCORE_R}" width="31%" maxValue="${rightform_EV_SCORE_R_M}" decimalPlace="${rightform_EV_SCORE_R_NF}" disabled="${rightform_EV_SCORE_R_D}" readOnly="${rightform_EV_SCORE_R_RO}" required="${rightform_EV_SCORE_R_R}" />
				<e:inputHidden id="QUERY_STR" name="QUERY_STR" value=""/>
				</e:field>
		    </e:row>
		    <e:row>
			    <%-- 첨부파일 --%>
			    <e:label for="ATT_FILE_NUM" title="${rightform_ATT_FILE_NUM_N}"/>
				<e:field colSpan="3">
				<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${rightform.ATT_FILE_NUM}" readOnly="" downloadable="true" width="100%" bizType="EV" height="120px" required="${rightform_ATT_FILE_NUM_R}" />
				</e:field>
		    </e:row>
		    <e:row>
		    	<%-- 평가의견 --%>
		    	<e:label for="RMK" title="${rightform_RMK_N}"/>
				<e:field colSpan="3">
				<e:textArea id="RMK" style="ime-mode:inactive" name="RMK" height="50px" value="${rightform.RMK}" width="100%" maxLength="${rightform_RMK_M}" disabled="${rightform_RMK_D}" readOnly="${rightform_RMK_RO}" required="${rightform_RMK_R}" />
				</e:field>
		    </e:row>
	    </e:searchPanel>

	    <e:buttonBar align="right">
	    	<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
	    	<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
	    </e:buttonBar>
	    <hr>
	    </div>
	    <e:panel>
			<%--<c:if test="${developFlag eq 'true'}">--%>
				<%--<span style="font-size: 11px;">--%>
					<%--개발모드 테스트(라디오버튼 체크):--%>
					<%--<a href="#" onclick="javascript:checkFirstRadio();" title="eversrm.system.developmentFlag=true일 때만 노출되는 테스트용 버튼입니다.">[첫번째만 체크]</a>--%>
					<%--<a href="#" onclick="javascript:checkLastRadio();" title="eversrm.system.developmentFlag=true일 때만 노출되는 테스트용 버튼입니다.">[마지막만 체크]</a>--%>
				<%--</span>--%>
			<%--</c:if>--%>
	    	<div id="div_man" style="width:100%;" >
				<div id="div_sub" style="width:100%;height:380px;overflow-x:hidden;overflow-y:auto;">
				<table id="tb_item" style="width:100%;" class="font-form">
					<tbody id="item_body"></tbody>
				</table>
				</div>
			</div>
	    </e:panel>
	</e:panel>


</e:window>
</e:ui>
