<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>발주서</title>
    <style>
        @page {
            size: A4;
            margin: 0;
            page-break-after: always;
        }

        @media print {
            body, .page {
                margin: 0;
                box-shadow: 0;
            }
        }

        body {
            background: rgb(204, 204, 204);
            font-family: "Malgun Gothic", "Arial", sans-serif;
        }

        * {
            /*outline: 1px dotted gray;;*/
        }

        .page {
            background: white;
            width: 21cm;
            height: 29.7cm;
            display: block;
            margin: 0 auto 0cm;
            box-shadow: 0 0 0.5cm rgba(0, 0, 0, 0.5);
            padding: 20px;
        }

        .title {
            font-size: 28px;
            font-weight: bold;
            display: block;
            margin: 1cm auto 0.1cm;
            width: 21cm;
            height: 1cm;
            text-align: center;
            vertical-align: middle;
            border-bottom: 1px solid #000;
        }

        .logo {
        	position: absolute;
        	right: 3cm;
        	top: 1.3cm;
        }

        .info {
            font-size: 14px;
            width: 21cm;
            text-align: center;
            margin: 0 auto 0.4cm;
        }

        .header_section {
            margin: 0 auto 1.5cm;
            height: 100px;
        }

        .header_table {
            display: block;
            font-size: 13px;
            text-align: left;
            border-spacing: 2px;
            border-collapse: collapse;
        }

        .header_title {
            font-size: 16px;
            text-align: center;
        }

        .data_title {
            font-size: 14px;
            text-align: center;
        }


        .text_title {
            font-size: 15px;
        }
        .text_title2 {
            text-align: center;
            font-size: 15px;
        }

        .item_table {
            display: block;
            font-size: 13px;
            text-align: left;
            border-spacing: 2px;
            border-collapse: collapse;
        }

        .item_table th {
            background-color: #ccc;
            font-weight: normal;
            text-align: center;
            font-size: 14px;
            vertical-align: middle;
        }

        .item_table td {
            font-weight: normal;
            font-size: 13px;
            height: 40px;
            vertical-align: middle;
        }

        .item_section {
            margin: 0.5cm auto 0.1cm;
            height: 520px;
        }

        .sum_section {
            margin: 0.5cm auto 0.1cm;
            height: 40px;
            border: 1px solid #000;
            vertical-align: middle;
            text-align: center;
        }

        .footer {
            margin: 0.2cm auto 0.1cm;
            
        }

        .footer_table {
            width: 100%;
            display: block;
            font-size: 13px;
            text-align: left;
            border-spacing: 2px;
            border-collapse: collapse;
            border: 1px solid #000;
        }

        .footer_table td {
            padding: 4px;
        }

        .left {
            text-align: left;
        }
        .right {
            text-align: right;
        }
        .center {
            text-align: center;
        }
		.no_bb {
            border-bottom: 1px solid #000;
        }

    </style>
</head>
<body onLoad="window.print()">
<c:forEach items="${printData}" var="data">

    <div class="page">
        <c:set var="hd" value="${data[0]}" />

        <div class="header_section">
        <BR>
        <BR>
            <table class="header_table" width="100%" border="1" style="float: left;">

                <colgroup>
                    <col class="left" width="110">
                    <col class="left" width="290">
                    <col class="left" width="110">
                    <col class="left" width="290">
                </colgroup>

                <tr>
                    <td colspan="3" align="center"><font size="22px"><B>발 주 서</B></font></td>
                    <td class="data_title"><font size="5px"><B>${form.PO_NUM}&nbsp;</B></font></td>
                </tr>


                <tr>
                    <td class="header_title" width="70">수주처</td>
                    <td class="data_title">${form.VENDOR_NM}&nbsp;</td>
                    <td class="header_title" width="100">발주처</td>
                    <td class="data_title">${form.BUYER_NM}&nbsp;</td>
                </tr>
                <tr>
                    <td class="header_title">TEL/FAX</td>
                    <td class="data_title" >${form.VENDOR_CONTACT}&nbsp;</td>
                    <td class="header_title">TEL/FAX</td>
                    <td class="data_title" >${form.PLANT_CONTACT}&nbsp;</td>
                </tr>
                <tr>
                    <td class="header_title">발주일자</td>
                    <td class="data_title" >${form.PO_CREATE_DATE2}&nbsp;</td>
                    <td class="header_title">발주금액</td>
                    <td class="data_title" ><B>${form.PO_AMT}&nbsp;(V.A.T 별도)</B></td>
                </tr>
                <tr>
                    <td class="header_title">수신자</td>
                    <td class="data_title">대표이사귀하&nbsp;</td>
                    <td class="header_title">소속/담당자</td>
                    <td class="data_title" >${form.CTRL_USER_NM2}&nbsp;</td>
                </tr>
                <tr>
                    <td class="header_title">납기일자</td>
                    <td class="data_title" >${form.DUE_DATE}&nbsp;</td>
                    <td class="header_title">인도조건</td>
                    <td class="data_title" >${form.DELY_TERMS2}&nbsp;</td>
                </tr>
            </table>
        </div>

        <div class="item_section">
            <div class="text_title2"><B>공급내역(통화 : ${form.CUR}, V.A.T 별도)</div>
            
            <table class="item_table" width="100%" border="1" style="float: left;">
                <colgroup>
                    <col width="40">
                    <col width="170">
                    <col width="90">
                    <col width="90">
                    <col width="60">
                    <col width="60">
                    <col width="70">
	                <col width="70">
	                <col width="150">
                </colgroup>
                <tr>
                    <th>순서</th>
                    <th>품명</th>
                    <th>규격</th>
                    <th>제조사</th>
                    <th>수량</th>
                    <th>단위</th>
                    <th>단가</th>
	                <th>금액</th>
	                <th>비고</th>
                </tr>
                <c:forEach items="${data}" var="item">
                <tr>
                    <td class="center no_bb">${item.NUM}</td>
                    <td class="center no_bb">${item.ITEM_DESC}</td>
                    <td class="left no_bb">${item.ITEM_SPEC}</td>
                    <td class="left no_bb">${item.MAKER}</td>
                    <td class="right no_bb">${item.PO_QT2}</td>
                    <td class="center no_bb">${item.ORDER_UNIT_CD}</td>
                    <td class="right no_bb">${item.UNIT_PRC2}</td>
	                <td class="right no_bb">${item.ITEM_AMT2}</td>
	                <td class="right no_bb"></td>
                </tr>
                </c:forEach>
                <c:forEach begin="1" end="${12-data.size()}">
                    <tr>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <c:if test="${hd.BUYER_CODE != 'B00074'}">
	                        <td class="no_bb"></td>
	                        <td class="no_bb"></td>
	                    </c:if>
                    </tr>
                </c:forEach>


            </table>
        </div>

        <div class="footer">
        
             <table class="header_table" width="100%" border="1" style="float: left;">
               <tr>
                    <td class="header_title" width="800">특기사항</td>
                </tr>
                <tr height="150">
                    <td style="text-align: left;vertical-align: top; font-size: 13px;">${form.SPECIAL_CONTENTS}</td>
                </tr>
                <tr height="70">
                    <td style="text-align: left; font-size: 13px;"><B>
                    1) 당사는 친환경 경영을 목표로 합니다.<BR/>
                    2) 상기 공급의 물품은 당사의 시방을 준한 물품 및 품질이 일치하여야 한다.<BR/>
                    3) 당사의 검사기준과 방법에 합격되어야 하며, 납기일자를 반드시 준수하여야 함.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;직인생략</B>
                    </td>
                </tr>
            </table>
			<table width="100%">
                <tr>
                    <td style="text-align: center; font-size: 13px;">Page : ${hd.CURRENT_PAGE} / ${hd.TOTAL_PAGE}</td>
                </tr>
            </table>


        </div>
    </div>


</c:forEach>
</body>
</html>
