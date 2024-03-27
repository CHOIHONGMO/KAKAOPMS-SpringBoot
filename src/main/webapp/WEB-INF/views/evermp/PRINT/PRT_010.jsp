<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>주문서</title>
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
            margin: 2.5cm auto 0.1cm;
            height: 580px;
            width: 755px;
        }

        .sum_section {
            margin: 0cm auto 0.1cm;
            height: 40px;
            vertical-align: middle;
            text-align: center;
            width: 755px;
        }

        .footer {
            margin: 2.5cm auto 0.1cm;
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
            height: 30px;
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
            left: 635px;
            top: 10px;
        }

        .footer_title {
            font-size: 10px;
            font-weight: bold;
            padding: 0 0 0 20px;
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
                html += "   <div class=\"issue_date pageSize\"></div>\n";
                html += "        <div class=\"title\">" + hd.HEADER_CAPTION + "</div>\n";
                html += "        <div class=\"logo\"><img alt=\"\" src=\"/images/kakao/common/(주)대명소노시즌_logo.png\" style=\"width: 150px; height: auto;\"></div>\n";
                html += "        <br>\n";
                html += "        <div class=\"header_section pageSize\">\n";
                html += "            <!-- 1. 발신자 -->\n";
                html += "            <table class=\"header_table\" width=\"49.5%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"30\">\n";
                html += "                    <col class=\"left\"   width=\"90\">\n";
                html += "                    <col class=\"left\"   width=\"*\">\n";
                html += "                    <col class=\"left\"   width=\"50\">\n";
                html += "                    <col class=\"left\"   width=\"*\">\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td style=\"font-weight: bold;background-color: #dff8ff;padding: 5px;\" rowspan=\"6\">" + hd.SENDER + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.MUTUAL + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.CUST_NM + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.CEO + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.C_CEO_USER_NM + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.ADDR + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\" style=\"text-align: left;\">" + hd.C_ADDR + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.USER_NM + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.C_USER_NM + " "+ hd.C_POSITION_NM + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.DEPT_NM + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.C_DEPT_NM + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.TEL_NUM + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.C_TEL_NUM + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.FAX_NUM + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.C_FAX_NUM + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.EMAIL + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.C_EMAIL + "</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "            <!-- 2. 수신자 -->\n";
                html += "            <table class=\"header_table\" width=\"49.5%\" border=\"1\" style=\"float: right;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"30\">\n";
                html += "                    <col class=\"left\" width=\"90\">\n";
                html += "                    <col class=\"left\" width=\"*\">\n";
                html += "                    <col class=\"left\" width=\"60\">\n";
                html += "                    <col class=\"left\" width=\"*\">\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td style=\"font-weight: bold;background-color: #dff8ff;padding: 5px;\" rowspan=\"6\">" + hd.RECEIVER + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.MUTUAL + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.BUYER_NM + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.CEO + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.O_CEO_USER_NM + "</td>\n";
                html += "                   <div class=\"sign\"><img class=\"signImg\" alt=\"\" src=\"/images/kakao/common/bizneworks_company_sign.png\"></div>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.ADDR + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\" style=\"text-align: left;\">" + hd.O_ADDR + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.USER_NM + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.O_USER_NM + " "+ hd.O_POSITION_NM + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.DEPT_NM + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.O_DEPT_NM + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.TEL_NUM + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.O_TEL_NUM + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.FAX_NUM + "</td>\n";
                html += "                    <td class=\"header_text\">" + hd.O_FAX_NUM + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" height=\"30\">" + hd.EMAIL + "</td>\n";
                html += "                    <td class=\"header_text\" colspan=\"3\">" + hd.O_EMAIL + "</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "        </div>\n";
                html += "<!-- 품목리스트 -->\n";
                html += "        <div class=\"item_section\">\n";
                html += "            <span class='text_title' style=\"color:red;font-weight:bold\">" + hd.RFQ_NO + " : " + hd.RFQ_NUM + "</span>\n";
                html += "            <div  class=\"text_title\" style=\"float:right\">현재 페이지 : (" + hd.CURRENT_PAGE + "/" + hd.TOTAL_PAGE + " Page)&nbsp;</div>\n";
                html += "            <br>\n";
                html += "            <table class=\"item_table\" width=\"100%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col width=\"30\">  <!-- NO -->\n";
                html += "                    <col width=\"90\">  <!-- 품명 -->\n";
                html += "                    <col width=\"*\"> <!-- 규격 -->\n";
                html += "                    <col width=\"30\">  <!-- 단위 -->\n";
                html += "                    <col width=\"60\">  <!-- 수량 -->\n";
                html += "                    <col width=\"94\">  <!-- 제조사 -->\n";
                html += "                    <col width=\"94\">  <!-- 원산지 -->\n";
                html += "                    <col width=\"94\">  <!-- 비고 -->\n";
                html += "                </colgroup>\n";
                html += "                <tr style=\"height:30px;\">\n";
                html += "                    <th>" + hd.NO + "</th>\n";
                html += "                    <th>" + hd.ITEM_DESC + "</th>\n";
                html += "                    <th >" + hd.ITEM_SPEC + "</th>\n";
                html += "                    <th>" + hd.UNIT_CD + "</th>\n";
                html += "                    <th>" + hd.QTY + "</th>\n";
                html += "                    <th>" + hd.MAKER + "</th>\n";
                html += "                    <th>" + hd.ORIGIN_NM + "</th>\n";
                html += "                    <th>" + hd.REMARK + "</th>\n";
                html += "                </tr>\n";
                html += "                \n";
                for (var j in printHd) {
                    var dt = printHd[j];
                    html += "                <tr>\n";
                    html += "                    <td class=\"center no_bb\">" + dt.GRID_ITEM_NO + "</td>\n";
                    html += "                    <td class=\"center no_bb\">" + dt.DT_ITEM_DESC + "</td>\n";
                    html += "                    <td class=\"left   no_bb\">" + dt.DT_ITEM_SPEC + "</td>\n";
                    html += "                    <td class=\"center no_bb\">" + dt.DT_UNIT_CD + "</td>\n";
                    html += "                    <td class=\"center no_bb\">" + dt.DT_QTY + "</td>\n";
                    html += "                    <td class=\"center no_bb\">" + dt.DT_MAKER + "</td>\n";
                    html += "                    <td class=\"center no_bb\">" + dt.DT_ORIGIN_NM + "</td>\n";
                    html += "                    <td class=\"left   no_bb\"></td>\n";
                    html += "                </tr>\n";
                }
                for (var j = 0; j < 20 - printHd.length; j++) {
                    html += "                    <tr>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                    </tr>\n";
                }
                html += "            </table>\n";
                html += "        </div>\n";
                html += "\n";
                html += "        <div class=\"footer\" style=\"width: 755px;\">\n";
                html += "            <table class=\"footer_table\" width=\"100%\" border=\"1\" style=\"float: left; height: 100px;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"120\">\n";
                html += "                    <col class=\"left\"   width=\"262\">\n";
                html += "                    <col class=\"left\"   width=\"120\">\n";
                html += "                    <col class=\"left\"   width=\"*\">\n";
                html += "                </colgroup>\n";
                html += "                <tr height=\"30\">\n";
                html += "                    <th class=\"header_title\">" + hd.HD_REG_DATE + "</th>\n";
                html += "                    <td class='center'>" + hd.REG_DATE + "</td>\n";
                html += "                    <th class=\"header_title\">" + hd.DELY_CON + "</th>\n";
                html += "                    <td class='center'>" + hd.DELY_CON_N + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr height=\"30\">\n";
                html += "                    <th class=\"header_title\">" + hd.HD_RFQ_CLOSE_DATE + "</th>\n";
                html += "                    <td class='center'>" + hd.RFQ_CLOSE_DATE + "</td>\n";
                html += "                    <th class=\"header_title\">" + hd.PRICE_PAY + "</th>\n";
                html += "                    <td></td>\n";
                html += "                </tr>\n";
                html += "                <tr height=\"70\">\n";
                html += "                    <td class=\"header_title\">" + hd.REMARK + "</td>\n";
                html += "                    <td colspan='3'></td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "        </div>\n";
                html += "</div>\n";
                $('#view').append(html);
            }
        });

    </script>
</head>
<!-- 화면 LOAD시 프린트 -->
<body onLoad="window.print();">
<div id="view">

</div>
</body>
</html>
