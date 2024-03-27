<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>고객사 지표관리</title>
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
            font-family: 'Nanum Gothic', 'Malgun Gothic', '맑은고딕', '맑은 고딕', Arial, Helvetica, sans-serif !important;
        }

        * {
            /*outline: 1px dotted gray;;*/
        }

        .page {
            background: white;
            width: 21cm;
            height: 29.7cm;
            display: block;
            margin: 0 auto;
            box-shadow: 0 0 0.5cm rgba(0, 0, 0, 0.5);
            padding: 14px 14px 25px 14px;;
        }

        .title {
            font-size: 30px;
            font-weight: bold;
            display: block;
            margin: 2cm auto 1.0cm;
            width: 21cm;
            height: 1cm;
            text-align: center;
            vertical-align: middle;
            /*border-bottom: 1px solid #000;*/
        }

        .issue_date {
            position: relative;
            text-align: left;
            top: 30px;
            font-size: 20px;
            font-weight: bold;
        }

        .logo {
            position: relative;
            top: -35px;
            text-align: center;
            width: 100%;
        }

        .info {
            font-size: 14px;
            width: 21cm;
            text-align: center;
            margin: 0 auto 0.4cm;
        }

        .header_section {
            height: 100px;
        }

        .header_table {
            /*display: block;*/
            font-size: 10px;
            text-align: left;
            table-layout: fixed;
            /*border-spacing: 2px;*/
            border-collapse: collapse;
            /*border: 1px solid #000;*/
            font-weight: bold;
        }

        .header_title {
            font-size: 15px;
            text-align: center;
            background-color: #e8e8e8;
            font-weight: bold;
        }

        .text_title {
            font-size: 16px;
            line-height: 30px;
            float: left;
            padding-top: 40px;
            font-weight: bold;
        }

        .text_right {
            float: right;
            font-size: 12px;
        }

        .item_table {
            /*display: block;*/
            font-size: 10px;
            text-align: left;
            table-layout: fixed;
            /*border-spacing: 2px;*/
            border-collapse: collapse;
            /*border: 1px solid #000;*/
        }

        .item_table th {
            background-color: #e8e8e8;
            font-weight: bold;
            text-align: center;
            font-size: 15px;
            vertical-align: middle;
            border-bottom: 1px solid #000;
        }

        .item_table td {
            font-weight: normal;
            font-size: 15px;
            vertical-align: middle;
        }

        .item_section {
            margin: -1cm auto 6.8cm;
            height: 580px;
            width: 755px;
        }

        .sum_section {
            margin: 2.7cm auto 0.1cm;
            height: 40px;
            vertical-align: middle;
            text-align: center;
            width: 755px;
        }

        .footer {
            margin: 0.2cm auto 0.1cm;
        }

        .footer_table {
            width: 100%;
            /*display: block;*/
            font-size: 10px;
            text-align: left;
            border-spacing: 2px;
            border-collapse: collapse;
            /*border: 2px solid #000;*/
        }

        .footer_table td {
            padding: 4px;
        }

        .left {
            text-align: left;
        }

        .right {
            text-align: right;
            padding: 0 10px 0 0;
        }

        .center {
            text-align: center;
            height: 40px;
        }

        .no_bb {
            /*border-bottom: 1px solid #000;*/
            height: 40px;
            text-overflow: ellipsis;
            overflow: hidden;
            white-space: nowrap;
            width: 284px;
        }

        .header_text {
            font-weight: 100;
            font-size: 15px;
        }

        .pageSize {
            width: 755px;
            padding: 0 0 0 20px;
        }

    </style>
    <script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
    <script>
        var html = "";
        var printData = ${printData};

        $(document).ready(function () {
            var fromToDate = '${START_DATE}'.substr(0,4) + '/' + '${START_DATE}'.substr(4,2) + '/' + '${START_DATE}'.substr(6,2) + " ~ " + '${END_DATE}'.substr(0,4) + '/' + '${END_DATE}'.substr(4,2) + '/' + '${END_DATE}'.substr(6,2);

            for (var i in printData) {
                var printHd = printData[i];
                var hd = printHd[0];
                html = "<!-- 첫번째 납품명세서 -->\n";
                html += "<div class=\"page\">\n";
                html += "   <div class=\"issue_date pageSize\"><img src=\"/images/eversrm/logo/kakao_logo2.png\"></div>\n";
                html += "        <div class=\"title\">" + '${YEAR}' + "년 " + '${MONTH}' + "월 지표관리 Report</div>\n";
                html += "        <br>\n";
                html += "        <div class=\"header_section pageSize\">\n";
                html += "            <!-- 1. 기간 -->\n";
                html += "            <table class=\"header_table\" width=\"100%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col width=\"150\">\n";
                html += "                    <col width=\"*\">\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"20\">" + hd.DATE + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + fromToDate + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"20\">" + hd.CUST_NM + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.H_CUST_NM + "</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "        </div>\n";

                var dt1 = printHd[0]; // 당 월
                var dt2 = printHd[1]; // 전 월

                if (dt1 == null) dt1 = [];
                if (dt2 == null) dt2 = [];

                html += "<!-- 주요 거래현황 -->\n";
                html += "        <div class=\"item_section\">\n";
                html += "            <span class='text_title'>■ " + hd.TRANSACTION_STATUS + "</span>\n";
                html += "            <span class='text_title text_right'>" + hd.TRANSACTION_STATUS_SUB + "</span>\n";
                html += "            <table class=\"item_table\" width=\"100%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col width=\"150\">  <!-- 구분 -->\n";
                html += "                    <col width=\"*\">  <!-- 전 월 -->\n";
                html += "                    <col width=\"*\"> <!-- 당 월 -->\n";
                html += "                    <col width=\"100\"> <!-- 비고 -->\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <th>" + hd.SORTATION + "</th>\n";
                html += "                    <th>" + hd.PREV_MONTH + "</th>\n";
                html += "                    <th>" + hd.CURRENT_MONTH + "</th>\n";
                html += "                    <th>" + hd.REMARK + "</th>\n";
                html += "                </tr>\n";
                html += "                \n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.ORDER_CNT + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt2.CPO_CNT) + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt1.CPO_CNT) + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.DEAL_ITEM_CNT + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt2.ITEM_CNT) + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt1.ITEM_CNT) + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.SUPPLIER_CNT + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt2.VENDOR_CNT) + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt1.VENDOR_CNT) + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "<!-- 관리현황 -->\n";
                html += "            <span class='text_title'>■ " + hd.MANAGEMENT_STATUS + "</span>\n";
                html += "            <span class='text_title text_right'>" + hd.MANAGEMENT_STATUS_SUB + "</span>\n";
                html += "            <table class=\"item_table\" width=\"100%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col width=\"150\">  <!-- 구분 -->\n";
                html += "                    <col width=\"*\">  <!-- 전 월 -->\n";
                html += "                    <col width=\"*\"> <!-- 당 월 -->\n";
                html += "                    <col width=\"100\"> <!-- 비고 -->\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <th>" + hd.SORTATION + "</th>\n";
                html += "                    <th>" + hd.PREV_MONTH + "</th>\n";
                html += "                    <th>" + hd.CURRENT_MONTH + "</th>\n";
                html += "                    <th>" + hd.REMARK + "</th>\n";
                html += "                </tr>\n";
                html += "                \n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.SOURCING_READ_TIME + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt2.A_AVG_LT_DAY) + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt1.A_AVG_LT_DAY) + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.WEARING_READ_TIME + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt2.D_AVG_LT_DAY) + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt1.D_AVG_LT_DAY) + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.DELI_READ_TIME + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt2.C_AVG_LT_DAY) + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt1.C_AVG_LT_DAY) + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.PAYMENT + "</th>\n";
                html += "                    <td class=\"right no_bb\">" + dt2.STD_DELY_RATE + "</td>\n";
                html += "                    <td class=\"right no_bb\">" + dt1.STD_DELY_RATE + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "<!-- 실적현황 -->\n";
                html += "            <span class='text_title'>■ " + hd.PERFORMANCE_STATUS + "</span>\n";
                html += "            <span class='text_title text_right'>" + hd.PERFORMANCE_STATUS_SUB + "</span>\n";
                html += "            <table class=\"item_table\" width=\"100%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col width=\"150\">  <!-- 구분 -->\n";
                html += "                    <col width=\"*\">  <!-- 전 월 -->\n";
                html += "                    <col width=\"*\"> <!-- 당 월 -->\n";
                html += "                    <col width=\"100\"> <!-- 비고 -->\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <th>" + hd.SORTATION + "</th>\n";
                html += "                    <th>" + hd.PREV_MONTH + "</th>\n";
                html += "                    <th>" + hd.CURRENT_MONTH + "</th>\n";
                html += "                    <th>" + hd.REMARK + "</th>\n";
                html += "                </tr>\n";
                html += "                \n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.CPO_AMT + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt2.D_CPO_ITEM_AMT) + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt1.D_CPO_ITEM_AMT) + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.SALES_AMT + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt2.D_GR_ITEM_AMT) + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt1.D_GR_ITEM_AMT) + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.PROFIT_AMT + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt2.D_PROFIT_AMT) + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + $.number(dt1.D_PROFIT_AMT) + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <th class=\"center no_bb\">" + hd.PROFIT_RATE + "</th>\n";
                html += "                    <td class=\"right no_bb\"> " + dt2.D_PROFIT_RATE + "</td>\n";
                html += "                    <td class=\"right no_bb\"> " + dt1.D_PROFIT_RATE + "</td>\n";
                html += "                    <td class=\"left no_bb\"></td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "        </div>\n";
                html += "        <div class=\"logo\"><img alt=\"\" src=\"/images/kakao/common/yongma_logo_eng.png\" style=\"width: 205px;\"></div>\n";
                html += "</div>\n";
                $('#view').append(html);
            }

            $('.no_bb').each(function (k, v) {
                if ($(v).text().indexOf('undefined') > -1) {
                    $(v).text($(v).text().replace('undefined', 0));
                }
            });
        });

    </script>
</head>
<!-- 화면 LOAD시 프린트 -->
<body onLoad="window.print();">
<div id="view">

</div>
</body>
</html>
