<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>매입</title>
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
            font-size: 22px;
            /*font-weight: bold;*/
            display: block;
            margin: 1cm auto 0.1cm;
            width: 21cm;
            height: 1cm;
            text-align: center;
            vertical-align: middle;
            /*border-bottom: 1px solid #000;*/
        }

        .issue_date {
            position: relative;
            left: 0;
            top: 30px;
            font-size: 10px;
        }

        .logo {
            position: relative;
            float: right;
            top: -35px;
            text-align: right;
            width: 770px;
            right: 20px;
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
            font-size: 10px;
            text-align: center;
            background-color: #dff8ff;
            font-weight: bold;
        }

        .text_title {
            font-size: 10px;
            line-height: 23px;
            float: left;
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
            background-color: #dff8ff;
            font-weight: bold;
            text-align: center;
            font-size: 10px;
            vertical-align: middle;
            border-bottom: 1px solid #000;
        }

        .item_table td {
            font-weight: normal;
            font-size: 10px;
            vertical-align: middle;
        }

        .item_section {
            margin: -2.5cm auto 0.1cm;
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
        }

        .center {
            text-align: center;
        }

        .no_bb {
            /*border-bottom: 1px solid #000;*/
            height: 24px;
            text-overflow: ellipsis;
            overflow: hidden;
            white-space: nowrap;
            width: 284px;
        }

        .header_text {
            font-weight: 100;
            font-size: 10px;
        }

        .pageSize {
            width: 755px;
            padding: 0 0 0 20px;
        }

        .sign {
            position: absolute;
        }

        .signImg {
            width: 50px;
            position: relative;
            left: 640px;
            top: -3px;
        }
    </style>
    <script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
    <script>
        var html = "";
        var printData = ${printData};

        $(document).ready(function () {
            for (var i in printData) {
                var printHd = printData[i];
                var hd = printHd[0];
                html = "<!-- 첫번째 납품명세서 -->\n";
                html += "<div class=\"page\">\n";
                html += "   <div class=\"issue_date pageSize\">" + hd.HEADER_ISSUE_DATE + " : " + hd.V_ISSUE_DATE + "</div>\n";
                html += "        <div class=\"title\">" + hd.HEADER_CAPTION + "</div>\n";
                html += "        <div class=\"logo\"><img alt=\"\" src=\"" +  "\" style=\"width: 0px; height: auto;\"></div>\n";
                html += "        <br>\n";
                html += "        <div class=\"header_section pageSize\">\n";
                html += "            <!-- 1. 공급받는자 -->\n";
                html += "            <table class=\"header_table\" width=\"49.5%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"30\">\n";
                html += "                    <col class=\"left\"   width=\"90\">\n";
                html += "                    <col class=\"left\"   width=\"*\">\n";
                html += "                    <col class=\"left\"   width=\"50\">\n";
                html += "                    <col class=\"left\"   width=\"*\">\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td style=\"font-weight: bold;background-color: #dff8ff;padding: 5px;\" rowspan=\"5\">" + hd.BUYER_CAPTION + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"20\">" + hd.BUYER_NAME + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.V_BUYER_NAME + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"20\">" + hd.BUYER_CEO_NAME + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.V_BUYER_CEO_NAME + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"20\">" + hd.BUYER_IRS_NO + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.V_BUYER_IRS_NO + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"40\">" + hd.BUYER_ADDRESS + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.V_BUYER_ADDRESS + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"50\">" + hd.BUYER_BUSINESS_TYPE + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.V_BUYER_BUSINESS_TYPE + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"50\">" + hd.BUYER_INDUSTRY_TYPE + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.V_BUYER_INDUSTRY_TYPE + "</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "            <!-- 2. 공급자 -->\n";
                html += "            <table class=\"header_table\" width=\"49.5%\" border=\"1\" style=\"float: right;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"30\">\n";
                html += "                    <col class=\"left\" width=\"90\">\n";
                html += "                    <col class=\"left\" width=\"*\">\n";
                html += "                    <col class=\"left\" width=\"60\">\n";
                html += "                    <col class=\"left\" width=\"*\">\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td style=\"font-weight: bold;background-color: #dff8ff;padding: 5px;\" rowspan=\"5\">" + hd.VENDOR_CAPTION + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"20\">" + hd.VENDOR_NAME + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.V_VENDOR_NAME + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"20\">" + hd.VENDOR_CEO_NAME + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.V_VENDOR_CEO_NAME + "</td>\n";
                html += "                   <div class=\"sign\"></div>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"20\">" + hd.VENDOR_IRS_NO + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.V_VENDOR_IRS_NO + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"40\">" + hd.VENDOR_ADDRESS + "</td>\n";
                html += "                    <td class=\"header_text\"colspan=\"3\">" + hd.V_VENDOR_ADDRESS + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"50\">" + hd.VENDOR_BUSINESS_TYPE + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.V_VENDOR_BUSINESS_TYPE + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"50\">" + hd.VENDOR_INDUSTRY_TYPE + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.V_VENDOR_INDUSTRY_TYPE + "</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "        </div>\n";
                html += "<!-- 품목리스트 -->\n";
                html += "        <div class=\"item_section\">\n";
                html += "            <span class='text_title' style=\"color:red;font-weight:bold\">" + hd.HEADER_CPO_NO + " : " + hd.V_CPO_NO + "</span>\n";
                html += "            <div  class=\"text_title\" style=\"float:right\">현재 페이지 : (" + hd.CURRENT_PAGE + "/" + hd.TOTAL_PAGE + " Page)&nbsp;</div>\n";
                html += "            <br>\n";
                html += "            <table class=\"item_table\" width=\"100%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col width=\"30\">  <!-- 순번 -->\n";
                html += "                    <col width=\"66\">  <!-- 품목코드 -->\n";
                html += "                    <col width=\"280\"> <!-- 품명 -->\n";
                html += "                    <col width=\"30\">  <!-- 단위 -->\n";
                html += "                    <col width=\"66\">  <!-- 발주량/잔량 -->\n";
                html += "                    <col width=\"51\">  <!-- 납품량 -->\n";
                html += "                    <col width=\"70\">  <!-- 단가 -->\n";
                html += "                    <col width=\"70\"> <!-- 공급가액 -->\n";
                html += "                    <col width=\"83\"> <!-- 제조사 -->\n";
                html += "                </colgroup>\n";
                html += "                <tr style=\"height:24px;\">\n";
                html += "                    <th rowspan=\"2\">" + hd.GRID_ITEM_NO + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.GRID_ITEM_CODE + "</th>\n";
                html += "                    <th>" + hd.GRID_ITEM_DESC + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.GRID_UNIT_MEASURE + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.GRID_QTY + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.GRID_INV_QTY + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.GRID_PRICE + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.GRID_AMT + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.GRID_MAKER_NAME + "</th>\n";
                html += "                </tr>\n";
                html += "                <tr style=\"height:24px;\">\n";
                html += "                    <th>" + hd.GRID_ITEM_SPEC + "</th>\n";
//                html += "                    <th>" + hd.GRID_RES_QTY + "</th>\n";
                html += "                </tr>\n";
                html += "                \n";
                for (var j in printHd) {
                    var dt = printHd[j];
                    html += "                <tr>\n";
                    html += "                    <td class=\"center no_bb\" rowspan=\"2\">" + (dt.V_GRID_ITEM_NO == null ? '' :dt.V_GRID_ITEM_NO)+ "</td>\n";
                    html += "                    <td class=\"center no_bb\" rowspan=\"2\">" + (dt.V_GRID_ITEM_CODE == null ? '' :dt.V_GRID_ITEM_CODE) + "</td>\n";
                    html += "                    <td class=\"left   no_bb\">" + dt.V_GRID_ITEM_DESC + "</td>\n";
                    html += "                    <td class=\"center no_bb\" rowspan=\"2\">" + dt.V_GRID_UNIT_MEASURE + "</td>\n";
                    html += "                    <td class=\"right  no_bb\" rowspan=\"2\">" + dt.V_GRID_CPO_QTY + "</td>\n";
                    html += "                    <td class=\"right  no_bb\" rowspan=\"2\">" + dt.V_GRID_INV_QTY + "</td>\n";
                    html += "                    <td class=\"right  no_bb\" rowspan=\"2\">" + dt.V_GRID_PRICE +"</td>\n";
                    html += "                    <td class=\"right  no_bb\" rowspan=\"2\">" + dt.V_GRID_AMT +"</td>\n";
                    html += "                    <td class=\"left   no_bb\" rowspan=\"2\">" + dt.V_GRID_MAKER_NAME + "</td>\n";
                    html += "                </tr>\n";
                    html += "                <tr>\n";
                    html += "                    <td class=\"left  no_bb\">" + dt.V_GRID_ITEM_SPEC + "</td>\n";
                    //html += "                    <td class=\"right no_bb\">" + dt.V_GRID_RES_QTY + "</td>\n";
                    html += "                </tr>\n";
                }

                for (var j = 0; j < 15 - printHd.length; j++) {
                    html += "                    <tr>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                    </tr>\n";
                    html += "                <tr>\n";
                    html += "                    <td class=\"no_bb\" height=\"20\"></td>\n";
//                    html += "                    <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                </tr>\n";
                }
                html += "            </table>\n";
                html += "        </div>\n";
                html += "\n";
                html += "<!-- 합계 나오는 부분 -->\n";
                html += "        <div class=\"sum_section\">\n";
                html += "            <table class=\"footer_table\" width=\"100%\" border=\"1\" style=\"float: left; border-bottom: 2px solid #000; border-left: 2px solid #000; border-right: 2px solid #000;\">\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" width=\"91\">전체 : " + hd.V_GROUP_CNT + " 건</td>\n";
                html += "                    <td class=\"header_title\" style=\"font-weight: bold;\" width=\"282\">합&nbsp;&nbsp;&nbsp;계</td>\n";
                html += "                    <td width=\"372\" style=\"font-weight: bold;text-align: right\">" + hd.V_GROUP_AMT + " 원 (VAT별도)</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "        </div>\n";
                html += "\n";




                html += "</div>\n";
                $('#view').append(html);
            }
        });

    </script>
</head>

<!-- 화면 LOAD시 프린트 -->
<body onLoad="">
<div id="view">
</div>
</body>
</html>
