<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--@ page import="model.outldap.samsung.net.*" --%>
<%--
<html>
<head></head>
	<script type="text/javascript">
	function init() {
		f = document.forms[0];
		f.searchType.value='${param.searchType}';		
	}
	function searchEmp() {
		f = document.forms[0];
		f.action = '/everinterface/mySingle/searchEmp';
		f.submit();
	}
	</script>

<body onload="init();">
<form name="se">
<select name="searchType">
	<option value="findByEpId">findByEpId</option>
	<option value="findByName">findByName</option>
	<option value="findByUid">findByUid</option>
	<option value="findByEmployeeNumber">findByEmployeeNumber</option>
	<option value="findByDepartmentNumber">findByDepartmentNumber</option>
</select>
<input type="text"  name="searchvalue" value="${param.searchvalue}"/>
	<a href="javascript:searchEmp()">조회</a>
</form>

<%
	if (request.getAttribute("employee")!=null) {
%>		
	<table border=1 width=20000>   
	<tr>
<td width="200" align="center">전체이름(fullname)     </td>
<td width="200" align="center">부서명     </td>
<td width="200" align="center">부서코드     </td>
<td width="200" align="center">담당업무,회사이름     </td>
<td width="200" align="center">사번     </td>
<td width="200" align="center">사용자구분     </td>
<td width="200" align="center">계정신청상태     </td>
<td width="200" align="center">사업장 코드     </td>
<td width="200" align="center">사업장명     </td>
<td width="200" align="center">영문 사업장명     </td>
<td width="200" align="center">영문 전체 이름     </td>
<td width="200" align="center">영문 부서명     </td>
<td width="200" align="center">영문 담당업무     </td>
<td width="200" align="center">영문이름     </td>
<td width="200" align="center">영문 직위명     </td>
<td width="200" align="center">영문 집주소     </td>
<td width="200" align="center">영문 회사명     </td>
<td width="200" align="center">영문 회사주소     </td>
<td width="200" align="center">영문 지역명     </td>
<td width="200" align="center">영문 파견 사업장명     </td>
<td width="200" align="center">영문 파견 회사명     </td>
<td width="200" align="center">영문 파견 부서명     </td>
<td width="200" align="center">영문 파견 직위명     </td>
<td width="200" align="center">영문 파견 지역명     </td>
<td width="200" align="center">영문 파견 총괄명     </td>
<td width="200" align="center">영문 파견 직급명     </td>
<td width="200" align="center">영문성     </td>
<td width="200" align="center">영문 총괄명     </td>
<td width="200" align="center">영문 직급명     </td>
<td width="200" align="center">성별     </td>
<td width="200" align="center">직위명     </td>
<td width="200" align="center">집주소 1     </td>
<td width="200" align="center">집우편번호     </td>
<td width="200" align="center">EPID     </td>
<td width="200" align="center">회사코드     </td>
<td width="200" align="center">지역코드     </td>
<td width="200" align="center">지역명     </td>
<td width="200" align="center">주민번호     </td>
<td width="200" align="center">총괄코드     </td>
<td width="200" align="center">총괄명     </td>
<td width="200" align="center">회사직급명     </td>
<td width="200" align="center">직급코드     </td>
<td width="200" align="center">임직원 상태     </td>
<td width="200" align="center">집 전화번호     </td>
<td width="200" align="center">집 주소 2     </td>
<td width="200" align="center">회사주소1     </td>
<td width="200" align="center">메일주소     </td>
<td width="200" align="center">핸드폰     </td>
<td width="200" align="center">회사명     </td>
<td width="200" align="center">집팩스     </td>
<td width="200" align="center">부서명     </td>
<td width="200" align="center">회사 주소 2     </td>
<td width="200" align="center">회사 우편번호     </td>
<td width="200" align="center">성(lastname)     </td>
<td width="200" align="center">회사 전화번호     </td>
<td width="200" align="center">이름(firstname)     </td>
<td width="200" align="center">직급 정렬 순서     </td>
<td width="200" align="center">파견 직급 정렬 순서     </td>
<td width="200" align="center">국가     </td>
<td width="200" align="center">dn     </td>
<td width="200" align="center">기본소속구분코드     </td>
<td width="200" align="center">직급/직위 표기방식     </td>
<td width="200" align="center">임원여부     </td>
<td width="200" align="center">표현언어     </td>
<td width="200" align="center">보안등급     </td>
<td width="200" align="center">파견사업장코드     </td>
<td width="200" align="center">파견회사코드     </td>
<td width="200" align="center">파견회사명     </td>
<td width="200" align="center">파견부서코드     </td>
<td width="200" align="center">파견부서명     </td>
<td width="200" align="center">파견직위     </td>
<td width="200" align="center">파견사 직급/직위 표기방식     </td>
<td width="200" align="center">파견지역코드     </td>
<td width="200" align="center">파견보안등급     </td>
<td width="200" align="center">파견총괄코드     </td>
<td width="200" align="center">파견직급명     </td>
<td width="200" align="center">파견직급코드     </td>
<td width="200" align="center">사용자등급     </td>
<td width="200" align="center">회사팩스번호     </td>
<td width="200" align="center">Nickname     </td>
<td width="200" align="center">메일자동응답언어     </td>
<td width="200" align="center">인터넷전화     </td>
<td width="200" align="center">파견총괄명     </td>
<td width="200" align="center">메일호스트     </td>
<td width="200" align="center">내부부서코드     </td>
<td width="200" align="center">직무명     </td>
<td width="200" align="center">직무코드     </td>
<td width="200" align="center">내부부서명     </td>
<td width="200" align="center">퇴직/휴직일     </td>
<td width="200" align="center">현채인여부     </td>
<td >실가명구분     </td>
	</tr>
<%
		
		Employee[] empdata = (Employee[])request.getAttribute("employee");
		for(int k = 0;k < empdata.length;k++) {
		
%>
	<tr>
<td><%=empdata[k].getCn()  %>     </td>
<td><%=empdata[k].getDepartment()  %>     </td>
<td><%=empdata[k].getDepartmentnumber()  %>     </td>
<td><%=empdata[k].getDescription()  %>     </td>
<td><%=empdata[k].getEmployeenumber()  %>     </td>
<td><%=empdata[k].getEmployeetype()  %>     </td>
<td><%=empdata[k].getEpaccountstatus()  %>     </td>
<td><%=empdata[k].getEpbusicode()  %>     </td>
<td><%=empdata[k].getEpbusiname()  %>     </td>
<td><%=empdata[k].getEpenbusiname()  %>     </td>
<td><%=empdata[k].getEpencn()  %>     </td>
<td><%=empdata[k].getEpendepartment()  %>     </td>
<td><%=empdata[k].getEpendescription()  %>     </td>
<td><%=empdata[k].getEpengivenname()  %>     </td>
<td><%=empdata[k].getEpengradename()  %>     </td>
<td><%=empdata[k].getEpenhomepostaladdress()  %>     </td>
<td><%=empdata[k].getEpenorganizationname()  %>     </td>
<td><%=empdata[k].getEpenpostaladdress()  %>     </td>
<td><%=empdata[k].getEpenregionname()  %>     </td>
<td><%=empdata[k].getEpensendbusiname()  %>     </td>
<td><%=empdata[k].getEpensendcompanyname()  %>     </td>
<td><%=empdata[k].getEpensenddeptname()  %>     </td>
<td><%=empdata[k].getEpensendgradename()  %>     </td>
<td><%=empdata[k].getEpensendregionname()  %>     </td>
<td><%=empdata[k].getEpensendsuborgname()  %>     </td>
<td><%=empdata[k].getEpensendtitlename()  %>     </td>
<td><%=empdata[k].getEpensn()  %>     </td>
<td><%=empdata[k].getEpensuborgname()  %>     </td>
<td><%=empdata[k].getEpentitle()  %>     </td>
<td><%=empdata[k].getEpgender()  %>     </td>
<td><%=empdata[k].getEpgradename()  %>     </td>
<td><%=empdata[k].getEphomel()  %>     </td>
<td><%=empdata[k].getEphomepostalcode()  %>     </td>
<td><%=empdata[k].getEpid()  %>     </td>
<td><%=empdata[k].getEporganizationnumber()  %>     </td>
<td><%=empdata[k].getEpregioncode()  %>     </td>
<td><%=empdata[k].getEpregionname()  %>     </td>
<td><%=empdata[k].getEpregisternumber()  %>     </td>
<td><%=empdata[k].getEpsuborgcode()  %>     </td>
<td><%=empdata[k].getEpsuborgname()  %>     </td>
<td><%=empdata[k].getTitle()  %>     </td>
<td><%=empdata[k].getEptitlenumber()  %>     </td>
<td><%=empdata[k].getEpuserstatus()  %>     </td>
<td><%=empdata[k].getHomephone()  %>     </td>
<td><%=empdata[k].getHomepostaladdress()  %>     </td>
<td><%=empdata[k].getL()  %>     </td>
<td><%=empdata[k].getMail()  %>     </td>
<td><%=empdata[k].getMobile()  %>     </td>
<td><%=empdata[k].getO()  %>     </td>
<td><%=empdata[k].getOtherfacsimiletelephonenumber()  %>     </td>
<td><%=empdata[k].getOu()  %>     </td>
<td><%=empdata[k].getPostaladdress()  %>     </td>
<td><%=empdata[k].getPostalcode()  %>     </td>
<td><%=empdata[k].getSn()  %>     </td>
<td><%=empdata[k].getTelephonenumber()  %>     </td>
<td><%=empdata[k].getGivenname()  %>     </td>
<td><%=empdata[k].getEptitlesortorder()  %>     </td>
<td><%=empdata[k].getEpsendtitlesortorder()  %>     </td>
<td><%=empdata[k].getC()  %>     </td>
<td><%=empdata[k].getDn()  %>     </td>
<td><%=empdata[k].getEpdefaultcompcode()  %>     </td>
<td><%=empdata[k].getEpgradeortitle()  %>     </td>
<td><%=empdata[k].getEpisblue()  %>     </td>
<td><%=empdata[k].getEppreferredlanguage()  %>     </td>
<td><%=empdata[k].getEpsecuritylevel()  %>     </td>
<td><%=empdata[k].getEpsendbusicode()  %>     </td>
<td><%=empdata[k].getEpsendcompanycode()  %>     </td>
<td><%=empdata[k].getEpsendcompanyname() %>     </td>
<td><%=empdata[k].getEpsenddeptcode() %>     </td>
<td><%=empdata[k].getEpsenddeptname()  %>     </td>
<td><%=empdata[k].getEpsendgradename()  %>     </td>
<td><%=empdata[k].getEpsendgradeortitle() %>     </td>
<td><%=empdata[k].getEpsendregioncode()  %>     </td>
<td><%=empdata[k].getEpsendsecuritylevel()  %>     </td>
<td><%=empdata[k].getEpsendsuborgcode()  %>     </td>
<td><%=empdata[k].getEpsendtitlename()  %>     </td>
<td><%=empdata[k].getEpsendtitlenumber()  %>     </td>
<td><%=empdata[k].getEpuserlevel()  %>     </td>
<td><%=empdata[k].getFacsimiletelephonenumber()  %>     </td>
<td><%=empdata[k].getNickname()  %>     </td>
<td><%=empdata[k].getPreferredlanguage()  %>     </td>
<td><%=empdata[k].getEpvoipnumber()  %>     </td>
<td><%=empdata[k].getEpsendsuborgcode()  %>     </td>
<td><%=empdata[k].getMailHost()  %>     </td>
<td><%=empdata[k].getEpindeptcode()  %>     </td>
<td><%=empdata[k].getEpjobname()  %>     </td>
<td><%=empdata[k].getEpjob()  %>     </td>
<td><%=empdata[k].getEpindeptcodename()  %>     </td>
<td><%=empdata[k].getEpwithdrawdate()  %>     </td>
<td><%=empdata[k].getEpnative()  %>     </td>
<td><%=empdata[k].getEpuserclassify()  %>     </td>
	</tr>
<%
		}
%>	
	</table>		
<%	
	}
%>
</body>
</html>
 --%>