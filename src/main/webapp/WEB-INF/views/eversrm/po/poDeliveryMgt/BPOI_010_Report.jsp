<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>거래명세서</title>
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
            box-shadow: 0 0 0cm rgba(0, 0, 0, 0);
            padding: 20px;
        }

        .title {
            font-size: 28px;
            font-weight: bold;
            /*display: block;*/
            margin: 1cm auto 0.1cm;
            width: 21cm;
            height: 2cm;
            text-align: center;
            vertical-align: middle;
            /*border-bottom: 1px solid #000;*/
            border-right: 1px solid transparent; /*완전히 투명하게*/
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
            table-layout: fixed;
            border-spacing: 2px;
            border-collapse: collapse;
        }

        .header_title {
            font-size: 15px;
            background-color: #ccc;
            font-weight: bold;
        }

        .header_title2 {
            font-size: 14px;
            background-color: #EAEAEA;
        }

        .header_text {
            font-weight: bold;
        }

        .header_text2 {
            font-weight: bold;
            height: 25px;
            border-bottom: 1px solid transparent; /*완전히 투명하게*/
        }

        .text_title {
            font-size: 20px;
            text-align: center;
            font-weight: bold;
        }

        .item_table {
            display: block;
            font-size: 13px;
            text-align: left;
            table-layout: fixed;
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
    <%--<script src="/ClipReport4/js/jquery-1.11.1.js"></script>--%>
    <script>
        function init() {
            /*
            // Parameter 넘겨준 값으로 조회
            var url = "/eversrm/po/deliveryMgt/BPOI_010_Report/doSearch";
            var param = {
                'inv_num': "${param.inv_num}"
            };

            $.post(url, param, function(printData) {
                console.log(printData)
            });
            */
        }
    </script>
</head>
<body onLoad="window.print();">
<c:forEach items="${printData}" var="data">
    <div class="page">
        <div class="header_section">
            <c:set var="hd" value="${data[0]}" />
            <table class="header_table" width="100%" border="1" style="float: left;">
                <colgroup>
                    <col class="left" width="40px">
                    <col class="left" width="70px">
                    <col class="left" width="130px">
                    <col class="left" width="70px">
                    <col class="left" width="90px">
                    <col class="left" width="40px">
                    <col class="left" width="70px">
                    <col class="left" width="130px">
                    <col class="left" width="70px">
                    <col class="left" width="90px">
                </colgroup>

                <tr>
                    <td class="title" colspan="7">거 래 명 세 서</td>
                    <td class="text_title" colspan="3">${hd.INV_NUM}</td>
                </tr>
                <tr>
                    <td class="center header_title" rowspan="6">공<br><br>급<br><br>자</td>
                    <td class="center header_title2" >일 자</td>
                    <td class="center" colspan="3">${hd.INV_DATE}</td>
                    <td class="center header_title" rowspan="6">공<br>급<br>받<br>는<br>자</td>
                    <td class="center header_title2" >인수자</td>
                    <td class="center" colspan="3">${hd.O_INSPECT_USER_NM}</td>
                </tr>
                <tr>
                    <td class="center header_title2">등록번호</td>
                    <td class="center header_text" colspan="3">${hd.V_IRS_NUM}</td>
                    <td class="center header_title2">등록번호</td>
                    <td class="center header_text" colspan="3">${hd.O_IRS_NUM}</td>
                </tr>
                <tr>
                    <td class="center header_title2">상 호</td>
                    <td class="center">${hd.VENDOR_NM}</td>
                    <td class="center header_title2">성 명</td>
                    <td class="center">${hd.V_CEO_USER_NM}</td>
                    <td class="center header_title2">상 호</td>
                    <td class="center">${hd.BUYER_NM}</td>
                    <td class="center header_title2">성 명</td>
                    <td class="center">${hd.O_CEO_USER_NM}</td>
                </tr>
                <tr>
                    <td class="center header_title2">주 소</td>
                    <td class="center" colspan="3">${hd.V_ADDR}</td>
                    <td class="center header_title2">주 소</td>
                    <td class="center" colspan="3">${hd.O_ADDR}</td>
                </tr>
                <tr>
                    <td class="center header_title2">업 태</td>
                    <td class="center" colspan="3">${hd.V_BUSINESS_TYPE}</td>
                    <td class="center header_title2">업 태</td>
                    <td class="center" colspan="3">${hd.O_BUSINESS_TYPE }</td>
                </tr>
                <tr>
                    <td class="center header_title2">업 종</td>
                    <td class="center" colspan="3">${hd.V_INDUSTRY_TYPE}</td>
                    <td class="center header_title2">종 목</td>
                    <td class="center" colspan="3">${hd.O_INDUSTRY_TYPE}</td>
                </tr>
                <tr>
                    <td class="center header_text2" colspan="10">공급가액 (통화 : ${hd.CUR}) 금액 : ${hd.ITEM_AMT_SUM} (V.A.T 별도)</td>
                </tr>
            </table>
        </div>
        <div class="item_section">
            <table class="item_table" width="100%" border="1" style="float: left;">
                <colgroup>
                    <col width="40px">
                    <col width="200px">
                    <col width="200px">
                    <col width="100px">
                    <col width="40px">
                    <col width="50px">
                    <col width="70px">
                    <col width="100px">
                </colgroup>
                <tr>
                    <th>순서</th>
                    <th>품명</th>
                    <th>규격</th>
                    <th>제조사</th>
                    <th>단위</th>
                    <th>수량</th>
                    <th>단가</th>
                    <th>금액</th>
                </tr>
                <c:forEach items="${data}" var="item" varStatus="idx">
                <tr>
                    <td class="center no_bb">${item.NUM}</td>
                    <td class="left no_bb">${item.ITEM_DESC}</td>
                    <td class="left no_bb">${item.ITEM_SPEC}</td>
                    <td class="left no_bb">${item.MAKER}</td>
                    <td class="center no_bb">${item.UNIT_CD}</td>
                    <td class="right no_bb">${item.INV_QT}</td>
                    <td class="right no_bb">${item.UNIT_PRC}</td>
                    <td class="right no_bb">${item.ITEM_AMT}</td>
                    <c:if test="${data.size() eq idx.count}" >
                        <tr>
                            <td class="center" colspan="8">==== 이 하 여 백 ====</td>
                        </tr>
                    </c:if>
                </tr>
                </c:forEach>
                <c:forEach begin="2" end="${21-data.size()}">
                    <tr>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                        <td class="no_bb"></td>
                    </tr>
                </c:forEach>
            </table>
        </div>
        <div class="footer">
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
