<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <title>협력업체 자격심사</title>
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
            font-weight: bold;
            display: block;
            margin: 2cm auto 0.1cm;
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
            font-size: 12px;
            text-align: center;
            background-color: #dff8ff;
            font-weight: bold;
            border-bottom: 1px;
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
            margin: 2.2cm auto 6.1cm;
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
            font-size: 12px;
            border-bottom: 1px;
        }

        .pageSize {
            width: 750px;
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
    </style>
    <script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
    <script type="text/javascript" src="/js/ever-string.js"></script>
    <script type="text/javascript" src="/js/ever-math.js"></script>
    <script>
        var html = "";
        var formValue = ${form2};
        var EVVM = formValue.EVVM;
        var ev_type = formValue.ev_type;
        var ev_subject = formValue.ev_subject;
        var tot_score = 0;

        $(document).ready(function () {
                html = "<!-- 협력업체 자격심사 -->\n";
                html += "<div class=\"page\">\n";
                html += "        <div class=\"title\" style='text-decoration: underline;'>" + "협력업체 자격심사" + "</div>\n";
                html += "        <br><br><br>\n";
                html += "        <div class=\"header_section pageSize\">\n";
                html += "            <table class=\"header_table\" width=\"100%\" border=\"1\" style=\"float: left;border-bottom: 0px;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"140\">\n";
                html += "                    <col class=\"center\" width=\"460\">\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "심사일자" + "</td>\n";
                html += "                    <td class=\"header_text\" >" + (EVVM.REQUEST_DATE).substring(0, 4) + "년 " + (EVVM.REQUEST_DATE).substring(4, 6) + "월 " + (EVVM.REQUEST_DATE).substring(6, 8) + "일" + "</td>\n";
                html += "                </tr>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "회 사 명" + "</td>\n";
                html += "                    <td class=\"header_text\" >" + EVVM.VENDOR_NM + "</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "            <table class=\"header_table\" width=\"100%\" border=\"1\" style=\"float: left;border-bottom: 0px;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"60\">\n";
                html += "                    <col class=\"center\" width=\"80\">\n";
                html += "                    <col class=\"center\" width=\"280\">\n";
                html += "                    <col class=\"center\" width=\"45\">\n";
                html += "                    <col class=\"center\" width=\"45\">\n";
                html += "                    <col class=\"center\" width=\"45\">\n";
                html += "                    <col class=\"center\" width=\"45\">\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "구분" + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "평가항목" + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "평가기준" + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "배점" + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "현황" + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "점수" + "</td>\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "비고" + "</td>\n";
                html += "                </tr>\n";
            for(var i in ev_type) {
                var TYPE = ev_type[i];
                var jj = 0;

                for(var j in ev_subject) {
                    var SUBJECT = ev_subject[j];

                    if(TYPE.EV_ITEM_TYPE_CD == SUBJECT.EV_ITEM_TYPE_CD) {
                        var EV_ITEM_CONTENTS_ADD = SUBJECT.EV_ITEM_CONTENTS_ADD;
                        EV_ITEM_CONTENTS_ADD = EV_ITEM_CONTENTS_ADD.replace(",", "");
                        EV_ITEM_CONTENTS_ADD = "점수 = " + EV_ITEM_CONTENTS_ADD;

                        var RESULT_VALUE = SUBJECT.RESULT_VALUE;
                        tot_score += SUBJECT.EV_SCORE;

                        if(TYPE.EV_ITEM_CNT == "1") {
                            EV_ITEM_CONTENTS_ADD = EV_ITEM_CONTENTS_ADD.replace(/,/gi, ",&nbsp;");

                            html += "                <tr class=\"center\">\n";
                            html += "                    <td class=\"header_text\" height=\"27\" rowspan='" + TYPE.EV_ITEM_CNT + "'>" + TYPE.EV_ITEM_TYPE_NM + "</td>\n";
                            html += "                    <td class=\"header_text\" height=\"27\">" + SUBJECT.EV_ITEM_SUBJECT + "</td>\n";
                            html += "                    <td class=\"header_text left\" height=\"27\"><table class='header_table' width='100%' style='border-bottom: 1px #cccccc solid;'><tr><td class='header_text' height='27' >" + SUBJECT.EV_ITEM_CONTENTS + "</td></tr></table>\n";
                            html += "                                                                 <table class='header_table' border='0' ><tr><td class='header_text' height='27'>" + EV_ITEM_CONTENTS_ADD + "</td></tr></table>" + "</td>\n";
                            html += "                    <td class=\"header_text\" height=\"27\">" + SUBJECT.EV_ID_SCORE + "</td>\n";
                            html += "                    <td class=\"header_text\" height=\"27\">" + (RESULT_VALUE==null?"":RESULT_VALUE) + "</td>\n";
                            html += "                    <td class=\"header_text\" height=\"27\">" + (SUBJECT.EV_SCORE==null?"":SUBJECT.EV_SCORE) + "</td>\n";
                            html += "                    <td class=\"header_text\" height=\"27\">" + "" + "</td>\n";
                            html += "                </tr>\n";
                        } else {
                            if(jj == "0") {
                                html += "                <tr class=\"center\">\n";
                                html += "                    <td class=\"header_text\" height=\"27\" rowspan='" + (TYPE.EV_ITEM_CNT+3) + "'>" + TYPE.EV_ITEM_TYPE_NM + "</td>\n";
                                html += "                </tr>\n";
                            }

                            if(jj == "0" || jj == "1") {
                                var s = EV_ITEM_CONTENTS_ADD.split(",");
                                EV_ITEM_CONTENTS_ADD = s[0] + ",&nbsp;" + s[1] + ",&nbsp;" + s[2] + ",<br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + s[3] + ",&nbsp;" + s[4] + "";
                            } else {
                                EV_ITEM_CONTENTS_ADD = EV_ITEM_CONTENTS_ADD.replace(/,/gi, ",&nbsp;");
                            }

                            if(jj == "1") {
                                RESULT_VALUE = RESULT_VALUE.substring(0, RESULT_VALUE.length - 1) + "%";
                                var t = SUBJECT.RESULT_VALUE_ADD.split(",");
                                var sum = (t[0] * 10) + (t[1] * 8) + (t[2] * 6) + (t[3] * 4);
                                var per = sum / 60 * 100;
                                per = everMath.round_float(per, 2) + "%";

                                html += "                <tr class=\"center\">\n";
                                html += "                    <td class=\"header_text\" height=\"27\" rowspan='3'>" + SUBJECT.EV_ITEM_SUBJECT + "</td>\n";
                                html += "                </tr>\n";
                                html += "                <tr class=\"center\">\n";
                                html += "                    <td class=\"header_text left\" height=\"27\"><table class='header_table' width='100%' style='border-bottom: 1px #cccccc solid;'><tr><td class='header_text' height='27'>" + SUBJECT.EV_ITEM_CONTENTS + "</td></tr></table>\n";
                                html += "                                                                 <table class='header_table' border='0' ><tr><td class='header_text' height='27'>" + EV_ITEM_CONTENTS_ADD + "</td></tr></table>" + "</td>\n";
                                html += "                    <td class=\"header_text\" height=\"27\">" + SUBJECT.EV_ID_SCORE + "</td>\n";
                                html += "                    <td class=\"header_text\" height=\"27\">" + (RESULT_VALUE==null?"":RESULT_VALUE) + "</td>\n";
                                html += "                    <td class=\"header_text\" height=\"27\">" + (SUBJECT.EV_SCORE==null?"":SUBJECT.EV_SCORE) + "</td>\n";
                                html += "                    <td class=\"header_text\" height=\"27\">" + "" + "</td>\n";
                                html += "                </tr>\n";
                                html += "                <tr class=\"center\">\n";
                                html += "                    <td class=\"header_text left\" height=\"27\" colspan='5'><table><tr><td class='header_text' width='405' height='27'>특급기술자 : 표준인원 1명, 가중치 10점</td><td class='header_text center'>" + t[0] + " 명</td></tr>\n";
                                html += "                                                                             <tr><td class='header_text' height='27'>고급기술자 : 표준인원 2명, 가중치  8점</td><td class='header_text center'>" + t[1] + " 명</td></tr>\n";
                                html += "                                                                             <tr><td class='header_text' height='27'>중급기술자 : 표준인원 3명, 가중치  6점</td><td class='header_text center'>" + t[2] + " 명</td></tr>\n";
                                html += "                                                                             <tr><td class='header_text' height='27'>초급기술자 : 표준인원 4명, 가중치  4점</td><td class='header_text center'>" + t[3] + " 명</td></tr>\n";
                                html += "                                                                             <tr><td class='header_text' height='27'>계량점수 : ∑(등급별 인원 × 등급별 가중치)</td><td class='header_text center'>" + sum + "</td></tr>\n";
                                html += "                                                                             <tr><td class='header_text' height='27'>인력보유비율% : 계량점수 ÷ 표준계량점수(60) × 100 =</td><td class='header_text center'>" + per + "</td></tr></table></td>\n";
                                html += "                </tr>\n";
                            } else {
                                html += "                <tr class=\"center\">\n";
                                html += "                    <td class=\"header_text\" height=\"27\">" + SUBJECT.EV_ITEM_SUBJECT + "</td>\n";
                                html += "                    <td class=\"header_text left\" height=\"27\"><table class='header_table' width='100%' style='border-bottom: 1px #cccccc solid;'><tr><td class='header_text' height='27'>" + SUBJECT.EV_ITEM_CONTENTS + "</td></tr></table>\n";
                                html += "                                                                 <table class='header_table' border='0' ><tr><td class='header_text' height='27'>" + EV_ITEM_CONTENTS_ADD + "</td></tr></table>" + "</td>\n";
                                html += "                    <td class=\"header_text\" height=\"27\">" + SUBJECT.EV_ID_SCORE + "</td>\n";
                                html += "                    <td class=\"header_text\" height=\"27\">" + (RESULT_VALUE==null?"":RESULT_VALUE) + "</td>\n";
                                html += "                    <td class=\"header_text\" height=\"27\">" + (SUBJECT.EV_SCORE==null?"":SUBJECT.EV_SCORE) + "</td>\n";
                                html += "                    <td class=\"header_text\" height=\"27\">" + "" + "</td>\n";
                                html += "                </tr>\n";
                            }


                            jj++;
                        }
                    }
                }
            }
                html += "            </table>\n";
                html += "            <table class=\"header_table\" width=\"100%\" border=\"1\" style=\"float: left;border-bottom: 0px;\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"420\">\n";
                html += "                    <col class=\"center\" width=\"45\">\n";
                html += "                    <col class=\"center\" width=\"45\">\n";
                html += "                    <col class=\"center\" width=\"45\">\n";
                html += "                    <col class=\"center\" width=\"45\">\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_title\" height=\"35\">" + "총&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;점" + "</td>\n";
                html += "                    <td class=\"header_title\" >" + "100" + "</td>\n";
                html += "                    <td class=\"header_title\" >" + "</td>\n";
                html += "                    <td class=\"header_title\" >" + tot_score + "</td>\n";
                html += "                    <td class=\"header_title\" >" + "</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";

            var RMK = ev_subject[0].RMK;
            var rmk_text = "";

            if(RMK != "" && RMK != null && RMK != "null") {
                var tmp = RMK.split("@,@");

                for(var ii in tmp) {
                    if(tmp[ii] != "") {
                        rmk_text += "- " + tmp[ii] + "<br><br>";
                    }
                }

            }
                html += "            <table class=\"header_table\" width=\"100%\" border=\"1\">\n";
                html += "                <colgroup>\n";
                html += "                    <col class=\"center\" width=\"600\">\n";
                html += "                </colgroup>\n";
                html += "                <tr class=\"center\">\n";
                html += "                    <td class=\"header_text left\" height=\"170\" style='vertical-align: top;'>" + "[평가의견]<br>" + rmk_text + "</td>\n";
                html += "                </tr>\n";
                html += "            </table>\n";
                html += "        </div>\n";
                html += "</div>\n";
                $('#view').append(html);
        });

    </script>
</head>
<body onLoad="window.print();">
<%--<body>--%>
    <div id="view">
    </div>
</body>
</html>
