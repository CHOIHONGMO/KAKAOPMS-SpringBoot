<%@ page contentType="text/xml; charset=-kr" %>
<%@ page import="econt.entity.*,java.text.DecimalFormat" %>
 
<%@ include file="/include/wisehub_scripts.jsp" %>
 

<%
  //response.setContentType("text/xml");
  //String XML_DATA = (String)dataMap.get("XML_DATA");
  DecimalFormat df = new DecimalFormat("###,###,###,###,##0");

  GuaranteeEntity guarantee_ett = (GuaranteeEntity)request.getAttribute("GUARANTEE_INFO");

  //out.println(guarantee_ett.toString());

  if(guarantee_ett != null && guarantee_ett.getHeadMesgName().length()>= 5 && (guarantee_ett.getHeadMesgName().equals("계약보증서") || guarantee_ett.getHeadMesgName().equals("하자보증서") || guarantee_ett.getHeadMesgName().equals("선금급보증서"))){
 %>

<html>
<head>
	<title>
		보증서 조회
	</title>

    <meta content="text/html; charset=euc-kr" http-equiv="Content-Type"/>
	<style type="text/css">
		BODY  {  scrollbar-3dlight-color:595959; scrollbar-arrow-color:ffffff; scrollbar-3dlight-color:595959; scrollbar-arrow-color:ffffff; scrollbar-base-color:CFCFCF; scrollbar-darkshadow-color:FFFFFF; scrollbar-face-color:CFCFCF; scrollbar-highlight-color:FFFFF; scrollbar-shadow-color:595959; margin:0 0 0 0; } 
		BODY,TD,SELECT,TEXTAREA,FORM,INPUT { font-family: "굴림"; font-size: 9pt; color: #3C3C3C; }
		.HEADLINE	{ font-family: "굴림체"; font-size: 23pt; font-weight: bold; color: #000000; vertical-align: bottom;}
		.fontb	  {   font-family: "굴림체"; line-height: 14pt; font-weight: bold; text-align: left;  vertical-align: bottom; color: #3C3C3C}
		.fontbc	  {   font-family: "굴림체"; line-height: 14pt; font-weight: bold; text-align: center;  vertical-align: middle; color: #3C3C3C}
		.text_text {  font-family: '굴림체'; font-size: 7pt; color: #000000}
		.text5 {  font-family: '굴림체'; font-size: 6pt; color: #000000}
		.text6 {  font-family: '굴림체'; font-size: 10pt; font-weight: bold;}
		.sub_title {  font-family: '굴림체'; font-size: 12pt; font-weight: bold}
	</style>

	<script language="javascript">
	<!--
	function printWindow() {
		factory.printing.header          = ""; // 머리말을 설정합니다.
		factory.printing.footer          = ""; // 꼬리말을 설정합니다.
		factory.printing.portrait        = true; // 세로로 출력할것인지 가로로 출력할것인지 설정합니다. true:세로 false:가로

		factory.printing.leftMargin      = 10.00;   // 좌측여백
		factory.printing.topMargin       = 10.00;   // 상단여백
		factory.printing.rightMargin     = 10.00;   // 우측여백
		factory.printing.bottomMargin    = 10.00;   // 하단여백
		//factory.printing.printBackground = true;  // 백그라운드까지 출력

		factory.printing.Print(true, window);     // 현재윈도를 프린트하는뜻(window대신에 frame을 지정해주면 해당 프레임을 출력합니다.)

		// window.print();
	}

	function go_print(){
		window.print();
	}
	-->
	</script>
</head>
<body ondragstart="return false">
<object id="factory" style="display:none" classid="clsid:1663ed61-23eb-11d2-b92f-008048fdd814" codebase="/kr/ctr/ScriptX.cab#Version=6,5,439,72">
</object>
<xml id="xid"> xid </xml> 
<table width="750" border="0" cellspacing="0" cellpadding="0" background="http://egis.sgic.co.kr/common/images/<%=info.getSession("HOUSE_CODE")%>/back_image(5).jpg">
	<tr>
		<td width="35">&#160;</td>
		<td align="center">
			<table border="0" width="680" cellspacing="0" cellpading="0" height="95"> 
				<tr height="90">
					<td colspan="3" valign="top">
						<table border="0" height="55">
							<tr>
								<td>
									<table width="110" border="0" cellspacing="0" cellpadding="0" height="40" style="border:1px solid;border-collapse:collapse;border-color:#000000;">
										<tr>
											<td align="center">
												<table border="0" cellspacing="0" cellpadding="0" height="40">
													<tr><td class="text_text" align="middle"><span style="line-height:13px;letter-spacing:-2px">대한민국정부&#160;인지세&#160;</span>200원<br/><span style="line-height:13px;letter-spacing:-2px">종로세무서장<br/>인쇄승인제</span>2003-1호</td></tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>			
					</td>
				</tr>
				<tr> 
					<td width="74" rowspan="2" height="90">
						&#160; 
					</td> 
					<td align="center" class="headline" width="520" height="45">
					  이행(
                        <% if(guarantee_ett.getHeadMesgName().equals("계약보증서")){ %>
							계약
						<% }else if(guarantee_ett.getHeadMesgName().equals("하자보증서")){ %>
							하자
						<% }else if(guarantee_ett.getHeadMesgName().equals("선금급보증서")){ %>
							선금급
						<% } %>
					  )보증보험증권
					</td>
					<td widtn="70" rowspan="2">&#160;</td>
				</tr> 
				<tr>
					<td align="center" class="sub_title" valign="top" width="500">
						(인터넷조회용)
					</td>
				</tr>
				<tr> 
					<td colspan="3" height="28" valign="bottom"> 
						<table width="600" border="0" cellspacing="0" cellpadding="0"> 
							<tr> 
								<td width="560" height="23" class="sub_title" valign="bottom">
									증권번호 제
									<%=guarantee_ett.getBondNumbText().substring(6, 9)%>-<%=guarantee_ett.getBondNumbText().substring(9, 12)%>
										-<%=guarantee_ett.getBondNumbText().substring(12, 25)%>
									호
								 </td> 
							</tr> 
						</table> 
					</td> 
				</tr>
				<tr>
					<!--- 내용 시작 -->
					<td colspan="3">
						<table width="680" cellspacing="0" border="1" cellpadding="2" class="tr">
							<tr>
								<td width="15%" class="fontbc">보험계약자</td>
								<td width="35%" height="55">
								<%if(guarantee_ett.getApplOrpsDivs().equals("O")){%>
						
								    <%=guarantee_ett.getApplOrpsIden().substring(0, 3)%>
									-<%=guarantee_ett.getApplOrpsIden().substring(3, 5)%>
									-<%=guarantee_ett.getApplOrpsIden().substring(5, 10)%>

						         <%}else if(guarantee_ett.getApplOrpsDivs().equals("P")){%>
									<%=guarantee_ett.getApplOrpsIden().substring(0, 6)%>
									-<%=guarantee_ett.getApplOrpsIden().substring(6, 13)%>
									<%}%>
									<br />&nbsp;
									<%=guarantee_ett.getApplOrgaName()%>
									<br />&nbsp;
									<%=guarantee_ett.getApplOwnrName()%>
								</td>
								<td width="15%" class="fontbc">피보험자</td>
								<td width="35%" colspan="2">&nbsp;
								<%if(guarantee_ett.getCredOrpsDivs().equals("O")){%>
						
								    <%=guarantee_ett.getCredOrpsIden().substring(0, 3)%>
									-<%=guarantee_ett.getCredOrpsIden().substring(3, 5)%>
									-<%=guarantee_ett.getCredOrpsIden().substring(5, 10)%>

						         <%}else if(guarantee_ett.getCredOrpsDivs().equals("P")){%>
									<%=guarantee_ett.getCredOrpsIden().substring(0, 6)%>
									-<%=guarantee_ett.getCredOrpsIden().substring(6, 13)%>
									<%}%>
									
									<br />&nbsp;
									<%=guarantee_ett.getCredOrgaName()%>
								</td>
							</tr>
							<tr>
								<td class="fontbc" height="45">보험가입금액</td>
								<td colspan="2">&nbsp;金 <%=guarantee_ett.getBondPenlText()%> 
									 整
									<br />&nbsp;\<%=df.format(Long.parseLong(guarantee_ett.getBondPenlAmnt()))%>-
									
									
							    </td>
								<td class="fontbc">보 험 료</td>
								<td align="right">\<%=df.format(Long.parseLong(guarantee_ett.getBondPremAmnt()))%>-
									
								</td>
							</tr>
							<tr>
								<td class="fontbc" height="30">보 험 기 간</td>
								<td colspan="4">&nbsp;<%=guarantee_ett.getBondBegnDate().substring(0,4)%>  년 <%=guarantee_ett.getBondBegnDate().substring(4,6)%> 월 <%=guarantee_ett.getBondBegnDate().substring(6,8)%> 일
									 부터 
								<%=guarantee_ett.getBondFnshDate().substring(0,4)%>  년 <%=guarantee_ett.getBondFnshDate().substring(4,6)%> 월 <%=guarantee_ett.getBondFnshDate().substring(6,8)%> 일
								   까지
								</td>
							</tr>
							<tr>
								<td class="fontbc" height="30">보 증 내 용</td>
								<td colspan="4">&nbsp;<%=guarantee_ett.getBondStatText()%>
								</td>
							</tr>
							<tr>
								<td class="fontbc" height="70">특 별 약 관</td>  
								<td colspan="4">&nbsp;<%=guarantee_ett.getSpclProvText()%>
								</td>
							</tr>
							<tr>
								<td class="fontbc" height="70">특 기 사 항</td>
								<td colspan="4">&nbsp;<%=guarantee_ett.getSpclCondText()%>
									
								</td>
							</tr>
							<tr>
								<td colspan="5" align="center" height="190" valign="top">
									<!--- 주계약내용 시작 (이행계약) -->
                                    <% if(guarantee_ett.getHeadMesgName().equals("계약보증서")){ %>
									<table width="97%" border="0">
										<tr>
											<td class="text6" colspan="2">주계약내용</td>
										</tr>
										<tr>
											<td class="fontb" width="100">계약명</td>
											<td>
												<%=guarantee_ett.getContNameText()%>
											</td>
										</tr>
										<tr>
											<td class="fontb">계약기간</td>
											<td>
											<%if(guarantee_ett.getContBegnDate().length()>=8){ %>
											      <%=guarantee_ett.getContBegnDate().substring(0,4)%>  년 <%=guarantee_ett.getContBegnDate().substring(4,6)%> 월 <%=guarantee_ett.getContBegnDate().substring(6,8)%> 일 부터
											<%}%>
                                            <%if(guarantee_ett.getContFnshDate().length()>=8){ %>
											      <%=guarantee_ett.getContFnshDate().substring(0,4)%>  년 <%=guarantee_ett.getContFnshDate().substring(4,6)%> 월 <%=guarantee_ett.getContFnshDate().substring(6,8)%> 일 까지
											 <%}%>
											</td>
										</tr>
										<tr>
											<td class="fontb">계약체결일자</td>
											<td>
											<%if(guarantee_ett.getContMainDate().length()>=8){ %>
											    <%=guarantee_ett.getContMainDate().substring(0,4)%>  년 <%=guarantee_ett.getContMainDate().substring(4,6)%> 월 <%=guarantee_ett.getContMainDate().substring(6,8)%> 일
											<%}%>
												
											</td>
										</tr>
										<tr>
											<td class="fontb">계약금액</td>
											<td>\<%=df.format(Long.parseLong(guarantee_ett.getContMainAmnt()))%>- 
											</td>
										</tr>
										<tr>
											<td class="fontb">계약보증금율</td>
											<td><%=guarantee_ett.getBondPricRate()%>
											      % 
											</td>
										</tr>
									</table>
									</xsl:if>																
									<!--- 주계약내용 끝 (이행계약) -->
								
									<!--- 주계약내용 시작 (이행하자) -->
									<% }else if(guarantee_ett.getHeadMesgName().equals("하자보증서")){ %>
									<table width="97%" border="0">
										<tr>
											<td class="text6" colspan="2">주계약내용</td>
										</tr>
										<tr>
											<td class="fontb" width="100">계약명</td>
											<td>
												<%=guarantee_ett.getContNameText()%>
											</td>
										</tr>
										<tr>
											<td class="fontb">하자담보기간</td>
											<td>
											<%if(guarantee_ett.getContBegnDate().length()>=8){ %>
											      <%=guarantee_ett.getContBegnDate().substring(0,4)%>  년 <%=guarantee_ett.getContBegnDate().substring(4,6)%> 월 <%=guarantee_ett.getContBegnDate().substring(6,8)%> 일 부터
											<%}%>
                                            <%if(guarantee_ett.getContFnshDate().length()>=8){ %>
											      <%=guarantee_ett.getContFnshDate().substring(0,4)%>  년 <%=guarantee_ett.getContFnshDate().substring(4,6)%> 월 <%=guarantee_ett.getContFnshDate().substring(6,8)%> 일 까지
											 <%}%>
											</td>
										</tr>
										<tr>
											<td class="fontb">계약체결일자</td>
											<td>
											<%if(guarantee_ett.getContMainDate().length()>=8){ %>
											    <%=guarantee_ett.getContMainDate().substring(0,4)%>  년 <%=guarantee_ett.getContMainDate().substring(4,6)%> 월 <%=guarantee_ett.getContMainDate().substring(6,8)%> 일
											<%}%>
											</td>
										</tr>
										<tr>
											<td class="fontb">계약금액</td>
											<td>\<%=df.format(Long.parseLong(guarantee_ett.getContMainAmnt()))%>- 
											</td>
										</tr>
										<tr>
											<td class="fontb">하자보증금율</td>
											<td><%=guarantee_ett.getBondPricRate()%> % 
											</td>
										</tr>
									</table>
									</xsl:if>

									</xsl:if>
									<!--- 주계약내용 끝 (이행하자) -->
									<!--- 주계약내용 시작 (이행선금급) -->
									<% }else if(guarantee_ett.getHeadMesgName().equals("선금급보증서")){ %>
									<table width="97%" border="0">
										<tr>
											<td class="text6" colspan="2">주계약내용</td>
										</tr>
										<tr>
											<td class="fontb" width="180">계약명</td>
											<td>
												<%=guarantee_ett.getContNameText()%>
											</td>
										</tr>
										<tr>
											<td class="fontb">계약금액</td>
											<td>\<%=df.format(Long.parseLong(guarantee_ett.getContMainAmnt()))%>- 
											</td>
										</tr>
										<tr>
											<td class="fontb">선금(전도자재)액</td>
											<td>
											\<%=df.format(Long.parseLong(guarantee_ett.getContPaymAmnt()))%>- 
												
											</td>
										</tr>
										<tr>
											<td class="fontb">계약체결일자</td>
											<td>
											<%if(guarantee_ett.getContMainDate().length()>=8){ %>
											    <%=guarantee_ett.getContMainDate().substring(0,4)%>  년 <%=guarantee_ett.getContMainDate().substring(4,6)%> 월 <%=guarantee_ett.getContMainDate().substring(6,8)%> 일
											<%}%>
											</td>
										</tr>
										<tr>
											<td class="fontb">계약기간</td>
											<td>
											<%if(guarantee_ett.getContBegnDate().length()>=8){ %>
											      <%=guarantee_ett.getContBegnDate().substring(0,4)%>  년 <%=guarantee_ett.getContBegnDate().substring(4,6)%> 월 <%=guarantee_ett.getContBegnDate().substring(6,8)%> 일 부터
											<%}%>
                                            <%if(guarantee_ett.getContFnshDate().length()>=8){ %>
											      <%=guarantee_ett.getContFnshDate().substring(0,4)%>  년 <%=guarantee_ett.getContFnshDate().substring(4,6)%> 월 <%=guarantee_ett.getContFnshDate().substring(6,8)%> 일 까지
											 <%}%>
											</td>
										</tr>
										<tr>
											<td class="fontb">선금(전도자재)지급(예정)일</td>
											<td>
											<%if(guarantee_ett.getContPaymDate().length()>=8){ %>
											      <%=guarantee_ett.getContPaymDate().substring(0,4)%>  년 <%=guarantee_ett.getContPaymDate().substring(4,6)%> 월 <%=guarantee_ett.getContPaymDate().substring(6,8)%> 일 부터
											<%}%>
											</td>
										</tr>
									</table>
									<%}%>
                                    <!--- 주계약내용 끝 (이행선금급) -->

								</td>
							</tr>
						</table>
					</td>
					<!--- 내용 끝 -->
				</tr> 
				<tr>
					<td colspan="3" height="35" valign="bottom">
                        <% if(guarantee_ett.getHeadMesgName().equals("계약보증서")){ %>
						
						우리 회사는 이행(계약)보증보험 보통약관, 특별약관 및 이 증권에 기재된 내용에 따라 이행(계약)보증보험 계약을 체결하였음이 확실하므로 그 증으로 이 증권을 발행합니다.
						
						<% }else if(guarantee_ett.getHeadMesgName().equals("하자보증서")){ %>
						
						우리 회사는 이행(하자)보증보험 보통약관, 특별약관 및 이 증권에 기재된 내용에 따라 이행(하자)보증보험 계약을 체결하였음이 확실하므로 그 증으로 이 증권을 발행합니다.
						
						<% }else if(guarantee_ett.getHeadMesgName().equals("선금급보증서")){ %>
						
						우리 회사는 이행(선금급)보증보험 보통약관, 특별약관 및 이 증권에 기재된 내용에 따라 이행(선금급)보증보험 계약을 체결하였음이 확실하므로 그 증으로 이 증권을 발행합니다.
						
						<% } %>

				
					</td>
				</tr>
				<tr>
					<td colspan="3" height="30">&#160;</td>
				</tr>
				<tr>
					<td colspan="3">
						<table border="0">
							<tr>
								<td width="405">
									<table border="0">
										<tr>
											<td class="sub_title">※ 증권발급 사실 확인 안내<br/></td>
										</tr>
										<tr>
											<td><br/>발 급 부 서 : 
												<%=guarantee_ett.getBondNumbText().substring(6, 9)%>
												<%=guarantee_ett.getIssuDeptName()%>
												(<%=guarantee_ett.getChrgPhonText()%>)
											</td>
										</tr>
										<tr>
											<td>부&#160;&#160;&#160;서&#160;&#160;&#160;장 : 
												<%=guarantee_ett.getIssuDeptOwnr()%>
											</td>
										</tr>
										<tr>
											<td>담&#160;&#160;&#160;당&#160;&#160;&#160;자 : 
												<%=guarantee_ett.getChrgNameText()%>
											</td>
										</tr>
										<tr>
											<td>주&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;소 : 
											<%=guarantee_ett.getIssuAddrTxt1()%>
												<br /> 
						      					&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
												<%=guarantee_ett.getIssuAddrTxt2()%>
											</td>
										</tr>
										<!--tr>
											<td>취급 대리점 : <xsl:value-of select="//Issuer.Details/Agency.Details/cc:Department.Name/Text.Content"/></td>
										</tr-->
									</table>
								</td>
								<td valign="top">
									<table width="200">
										<tr>
											<td align="right">
											<%if(guarantee_ett.getDocuIssuDate().length()>=8){ %>
											      <%=guarantee_ett.getDocuIssuDate().substring(0,4)%>  년 <%=guarantee_ett.getDocuIssuDate().substring(4,6)%> 월 <%=guarantee_ett.getDocuIssuDate().substring(6,8)%> 일 부터
											<%}%>
											</td>
										</tr>
										<tr>
											<td align="right">
												<%=guarantee_ett.getIssuAddrTxt1()%><br /> 
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>			
					</td>
				</tr>
				<tr>
					<td colspan="3" height="26" align="center">&#160;<script language="javascript">btn("javascript:printWindow()",5,"인쇄")</script></td>
				</tr>
			</table>  
		</td>
		<td width="38">&#160;</td>
	</tr>
</table> 
</body>
</html>
<%}else{%>

<Script language="javascript">
	alert("보증 데이터가 없습니다.");
	self.close();
</Script>
<%}%>
