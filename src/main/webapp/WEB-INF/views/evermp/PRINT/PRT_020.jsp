<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>견적서</title>
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
            padding: 14px 14px 25px 14px;
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
            /*
            float: left;
            right: 20px;
            top: -35px;
            */
            position: relative;
            text-align: left;
            width: 770px;
            left: 20px;
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

        .header_table_l {
            /*display: block;*/
            font-size: 15px;
            text-align: left;
            table-layout: fixed;
            /*border-spacing: 2px;*/
            border-collapse: collapse;
            /*border: 1px solid #000;*/
            font-weight: bold;
            line-height: 10px;
        }

        .header_table_r {
            /*display: block;*/
            font-size: 15px;
            text-align: right;
            table-layout: fixed;
            /*border-spacing: 2px;*/
            border-collapse: collapse;
            /*border: 1px solid #000;*/
            font-weight: bold;
            line-height: 10px;
        }

        .top_header_title {
            font-size: 10px;
            line-height: 10px;
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
            margin: 1.8cm auto 0.1cm;
            height: 580px;
            width: 755px;
        }

        .sum_section {
            margin: 0 auto 0.1cm;
            height: 40px;
            vertical-align: middle;
            text-align: center;
            width: 755px;
        }

        .footer {
            margin: 1cm auto;
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
            height: 26px;
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
            left: 251px;
            top: 2px;
        }

        .footer_title {
            font-size: 10px;
            font-weight: bold;
            padding: 0 0 0 20px;
        }

        #container {
            width: 100%;
        }

        #left {
            float:left;
            width:50%;
            height: 190px;
            text-align: left;
        }

        #center {
            display: inline-block;
            margin:0 auto;
            width:100px;
        }

        #right {
            float:right;
            width:50%;
            height: 190px;
            text-align: right;
        }

        .space {
            margin: 0;
            padding: 1px 0 0 0;
        }
    </style>
    <script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
    <script>
        var html = "";
        var printData = ${printData};

        $(document).ready(function () {
            var o_ceo_nm = "", v_ceo_nm = "";
            for (var i in printData) {
                var printHd = printData[i];
                var hd = printHd[0];
                html = "<!-- 첫번째 납품명세서 -->\n";
                html += "<div class=\"page\">\n";
                html += "   <div class=\"issue_date pageSize\">&nbsp;</div>\n";
                html += "   <div class=\"title\">" + hd.HEADER_CAPTION + "</div>\n";
                html += "   <div class=\"logo\"><img alt=\"\" src=\"/images/kakao/common/dspmro_logo_all_A.png\" style=\"width: 150px; height: auto;\"></div>\n";
                html += "   <br>\n";
                html += "        <div class=\"header_section pageSize\">\n";
                html += "           <div id=\"container\">\n";
                html += "               <!-- 1. 발신자 -->\n";
                html += "               <div id=\"left\">\n";
                html += "                   <p class='header_table_l'>"+ hd.RECV +" : "+ hd.BUYER_NM +"</p>\n";
                for(var n in hd.O_CEO_USER_NM) {
                    if(i == 0) {
                        o_ceo_nm += hd.O_CEO_USER_NM[n] + " ";
                    }
                }
                html += "                   <p class='header_table_l'>"+ hd.CEO_NAME +"&nbsp;&nbsp;"+ o_ceo_nm +"</p>\n";
                html += "                   <p class='space'>\n";
                html += "                   <p class='top_header_title'>"+ hd.TEL_NO +" : "+ hd.O_TEL_NUM +", "+ hd.FAX_NO +" : "+ hd.O_FAX_NUM +"</p>\n";
                html += "                   <p class='top_header_title'>"+ hd.USER_NM +" : "+ hd.O_DEPT_NM + " " + hd.O_USER_NM + " " + hd.O_POSITION_NM+"</p>\n";
                html += "                   <p class='top_header_title'>"+ hd.EMAIL +" : "+ hd.O_EMAIL +"</p>\n";
                html += "                   <p class='top_header_title'>"+ hd.HEADER_ISSUE_DATE +" : "+ hd.ISSUE_DATE +"</p>\n";
                html += "               </div>\n";
                html += "               <div id=\"right\">\n";
                html += "               <!-- 2. 수신자 -->\n";
                html += "                   <p class='header_table_r'>"+ hd.SEND +" : "+ hd.V_VENDOR_NM +"</p>\n";
                html += "                   <p class='header_table_r''>"+ hd.V_HQ_ADDR +"</p>\n";
                for(var n in hd.V_CEO_USER_NM) {
                    if(i == 0) {
                        v_ceo_nm += hd.V_CEO_USER_NM[n] + " ";
                    }
                }
                html += "                   <p class='header_table_r'>"+ hd.CEO_NAME +"&nbsp;&nbsp;"+ v_ceo_nm +"</p>\n";
                html += "                   <p class='space'>\n";
                html += "                   <p class='top_header_title'>"+ hd.TEL_NO +" : "+ hd.V_TEL_NUM +", "+ hd.FAX_NO +" : "+ hd.V_FAX_NUM +"</p>\n";
                html += "                   <p class='top_header_title'>"+ hd.USER_NM +" : "+ hd.V_DEPT_NM + " " + hd.V_USER_NM + " " + hd.V_POSITION_NM+"</p>\n";
                html += "                   <p class='top_header_title'>"+ hd.EMAIL +" : "+ hd.V_EMAIL +"</p>\n";
                html += "               </div>\n";
                html += "           </div>\n";
                html += "        </div>\n";
                html += "<!-- 품목리스트 -->\n";
                html += "        <div class=\"item_section\">\n";
                html += "            <span class='text_title' style=\"color:red;font-weight:bold; font-size:11px;\">" + hd.RFQ_NO + " : " + hd.RFQ_NUM + "</span>\n";
                html += "            <div  class=\"text_title\" style=\"float:right\">현재 페이지 : (" + hd.CURRENT_PAGE + "/" + hd.TOTAL_PAGE + " Page)&nbsp;</div>\n";
                html += "            <br>\n";
                html += "            <table class=\"item_table\" width=\"100%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col width=\"30\">  <!-- NO -->\n";
                html += "                    <col width=\"90\">  <!-- 품목코드 -->\n";
                html += "                    <col width=\"*\"> <!-- 품명 -->\n";
                html += "                    <col width=\"50\">  <!-- 단위 -->\n";
                html += "                    <col width=\"100\">  <!-- 단가 -->\n";
                html += "                    <col width=\"100\">  <!-- 금액 -->\n";
                html += "                    <col width=\"100\">  <!-- 희망납기일 -->\n";
                html += "                </colgroup>\n";
                html += "                <tr style=\"height:26px;\">\n";
                html += "                    <th rowspan=\"2\">" + hd.NO + "</th>\n";
                html += "                    <th>" + hd.ITEM_CD + "</th>\n";
                html += "                    <th>" + hd.ITEM_DESC + "</th>\n";
                html += "                    <th>" + hd.UNIT_CD + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.UNIT_PRC + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.UNIT_AMT + "</th>\n";
                html += "                    <th rowspan=\"2\">" + hd.MODEL + "</th>\n";
                html += "                </tr>\n";
                html += "                <tr style=\"height:26px;\">\n";
                html += "                    <th colspan=\"2\">" + hd.ITEM_SPEC + "</th>\n";
                html += "                    <th>" + hd.QTY + "</th>\n";
                html += "                </tr>\n";
                html += "                \n";
                for (var j in printHd) {
                    var dt = printHd[j];
                    html += "                <tr>\n";
                    html += "                    <td class=\"center no_bb\" rowspan=\"2\">" + dt.GRID_ITEM_NO + "</td>\n";
                    html += "                    <td class=\"center no_bb\">" + dt.DT_ITEM_CD + "</td>\n";
                    html += "                    <td class=\"left   no_bb\">" + dt.DT_ITEM_DESC + "</td>\n";
                    html += "                    <td class=\"center no_bb\">" + dt.DT_UNIT_CD + "</td>\n";
                    html += "                    <td class=\"right  no_bb\" rowspan=\"2\">" + dt.DT_QTA_UNIT_PRC + "</td>\n";
                    html += "                    <td class=\"right   no_bb\" rowspan=\"2\">" + dt.DT_QTA_UNIT_AMT + "</td>\n";
                    html += "                    <td class=\"center   no_bb\" rowspan=\"2\">" + dt.DT_MAKER_MODEL + "</td>\n";
                    html += "                </tr>\n";
                    html += "                <tr>\n";
                    html += "                    <td class=\"left  no_bb\" colspan=\"2\">" + dt.DT_ITEM_SPEC + "</td>\n";
                    html += "                    <td class=\"center no_bb\">" + dt.DT_QTY + "</td>\n";
                    html += "                </tr>\n";
                }

                for (var j = 0; j < 10 - printHd.length; j++) {
                    html += "                    <tr>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                        <td class=\"no_bb\" rowspan=\"2\" height=\"20\"></td>\n";
                    html += "                    </tr>\n";
                    html += "                <tr>\n";
                    html += "                    <td class=\"no_bb\" colspan=\"2\" height=\"20\"></td>\n";
                    html += "                    <td class=\"no_bb\" height=\"20\"></td>\n";
                    html += "                </tr>\n";
                }
                html += "            </table>\n";
                html += "        </div>\n";
                html += "\n";
                html += "<!-- 합계 나오는 부분 -->\n";
                html += "        <div class=\"sum_section\">\n";
                html += "            <table class=\"footer_table\" width=\"100%\" border=\"1\" style=\"float: left; border-bottom: 2px solid #000; border-left: 2px solid #000; border-right: 2px solid #000;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"119\">\n";
                html += "                    <col class=\"center\" width=\"284\">\n";
                html += "                    <col class=\"right\" width=\"*\">\n";
                html += "                </colgroup>\n";
                html += "                <tr>\n";
                html += "                    <td class=\"header_title\" >전체 : " + hd.GROUP_CNT + " 건</td>\n";
                html += "                    <td class=\"header_title\" style=\"font-weight: bold;\" >합&nbsp;&nbsp;&nbsp;계</td>\n";
                html += "                    <td style=\"font-weight: bold;text-align: right\">" + hd.GROUP_AMT + " 원 (VAT별도)</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "        </div>\n";
                html += "\n";
                html += "        <!-- 정보 -->\n";
                html += "        <div class=\"footer\" style=\"width: 755px;\">\n";
                html += "            <!-- 비고 -->\n";
                html += "            <table class=\"item_table\" width=\"100%\" border=\"1\" style=\"float: left;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col width=\"120\">\n";
                html += "                    <col width=\"284\">\n";
                html += "                    <col width=\"120\">\n";
                html += "                    <col width=\"*\">\n";
                html += "                </colgroup>\n";
                html += "                <tr height=\"25\">\n";
                html += "                    <th class=\"center\">" + hd.CONT_DATE + "</th>\n";
                html += "                    <td class=\"center\">" + hd.CONT_DATE_N + "</td>\n";
                html += "                    <th class=\"center\">" + hd.DELY_CON + "</th>\n";
                html += "                    <td class=\"center\">" + hd.DELY_CON_N + "</td>\n";

                html += "                </tr>\n";
                html += "                <tr height=\"100\">\n";
                html += "                    <th class=\"center\">" + hd.REMARK + "</th>\n";
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
