<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>

<c:set var="sessionInfo" value='<%=request.getAttribute("SESSION_INFO")%>'/>
<e:ui>

    <style type="text/css">
        th {
            background-color: #027bc7;
            color: #fff;
            height: 24px;
            font-size: 13px;
        }

        .e-field-wrapper:last-child {
            font-style: italic;
        }
    </style>

    <e:window id="sessionInfo">
        <e:title title="세션정보"/>
        <table class="e-searchpanel-content font-form " id="sp_sessionTable" style="border-top: 0;">
            <colgroup>
                <col width="150">
                <col style="width: auto;">
            </colgroup>
            <tbody>
                <tr>
                    <th>코드</th>
                    <th>값</th>
                    <th>코멘트</th>
                </tr>
            <c:forEach var="s" items="${sessionInfo}" varStatus="ss" step="1">
                <tr>
                    <td class="e-label-wrapper" style="background-position: 2px center; text-indent: 8px;">${s.text}</td>
                    <td class="e-field-wrapper" style="text-indent: 4px;">${s.value}</td>
                    <td class="e-field-wrapper" style="text-indent: 4px;">${s.comments}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </e:window>
</e:ui>