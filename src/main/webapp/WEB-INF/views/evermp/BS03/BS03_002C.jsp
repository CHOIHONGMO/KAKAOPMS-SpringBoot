<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">
        var baseUrl = "/evermp/BS03/BS0301/";

        function init() {

        }

		function getHistGo() {
            var param = {
                    'VENDOR_CD': '${param.VENDOR_CD}',
                    'CLOSE_YEAR': EVF.C("CLOSE_YEAR").getValue(),
                    'detailView': false,
                    'popupFlag': true
            };
            location.href = '/evermp/BS03/BS0301/BS03_002C/view.so?' + $.param(param);
		}
    </script>
    <e:window id="BS03_002C" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:buttonBar id="buttonTopBottom" align="right" width="100%" title="${BS03_002_CAPTION1 }">
        </e:buttonBar>
            <e:searchPanel id="form2" title="${form_CAPTION_N }" labelWidth="25%" width="100%" columnCount="1" useTitleBar="false">

				<e:row>
					<e:field><e:text><b>년도</b></e:text></e:field>
					<e:field>
					<e:select id="CLOSE_YEAR" name="CLOSE_YEAR" value="${CLOSE_YEAR}" onChange="getHistGo" options="${closeYearOptions}" width="${form_CLOSE_YEAR_W}" disabled="${form_CLOSE_YEAR_D}" readOnly="${form_CLOSE_YEAR_RO}" required="${form_CLOSE_YEAR_R}" placeHolder="" usePlaceHolder="false"/>
					</e:field>
					<e:field></e:field>
				</e:row>


				<e:row>
					<e:field><e:text><b>기본정보</b></e:text></e:field>
					<e:field><e:text><b>한국기업데이터</b></e:text></e:field>
					<e:field><e:text><b>이크래더블</b></e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>보고서 보기</b></e:text></e:field>
					<e:field><e:button id="goK" name="goK" label="${goK_N}" onClick="dogoK" disabled="${goK_D}" visible="${goK_V}"/></e:field>
					<e:field><e:button id="goE" name="goE" label="${goE_N}" onClick="dogoE" disabled="${goE_D}" visible="${goE_V}"/></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>기준년도</b></e:text></e:field>
					<e:field><e:text>${formData.YEAR1}</e:text></e:field>
					<e:field><e:text>${formData.YEAR3}</e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>설립년도</b></e:text></e:field>
					<e:field><e:text>${formData.MAKE1}</e:text></e:field>
					<e:field><e:text>${formData.MAKE3}</e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>신용평가등급</b></e:text></e:field>
					<e:field><e:text>${formData.GRADE1}</e:text></e:field>
					<e:field><e:text>${formData.GRADE3}</e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>현금흐름등급</b></e:text></e:field>
					<e:field><e:text>${formData.CASHGRADE1}</e:text></e:field>
					<e:field><e:text>${formData.CASHGRADE3}</e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>매출액</b></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.AMT1}"/></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.AMT3}"/></e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>영업이익</b></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.OPERATION1}"/></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.OPERATION3}"/></e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>당기순이익</b></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.PROFIT1}"/></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.PROFIT3}"/></e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>자본총계</b></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.TOTAL_OWNER1}"/></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.TOTAL_OWNER3}"/></e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>부채총계</b></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.TOTAL_DEBT1}"/></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.TOTAL_DEBT3}"/></e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>영업이익율</b></e:text></e:field>
					<e:field><e:text>${formData.SALES_PROFIT1}</e:text></e:field>
					<e:field><e:text>${formData.SALES_PROFIT3}</e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>당기순이익율</b></e:text></e:field>
					<e:field><e:text>${formData.NET_PROFIT1}</e:text></e:field>
					<e:field><e:text>${formData.NET_PROFIT3}</e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>부채비율</b></e:text></e:field>
					<e:field><e:text>${formData.DEBT_RATIO1}</e:text></e:field>
					<e:field><e:text>${formData.DEBT_RATIO3}</e:text></e:field>
				</e:row>
				<e:row>
					<e:field><e:text><b>직원현황</b></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.STAFF1}"/></e:text></e:field>
					<e:field><e:text><fmt:formatNumber value="${formData.STAFF3}"/></e:text></e:field>
				</e:row>
            </e:searchPanel>

    </e:window>
</e:ui>