<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true">
    <jsp:param value="AP00000257" name="APP_DOC_NUM"/>
    <jsp:param value="1" name="APP_DOC_CNT"/>
    </jsp:include>    
    ======================================================================================================
</e:ui>

