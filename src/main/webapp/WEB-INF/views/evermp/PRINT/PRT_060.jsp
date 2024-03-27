<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>:: 전자세금계산서 ::</title>
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

        .page {
            background: white;
            width: 21cm;
            height: 29.7cm;
            display: block;
            margin: 0 auto;
            box-shadow: 0 0 0.5cm rgba(0, 0, 0, 0.5);
            padding: 14px 14px 25px 14px;
            position: relative;
        }

        td {font-size: 12px; line-height:150% ; color: #666666; }
        .content { left: 4%; position: absolute;}
        .taxBillDivision	{/* 세금계산서 division */margin-bottom:20px;}
        .taxBillFormDescription	{margin-bottom:5px;}
        .tax_invoice{width:749px; margin-top:20px; color: #666;}
        /******************* Red **********************/
        .tax_table {position:relative; border:#e66464 solid 1px; padding:1px; z-index:99999; width:745px; }
        /* 테이블 헤더 start */
        .tax_invoice01 {border-top:#e66464 solid 1px; border-left:#e66464 solid 1px; border-right:#e66464 solid 1px; border-collapse:collapse; width:100%; table-layout:fixed;  z-index:999; position:relative;}
        .tax_invoice01 td {border-bottom:#e66464 solid 1px; color:#666; padding:2px 0 0 2px; background:none; }
        .tax_invoice01 th{padding:4px 0 1px 0; line-height:150%; color:#fe6d69; font-size:12px; font-weight:normal; border-bottom:#e66464 solid 1px;}
        .title{font-size:17px; font-weight:bold; color:#fe6d69; text-align:center;}
        .td2{text-align:center; letter-spacing:0.3em;}
        .tax_invoice01 td.td3{color:#666; border-left:#e66464 solid 1px; border-bottom:#e66464 solid 1px;}
        .td4{border-right:#e66464 solid 1px;}
        .cell_right01{text-align:right;}
        /* 테이블 헤더 end */
        /* 테이블 start */
        .tax_invoice02 {margin-top:1px; border-top:#e66464 solid 1px; border-right:#e66464 solid 1px; border-collapse:collapse; width:100%;  table-layout:fixed; word-break:break-all; z-index:999; position:relative;}
        .tax_invoice02 td {border-bottom:#e66464 solid 1px; border-left:#e66464 solid 1px; padding:2px 2px 0 2px; color:#666; vertical-align:middle; line-height:170%;}
        .tax_invoice02 th{border-bottom:#e66464 solid 1px; border-left:#e66464 solid 1px;  font-size:12px;  font-weight:normal; color:#fe6d69; text-align:center; padding:4px 0 1px 0; line-height:150%; vertical-align:middle;}
        .tax_invoice02 th .invoice02_th{border:none;  font-weight:normal; color:#fe6d69; text-align:center;}
        .tax_bold01{font-weight:bold; text-align:center; font-size:13px;}
        .tax_invoice02 .td_chargeL{text-align:left; padding:0; border-bottom:#e66464 solid 1px; border-left:0;}
        .tax_invoice02 .td_chargeR{text-align:right; padding:0; border-left:#e66464 solid 1px; border-bottom:#e66464 solid 1px;}
        .tax_invoice02 .td_chargeC{text-align:center; padding:0; border-left:0; border-top:0;}
        .tax_invoice02 .li0202{color:#666; font-weight:bold;}
        .tax_invoice02 .fontB{font-weight:bold;}
        .center{text-align:center;}
        .tax_invoice02 {border-left:#e66464 double 1px; border-left-width:3px;}
        .tax_invoice02 {color:#fe6d69; text-align:center; line-height:15px; padding:3px 0 0 0;}
        .td31{height:32px;}
        /* 테이블 end */

        .taxBillFormAttention	em	{font-style:normal;font-weight:bold;text-decoration:underline;}
    </style>
    <script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
    <script>
        var html = "";
        var printData = ${printData};

        $(document).ready(function() {
            for (var i in printData) {
                var printHd = printData[i];
                for (var j in printHd) {
                    var dt = printHd[j];
                    html = "<!-- 전자세금계산서 -->\n";
                    html += "<div class=\"page\">\n";
                    html += "<div class=\"content\">\n";
                    html += "    <table width=\"100%\" height=\"600\" summary=\"세금계산서\">\n";
                    html += "        <tbody>\n";
                    html += "        <tr valign=\"top\">\n";
                    html += "            <td id=\"DtiMessge\">\n";
                    html += "\n";
                    html += "                <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-16\">\n";
                    html += "                <title>:: 전자세금계산서 ::</title>\n";
                    html += "\n";
                    html += "                <div class=\"taxBillDivision\">\n";
                    html += "                    <p class=\"taxBillFormDescription\">\n";
                    html += "                        <b style=\"color:Red\"></b>\n";
                    html += "                    </p>\n";
                    html += "                    <div class=\"tax_invoice\">\n";
                    html += "                        <div class=\"tax_table\">\n";
                    html += "                            <table class=\"tax_invoice01\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\" summary=\"전자세금계산서 승인번호, 관리번호\">\n";
                    html += "                                <colgroup>\n";
                    html += "                                    <col width=\"41%\">\n";
                    html += "                                    <col width=\"15%\">\n";
                    html += "                                    <col width=\"5%\">\n";
                    html += "                                    <col width=\"12%\">\n";
                    html += "                                    <col width=\"%\">\n";
                    html += "                                </colgroup>\n";
                    html += "                                <tr>\n";
                    html += "                                    <th rowspan=\"2\">\n";
                    html += "                                        <h1 class=\"title\">전자세금계산서</h1>\n";
                    html += "                                    </th>\n";
                    html += "                                    <th rowspan=\"2\" class=\"td2\">\n";
                    html += "                                        공급자<br>(보관용)\n";
                    html += "                                    </th>\n";
                    html += "                                    <td rowspan=\"2\" class=\"td4\"></td>\n";
                    html += "                                    <th>승인번호</th>\n";
                    html += "                                    <td class=\"td3\">" + dt.TAX_EXD_ID + "</td>\n";
                    html += "                                </tr>\n";
                    html += "                                <tr>\n";
                    html += "                                    <th>관리번호</th>\n";
                    html += "                                    <td class=\"td3\"></td>\n";
                    html += "                                </tr>\n";
                    html += "                            </table>\n";
                    html += "                            <table class=\"tax_invoice02\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\" summary=\"공급자, 공급받는자 정보\">\n";
                    html += "                                <colgroup>\n";
                    html += "                                    <col width=\"3%\">\n";
                    html += "                                    <col width=\"8%\">\n";
                    html += "                                    <col width=\"17%\">\n";
                    html += "                                    <col width=\"1%\">\n";
                    html += "                                    <col width=\"7%\">\n";
                    html += "                                    <col width=\"\">\n";
                    html += "                                    <col width=\"3%\">\n";
                    html += "                                    <col width=\"8%\">\n";
                    html += "                                    <col width=\"17%\">\n";
                    html += "                                    <col width=\"1%\">\n";
                    html += "                                    <col width=\"7%\">\n";
                    html += "                                    <col width=\"\">\n";
                    html += "                                </colgroup>\n";
                    html += "                                <tr>\n";
                    html += "                                    <th class=\"title02-1 fontB\" rowspan=\"4\">공급자</th>\n";
                    html += "                                    <th>등록번호</th>\n";
                    html += "                                    <td class=\"tax_bold01\" colspan=\"4\">"+ dt.SIRS_NUM +"</td>\n";
                    html += "                                    <th class=\"title02-1 fontB\" rowspan=\"4\">공급받는자</th>\n";
                    html += "                                    <th>등록번호</th>\n";
                    html += "                                    <td class=\"tax_bold01\" colspan=\"4\">"+ dt.RIRS_NUM +"</td>\n";
                    html += "                                </tr>\n";
                    html += "                                <tr>\n";
                    html += "                                    <th>\n";
                    html += "                                        상호<br>(법인명)\n";
                    html += "                                    </th>\n";
                    html += "                                    <td colspan=\"2\">"+ dt.SCOM_NM +"</td>\n";
                    html += "                                    <th>성명</th>\n";
                    html += "                                    <td>"+ dt.SCEO_NM +"</td>\n";
                    html += "                                    <th>\n";
                    html += "                                        상호<br>(법인명)\n";
                    html += "                                    </th>\n";
                    html += "                                    <td colspan=\"2\">"+ dt.RCOM_NM +"</td>\n";
                    html += "                                    <th>성명</th>\n";
                    html += "                                    <td>"+ dt.RCEO_NM +"</td>\n";
                    html += "                                </tr>\n";
                    html += "                                <tr>\n";
                    html += "                                    <th>\n";
                    html += "                                        사업장<br>주소\n";
                    html += "                                    </th>\n";
                    html += "                                    <td colspan=\"2\">"+ dt.SADDR +"</td>\n";
                    html += "                                    <th>\n";
                    html += "                                        종사업<br>장번호\n";
                    html += "                                    </th>\n";
                    html += "                                    <td>"+ dt.SSUB_IRS_NUM +"</td>\n";
                    html += "                                    <th>\n";
                    html += "                                        사업장<br>주소\n";
                    html += "                                    </th>\n";
                    html += "                                    <td colspan=\"2\">"+ dt.RADDR +"</td>\n";
                    html += "                                    <th>\n";
                    html += "                                        종사업<br>장번호\n";
                    html += "                                    </th>\n";
                    html += "                                    <td>"+ dt.RSUB_IRS_NUM +"</td>\n";
                    html += "                                </tr>\n";
                    html += "                                <tr>\n";
                    html += "                                    <th>업태</th>\n";
                    html += "                                    <td colspan=\"2\">"+ dt.SBUSINESS_TYPE +"</td>\n";
                    html += "                                    <th>종목</th>\n";
                    html += "                                    <td>"+ dt.SINDUSTRY_TYPE +"</td>\n";
                    html += "                                    <th>업태</th>\n";
                    html += "                                    <td colspan=\"2\">"+ dt.RBUSINESS_TYPE +"</td>\n";
                    html += "                                    <th>종목</th>\n";
                    html += "                                    <td>"+ dt.RINDUSTRY_TYPE +"</td>\n";
                    html += "                                </tr>\n";
                    html += "                            </table>\n";
                    html += "                            <table class=\"tax_invoice02\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" summary=\"작성일자, 공급가액, 세액, 수정사유, 비고\">\n";
                    html += "                                <colgroup>\n";
                    html += "                                    <col width=\"11%\">\n";
                    html += "                                    <col width=\"25%\">\n";
                    html += "                                    <col width=\"25.1%\">\n";
                    html += "                                    <col width=\"\">\n";
                    html += "                                </colgroup>\n";
                    html += "                                <tbody>\n";
                    html += "                                <tr>\n";
                    html += "                                    <th class=\"fontB td31\">작성일자</th>\n";
                    html += "                                    <th class=\"fontB td31\">공급가액</th>\n";
                    html += "                                    <th class=\"fontB td31\">세 액</th>\n";
                    html += "                                    <th class=\"fontB td31\">비 고</th>\n";
                    html += "                                </tr>\n";
                    html += "                                <tr>\n";
                    html += "                                    <td class=\"center td31\">"+ dt.ISSUE_DATE +"</td>\n";
                    html += "                                    <td class=\"cell_right01 td31\">"+ dt.SUP_AMT +"</td>\n";
                    html += "                                    <td class=\"cell_right01 td31\">"+ dt.TAX_AMT +"</td>\n";
                    html += "                                    <td class=\"center\">"+ dt.REMARK +"</td>\n";
                    html += "                                </tr>\n";
                    html += "                                </tbody>\n";
                    html += "                            </table>\n";
                    html += "                            <table class=\"tax_invoice02\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\" summary=\"월, 일, 품목, 규격, 수량, 단가, 공급가액, 세액, 비고\">\n";
                    html += "                                <colgroup>\n";
                    html += "                                    <col width=\"3%\">\n";
                    html += "                                    <col width=\"3%\">\n";
                    html += "                                    <col width=\"\">\n";
                    html += "                                    <col width=\"8.4%\">\n";
                    html += "                                    <col width=\"8.4%\">\n";
                    html += "                                    <col width=\"8.4%\">\n";
                    html += "                                    <col width=\"17%\">\n";
                    html += "                                    <col width=\"13.9%\">\n";
                    html += "                                    <col width=\"8.4%\">\n";
                    html += "                                </colgroup>\n";
                    html += "                                <thead>\n";
                    html += "                                <tr>\n";
                    html += "                                    <th class=\"fontB\">월</th>\n";
                    html += "                                    <th class=\"fontB\">일</th>\n";
                    html += "                                    <th class=\"fontB\">품 목</th>\n";
                    html += "                                    <th class=\"fontB\">규 격</th>\n";
                    html += "                                    <th class=\"fontB\">수 량</th>\n";
                    html += "                                    <th class=\"fontB\">단 가</th>\n";
                    html += "                                    <th class=\"fontB\">공 급 가 액</th>\n";
                    html += "                                    <th class=\"fontB\">세 액</th>\n";
                    html += "                                    <th class=\"fontB\">비 고</th>\n";
                    html += "                                </tr>\n";
                    html += "                                </thead>\n";
                    html += "                                <tbody>\n";
                    html += "                                <tr>\n";
                    html += "                                    <td class=\"center\">"+ dt.ISSUE_MON +"</td>\n";
                    html += "                                    <td class=\"center\">"+ dt.ISSUE_DAY +"</td>\n";
                    html += "                                    <td>"+ dt.SUBJECT_ITEM_NM +"</td>\n";
                    html += "                                    <td class=\"center\"></td>\n";
                    html += "                                    <td class=\"center\"></td>\n";
                    html += "                                    <td class=\"cell_right01\"></td>\n";
                    html += "                                    <td class=\"cell_right01\">"+ dt.SUP_AMT +"</td>\n";
                    html += "                                    <td class=\"cell_right01\">"+ dt.TAX_AMT +"</td>\n";
                    html += "                                    <td></td>\n";
                    html += "                                </tr>\n";
                    html += "                                </tbody>\n";
                    html += "                            </table>\n";
                    html += "                            <table class=\"tax_invoice02\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\" summary=\"합계금액, 현금, 수표, 어음, 외상미수금\">\n";
                    html += "                                <colgroup>\n";
                    html += "                                    <col width=\"15%\">\n";
                    html += "                                    <col width=\"15%\">\n";
                    html += "                                    <col width=\"15%\">\n";
                    html += "                                    <col width=\"15%\">\n";
                    html += "                                    <col width=\"15%\">\n";
                    html += "                                    <col width=\"10%\">\n";
                    html += "                                    <col width=\"\">\n";
                    html += "                                    <col width=\"6%\">\n";
                    html += "                                </colgroup>\n";
                    html += "                                <tr>\n";
                    html += "                                    <th class=\"fontB\">합계금액</th>\n";
                    html += "                                    <th class=\"fontB\">현 금</th>\n";
                    html += "                                    <th class=\"fontB\">수 표</th>\n";
                    html += "                                    <th class=\"fontB\">어 음</th>\n";
                    html += "                                    <th class=\"fontB\">외상미수금</th>\n";
                    html += "                                    <td class=\"td_chargeR\" rowspan=\"2\">이 금액을</td>\n";
                    html += "                                    <td class=\"td_chargeC\" rowspan=\"2\"><span class=\"li0201\">영수</span><br><span class=\"li0202\">[ 청구 ]</span></td>\n";
                    html += "                                    <td class=\"td_chargeL\" rowspan=\"2\">함</td>\n";
                    html += "                                </tr>\n";
                    html += "                                <tr>\n";
                    html += "                                    <td class=\"cell_right01\">"+ dt.SUP_TAX_SUM +"</td>\n";
                    html += "                                    <td class=\"cell_right01\"></td>\n";
                    html += "                                    <td class=\"cell_right01\"></td>\n";
                    html += "                                    <td class=\"cell_right01\"></td>\n";
                    html += "                                    <td class=\"cell_right01\"></td>\n";
                    html += "                                </tr>\n";
                    html += "                            </table>\n";
                    html += "                        </div>\n";
                    html += "                    </div>\n";
                    html += "                    <p class=\"taxBillFormAttention\" id=\"taxBillFormAttention01\">\n";
                    html += "                        본 계산서는 부가세법에 의하여 발생한 전자세금계산서이며, 전자서명으로 인감날인이 없어도 법적 효력을 갖습니다.\n";
                    html += "                    </p>\n";
                    html += "                </div>\n";
                    html += "            </td>\n";
                    html += "        </tr>\n";
                    html += "        </tbody>\n";
                    html += "    </table>\n";
                    html += "</div>\n";
                    html += "</div>";
                    $('#view').append(html);
                }
            }
        })
    </script>
</head>
<body onLoad="/*window.print();*/">
<div id="view">

</div>
</body>
</html>