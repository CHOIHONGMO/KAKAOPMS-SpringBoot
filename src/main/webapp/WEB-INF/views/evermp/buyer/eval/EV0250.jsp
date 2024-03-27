<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
	<link href="/css/kakao/ui2/sub.css" rel="stylesheet">

	<script type="text/javascript">

		var baseUrl = '/evermp/buyer/eval/EV0250';
		var leftgrid;
		var selRow;
		var readOnly = "";

		var formValue = '${form2}';

		if(formValue != "") {
			formValue = JSON.parse(formValue);
		}

		function init() {
			
			// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
			if('${param.detailView}' == 'true') {
				$('#upload-button-BUYER_ATT_FILE_NUM').css('display','none');
				$('#upload-button-ATT_FILE_NUM').css('display','none');
			}
			
			leftgrid = EVF.C('leftgrid');
			leftgrid.setProperty('shrinkToFit', true);
			leftgrid.setProperty('multiselect', false);

			EVF.C('VENDOR_NM_R').setDisabled(false);
			$('#VENDOR_NM_R').css('color','#eb6220');

			<%--EVF.C('doSave') .setVisible(false); --%><%-- 셀클릭시 보여짐, 첫로드시와 조회시 숨김 --%>
			EVF.C('RMK').setDisabled(true);
			<%-- 조회용 화면 호출시 --%>
			if( '${param.detailView}' == 'true' || '${leftform.detailView}' == 'true') {
				readOnly = "disabled";
				doSearch();

				EVF.C('doSearch')		.setVisible(false);
				EVF.C('doSave')			.setVisible(false);
				EVF.C('DETAIL_VIEW')	.setValue('true');
				EVF.C('REG_STATUS_L')	.setDisabled(true);
//				EVF.C('VENDOR_NM_L')	.setDisabled(true);
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
					EVF.V('EV_USER_NM_R', leftgrid.getCellValue(rowId, "EV_USER"));
					EVF.V('EV_USER_ID',	  leftgrid.getCellValue(rowId, "EV_USER_ID"));
					EVF.V('VENDOR_NM_R',  leftgrid.getCellValue(rowId, "VENDOR_NM"));
					EVF.V('VENDOR_CD',    leftgrid.getCellValue(rowId, "VENDOR_CD"));
					EVF.V("VENDOR_SQ",    leftgrid.getCellValue(rowId, "VENDOR_SQ"));
					EVF.V('EV_SCORE_R',   leftgrid.getCellValue(rowId, "EV_SCORE"));
					EVF.V('EV_TPL_NUM',   leftgrid.getCellValue(rowId, "EV_TPL_NUM"));
					EVF.V('ESG_CHK_TYPE',   leftgrid.getCellValue(rowId, "ESG_CHK_TYPE"));
					EVF.V('ESG_CHK_TYPE2',   leftgrid.getCellValue(rowId, "ESG_CHK_TYPE"));
					EVF.V('SEL_ROW',	  rowId);



					doSelectRight();
				}else if(colId === 'QTA_NUM' && value !== '') {
					var param = {
						QTA_NUM: leftgrid.getCellValue(rowId, 'QTA_NUM')
						, QTA_CNT: leftgrid.getCellValue(rowId, 'QTA_CNT')
						, popupFlag: true
						, detailView: true
					};
					everPopup.openPopupByScreenId('BQ0320', 1200, 900, param);
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
					EVF.C('doSave').setVisible(false);
					EVF.C('RMK').setDisabled(true);
					EVF.C('ATT_FILE_NUM').setReadOnly(true);
				}else{
					<%--if(EVF.C("EV_USER_ID").getValue() == "${ses.userId}"){EVF.C('doSave').setVisible(true);}--%>
					var formValue = '${form2}';
					formValue = JSON.parse(formValue);
					if(formValue.ev_type != null && formValue.ev_type != ""){
						EVF.C('doSave').setVisible(true);

					}else{
						EVF.C('doSave').setVisible(false);
					}

					EVF.C('RMK').setDisabled(false);
					EVF.C('ATT_FILE_NUM').setReadOnly(false);
				}
				drawingTable();
			}else{
				EVF.C('doSave').setVisible(false);
				$('#div_man').remove();
			}

			<c:if test="${ses.userType == 'S'.toString() }">
				$('#leftP').css('width','0');
				$('#rightP').css('width','98%');
			</c:if>


			if(EVF.V('EV_TYPE') !== 'R'){
				leftgrid.hideCol('QTA_NUM',true);
				leftgrid.hideCol('OPNP',true);
			}

		}

		function btnSearch(){ <%-- 조회버튼 클릭 --%>
			<%--EVF.C('doSave').setVisible(false); --%><%-- 셀클릭시 보여짐, 첫로드시와 조회시 숨김 --%>
			EVF.C('doSave').setVisible(false);
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
					EVF.alert("${msg.M0002 }");
				} else {
					leftgrid.checkRow(parseFloat("${leftform.SEL_ROW}"),true);
					EVF.C('EV_SCORE_R').setValue(leftgrid.getCellValue('${leftform.SEL_ROW}', 'EV_SCORE'));


					<c:if test="${param.gbn != 'doSearchRight' }">
						EVF.V('EV_USER_NM_R', leftgrid.getCellValue(0, "EV_USER"));
						EVF.V('EV_USER_ID',	  leftgrid.getCellValue(0, "EV_USER_ID"));
						EVF.V('VENDOR_NM_R',  leftgrid.getCellValue(0, "VENDOR_NM"));
						EVF.V('VENDOR_CD',    leftgrid.getCellValue(0, "VENDOR_CD"));
						EVF.V("VENDOR_SQ",    leftgrid.getCellValue(0, "VENDOR_SQ"));
						EVF.V('EV_SCORE_R',   leftgrid.getCellValue(0, "EV_SCORE"));
						EVF.V('EV_TPL_NUM',   leftgrid.getCellValue(0, "EV_TPL_NUM"));
						EVF.V('SEL_ROW',	  0);
						doSelectRight();
					</c:if>

					if(EVF.V('EV_USER_NM_L') !== ''){
						var leftgridData = leftgrid.getAllRowValue();
						for(var i in leftgridData){
							if(leftgridData[i].VENDOR_CD === EVF.V('VENDOR_CD')){
								leftgrid.setRowBgColor(i,'#F9C3B8');
							}
						}
					}else{
						var leftgridData = leftgrid.getAllRowValue();
						for(var i in leftgridData){
							if(leftgridData[i].EV_USER_ID === EVF.V('EV_USER_ID')){
								leftgrid.setRowBgColor(i,'#F9C3B8');
							}
						}
					}

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
				$("#item_div div").remove();
				// $("#item_body tr").remove();

				var html		= "";
				if(formValue.ev_type == "" || formValue.ev_type == null){alert('${EV0250_noItem}');}
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
						EVF.C("EV_SCORE").setValue(ev_score);
					}
				}

				$("#top_title").text(ev_item[0].EV_TPL_SUBJECT);

				$.each(ev_type,function(key,type) {

					var item_type 					= type.EV_ITEM_TYPE_CD;
					var item_type_nm				= type.EV_ITEM_TYPE_NM;
					html += "<div class=\"sub-title\">"+ item_type_nm + "</div>";
					html += "<div class=\"wrap_bg\">";

					$.each(ev_subject,function(key,subject) {
						var item_type2 					= subject.EV_ITEM_TYPE_CD;
						var item_subject				= subject.EV_ITEM_SUBJECT;
						var item_contents				= subject.EV_ITEM_CONTENTS;
						var item_weight					= subject.WEIGHT;

						var rownum = subject.ROWNUMX;

						if( item_type == item_type2 ) { <%-- EV_ITEM_TYPE_CD 가 같을 경우에만 화면에 표시 --%>
							var item_cnt = 1;
							var m_type_cnt = 0;
							var str_checked = "";
							var div_check = false;
							var old_item_num = "";
							var rmkInputYn = false;

							html +="";

							$.each(ev_item,function(key,item) {
								var item_type3 				= item.EV_ITEM_TYPE_CD;
								var item_subject3			= item.EV_ITEM_SUBJECT;
								var item_contents3			= item.EV_ITEM_CONTENTS;
								var item_num				= item.EV_ITEM_NUM;
								var item_id_sq				= item.EV_ID_SQ;
								var item_id_contents		= item.EV_ID_CONTENTS;
								var item_id_score			= item.EV_ID_SCORE;
								var item_id_score2			= item.EV_ID_SCORE2;
								var scale_type				= item.SCALE_TYPE_CD;

								var item_id_sq2				= item.EV_ID_SQ2;
								var item_id_remark			= item.EV_REMARK == null ? '' : item.EV_REMARK;

								var ev_id_sq_final			= item.EV_ID_SQ_FINAL;

								var item_method_cd = item.EV_ITEM_METHOD_CD;
								var att_file_num = item.ATT_FILE_NUM;
								var att_file_cou = item.ATT_FILE_COU;

								var esg_weight = item.ESG_WEIGHT;


								if (old_item_num != item_num && ev_id_sq_final == item_id_sq) {
									rmkInputYn = true;
									old_item_num = item_num;
								} else {
									rmkInputYn = false;
								}


								if( item_type2 == item_type3 && item_subject == item_subject3 && item_contents == item_contents3 ) {
									if(item_cnt == 1) {
										if(scale_type == "A") {
											html += "<div class=\"question\">";
											html += "<div class=\"title\">"+rownum +". " + item_subject + "  <label style='font-weight: normal; font-size:13px'><br/>" + item_contents + "</label></div>";
											html += "<div class=\"wrap_radio\">";
											div_check = true;
										} else if(scale_type == "C") {
											html += "<div class=\"question\">";
											html += "<div class=\"title\">"+rownum +". " +item_subject + "  <label style='font-weight: normal; font-size:13px'><br/>" + item_contents + "</label></div>";
											html += "<div class=\"wrap_radio\">";
											div_check = true;
										} else if(scale_type == "M") {
											html += "<div class=\"question\">";
											html += "<div class=\"title title_check\">" + item_id_contents + "</div>";
											html += "<div>";
										}
									} else {
										if(scale_type == "M") {
											html += "<div class=\"question\">";
											html += "<div class=\"title title_check\">" + item_id_contents + "</div>";
											html += "<div>";
										}
									}

									if("${param.detailView}" == "false") {
										if(item_method_cd== "QTY") {
											readOnly = "disabled";
										} else {
											readOnly = "";
										}
									}

									if(scale_type == "A") { <%--선택형--%>
										if( item_id_sq == item_id_sq2 ) {
											str_checked = "checked";
										}else{
											str_checked = "";
										}

										html += "<div class=\"custom-control custom-radio\">";
										html += "	<input type=\"radio\" id='item_" + item_num + item_id_sq + "' name=\"item_" + item_num + "\" method_cd='" + item_method_cd + "' id_sq='" + item_id_sq + "' score='" + item_id_score + "' weight='" + item_weight + "' " + str_checked + " " + readOnly + "ev_item_type_cd="+item_type3+" esg_weight="+esg_weight+" class=\"custom-control-input\">";
										html += "	<label class=\"custom-control-label\" for=\"item_" + item_num + item_id_sq + "\">" + item_id_contents + "</label>";
										html += "</div>";

										if (rmkInputYn) {
											html += "<div>";
											html += "<textarea id='remark_" + item_num + "' name='remark_" + item_num + "' maxLength='1000' " + readOnly + " style='width: 85%;height: 80px' placeholder='평가의견을 입력해주세요' >" + item_id_remark + "</textarea>";


											html += "<input type=\"hidden\" id='file_" + item_num + "' name=\"file_" + item_num + "\" value=\""+att_file_num+"\">";
											html += "</div>";
											html += "<div>";

											html += "<input type=\"text\" id='fileCou_" + item_num + "' name=\"fileCou_" + item_num + "\" readOnly style=\"width:30px; height:25px; font-size:8px\" value=\""+att_file_cou+"\">";
											html += "&nbsp;<input type=button onClick='fileAtt(\"" + item_num + "\")' style=\"cursor: pointer\"  value='첨부파일'/>";
											html += "</div>";
										}


									} else if(scale_type == "C") { <%--checkbox--%>
										if( item_id_sq == item_id_sq2 ) {
											str_checked = "checked";
										}else{
											str_checked = "";
										}
										html += "<div class=\"custom-control custom-radio\">";
										html += "	<input type=\"checkbox\" id='item_" + item_num + item_id_sq + "' name=\"item_" + item_num + "\" method_cd='" + item_method_cd + "' id_sq='" + item_id_sq + "' score='" + item_id_score + "' weight='" + item_weight + "' " + str_checked + " " + readOnly + "ev_item_type_cd="+item_type3+" esg_weight="+esg_weight+" class=\"custom-control-input\">";
										html += "	<label class=\"custom-control-label\" for=\"item_" + item_num + item_id_sq + "\">" + item_id_contents + "</label>";
										html += "</div>";

										if (rmkInputYn) {
											html += "<div>";

											html += "<textarea id='remark_" + item_num + "' name='remark_" + item_num + "' maxLength='1000' " + readOnly + " style='width: 85%;height: 80px' placeholder='평가의견을 입력해주세요' >" + item_id_remark + "</textarea>";
											html += "<input type=\"hidden\" id='file_" + item_num + "' name=\"file_" + item_num + "\" value=\""+att_file_num+"\">";
											html += "</div>";
											html += "<div>";

											html += "<input type=\"text\" id='fileCou_" + item_num + "' name=\"fileCou_" + item_num + "\" readOnly style=\"width:30px; height:25px; font-size:8px\" value=\""+att_file_cou+"\">";
											html += "&nbsp;<input type=button onClick='fileAtt(\"" + item_num + "\")' style=\"cursor: pointer\"  value='첨부파일'/>";
											html += "</div>";
										}

									} else if(scale_type == "M") { <%--직접입력--%>
										html += "<div class=\"mb_10\">";
										html += "	<label class=\"bullet\" for=\"item_" + item_num + item_id_sq + "\">점수입력 :</label>";
										html += "	<input class=\"number\" type=\"number\" id='item_" + item_num + item_id_sq + "' name='item_" + item_num + "' method_cd='" + item_method_cd + "' id_sq='" + item_id_sq + "' score='" + item_id_score + "' ev_item_type_cd="+item_type3+" esg_weight="+esg_weight	+"    weight='" + item_weight + "' value='" + item_id_score2 + "' maxLength='3' placeholder=\"0\" " + readOnly + ">";
										html += "	<span class=\"point\">배점 [" + item_id_score + "점]</span>";
										html += "</div>";
										html += "<div>";
										html += "	<label class=\"bullet\" for=\"remark_" + item_num + item_id_sq + "\">평가의견 : </label>";
										html += "	<input type=\"text\" id='remark_" + item_num + item_id_sq + "' name='remark_" + item_num + "' value='" + item_id_remark + "' maxLength='1000' " + readOnly + " style='width: 75%' >";
										html += "<input type=\"hidden\" id='file_" + item_num + "' name=\"file_" + item_num + "\" value=\""+att_file_num+"\">";
										html += "</div>";
										html += "<div>";
										html += "<input type=\"text\" id='fileCou_" + item_num + "' name=\"fileCou_" + item_num + "\" readOnly style=\"width:30px; height:25px; font-size:8px\" value=\""+att_file_cou+"\">";
										html += "&nbsp;<input type=button onClick='fileAtt(\"" + item_num + "\")' style=\"cursor: pointer\"  value='첨부파일'/>";
										html += "</div>";

										m_type_cnt++;
									}

									item_cnt++;

									if(scale_type == "M") {
										html += "</div></div>";
									}
								}
							});

							if(div_check) {
								html += "</div>"; // wrap_radio
								html += "</div>"; // question
							}
						}
					});

					html += "</div>";
				});
				$("#item_div").append(html);
			}
		}

		<%-- 셀클릭 --%>
		function doSelectRight(){
			//console.log(baseUrl+"/view.so?gbn=doSearchRight&"+$("input").serialize());
			location.href = baseUrl+"/view.so?popupFlag=true&detailView="+${leftform.detailView}+"&gbn=doSearchRight&"+$("input").serialize();
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

			EVF.confirm("${msg.M8888 }", function () {

				$("input[name*=item_]").each(function(){
					var name 	= $(this).attr("name");
					var weight 	= $(this).attr("weight");
					var score 	= $(this).attr("score");
					var id_sq 	= $(this).attr("id_sq");
					var method_cd = $(this).attr("method_cd");

					var esg_weight = $(this).attr("esg_weight");



					var ev_item_type_cd = $(this).attr("ev_item_type_cd");


					var info 	= name.split("_");
					if($(this).attr("type") == "radio") {<%-- radio --%>
							var item_score = 0;
							if(ev_item_type_cd=='E'||ev_item_type_cd=='S'||ev_item_type_cd=='G') {
								if(score!=0) {


								if(ev_item_type_cd=='S') {
//								alert( everMath.round_float( parseFloat(esg_weight) / parseFloat(score) , 5) +'=====================' +everMath.ceil_float( parseFloat(esg_weight) / parseFloat(score) , 5) );
//								alert(parseFloat(esg_weight) +'=================='+parseFloat(score))
								}


									item_score =  everMath.round_float( parseFloat(esg_weight) / parseFloat(score) , 5); // 항목점수
								}


							} else {
								item_score =  everMath.round_float( parseFloat(score) * ( parseFloat(weight) ) , 5); // 항목점수 * 가중치(%)
							}
							//alert('radio====='+item_score+' esg_weight'+esg_weight+' score'+score);
							var item_remark =  $("textarea[name='remark_"+info[1]+"']").val();
							if( item_remark == null || item_remark == "" ) item_remark = "_";

							var item_att_file_num =  $("input[name='file_"+info[1]+"']").val();
							if( item_att_file_num == null || item_att_file_num == "" ) item_att_file_num = "_";


							<%-- var item_score =  score;  항목점수 --%>
							queryString += info[1]; <%--item_num--%>
							queryString += "@@";
							queryString += id_sq;	<%--item_id_sq--%>
							queryString += "@@";
							queryString += item_score; <%--id_score--%>
							queryString += "@@";
							queryString += item_remark; <%--평가의견--%>

							queryString += "@@";
							queryString += item_att_file_num; <%--첨부파일--%>

						if($(this).is(":checked")){
							queryString += "@@";
							queryString += '1'; <%--체크여부--%>
							totalScore  += parseFloat(item_score);
							if(method_cd != "QTY") chkCount++;
						} else {
							queryString += "@@";
							queryString += '0'; <%--체크여부--%>
						}
						queryString += "##";

						if( info[1] != old_item_num){
							if(method_cd != "QTY") itemCount++;
							old_item_num = info[1];
						}

					}

					else if($(this).attr("type") == "checkbox") {<%-- 선택형 CHECK BOX --%>
							var item_score = 0;
							if(ev_item_type_cd=='E'||ev_item_type_cd=='S'||ev_item_type_cd=='G') {
								if(score!=0)
								item_score =  everMath.round_float( parseFloat(esg_weight) / parseFloat(score) , 5); // 항목점수
							} else {
								item_score =  everMath.round_float( parseFloat(score) * ( parseFloat(weight) ) , 5); // 항목점수 * 가중치(%)
							}
							//alert('radio====='+item_score+' esg_weight'+esg_weight+' score'+score);

							var item_remark =  $("textarea[name='remark_"+info[1]+"']").val();
							if( item_remark == null || item_remark == "" ) item_remark = "_";
							var item_att_file_num =  $("input[name='file_"+info[1]+"']").val();
							if( item_att_file_num == null || item_att_file_num == "" ) item_att_file_num = "_";



							<%-- var item_score =  score;  항목점수 --%>
							queryString += info[1]; <%--item_num--%>
							queryString += "@@";
							queryString += id_sq;	<%--item_id_sq--%>
							queryString += "@@";
							queryString += item_score; <%--id_score--%>
							queryString += "@@";
							queryString += item_remark; <%--평가의견--%>
							queryString += "@@";
							queryString += item_att_file_num; <%--첨부파일--%>
							if($(this).is(":checked")){
								queryString += "@@";
								queryString += '1'; <%--체크여부--%>
								totalScore  += parseFloat(item_score);
							} else {
								queryString += "@@";
								queryString += '0'; <%--체크여부--%>
							}
							queryString += "##";


						if( info[1] != old_item_num){
//							if(method_cd != "QTY") itemCount++;
							old_item_num = info[1];
						}

					}


					else if( $(this).attr("type") == "number" ){ <%-- 직접입력일 경우 --%>
						var item_score2 = $(this).val();
						var item_id_score = $(this).attr("score");
						var item_remark =  $("input[name='remark_"+info[1]+"']").val();
						if( item_remark == null || item_remark == "" ) item_remark = "_";
						<%-- var item_score =  everMath.round_float( parseFloat(item_score2) * ( parseFloat(weight) / 100 ) , 2); // 항목점수 * 가중치(%) --%>
						var item_score =  item_score2;<%-- 항목점수 --%>
						if( isNaN(item_score2)){
							alert('${EV0250_onlyNumber}');
							$(this).select();
							$(this).focus();
							is_ok = false;
						}
						if(parseFloat(item_score2) > parseFloat(item_id_score)){
							alert(item_id_score+'${EV0250_item_id_score}');
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
						queryString += "@@";
						queryString += item_att_file_num; <%--첨부파일--%>
						queryString += "@@";
						queryString += '1'; <%--체크여부--%>
						queryString += "##";
						totalScore  += parseFloat(item_score);

						if(method_cd != "QTY") chkCount++;

						if(info[1] != old_item_num){
							if(method_cd != "QTY") itemCount++;
							old_item_num = info[1];
						}
					}
				});

				queryString = queryString.substring(0, queryString.length-2); <%-- 끝부분 ## 제거 --%>

				if( itemCount != chkCount ){
					EVF.alert('${EV0250_emptyGrid}'); // 다 평가 하지 않아도 저장할수 있게...
					return;
				}

				if(${not rightform.OVER_100_FLAG eq '1'} && parseFloat(totalScore) > 100 && is_ok) {
					EVF.alert('${EV0250_overHundred} '+totalScore);
					$(this).focus();
					is_ok = false;
				}
				if(!is_ok){
					return;
				}

				totalScore = everMath.round_float(totalScore,1);


				EVF.C("QUERY_STR") .setValue(queryString);
				EVF.C("TOTAL_SCORE").setValue(totalScore);
			//EVF.C("EV_SCORE_R").setValue(totalScore);

				store.doFileUpload(function(){
					store.load(baseUrl + '/doSave', function(){
						EVF.alert(this.getResponseMessage(), function() {
							doSearch();
							EVF.C("QUERY_STR") .setValue('');
						});
					});
				});

			});

		}

		<%-- 닫기 --%>
		function doClose(){
			EVF.closeWindow();
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




		function fileAtt(setName) {
			var attFileNum =  $("input[name='file_"+setName+"']").val();

			if(attFileNum=='null') attFileNum = '';

			param = {
				 //detailView: '${leftform.detailView}'
				 havePermission : '${!leftform.detailView}'
				,attFileNum: attFileNum
				,rowId: setName
				,callBackFunction: "_V_setAttFile"
				,bizType: "EE"
				,fileExtension: "*"
			};
			everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
		}
		function _V_setAttFile(inputName, fileId, fileCount){
			$("input[name='file_"+inputName+"']").val(fileId);
			$("input[name='fileCou_"+inputName+"']").val(fileCount);
		}

	</script>
	
	<e:window id="EV0250" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" >
		<e:inputHidden id="TOTAL_SCORE" name="TOTAL_SCORE" value="${rightform.EV_SCORE_R}" />
		<e:inputHidden id="VENDOR_CD_L" name="VENDOR_CD_L" value="${leftform.VENDOR_CD_L}" />
		<e:inputHidden id="VENDOR_SQ_L" name="VENDOR_SQ_L" value="${leftform.VENDOR_SQ_L}" />
		<e:inputHidden id="EV_TYPE" name="EV_TYPE" value="${leftform.EV_TYPE}" />
		<e:inputHidden id="detailView" name="detailView" value="${leftform.detailView}" />
		<e:panel id="leftP" width="49%" height="100%">
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
			<c:if test="${ses.userType == 'C' }">
				<e:row>
					<%-- 협력사명 --%>
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
			</c:if>
			<c:if test="${ses.userType == 'S' || ses.userType =='B'}">
				<e:inputHidden id="EV_USER_NM_L" name="EV_USER_NM_L" value="${leftform.EV_USER_NM_L}"/>
			</c:if>
				<e:inputHidden id="RESULT_ENTER_CD" name="RESULT_ENTER_CD" value="${leftform.RESULT_ENTER_CD}"/>
				<e:inputHidden id="RESULT_ENTER_USER_ID" name="RESULT_ENTER_USER_ID" value="${leftform.RESULT_ENTER_USER_ID}"/>
				<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${leftform.EV_CTRL_USER_ID}"/>
			</e:searchPanel>

			<e:buttonBar align="right">
				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="btnSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			</e:buttonBar>

			<%-- 그리드 창 켜줌 --%>
			<e:gridPanel gridType="${_gridType}" id="leftgrid" name="leftgrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.leftgrid.gridColData}"/>
		</e:panel>

		<e:panel width="1%" height="100%">
			&nbsp;
		</e:panel>

		<%-- -----------------------------[ RIGHT GRID ]----------------------------------- --%>
		<e:panel id="rightP" width="50%" height="100%">
			<div id="rightTopPanel" style="padding:0;margin:0;">
				<e:searchPanel id="rightform" title="${rightform_RIGHT_TITLE_N}" columnCount="2" labelWidth="${labelWidth}" onEnter="btnSearch" useTitleBar="true">
					<e:row>
						<%-- 평가자명 --%>
						<e:label for="EV_USER_NM_R" title="${rightform_EV_USER_NM_R_N}"/>
						<e:field>
							<e:inputText id="EV_USER_NM_R" style="${imeMode}" name="EV_USER_NM_R" value="${rightform.EV_USER_NM_R}" width="99%" maxLength="${rightform_EV_USER_NM_R_M}" disabled="${rightform_EV_USER_NM_R_D}" readOnly="${rightform_EV_USER_NM_R_RO}" required="${rightform_EV_USER_NM_R_R}"/>
							<e:inputHidden id="EV_USER_ID" name="EV_USER_ID" value="${rightform.EV_USER_ID}"/>
						</e:field>
						<%-- 협력사명 --%>
						<e:label for="VENDOR_NM_R" title="${rightform_VENDOR_NM_R_N}"/>
						<e:field>
							<e:inputText id="VENDOR_NM_R" style="${imeMode}" name="VENDOR_NM_R" value="${rightform.VENDOR_NM_R}" width="99%" maxLength="${rightform_VENDOR_NM_R_M}" disabled="${rightform_VENDOR_NM_R_D}" readOnly="${rightform_VENDOR_NM_R_RO}" required="${rightform_VENDOR_NM_R_R}"/>
							<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${rightform.VENDOR_CD}"/>
							<e:inputHidden id="VENDOR_SQ" name="VENDOR_SQ" value="${rightform.VENDOR_SQ}"/>
						</e:field>
					</e:row>
				<c:if test="${ses.userType == 'C' }">
					<e:row>
						<%-- 점수 --%>
						<e:label for="EV_SCORE_R" title="${rightform_EV_SCORE_R_N}"/>

						<c:if test="${leftform.EV_TYPE == 'ESG' }">
							<e:field>
								<e:inputNumber id="EV_SCORE_R" name="EV_SCORE_R" value="${rightform.EV_SCORE_R}" width="31%" maxValue="${rightform_EV_SCORE_R_M}" decimalPlace="${rightform_EV_SCORE_R_NF}" disabled="${rightform_EV_SCORE_R_D}" readOnly="${rightform_EV_SCORE_R_RO}" required="${rightform_EV_SCORE_R_R}" />
								<e:inputHidden id="QUERY_STR" name="QUERY_STR" value=""/>
							</e:field>
							<%--점검상태--%>
							<e:label for="ESG_CHK_TYPE" title="${rightform_ESG_CHK_TYPE_N}"/>
							<e:field>
							<e:select id="ESG_CHK_TYPE" name="ESG_CHK_TYPE" value="${leftform.ESG_CHK_TYPE}" options="${esgChkTypeOptions}" width="${rightform_ESG_CHK_TYPE_W}" disabled="${rightform_ESG_CHK_TYPE_D}" readOnly="${rightform_ESG_CHK_TYPE_RO}" required="${rightform_ESG_CHK_TYPE_R}" placeHolder="" />
							<e:inputHidden id="ESG_CHK_TYPE2" name="ESG_CHK_TYPE2" value="${leftform.ESG_CHK_TYPE}"/>
							</e:field>

						</c:if>
						<c:if test="${leftform.EV_TYPE != 'ESG' }">
							<e:field colSpan="3">
								<e:inputNumber id="EV_SCORE_R" name="EV_SCORE_R" value="${rightform.EV_SCORE_R}" width="31%" maxValue="${rightform_EV_SCORE_R_M}" decimalPlace="${rightform_EV_SCORE_R_NF}" disabled="${rightform_EV_SCORE_R_D}" readOnly="${rightform_EV_SCORE_R_RO}" required="${rightform_EV_SCORE_R_R}" />
								<e:inputHidden id="QUERY_STR" name="QUERY_STR" value=""/>
								<e:inputHidden id="ESG_CHK_TYPE" name="ESG_CHK_TYPE" value=""/>
								<e:inputHidden id="ESG_CHK_TYPE2" name="ESG_CHK_TYPE2" value=""/>
							</e:field>
						</c:if>
					</e:row>
				</c:if>
				<c:if test="${ses.userType == 'S' || ses.userType =='B' }">
					<e:inputHidden id="EV_SCORE_R" name="EV_SCORE_R" value="${rightform.EV_SCORE_R}"/>
					<e:inputHidden id="QUERY_STR" name="QUERY_STR" value=""/>
					<e:inputHidden id="ESG_CHK_TYPE" name="ESG_CHK_TYPE" value=""/>
				    <e:inputHidden id="ESG_CHK_TYPE2" name="ESG_CHK_TYPE2" value=""/>
				</c:if>
					<e:row>
						<%--평가안내--%>
						<e:label for="RMK2" title="${form_RMK2_N}"/>
						<e:field colSpan="3">
							<e:richTextEditor id="RMK2" name="RMK2" width="100%" height="180px" required="${form_RMK2_R }" readOnly="${form_RMK2_RO }" disabled="${form_RMK2_D }" value="${rightform.RMK2}" useToolbar="false" />
						</e:field>
					</e:row>
					<e:row>
						<%-- 첨부파일 --%>
						<e:label for="BUYER_ATT_FILE_NUM" title="${rightform_BUYER_ATT_FILE_NUM_N}"/>
						<e:field colSpan="3">
							<e:fileManager id="BUYER_ATT_FILE_NUM" name="BUYER_ATT_FILE_NUM" fileId="${rightform.BUYER_ATT_FILE_NUM}" readOnly="true" downloadable="true" width="100%" bizType="EV" height="80px" required="${rightform_BUYER_ATT_FILE_NUM_R}" />
						</e:field>
					</e:row>
					<e:row>
						<%-- 첨부파일 --%>
						<e:label for="ATT_FILE_NUM" title="${rightform_ATT_FILE_NUM_N}"/>
						<e:field colSpan="3">
							<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${rightform.ATT_FILE_NUM}" readOnly="${leftform.detailView}" downloadable="true" width="100%" bizType="EV" height="80px" required="${rightform_ATT_FILE_NUM_R}" />
						</e:field>
					</e:row>
					<e:row>
						<%-- 평가의견 --%>
						<e:label for="RMK" title="${rightform_RMK_N}"/>
						<e:field colSpan="3">
							<e:textArea id="RMK" style="ime-mode:inactive" name="RMK" height="100px" value="${rightform.RMK}" width="100%" maxLength="${rightform_RMK_M}" disabled="${rightform_RMK_D}" readOnly="${rightform_RMK_RO}" required="${rightform_RMK_R}" />
						</e:field>
					</e:row>
				</e:searchPanel>

				<e:buttonBar align="right">
					<e:text style="color:red">일정시간(약 90분)동안 사용하지 않을시 작업한 내용이 소실될 수 있습니다. 중간 중간 저장해주세요.</e:text>
					<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
					<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
				</e:buttonBar>
				<hr>
			</div>
			
			<e:panel width="100%">
				<div id="div_man" class="wrap">
					<div class="sub_appraisal">
						<div class="title_upper"><span id="top_title"></span></div>
						<div class="wrap_question">
							<div id="item_div">

							</div>
						</div>
					</div>
				</div>
			</e:panel>
		</e:panel>


	</e:window>
</e:ui>
