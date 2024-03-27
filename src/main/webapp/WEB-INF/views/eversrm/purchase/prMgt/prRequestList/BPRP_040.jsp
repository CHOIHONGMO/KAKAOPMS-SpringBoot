<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-05-18
  Time: 오후 1:44
  Scrren ID : BPRP_040
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <style>
    .tbltype {border-top:1px solid #cccccc; font-family:Dotum,"돋움";}
    .tbltype tbody {}
    .tbltype tbody th {vertical-align:middle; border-right:1px solid #cccccc; border-bottom:1px solid #cccccc; background:#e4e4e4; width: 600px; height: 40px; font-size: 13px;}
    .tbltype tbody td {border-right:1px solid #cccccc; border-bottom:1px solid #cccccc; width: 600px; font-size: 13px;}
  </style>
  <script>
    var baseUrl = "/eversrm/purchase/prMgt/prRequestList/BPRP_040/";

    function doClose() {
      window.close();
    }
  </script>

  <e:window id="BPRP_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:inputHidden id="PR_NUM" name="PR_NUM" value="${param.PR_NUM}" />
    <e:buttonBar width="100%" align="right">
      <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
    </e:buttonBar>

    <div>
      <c:if test="${rmkCnt > 0}">
      <table class="tbltype" onscroll="true">
        <tbody>
          <c:forEach items="${rmkList}" var="rmk">
            <tr>
              <%--품의번호--%>
              <th>${form_PR_NUM_N}</th>
              <td>${rmk.PR_NUM}</td>
              <%--반려일자--%>
              <th>${form_REJECT_DATE_N}</th>
              <td>${rmk.REJECT_DATE}</td>
            </tr>
            <tr>
              <%--반려사유--%>
              <th>${form_REJECT_RMK_N}</th>
              <td colspan="3"><pre>${rmk.REJECT_RMK}</pre></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
      </c:if>
    </div>
  </e:window>
</e:ui>