package com.st_ones.common.html.service;

import com.st_ones.common.util.clazz.EverAuthorityIgnore;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.bd.service.BD0300Service;
import com.st_ones.evermp.buyer.cn.service.CN0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 * </pre>
 * @File Name : HtmlService.java
 * @author ParkMinHo
 * @date 2022. 10. 19.
 * @version 1.0
 * @see
 */

@EverAuthorityIgnore
@Service(value = "htmlService")
public class HtmlService extends BaseService {

	@Autowired CN0100Service cN0100Service;
	@Autowired BD0300Service bd0300Service;

	//콤마 포맷
	DecimalFormat decFormat = new DecimalFormat("###,###");
    //본사품의
	public Map<String,Object> getLoHtml(Map<String, String> formData) throws Exception {
		//리턴데이터
		Map<String, Object> reData = new HashMap<String, Object>();

		//품의 구매사.
		Map<String, String> cnHdInfo 		  = cN0100Service.getCnhd(formData);
		//대금지급 구매사.
		List<Map<String, Object>> getCnpyList =  cN0100Service.getHtmlCnpyList(formData);
		//상품리스트
		List<Map<String, Object>> getCnDtList =  cN0100Service.doSearchCndt(formData);

		//dp선급 pp중도 bp잔금
		BigDecimal dpPercent = BigDecimal.ZERO;
		BigDecimal ppPercent = BigDecimal.ZERO;
		BigDecimal bpPercent = BigDecimal.ZERO;

        //대금지급조건
		String 	cnTitle = "";
		//품의제목
		String execSubject=cnHdInfo.get("EXEC_SUBJECT")+ (cnHdInfo.get("ETC_RMK") == null ? "" : " ["+cnHdInfo.get("ETC_RMK")+"]");
		//부서정보
		String reqDeptInfo = cnHdInfo.get("REQ_DEPT_INFO");
		//예산금액
		BigDecimal cpoUnitAmt   = BigDecimal.ZERO;
		//집행금액
		BigDecimal salesUnitAmt = BigDecimal.ZERO;
		//예산대비
		BigDecimal cpoUnitRate = BigDecimal.ZERO;


		//납품예정일
		String delyDate = cnHdInfo.get("DELY_DATE");
		//예산집행월
		String budgetExeDate = cnHdInfo.get("BUDGET_EXE_DATE").substring(0,4)+ "년 " + cnHdInfo.get("BUDGET_EXE_DATE").substring(5,7)+ "월 ";
		//본사품의 비고
		String exRmk = cnHdInfo.get("EX_RMK");
		//구매담당자 인포
		String ctrlUserInfo = cnHdInfo.get("CTRL_USER_INFO");

		//대금지급 조건 sum
		for(Map<String,Object> cnpy : getCnpyList) {
			if(cnpy.get("APAR_TYPE").equals("S")) {
				if(cnpy.get("PAY_CNT_TYPE").equals("DP")) {
					dpPercent = dpPercent.add(((BigDecimal)cnpy.get("PAY_PERCENT")));
				}else if(cnpy.get("PAY_CNT_TYPE").equals("PP")) {
					ppPercent = ppPercent.add(((BigDecimal)cnpy.get("PAY_PERCENT")));
				}else {
					bpPercent = bpPercent.add(((BigDecimal)cnpy.get("PAY_PERCENT")));
				}
				cnTitle= String.valueOf(cnpy.get("PAY_METHOD_NM"));
			}
		}

		//상품리스트 금액 sum
		for(Map<String,Object> cndt : getCnDtList) {
			cpoUnitAmt   = cpoUnitAmt.add(((BigDecimal)cndt.get("CPO_UNIT_AMT")));
			salesUnitAmt = salesUnitAmt.add(((BigDecimal)cndt.get("SALES_UNIT_AMT")));
		}

		cpoUnitRate = salesUnitAmt.divide(cpoUnitAmt,4,BigDecimal.ROUND_HALF_UP);
		cpoUnitRate = cpoUnitRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);

		StringBuffer str = new StringBuffer("");
		str.append("<table class='Table' style='width:650.65pt; border:none' width='650'>\r\n");
		str.append("	<tbody>\r\n");
		str.append("		<tr>\r\n");
		str.append("		<td>\r\n");
		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'><b>&nbsp;&nbsp;내 용 : "+execSubject+" 을</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;근거로 아래와 같이 물품공급사 선정(계약)하고자 하오니 검토 후 재가하여 주시기 바랍니다.\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; color:black; border:none; padding:0cm'>- 아&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;래 -\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>1. 구매 및 대금지급 조건</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='4' rowspan='1' style='width:67%; text-align:center; border-bottom:windowtext 1.0pt; background:#f2f2f2; border-top:windowtext 1.0pt; border-left:windowtext 1.0pt; border-right:black 1.0pt; border-style:solid; padding:0cm 4.95pt 0cm 4.95pt;'> <b>구 매 요 청 및 진 행 정 보</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='3' rowspan='1' style='width:33%; text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>대 금 지 급 조 건</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:none; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>요청부서</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='3' rowspan='1' style='border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+reqDeptInfo+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>지불조건</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(cnTitle == null ? "" :cnTitle)+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:13%; border:solid windowtext 1.0pt; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>예&nbsp;&nbsp;&nbsp;산</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; width:19%; border-bottom:solid #a6a6a6 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(decFormat.format(cpoUnitAmt)==null ? "" : decFormat.format(cpoUnitAmt))+" 원\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:13%; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>납기 예정일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='width:19%; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(delyDate==null ? "" :delyDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:13%; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>선 급 금</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid #a6a6a6 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(dpPercent == null ? "" : dpPercent)+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='width:10%; border-bottom:solid #a6a6a6 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");


		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>집&nbsp;&nbsp;&nbsp;행</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid #a6a6a6 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(decFormat.format(salesUnitAmt)==null ? "" : decFormat.format(salesUnitAmt))+" 원\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>인 도 조 건</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>납품\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>중 도 금</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid #a6a6a6 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(ppPercent == null ? "" : ppPercent)+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='width:10%; border-bottom:solid #a6a6a6 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:80pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산대비</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cpoUnitRate+" %\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:80pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산 집행월</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(budgetExeDate == null ? "" : budgetExeDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:80pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>잔&nbsp;&nbsp;&nbsp;금</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(bpPercent== null ? "" : bpPercent)+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='width:10%; border-bottom:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");


		str.append("			</br>\r\n");


		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='border-bottom:solid windowtext 1.0pt; width:100pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt; height:102.75pt'>\r\n");
		str.append("			<p align='center' style='margin-bottom:0cm; text-align:center; margin:0cm 0cm 8pt'><span style='font-size:9pt'><span style='line-height:normal'><span style='text-autospace:ideograph-numeric ideograph-other'><span style='word-break:keep-all'><span style='font-family:&quot;맑은 고딕&quot;'><b><span style='font-family:굴림'><span style='color:black'>특이사항</span></span></b></span></span></span></span></span></p>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt; height:102.75pt'>\r\n");
		str.append("			<p align='left' style='margin-bottom:0cm; text-align:left; margin:0cm 0cm 8pt'><span style='font-size:9pt'><span style='line-height:normal'><span style='text-autospace:ideograph-numeric ideograph-other'><span style='word-break:keep-all'><span style='font-family:&quot;맑은 고딕&quot;'><span lang='EN-US' style='font-family:굴림'><span style='color:black'>"+(exRmk == null ? "" : exRmk)+"</span></span><br />\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");


		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>2. 공급사 담당자 정보</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:15%; border:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>상&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;호</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='width:35%; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>㈜대명소노시즌 MRO 구매팀\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:15%; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>주&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;소</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='width:35%; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>강원도 홍천군 서면 한치골길 262\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:15%; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>구매담당자</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='width:35%; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(ctrlUserInfo == null ? "　" : ctrlUserInfo)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:15%; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>정산담당자</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='width:35%; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");


		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; border:none; color:red; padding:0cm'><b>3. 공급품목 정보</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원, VAT별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:130pt; border-bottom:black 1.0pt; background:#f2f2f2; border-top:windowtext 1.0pt; border-left:windowtext 1.0pt; border-right:windowtext 1.0pt; border-style:solid; padding:0cm 4.95pt 0cm 4.95pt;'><b>주요 품목</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:33pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>단위</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:33pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>수량</b>\r\n");
		str.append("			</td>\r\n");

		str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예 산</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>㈜대명소노시즌</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:40pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산대비</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:150pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>비 고</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:45pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>단가</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:100pt;border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:45pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>단가</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:100pt;border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		for(Map<String,Object> cndt : getCnDtList) {
			str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cndt.get("ITEM_DESC")+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>EA\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("ITEM_QT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("CPO_UNIT_PRICE"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("CPO_UNIT_AMT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("SALES_UNIT_PRC"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("SALES_UNIT_AMT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+((BigDecimal)cndt.get("CPO_UNIT_RATE")).setScale(2, RoundingMode.HALF_UP)+"%\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:left; border:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
			str.append("			</td>\r\n");
			str.append("		</tr>\r\n");
		}

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border:solid windowtext 1.0pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>[&nbsp;합&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;계&nbsp;]</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(cpoUnitAmt)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(salesUnitAmt)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+cpoUnitRate+"%</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		str.append("			<p align='right' style='margin-bottom:0cm; text-align:right; margin:0cm 0cm 8pt'><span style='font-size:8pt'><span style='line-height:normal'><span style='text-autospace:ideograph-numeric ideograph-other'><span style='word-break:keep-all'><span style='font-family:&quot;맑은 고딕&quot;'><span lang='EN-US' style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>* </span></span></span><span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>보증현황</span></span></span><span lang='EN-US' style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'> : </span></span></span><span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>첨부파일</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>內</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>물품공급사선정안내</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>참고&nbsp;</span></span></span></span></span></span></span></span></p>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'><b># 첨부 :</b> 물품구매 내역서 등 해당내용 1부\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		str.append("		   </td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		//리턴값
		reData.put("PROGRESS_CD" , cnHdInfo.get("PROGRESS_CD"));
		reData.put("EXEC_NUM"    , cnHdInfo.get("EXEC_NUM"));
		reData.put("EXEC_CNT"    , cnHdInfo.get("EXEC_CNT"));

		reData.put("BLSM_HTML"    , str);
		return reData;
	}
	//구매품의
	public Map<String,Object> getPuHtml(Map<String, String> formData) throws Exception {
		//리턴데이터
		Map<String, Object> reData = new HashMap<String, Object>();
		//품의 구매사.
		Map<String, String> cnHdInfo 		  = cN0100Service.getCnhd(formData);
		//상품리스트
		List<Map<String, Object>> getCnDtList =  cN0100Service.doSearchCndt(formData);
		//공급사 리스트
		List<Map<String, Object>> getCnvdList =  cN0100Service.doHtmlhCnvd(formData);
		//대금합계 리스트
		List<Map<String, Object>> getCnpyListSum =  cN0100Service.getHtmlCnpyListSum(formData);



		//품의제목
		String execSubject=cnHdInfo.get("EXEC_SUBJECT")+ (cnHdInfo.get("ETC_RMK") == null ? "" : " ["+cnHdInfo.get("ETC_RMK")+"]");
		//예산금액
		BigDecimal cpoUnitAmt   = BigDecimal.ZERO;
		//매출금액
		BigDecimal salesUnitAmt = BigDecimal.ZERO;
		//매입금액
		BigDecimal qtaUnitAmt = BigDecimal.ZERO;
		//예산대비
		BigDecimal cpoUnitProfitAmt = BigDecimal.ZERO;
		//예산대비율
		BigDecimal cpoUnitRate = BigDecimal.ZERO;
		//매출이익율
		BigDecimal salesProfitRate = BigDecimal.ZERO;
		//매출이익율
		BigDecimal salesProfit = BigDecimal.ZERO;
		//매출단가
		BigDecimal salesUnitPrc = BigDecimal.ZERO;
		//매입단가
		BigDecimal qtaUnitPrc = BigDecimal.ZERO;
		//매출율
		BigDecimal salesUnitRate = BigDecimal.ZERO;
		//매출율
		BigDecimal qtaUnitRate = BigDecimal.ZERO;
		//부서정보
		String reqDeptInfo = cnHdInfo.get("REQ_DEPT_INFO");
		//공급사 업체명
		String vendorNames = cnHdInfo.get("VENDOR_NAMES");
		//대표 품목명
		String repItemNm = cnHdInfo.get("REP_ITEM_NM");

		//견적/입찰구분
		String rfGubn = "";
		//견적/입찰구분
		String rfxNum = "";

		//납품예정일
		String delyDate = cnHdInfo.get("DELY_DATE");
		//예산집행월
		String budgetExeDate = cnHdInfo.get("BUDGET_EXE_DATE").substring(0,4)+ "년 " + cnHdInfo.get("BUDGET_EXE_DATE").substring(5,7)+ "월 ";
		//구매품의 비고
		String prRmk = cnHdInfo.get("PR_RMK");
		//담당자 인포
		String ctrlUserInfo = cnHdInfo.get("REQ_USER_NM");
		//선정사유
		String selCause = cnHdInfo.get("SEL_CAUSE");




		//상품리스트 금액 sum
		for(Map<String,Object> cndt : getCnDtList) {
			cpoUnitAmt   = cpoUnitAmt.add(((BigDecimal)cndt.get("CPO_UNIT_AMT")));
			salesUnitAmt = salesUnitAmt.add(((BigDecimal)cndt.get("SALES_UNIT_AMT")));
			qtaUnitAmt   = qtaUnitAmt.add(((BigDecimal)cndt.get("QTA_UNIT_AMT")));
			salesUnitPrc = salesUnitPrc.add(((BigDecimal)cndt.get("SALES_UNIT_PRC")));
			qtaUnitPrc   = qtaUnitPrc.add(((BigDecimal)cndt.get("QTA_UNIT_PRC")));
			rfxNum		 = (String)cndt.get("RFX_NUM");

		}
		salesUnitRate	 = (salesUnitAmt.divide(cpoUnitAmt,4,BigDecimal.ROUND_HALF_UP)).multiply(new BigDecimal(100));
		salesUnitRate    =  salesUnitRate.setScale(1, RoundingMode.HALF_UP);
		qtaUnitRate  	 = (qtaUnitAmt.divide(salesUnitAmt,4,BigDecimal.ROUND_HALF_UP)).multiply(new BigDecimal(100));
		qtaUnitRate      =  qtaUnitRate.setScale(1, RoundingMode.HALF_UP);
		salesProfit  	 =  salesUnitAmt.subtract(qtaUnitAmt);
		cpoUnitProfitAmt =  salesUnitAmt.subtract(cpoUnitAmt);

		rfGubn = rfxNum.substring(0,2).equals("RQ") ? "전자견적" : "전자입찰";

		cpoUnitRate = salesUnitAmt.subtract(cpoUnitAmt);
		cpoUnitRate = cpoUnitRate.divide(cpoUnitAmt,4,BigDecimal.ROUND_HALF_UP);
		cpoUnitRate = cpoUnitRate.multiply(new BigDecimal(100)).setScale(1, RoundingMode.HALF_UP);

		salesProfitRate = salesUnitPrc.subtract(qtaUnitPrc);
		salesProfitRate = salesProfitRate.divide(salesUnitPrc,4,BigDecimal.ROUND_HALF_UP);
		salesProfitRate = salesProfitRate.multiply(new BigDecimal(100)).setScale(1, RoundingMode.HALF_UP);
		StringBuffer str = new StringBuffer("");
		str.append("<table class='Table' style='width:650.65pt; border:none' width='650'>\r\n");
		str.append("	<tbody>\r\n");
		str.append("		<tr>\r\n");
		str.append("		<td>\r\n");
		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'><b>&nbsp;&nbsp;내 용 : "+execSubject+" 을</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;근거로 아래와 같이 물품공급사 선정(계약)하고자 하오니 검토 후 재가하여 주시기 바랍니다.\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; color:black; border:none; padding:0cm'>- 아&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;래 -\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>1. 구매요청 정보 및 구매진행 세부내용</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원/V.A.T별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");


		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; width:324pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>구 매 요 청 정 보</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; width:324pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>MRO팀 구매진행 세부내용</b>\r\n");
		str.append("			</td>\r\n");


		str.append("		   </tr>\r\n");
		str.append("			<td style='text-align:center; width:80pt; border-bottom:none; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>부&nbsp;&nbsp;&nbsp;&nbsp;서</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border:none; width:244pt; border-top:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+reqDeptInfo+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:80pt; border-bottom:none; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>공 급 사</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border:solid black 1.0pt; width:244pt; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+vendorNames+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border:solid windowtext 1.0pt; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>담&nbsp;당&nbsp;자</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(ctrlUserInfo == null ? "" : ctrlUserInfo)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td rowspan='3' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>선 정 사 유 </br></br> 및 </br></br> 특 이 사 항</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='3' style='border-bottom:solid black 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(selCause ==null ? "" : selCause)+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>품&nbsp;&nbsp;&nbsp;&nbsp;목</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(repItemNm == null ? "" : repItemNm)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>사&nbsp;&nbsp;&nbsp;&nbsp;유</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(prRmk == null ? "" : prRmk)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			</td>\r\n");

		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>납기요청일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(delyDate  == null ? "" :delyDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>납기예정일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(delyDate  == null ? "" :delyDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산집행월</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border:none; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(budgetExeDate== null ? "":budgetExeDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>지 불 조 건</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-right:solid black 1.0pt; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+getCnvdList.get(0).get("PAY_RMK")+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td rowspan='3' style='text-align:center; border-bottom:black 1.0pt; background:#f2f2f2; border-top:windowtext 1.0pt; border-left:windowtext 1.0pt; border-right:windowtext 1.0pt; border-style:solid; padding:0cm 4.95pt 0cm 4.95pt;'><b>집행금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>매출</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>매입</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>매출이익</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산 比</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		    </tr>\r\n");


		str.append("			<tr>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:right; border:none; width:100pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(decFormat.format(cpoUnitAmt)== null ? "" :decFormat.format(cpoUnitAmt))+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:right; border:none; width:100pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(decFormat.format(salesUnitAmt)== null ? "" :decFormat.format(salesUnitAmt))+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:right; border:none; width:100pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(decFormat.format(qtaUnitAmt)== null ? "" :decFormat.format(qtaUnitAmt))+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:right; border:none; width:100pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(decFormat.format(salesProfit) == null ? "" : decFormat.format(salesProfit))+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:right; border:none; width:100pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(decFormat.format(cpoUnitProfitAmt) == null ? "" : decFormat.format(cpoUnitProfitAmt))+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		    </tr>\r\n");


		str.append("			<tr>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border:none; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>(예산대비)\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(salesUnitRate == null ? "" : salesUnitRate)+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border:none; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>(매출대비)\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(qtaUnitRate == null ? "" : qtaUnitRate)+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border:none; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;''>(매출이익율)\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(salesProfitRate == null ? "" : salesProfitRate)+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:none; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(cpoUnitRate == null ? "" : cpoUnitRate)+"%</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		    </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");


		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>2. 입찰/견적 및 계약 내용</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; border:none; padding:0cm 4.95pt 0cm 4.95pt;'>① 입찰/견적 세부사항\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원, VAT별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		List<Map<String, Object>> puVendorList =cN0100Service.getPuVendorList(formData);

		for(Map<String,Object> puVendor : puVendorList) {
			//참여공급사수
			//공급사 배열
			String[] vdNames  = new String[5];
			String[] vdNames1 = ((String) puVendor.get("VENDOR_LIST")).split(",");
			BigDecimal venCnt = (BigDecimal)puVendor.get("VENDOR_CNT");
			String gubn 	  = (String) puVendor.get("GUBN");
			venCnt=(BigDecimal)puVendor.get("VENDOR_CNT");
			for(int aa=0; aa<venCnt.intValue(); aa++) {
				if(aa<=4) {

					vdNames[aa]=vdNames1[aa].replaceAll("'", "");
				}

			}

			str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
			str.append("			<tbody>\r\n");
			str.append("			<tr>\r\n");
			str.append("			<td style='text-align:center; border:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>견적근거</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(rfGubn == null ? "" : rfGubn)+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(puVendor.get("RFX_NUM") == null ? "" :puVendor.get("RFX_NUM"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+puVendor.get("VENDOR_CNT")+"개사\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>발주구분</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td colspan='3' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
			str.append("			</td>\r\n");
			str.append("	     	</tr>\r\n");


			str.append("			<tr>\r\n");
			str.append("			<td style='text-align:center; width:100pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>구분(품목/현장)</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; width:100pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>규격</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; width:20pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>단위</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; width:30pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>수량</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; width:100pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[0]==null ? "" : vdNames[0])+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; width:100pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[1]==null ? "" : vdNames[1])+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; width:100pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[2]==null ? "" : vdNames[2])+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; width:100pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[3]==null ? "" : vdNames[3])+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; width:100pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[4]==null ? "" : vdNames[4])+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("	     	</tr>\r\n");


			List<Map<String, Object>> vendorItemList = new ArrayList<Map<String, Object>>();
			if(gubn.equals("BD")) {
				vendorItemList=cN0100Service.getPuBdItemList(puVendor);
			} else {
				vendorItemList=cN0100Service.getPuRqItemList(puVendor);
			}
			BigDecimal vdAmt1 = BigDecimal.ZERO;
			BigDecimal vdAmt2 = BigDecimal.ZERO;
			BigDecimal vdAmt3 = BigDecimal.ZERO;
			BigDecimal vdAmt4 = BigDecimal.ZERO;
			BigDecimal vdAmt5 = BigDecimal.ZERO;

			for(Map<String,Object> vendorItem:vendorItemList) {

				vdAmt1= vdAmt1.add((vendorItem.get("'"+vdNames[0]+"'"))==null ? BigDecimal.ZERO :((BigDecimal)vendorItem.get("'"+vdNames[0]+"'")));
				vdAmt2= vdAmt2.add((vendorItem.get("'"+vdNames[1]+"'"))==null ? BigDecimal.ZERO :((BigDecimal)vendorItem.get("'"+vdNames[1]+"'")));
				vdAmt3= vdAmt3.add((vendorItem.get("'"+vdNames[2]+"'"))==null ? BigDecimal.ZERO :((BigDecimal)vendorItem.get("'"+vdNames[2]+"'")));
				vdAmt4= vdAmt4.add((vendorItem.get("'"+vdNames[3]+"'"))==null ? BigDecimal.ZERO :((BigDecimal)vendorItem.get("'"+vdNames[3]+"'")));
				vdAmt5= vdAmt5.add((vendorItem.get("'"+vdNames[4]+"'"))==null ? BigDecimal.ZERO :((BigDecimal)vendorItem.get("'"+vdNames[4]+"'")));
				str.append("			<tr>\r\n");
				str.append("			<td style='border-bottom:solid black 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+vendorItem.get("ITEM_DESC")+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='border-bottom:solid black 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid black 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+vendorItem.get("UNIT_CD")+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid black 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(vendorItem.get("RFX_QT"))+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid black 1.0pt; border-top:none; border-left:solid  1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(vdNames[0]==null ? "" :(vendorItem.get("'"+vdNames[0]+"'") ==null ? "" : decFormat.format(vendorItem.get("'"+vdNames[0]+"'"))))+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid black 1.0pt; border-top:none; border-left:none; border-right:solid  1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(vdNames[1]==null ? "" :(vendorItem.get("'"+vdNames[1]+"'") ==null ? "" :decFormat.format(vendorItem.get("'"+vdNames[1]+"'"))))+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid black 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(vdNames[2]==null ? "" :(vendorItem.get("'"+vdNames[2]+"'") ==null ? "" :decFormat.format(vendorItem.get("'"+vdNames[2]+"'"))))+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid black 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(vdNames[3]==null ? "" :(vendorItem.get("'"+vdNames[3]+"'") ==null ? "" :decFormat.format(vendorItem.get("'"+vdNames[3]+"'"))))+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid black 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(vdNames[4]==null ? "" :(vendorItem.get("'"+vdNames[4]+"'") ==null ? "" :decFormat.format(vendorItem.get("'"+vdNames[4]+"'"))))+"\r\n");
				str.append("			</td>\r\n");
				str.append("	     	</tr>\r\n");
			}

			str.append("			<tr>\r\n");
			str.append("			<td style='text-align:center; border:solid windowtext 1.0pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>[합&nbsp;&nbsp;&nbsp;&nbsp;계]</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='border:solid windowtext 1.0pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b></b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b></b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:none; padding:0cm 4.95pt 0cm 4.95pt;'><b></b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(vdAmt1)+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(vdAmt2)+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(vdAmt3)+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(vdAmt4)+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid windowtext 1.0pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(vdAmt5)+"</b>\r\n");
			str.append("			</td>\r\n");
			str.append("	     	</tr>\r\n");
		};
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		str.append("			<p align='right' style='margin-bottom:0cm; text-align:right; margin:0cm 0cm 8pt'><span style='font-size:8pt'><span style='line-height:normal'><span style='text-autospace:ideograph-numeric ideograph-other'><span style='word-break:keep-all'><span style='font-family:&quot;맑은 고딕&quot;'><span lang='EN-US' style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>&nbsp;* </span></span></span><span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>상기공급사</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>外</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>견적</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>및</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>구매</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>정보</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>사항은</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>첨부파일</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>참고&nbsp;</span></span></span> </span></span></span></span></span></p>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; border:none; padding:0cm 4.95pt 0cm 4.95pt;'>② 계약 세부사항\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원, VAT별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:43pt; border:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>구분</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:120pt; background:#f2f2f2; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>협력사</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:120pt; background:#f2f2f2; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>공급금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:25pt; background:#f2f2f2; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>계약</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:42pt; background:#f2f2f2; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>선급금</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:42pt; background:#f2f2f2; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>중도금</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='4' rowspan='1' style='text-align:center; background:#f2f2f2; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>보증정보</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");


		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:45pt; background:#f2f2f2; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>계약</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='width:80pt; text-align:center; background:#f2f2f2; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>하자증권</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:45pt; background:#f2f2f2; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>보증</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		if(getCnvdList.size()>0) {
			for(Map<String,Object> cnvd : getCnvdList) {
				//선급퍼센트
				BigDecimal dpRate = BigDecimal.ZERO;
				//중도금퍼센트
				BigDecimal ppRate = BigDecimal.ZERO;
				//공급가액
				BigDecimal sumAmt  = BigDecimal.ZERO;

				//대금지급 조건 sum
				for(Map<String,Object> cnpy : getCnpyListSum) {
					if(cnvd.get("VENDOR_CD").equals(cnpy.get("VENDOR_CD"))) {
						sumAmt = sumAmt.add(((BigDecimal)cnpy.get("SUPPLY_AMT")));
						dpRate = dpRate.add(((BigDecimal)cnpy.get("DP_PAY_PERCENT")));
						ppRate = ppRate.add(((BigDecimal)cnpy.get("PP_PAY_PERCENT")));

					}
				}
				if(cnvd.get("APAR_TYPE").equals("S")) {
					str.append("			<tr>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>매출</b>\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cnvd.get("VENDOR_NM")+"\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(((BigDecimal)cnvd.get("SUPPLY_AMT")))+"\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(cnvd.get("CT_PO_TYPE").equals("CT") ? "Y" : "N")+"\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+dpRate+"%\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+ppRate+"%\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border:none; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("CONT_GUAR_PERCENT"))==null ? "0" : ((BigDecimal)cnvd.get("CONT_GUAR_PERCENT")))+"%\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("WARR_GUAR_PERCENT"))==null ? "0" : ((BigDecimal)cnvd.get("WARR_GUAR_PERCENT")))+"%\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; width:30pt; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("WARR_GUAR_QT"))==null ? "0" : ((BigDecimal)cnvd.get("WARR_GUAR_QT")))+"개월\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
					str.append("			</td>\r\n");
					str.append("		   </tr>\r\n");
				} else {
					str.append("			<tr>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>매입</b>\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cnvd.get("VENDOR_NM")+"\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(sumAmt)+"\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(cnvd.get("CT_PO_TYPE").equals("CT") ? "Y" : "N")+"\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+dpRate+"%\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+ppRate+"%\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("CONT_GUAR_PERCENT"))==null ? "0" : ((BigDecimal)cnvd.get("CONT_GUAR_PERCENT")))+"%\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("WARR_GUAR_PERCENT"))==null ? "0" : ((BigDecimal)cnvd.get("WARR_GUAR_PERCENT")))+"%\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("WARR_GUAR_QT"))==null ? "0" : ((BigDecimal)cnvd.get("WARR_GUAR_QT")))+"개월\r\n");
					str.append("			</td>\r\n");
					str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
					str.append("			</td>\r\n");
					str.append("		   </tr>\r\n");
				}
			}
		}
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		str.append("			<p align='right' style='margin-bottom:0cm; text-align:right; margin:0cm 0cm 8pt'><span style='font-size:8pt'><span style='line-height:normal'><span style='text-autospace:ideograph-numeric ideograph-other'><span style='word-break:keep-all'><span style='font-family:&quot;맑은 고딕&quot;'>&nbsp;<span lang='EN-US'><span style='color:#595959'>※</span></span><span lang='EN-US'><span style='font-family:굴림'><span style='color:#595959'> 500</span></span></span><span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>만원</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>이하</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>계약</span></span></span> <span style='font-family:굴림'><span style='color:#595959'>생략</span></span></span><span lang='EN-US'><span style='font-family:굴림'><span style='color:#595959'>, </span></span></span><span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>선급진행</span></span></span> <span style='font-family:굴림'><span style='color:#595959'>시</span></span></span> <span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>선급이행증권</span></span></span><span lang='EN-US' style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'> 100% </span></span></span><span style='font-size:8pt'><span style='font-family:굴림'><span style='color:#595959'>必</span></span></span>&nbsp;</span></span></span></span></span></p>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>3. 기타</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'>&nbsp;&nbsp;&nbsp;&nbsp;- 납품일정은 사업장 영업상황에 따라 변경 가능하므로 협의 후 진행\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'><b># 첨부 :</b> 물품구매 내역서 등(해당내용) 1부\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		str.append("		</td>\r\n");
		str.append("		</tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		//리턴값
		reData.put("PROGRESS_CD" , cnHdInfo.get("PROGRESS_CD"));
		reData.put("EXEC_NUM"    , cnHdInfo.get("EXEC_NUM"));
		reData.put("EXEC_CNT"    , cnHdInfo.get("EXEC_CNT"));

		reData.put("BLSM_HTML"    , str);
		return reData;
		}

	public Map<String, Object> getChPuHtml(Map<String, String> formData) {
		//리턴데이터
		Map<String, Object> reData = new HashMap<String, Object>();
		//당초품의데이터
		Map<String, String> prevData = new HashMap<String, String>();

		//변경품의 구매사.
		Map<String, String> cnHdInfo = cN0100Service.getCnhd(formData);
		//당초 품의 구매사.
		prevData.putAll(formData);
		//이전차수 1빼기
		prevData.put("EXEC_CNT" ,String.valueOf((Integer.valueOf(prevData.get("EXEC_CNT"))-1)));
		Map<String, String> prevCnHdInfo = cN0100Service.getCnhd(prevData);

		//상품리스트
		List<Map<String, Object>> getCnDtList =  cN0100Service.doHtmlChCndt(formData);
		//공급사 리스트
		List<Map<String, Object>> getCnvdList =  cN0100Service.doHtmlhCnvd(formData);



        //대금지급조건

		//품의제목
		String execSubject=cnHdInfo.get("EXEC_SUBJECT")+ (cnHdInfo.get("ETC_RMK") == null ? "" : " ["+cnHdInfo.get("ETC_RMK")+"]");

		//변경예산금액
		BigDecimal cpoUnitAmt   = BigDecimal.ZERO;
		//변경매출금액
		BigDecimal salesUnitAmt = BigDecimal.ZERO;
		//변경매입금액
		BigDecimal qtaUnitAmt = BigDecimal.ZERO;
		//변경예산대비
		BigDecimal cpoUnitRate = BigDecimal.ZERO;
		//변경이익율
		BigDecimal salesProfitRate = BigDecimal.ZERO;
		//변경매춛단가
		BigDecimal salesUnitPrc = BigDecimal.ZERO;
		//변경매입단가
		BigDecimal qtaUnitPrc = BigDecimal.ZERO;
		//변경매출대비율
		BigDecimal salesRate = BigDecimal.ZERO;
		//변경이익금액
		BigDecimal profitAmt = BigDecimal.ZERO;
		//당초매춛단가
		BigDecimal localSalesUnitPrc = BigDecimal.ZERO;
		//당초매입단가
		BigDecimal localQtaUnitPrc = BigDecimal.ZERO;
		//당초예산금액
		BigDecimal localCpoUnitAmt   = BigDecimal.ZERO;
		//당초매출금액
		BigDecimal localSalesUnitAmt = BigDecimal.ZERO;
		//당초매입금액
		BigDecimal localQtaUnitAmt = BigDecimal.ZERO;
		//당초예산대비
		BigDecimal localCpoUnitRate = BigDecimal.ZERO;
		//당초이익율
		BigDecimal localSalesProfitRate = BigDecimal.ZERO;
		//당초매출대비율
		BigDecimal localSalesRate = BigDecimal.ZERO;
		//당초이익금액
		BigDecimal localProfitAmt = BigDecimal.ZERO;
		//증감예산금액
		BigDecimal increaseCpoUnitAmt   = BigDecimal.ZERO;
		//증감매출금액
		BigDecimal increaseSalesUnitAmt = BigDecimal.ZERO;
		//증감매입금액
		BigDecimal increaseQtaUnitAmt = BigDecimal.ZERO;
		//증감예산대비
		BigDecimal increaseCpoUnitRate = BigDecimal.ZERO;
		//증감이익율
		BigDecimal increaseSalesProfitRate = BigDecimal.ZERO;
		//증감매출대비율
		BigDecimal increaseSalesRate = BigDecimal.ZERO;
		//증감이익금액
		BigDecimal increaseProfitAmt = BigDecimal.ZERO;


		//납품예정일
		String delyDate = cnHdInfo.get("DELY_DATE");
		//예산집행월
		String budgetExeDate = cnHdInfo.get("BUDGET_EXE_DATE").substring(0,4)+ "년 " + cnHdInfo.get("BUDGET_EXE_DATE").substring(5,7)+ "월 ";
		//당초납품예정일
		String prevDelyDate = prevCnHdInfo.get("DELY_DATE");
		//당초예산집행월
		String prevBudgetExeDate = prevCnHdInfo.get("BUDGET_EXE_DATE").substring(0,4)+ "년 " + prevCnHdInfo.get("BUDGET_EXE_DATE").substring(5,7)+ "월 ";

		//선정사유 비고
		String selCause = cnHdInfo.get("SEL_CAUSE");
		for(Map<String,Object> cndt : getCnDtList) {
			//당초금액
			localCpoUnitAmt   = localCpoUnitAmt.add(((BigDecimal)cndt.get("DT1_CPO_UNIT_AMT")));
			localSalesUnitAmt = localSalesUnitAmt.add(((BigDecimal)cndt.get("DT1_SALES_UNIT_AMT")));
			localQtaUnitAmt   = localQtaUnitAmt.add(((BigDecimal)cndt.get("DT1_QTA_UNIT_AMT")));
			localSalesUnitPrc = localSalesUnitPrc.add(((BigDecimal)cndt.get("DT1_SALES_UNIT_PRC")));
			localQtaUnitPrc   = localQtaUnitPrc.add(((BigDecimal)cndt.get("DT1_QTA_UNIT_PRC")));
			//변경금액
			cpoUnitAmt   = cpoUnitAmt.add(((BigDecimal)cndt.get("DT2_CPO_UNIT_AMT")));
			salesUnitAmt = salesUnitAmt.add(((BigDecimal)cndt.get("DT2_SALES_UNIT_AMT")));
			qtaUnitAmt   = qtaUnitAmt.add(((BigDecimal)cndt.get("DT2_QTA_UNIT_AMT")));
			salesUnitPrc = salesUnitPrc.add(((BigDecimal)cndt.get("DT2_SALES_UNIT_PRC")));
			qtaUnitPrc   = qtaUnitPrc.add(((BigDecimal)cndt.get("DT2_QTA_UNIT_PRC")));

		}
		//변경예상대비
		cpoUnitRate     = salesUnitAmt.divide(cpoUnitAmt,4,BigDecimal.ROUND_HALF_UP);
		cpoUnitRate     = cpoUnitRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//변경이익금액
		profitAmt = salesUnitAmt.subtract(qtaUnitAmt);
		//당초이익금액
		localProfitAmt = localSalesUnitAmt.subtract(localQtaUnitAmt);
		//당초예산대비
		localCpoUnitRate = localSalesUnitAmt.divide(localCpoUnitAmt,4,BigDecimal.ROUND_HALF_UP);
		localCpoUnitRate = localCpoUnitRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//변경이익율
		salesProfitRate = salesUnitPrc.subtract(qtaUnitPrc);
		salesProfitRate = salesProfitRate.divide(qtaUnitPrc,4,BigDecimal.ROUND_HALF_UP);
		salesProfitRate = salesProfitRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//당초이익율
		localSalesProfitRate = localSalesUnitPrc.subtract(localQtaUnitPrc);
		localSalesProfitRate = localSalesProfitRate.divide(localQtaUnitPrc,4,BigDecimal.ROUND_HALF_UP);
		localSalesProfitRate = localSalesProfitRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//변경매출대비율
		salesRate = qtaUnitPrc.divide(salesUnitPrc,4,BigDecimal.ROUND_HALF_UP);
		salesRate = salesRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//당초매출대비율
		localSalesRate = localQtaUnitPrc.divide(localSalesUnitPrc,4,BigDecimal.ROUND_HALF_UP);
		localSalesRate = localSalesRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
        //증감 계산
		increaseCpoUnitAmt       = cpoUnitAmt.subtract(localCpoUnitAmt);
		increaseSalesUnitAmt     = salesUnitAmt.subtract(localSalesUnitAmt);
		increaseQtaUnitAmt       = qtaUnitAmt.subtract(localQtaUnitAmt);
		increaseCpoUnitRate      = cpoUnitRate.subtract(localCpoUnitRate);
		increaseSalesProfitRate  = salesProfitRate.subtract(localSalesProfitRate);
		increaseSalesRate  		 = salesRate.subtract(localSalesRate);
		increaseProfitAmt		 = profitAmt.subtract(localProfitAmt);


		StringBuffer str = new StringBuffer("");
		str.append("<table class='Table' style='width:650.65pt; border:none' width='650'>\r\n");
		str.append("	<tbody>\r\n");
		str.append("		<tr>\r\n");
		str.append("			<td>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'><b>&nbsp;&nbsp;내 용 : "+execSubject+" 관련</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;아래와 같이 변경하고자 하오니 검토 후 재가하여 주시기 바랍니다.\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; color:black; border:none; padding:0cm'>- 아&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;래 -\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>1. 변경구매 정보 및 세부내용</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:100pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt; height:82.75pt'><b>※변경사유 :</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt; height:82.75pt'>"+(selCause == null ? "" : selCause)+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원, VAT별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:33pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>구분</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:73pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:73pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>매출</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:42pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산대비</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:73pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>매입</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:42pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>매출대비</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:73pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>매출이익</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:40pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>이익율</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:43pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>납기예정일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>집행월</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>당초</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(localCpoUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(localSalesUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+localCpoUnitRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(localQtaUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+localSalesRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(localProfitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+localSalesProfitRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(prevDelyDate == null ? "" : prevDelyDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(prevBudgetExeDate == null ? "" : prevBudgetExeDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>변경</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cpoUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(salesUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cpoUnitRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(qtaUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+salesRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(profitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+salesProfitRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(delyDate == null ? "" : delyDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(budgetExeDate == null ? "" : budgetExeDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>증감</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(increaseCpoUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(increaseSalesUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+increaseCpoUnitRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(increaseQtaUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+increaseSalesRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(increaseProfitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+increaseSalesProfitRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>2. 변경계약내용</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; border:none; padding:0cm 4.95pt 0cm 4.95pt;'>① 변경 세부사항\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원, VAT별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:120pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>주요품목</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:25pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>단위</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; width:95pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>당초</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; width:95pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>변경</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='3' rowspan='1' style='text-align:center; width:120pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>증감</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:120pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>비고</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");


		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:30pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>수량</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:30pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>수량</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:30pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>수량</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:33pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>비율</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");


		int cndtInx=1;

		BigDecimal increaseItemQtSum = BigDecimal.ZERO;
		BigDecimal increaseAmtSum    = BigDecimal.ZERO;

		BigDecimal itemQtSum         = BigDecimal.ZERO;
		BigDecimal itemQtSum1         = BigDecimal.ZERO;

		//상품리스트 금액 sum


		for(Map<String,Object> cndt : getCnDtList) {
			itemQtSum =itemQtSum.add((BigDecimal)cndt.get("DT1_ITEM_QT"));
			itemQtSum1 =itemQtSum1.add((BigDecimal)cndt.get("DT2_ITEM_QT"));


			str.append("			<tr>\r\n");
			str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cndtInx+". "+cndt.get("ITEM_DESC")+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cndt.get("UNIT_CD")+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT1_ITEM_QT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT1_SALES_UNIT_AMT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT2_ITEM_QT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT2_SALES_UNIT_AMT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT3_ITEM_QT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT3_SALES_UNIT_AMT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+ cndt.get("DT3_SALES_UNIT_RATE")+"%\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
			str.append("			</td>\r\n");
			str.append("		   </tr>\r\n");
			cndtInx++;
		}
		increaseItemQtSum = increaseItemQtSum.add(itemQtSum1.subtract((itemQtSum)));
		increaseAmtSum    = increaseAmtSum.add(salesUnitAmt.subtract((localSalesUnitAmt)));
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>[합&nbsp;&nbsp;&nbsp;계]</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b></b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(itemQtSum)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(localSalesUnitAmt)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(itemQtSum1)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(salesUnitAmt)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(increaseItemQtSum)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(increaseAmtSum)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b></b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b></b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");


		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; border:none; padding:0cm 4.95pt 0cm 4.95pt;'>② 계약 세부사항\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원, VAT별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:30pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>구분</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:140pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>협력사</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='3' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>계약금액 (VAT별도)</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:20pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>계약</br>여부</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:20pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>선급</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:20pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>중도</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='4' rowspan='1' style='text-align:center; width:100pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>보증정보</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");


		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:80pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>당초</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:80pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>변경</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:72pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>증감</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:24pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>계약</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>하자증권</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:24pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>보증</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		for(Map<String,Object> cnvd : getCnvdList) {

			//공급가액
			BigDecimal increaseSumAmt  = BigDecimal.ZERO;
			int execnt =Integer.valueOf(String.valueOf(cnvd.get("EXEC_CNT")))-1;
			Map<String,String> cnpyS = new HashMap<String,String>();
			cnpyS.put("EXEC_NUM" , String.valueOf(cnvd.get("EXEC_NUM")));
			cnpyS.put("EXEC_CNT" , String.valueOf(execnt));
			List<Map<String, Object>> cnpyInfoList = cN0100Service.getHtmlCnpyListSum(cnpyS);
			//당초대금지급 조건 sum
			for(Map<String,Object> cnpy : cnpyInfoList) {
				if(cnvd.get("VENDOR_CD").equals(cnpy.get("VENDOR_CD"))) {
					increaseSumAmt = increaseSumAmt.add(((BigDecimal)cnpy.get("SUPPLY_AMT")));


				}
			}
			//변경대금지급 구매사.
			Map<String,String> cnpySC = new HashMap<String,String>();
			cnpySC.put("EXEC_NUM" , String.valueOf(cnvd.get("EXEC_NUM")));
			cnpySC.put("EXEC_CNT" , String.valueOf(cnvd.get("EXEC_CNT")));
			//선급퍼센트
			BigDecimal dpRate = BigDecimal.ZERO;
			//중도금퍼센트
			BigDecimal ppRate = BigDecimal.ZERO;
			//공급가액
			BigDecimal sumAmt  = BigDecimal.ZERO;
			List<Map<String, Object>> getCnpyListSum =  cN0100Service.getHtmlCnpyListSum(cnpySC);
			//변경대금지급 조건 sum
			for(Map<String,Object> cnpy : getCnpyListSum) {
				if(cnvd.get("VENDOR_CD").equals(cnpy.get("VENDOR_CD"))) {
					sumAmt = sumAmt.add(((BigDecimal)cnpy.get("SUPPLY_AMT")));
					dpRate = dpRate.add(((BigDecimal)cnpy.get("DP_PAY_PERCENT")));
					ppRate = ppRate.add(((BigDecimal)cnpy.get("PP_PAY_PERCENT")));

				}
			}
			//증감금액
			String locAmt         = increaseSumAmt.equals(BigDecimal.valueOf(0)) ? "-" :decFormat.format(increaseSumAmt);
			String increaseAmt    = locAmt.equals("-") ? "-" : decFormat.format(sumAmt.subtract(increaseSumAmt));
			if(!increaseAmt.equals("-")) {
			}
			if(cnvd.get("APAR_TYPE").equals("S")) {
				str.append("			<tr>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>매출</b>\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cnvd.get("VENDOR_NM")+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+locAmt+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(sumAmt)+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+increaseAmt+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(cnvd.get("CT_PO_TYPE").equals("CT") ? "Y" : "N")+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border:none; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+dpRate+"%\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+ppRate+"%\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("CONT_GUAR_PERCENT"))==null ? "0" : ((BigDecimal)cnvd.get("CONT_GUAR_PERCENT")))+"%\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; width:24pt; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("WARR_GUAR_PERCENT"))==null ? "0" : ((BigDecimal)cnvd.get("WARR_GUAR_PERCENT")))+"%\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; width:30pt; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("WARR_GUAR_QT"))==null ? "0" : ((BigDecimal)cnvd.get("WARR_GUAR_QT")))+"개월\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
				str.append("			</td>\r\n");
				str.append("		</tr>\r\n");
			}else {
				str.append("			<tr>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:solid windowtext 1.0pt; border-right:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>매입</b>\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cnvd.get("VENDOR_NM")+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+locAmt+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(sumAmt)+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+increaseAmt+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(cnvd.get("CT_PO_TYPE").equals("CT") ? "Y" : "N")+"\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-top:solid #a6a6a6 1.0pt; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+dpRate+"%\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+ppRate+"%\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("CONT_GUAR_PERCENT"))==null ? "0" : ((BigDecimal)cnvd.get("CONT_GUAR_PERCENT")))+"%\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; width:24pt; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("WARR_GUAR_PERCENT"))==null ? "0" : ((BigDecimal)cnvd.get("WARR_GUAR_PERCENT")))+"%\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; width:30pt; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(((BigDecimal)cnvd.get("WARR_GUAR_QT"))==null ? "0" : ((BigDecimal)cnvd.get("WARR_GUAR_QT")))+"개월\r\n");
				str.append("			</td>\r\n");
				str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid #a6a6a6 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
				str.append("			</td>\r\n");
				str.append("		</tr>\r\n");
			}
		}
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>3. 기타</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'>&nbsp;&nbsp;&nbsp;&nbsp;- 납품일정은 사업장 영업상황에 따라 변경 가능하므로 협의 후 진행\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'><b># 첨부 :</b> 변경 내역서 등(해당내용) 1부\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("		   </td>\r\n");
		str.append("		</tr>\r\n");
		str.append("	</tbody>\r\n");
		str.append("</table>\r\n");
		//리턴값
		reData.put("PROGRESS_CD" , cnHdInfo.get("PROGRESS_CD"));
		reData.put("EXEC_NUM"    , cnHdInfo.get("EXEC_NUM"));
		reData.put("EXEC_CNT"    , cnHdInfo.get("EXEC_CNT"));

		reData.put("BLSM_HTML"    , str);
		return reData;

	}
	public Map<String, Object> getChLoHtml(Map<String, String> formData) {
		//리턴데이터
		Map<String, Object> reData = new HashMap<String, Object>();
		//당초품의데이터
		Map<String, String> prevData = new HashMap<String, String>();
		//품의 구매사.
		Map<String, String> cnHdInfo 		  = cN0100Service.getCnhd(formData);
		//당초 품의 구매사.
		prevData.putAll(formData);
		//이전차수 1빼기
		prevData.put("EXEC_CNT" ,String.valueOf((Integer.valueOf(prevData.get("EXEC_CNT"))-1)));
		prevData.put("APP_DOC_NUM" ,null);
		Map<String, String> prevCnHdInfo = cN0100Service.getCnhd(prevData);
		//상품리스트
		List<Map<String, Object>> getCnDtList =  cN0100Service.doHtmlChCndt(formData);
		//공급사 리스트
		List<Map<String, Object>> getCnvdList =  cN0100Service.doHtmlhCnvd(formData);




		//품의제목
		String execSubject=cnHdInfo.get("EXEC_SUBJECT")+ (cnHdInfo.get("ETC_RMK") == null ? "" : " ["+cnHdInfo.get("ETC_RMK")+"]");
		//당초납품예정일
		String prevDelyDate = prevCnHdInfo.get("DELY_DATE");
		//당초예산집행월
		String prevBudgetExeDate = prevCnHdInfo.get("BUDGET_EXE_DATE").substring(0,4)+ "년 " + prevCnHdInfo.get("BUDGET_EXE_DATE").substring(5,7)+ "월 ";
		//변경예산금액
		BigDecimal cpoUnitAmt   = BigDecimal.ZERO;
		//변경매출금액
		BigDecimal salesUnitAmt = BigDecimal.ZERO;
		//변경매입금액
		BigDecimal qtaUnitAmt = BigDecimal.ZERO;
		//변경예산대비
		BigDecimal cpoUnitRate = BigDecimal.ZERO;
		//변경이익율
		BigDecimal salesProfitRate = BigDecimal.ZERO;
		//변경매춛단가
		BigDecimal salesUnitPrc = BigDecimal.ZERO;
		//변경매입단가
		BigDecimal qtaUnitPrc = BigDecimal.ZERO;
		//변경매출대비율
		BigDecimal salesRate = BigDecimal.ZERO;
		//당초매춛단가
		BigDecimal localSalesUnitPrc = BigDecimal.ZERO;
		//당초매입단가
		BigDecimal localQtaUnitPrc = BigDecimal.ZERO;
		//당초예산금액
		BigDecimal localCpoUnitAmt   = BigDecimal.ZERO;
		//당초매출금액
		BigDecimal localSalesUnitAmt = BigDecimal.ZERO;
		//당초매입금액
		BigDecimal localQtaUnitAmt = BigDecimal.ZERO;
		//당초예산대비
		BigDecimal localCpoUnitRate = BigDecimal.ZERO;
		//당초이익율
		BigDecimal localSalesProfitRate = BigDecimal.ZERO;
		//당초매출대비율
		BigDecimal localSalesRate = BigDecimal.ZERO;
		//증감예산금액
		BigDecimal increaseCpoUnitAmt   = BigDecimal.ZERO;
		//증감매출금액
		BigDecimal increaseSalesUnitAmt = BigDecimal.ZERO;
		//증감예산대비
		BigDecimal increaseCpoUnitRate = BigDecimal.ZERO;

		//납품예정일
		String delyDate = cnHdInfo.get("DELY_DATE");
		//예산집행월
		String budgetExeDate = cnHdInfo.get("BUDGET_EXE_DATE").substring(0,4)+ "년 " + cnHdInfo.get("BUDGET_EXE_DATE").substring(5,7)+ "월 ";
		//선정사유 비고
		String selCause = cnHdInfo.get("SEL_CAUSE");
		//대금지급 구매사.
		List<Map<String, Object>> getCnpyList =  cN0100Service.getHtmlCnpyList(formData);

		for(Map<String,Object> cndt : getCnDtList) {
			//당초금액
			localCpoUnitAmt   = localCpoUnitAmt.add(((BigDecimal)cndt.get("DT1_CPO_UNIT_AMT")));
			localSalesUnitAmt = localSalesUnitAmt.add(((BigDecimal)cndt.get("DT1_SALES_UNIT_AMT")));
			localQtaUnitAmt   = localQtaUnitAmt.add(((BigDecimal)cndt.get("DT1_QTA_UNIT_AMT")));
			localSalesUnitPrc = localSalesUnitPrc.add(((BigDecimal)cndt.get("DT1_SALES_UNIT_PRC")));
			localQtaUnitPrc   = localQtaUnitPrc.add(((BigDecimal)cndt.get("DT1_QTA_UNIT_PRC")));
			//변경금액
			cpoUnitAmt   = cpoUnitAmt.add(((BigDecimal)cndt.get("DT2_CPO_UNIT_AMT")));
			salesUnitAmt = salesUnitAmt.add(((BigDecimal)cndt.get("DT2_SALES_UNIT_AMT")));
			qtaUnitAmt   = qtaUnitAmt.add(((BigDecimal)cndt.get("DT2_QTA_UNIT_AMT")));
			salesUnitPrc = salesUnitPrc.add(((BigDecimal)cndt.get("DT2_SALES_UNIT_PRC")));
			qtaUnitPrc   = qtaUnitPrc.add(((BigDecimal)cndt.get("DT2_QTA_UNIT_PRC")));

		}
		//변경예상대비
		cpoUnitRate     = salesUnitAmt.divide(cpoUnitAmt,4,BigDecimal.ROUND_HALF_UP);
		cpoUnitRate     = cpoUnitRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//당초예산대비
		localCpoUnitRate = localSalesUnitAmt.divide(localCpoUnitAmt,4,BigDecimal.ROUND_HALF_UP);
		localCpoUnitRate = localCpoUnitRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//변경이익율
		salesProfitRate = salesUnitPrc.subtract(qtaUnitPrc);
		salesProfitRate = salesProfitRate.divide(qtaUnitPrc,4,BigDecimal.ROUND_HALF_UP);
		salesProfitRate = salesProfitRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//당초이익율
		localSalesProfitRate = localSalesUnitPrc.subtract(localQtaUnitPrc);
		localSalesProfitRate = localSalesProfitRate.divide(localQtaUnitPrc,4,BigDecimal.ROUND_HALF_UP);
		localSalesProfitRate = localSalesProfitRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//변경매출대비율
		salesRate = qtaUnitPrc.divide(salesUnitPrc,4,BigDecimal.ROUND_HALF_UP);
		salesRate = salesRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
		//당초매출대비율
		localSalesRate = localQtaUnitPrc.divide(localSalesUnitPrc,4,BigDecimal.ROUND_HALF_UP);
		localSalesRate = localSalesRate.multiply(new BigDecimal(100)).setScale(2, RoundingMode.HALF_UP);
        //증감 계산
		increaseCpoUnitAmt       = cpoUnitAmt.subtract(localCpoUnitAmt);
		increaseSalesUnitAmt     = salesUnitAmt.subtract(localSalesUnitAmt);
		increaseCpoUnitRate      = cpoUnitRate.subtract(localCpoUnitRate);



		//선급금
		BigDecimal dpsupplyAmt = BigDecimal.ZERO;
		//중도금
		BigDecimal ppsupplyAmt = BigDecimal.ZERO;
		//공급가액
		for(Map<String,Object> cnvd : getCnvdList) {

			if(cnvd.get("APAR_TYPE").equals("S")) {
				//대금지급 조건 sum
				for(Map<String,Object> cnpy : getCnpyList) {
					if(cnvd.get("VENDOR_CD").equals(cnpy.get("VENDOR_CD"))) {
						if(cnpy.get("PAY_CNT_TYPE").equals("DP")) {
							dpsupplyAmt = dpsupplyAmt.add(((BigDecimal)cnpy.get("SUPPLY_AMT")));
						}else if(cnpy.get("PAY_CNT_TYPE").equals("PP")) {
							ppsupplyAmt = ppsupplyAmt.add(((BigDecimal)cnpy.get("SUPPLY_AMT")));
						}
					}



				}
			}

		}
		StringBuffer str = new StringBuffer("");
		str.append("<table class='Table' style='width:650.65pt; border:none' width='650'>\r\n");
		str.append("	<tbody>\r\n");
		str.append("		<tr>\r\n");
		str.append("			<td>\r\n");
		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'><b>&nbsp;&nbsp;내 용 : "+execSubject+" 관련</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;아래와 같이 변경하고자 하오니 검토 후 재가하여 주시기 바랍니다.\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; color:black; border:none; padding:0cm'>- 아&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;래 -\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>1. 변경구매 정보 및 세부내용</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:100pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt; height:82.75pt'><b>※변경사유 :</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt; height:82.75pt'>"+(selCause == null ? "" : selCause)+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원, VAT별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:30pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>구분</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:90pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:90pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>계약금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:45pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>예산대비</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>물품공급사</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:60pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>품의완료일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:60pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>납기예정일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:60pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>집행일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>당초</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(localCpoUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(localSalesUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+localCpoUnitRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>㈜대명소노시즌\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(prevDelyDate == null ? "" : prevDelyDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(prevBudgetExeDate == null ? "" : prevBudgetExeDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>변경</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cpoUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(salesUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cpoUnitRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>㈜대명소노시즌\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(delyDate == null ? "" : delyDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(budgetExeDate == null ? "" : budgetExeDate)+"\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>증감</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(increaseCpoUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(increaseSalesUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+increaseCpoUnitRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>2. 변경계약내용</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; border:none; padding:0cm 4.95pt 0cm 4.95pt;'>① 변경 세부사항\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원, VAT별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:120pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>주요품목</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:25pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>단위</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; width:95pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>당초</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; width:95pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>변경</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='3' rowspan='1' style='text-align:center; width:120pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>증감</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:120pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>비고</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:28pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>수량</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:28pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>수량</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:28pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>수량</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:33pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>비율</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		int cndtInx=1;

		BigDecimal increaseItemQtSum = BigDecimal.ZERO;
		BigDecimal increaseAmtSum    = BigDecimal.ZERO;
		BigDecimal localItemQtSum    = BigDecimal.ZERO;
		BigDecimal itemQtSum         = BigDecimal.ZERO;

		BigDecimal itemQtSum1         = BigDecimal.ZERO;

		//상품리스트 금액 sum


		for(Map<String,Object> cndt : getCnDtList) {
			itemQtSum =itemQtSum.add((BigDecimal)cndt.get("DT1_ITEM_QT"));
			itemQtSum1 =itemQtSum1.add((BigDecimal)cndt.get("DT2_ITEM_QT"));

			str.append("			<tr>\r\n");
			str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cndtInx+". "+cndt.get("ITEM_DESC")+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cndt.get("UNIT_CD")+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT1_ITEM_QT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT1_SALES_UNIT_AMT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; width:28pt; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT2_ITEM_QT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT2_SALES_UNIT_AMT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT3_ITEM_QT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(cndt.get("DT3_SALES_UNIT_AMT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+cndt.get("DT3_SALES_UNIT_RATE")+"%\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
			str.append("			</td>\r\n");
			str.append("		   </tr>\r\n");
			cndtInx++;
		}
		increaseItemQtSum = increaseItemQtSum.add(itemQtSum1.subtract((itemQtSum)));
		increaseAmtSum    = increaseAmtSum.add(salesUnitAmt.subtract((localSalesUnitAmt)));
		//선급퍼센트
		BigDecimal dpRate = BigDecimal.ZERO;
		//중도금퍼센트
		BigDecimal ppRate = BigDecimal.ZERO;
		//공급가액
		BigDecimal sumAmt  = BigDecimal.ZERO;

		//대금지급 조건 sum
		List<Map<String, Object>> getCnpyListSum =  cN0100Service.getHtmlCnpyListSum(formData);
		for(Map<String,Object> cnpy : getCnpyListSum) {
			if(cnpy.get("APAR_TYPE").equals("S")) {
				System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz");
			System.out.println(((BigDecimal)cnpy.get("DP_PAY_PERCENT")));
			System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz");

				sumAmt = sumAmt.add(((BigDecimal)cnpy.get("SUPPLY_AMT")));
				dpRate = dpRate.add(((BigDecimal)cnpy.get("DP_PAY_PERCENT")));
				ppRate = ppRate.add(((BigDecimal)cnpy.get("PP_PAY_PERCENT")));
			}
		}
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>[합&nbsp;&nbsp;&nbsp;계]</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b></b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(localItemQtSum)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(localSalesUnitAmt)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(itemQtSum)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(salesUnitAmt)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(increaseItemQtSum)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+decFormat.format(increaseAmtSum)+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b></b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b></b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; border:none; padding:0cm 4.95pt 0cm 4.95pt;'>② 계약 세부사항\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원, VAT별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:100pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>공급받는 자</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:100pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>공급하는 자</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='3' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>계약금액 (VAT)별도</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:30pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>계약</br>여부</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:30pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>선급</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:30pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>중도</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='4' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>보증정보</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>당초</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>변경</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>증감</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>계약</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' rowspan='1' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>하자증권</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>보증</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:none; padding:0cm 4.95pt 0cm 4.95pt;'>"+cnHdInfo.get("PR_BUYER_NM")+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>㈜대명소노시즌\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(localSalesUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(salesUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(increaseSalesUnitAmt)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(cnHdInfo.get("CT_PO_TYPE").equals("CT") ? "Y" : "N")+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border:none; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+dpRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+ppRate+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+((String.valueOf(cnHdInfo.get("CONT_GUAR_PERCENT")))==null ? "0" : (String.valueOf(cnHdInfo.get("CONT_GUAR_PERCENT"))))+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+((String.valueOf(cnHdInfo.get("WARR_GUAR_PERCENT")))==null ? "0" : (String.valueOf(cnHdInfo.get("WARR_GUAR_PERCENT"))))+"%\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+((String.valueOf(cnHdInfo.get("WARR_GUAR_QT")))==null ? "0" : (String.valueOf(cnHdInfo.get("WARR_GUAR_QT"))))+"개월\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("		</tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		str.append("			<p align='right' style='margin-bottom:0cm; text-align:right; margin:0cm 0cm 8pt'><span style='font-size:8pt'><span style='line-height:normal'><span style='text-autospace:ideograph-numeric ideograph-other'><span style='word-break:keep-all'><span style='font-family:&quot;맑은 고딕&quot;'>&nbsp;<span style='font-size:9pt'><span style='font-family:굴림'><span style='color:#595959'>*</span></span><span style='font-size:9pt'><span style='font-family:굴림'><span style='color:#595959'> 보증현황</span></span></span><span style='font-size:9pt'><span style='font-family:굴림'><span style='color:#595959'> : </span></span></span> <span style='font-size:9pt'><span style='font-family:굴림'><span style='color:#595959'>첨부파일 </span></span></span> <span style='font-size:9pt'><span style='font-family:굴림'><span style='color:#595959'>內 </span></span></span> <span style='font-size:9pt'><span style='font-family:굴림'><span style='color:#595959'>물품공급사선정안내 </span></span></span><span style='font-size:9pt'><span style='font-family:굴림'><span style='color:#595959'>참고</span></span></span></span></span></span></span></span></span></span></p>\r\n");

		str.append("			</br>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>3. 기타</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'>&nbsp;&nbsp;&nbsp;&nbsp;- 납품일정은 사업장 영업상황에 따라 변경 가능하므로 협의 후 진행\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'><b># 첨부 :</b> 변경 내역서 등(해당내용) 1부\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("		   </td>\r\n");
		str.append("		</tr>\r\n");
		str.append("	</tbody>\r\n");
		str.append("</table>\r\n");
		//리턴값
		reData.put("PROGRESS_CD" , cnHdInfo.get("PROGRESS_CD"));
		reData.put("EXEC_NUM"    , cnHdInfo.get("EXEC_NUM"));
		reData.put("EXEC_CNT"    , cnHdInfo.get("EXEC_CNT"));

		reData.put("BLSM_HTML"    , str);
		return reData;

	}
	public Map<String, Object> getBdHtml(Map<String, String> formData) throws Exception {
		//리턴 데이터
		Map<String, Object> reData = new HashMap<String, Object>();
		Map<String, String> param = new HashMap<String, String>();
		param.put("RFX_NUM"		, formData.get("EXEC_NUM"));
		param.put("RFX_CNT"		, formData.get("EXEC_CNT"));
		param.put("BUYER_CD"	, "2518");
		//입찰 헤더조회
		Map<String, Object> bdHd = bd0300Service.getBdHdDetail(param);
		//입찰 상품데이터 조회
		List<Map<String, Object>> bdItem = bd0300Service.getRfxDtDetail(param);
		//입찰 공급사데이터 조회
		List<Map<String, Object>> bdVdList = bd0300Service.getVendorListHtml(param);
		//오늘날짜
		String SYSDATE = EverDate.getDateString();
		//품의제목
		String execSubject=String.valueOf(bdHd.get("RFX_SUBJECT"));
		//개최여부
		String annFlag = String.valueOf(bdHd.get("ANN_FLAG"));
		//설명회일시
		String annDate = "";
		//설명회장소
		String annPlace = "";
		if(annFlag.equals("1")) {
			String val= String.valueOf(bdHd.get("ANN_DATE"));
			annDate  = val.substring(0,4)+"-"+val.substring(4,6)+"-"+val.substring(6,8);
			annPlace = String.valueOf(bdHd.get("ANN_FROM_HOUR"))+"시, "+String.valueOf(bdHd.get("ANN_PLACE_NM"));
		}
		//입찰마감일
		String rfxFromMin = String.valueOf(bdHd.get("RFX_TO_DATE")).substring(0,4)+"-"+String.valueOf(bdHd.get("RFX_TO_DATE")).substring(4,6)+"-"+String.valueOf(bdHd.get("RFX_TO_DATE")).substring(6,8);
		//입찰마감시간
		String rfxToHour  = "~"+String.valueOf(bdHd.get("RFX_TO_HOUR"))+"시 마감";

		StringBuffer str = new StringBuffer("");
		str.append("<table class='Table' style='width:650.65pt; border:none' width='650'>\r\n");
		str.append("	<tbody>\r\n");
		str.append("		<tr>\r\n");
		str.append("		<td>\r\n");
		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'><b>&nbsp;&nbsp;내 용 : "+execSubject+"을</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:black; border:none; padding:0cm'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;근거로 아래와 같이 입찰을 시행하고자 하오니 검토 후 재가하여 주시기 바랍니다.\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; color:black; border:none; padding:0cm'>- 아&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;래 -\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>1. 입찰설명 및 전자입찰 진행일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:190pt; border-bottom:none; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid black 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>구매요청일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>구매방식</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>주요일정</b>\r\n");
		str.append("		</tr>\r\n");
		str.append("		<tr>\r\n");
		str.append("			<td style='text-align:center; width:50pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt;; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>전자입찰</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:50pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt;; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>제안입찰</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:153pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:solid windowtext 1.0pt;; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>설명회 시행일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:153pt; border:solid windowtext 1.0pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; padding:0cm 4.95pt 0cm 4.95pt;'><b>전자입찰 종료일</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		</tr>\r\n");
		str.append("		<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid black 1.0pt; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt;; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;' valign='bottom'>"+SYSDATE+"</br>ERP 자재청구서\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid black 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>●\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid black 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid black 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;' valign='bottom'>"+(annDate=="" ? "" :annDate)+"</br>"+(annPlace=="" ? "" :annPlace)+"\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;' valign='bottom'>"+rfxFromMin+"</br>"+rfxToHour+"\r\n");
		str.append("			</td>\r\n");
		str.append("		</tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("		<br/>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; border:none; color:red; padding:0cm;'><b>2. 예산금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 원/V.A.T별도]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:190pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>주요품목</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:30pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>단위</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:43pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>수량</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:70pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>단가</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:90pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>금액</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:43pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>비율</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>비고</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");

		for(Map<String,Object> bdInfo :bdItem) {
			str.append("			<tr>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:solid black 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+bdInfo.get("ITEM_DESC")+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+bdInfo.get("UNIT_CD")+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(bdInfo.get("RFX_QT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(bdInfo.get("UNIT_PRC"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+decFormat.format(bdInfo.get("RFX_AMT"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:right; border:solid black 1.0pt; border-bottom:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
			str.append("			</td>\r\n");
			str.append("		</tr>\r\n");
		}
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("		<br/>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; border:none; color:red; padding:0cm;'><b>3.지명경쟁 입찰 참여사(예정)</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:right; border:none; padding:0cm 4.95pt 0cm 4.95pt;'><b>[단위: 백만원]<b/>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; width:120pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>회사명</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='2' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>협력사 등재</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='3' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>회사정보</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='5' style='text-align:center; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>신용평가</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td colspan='1' rowspan='2' style='text-align:center; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>비고</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:18pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>기존</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:18pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>신규</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:30pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>대표자</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:140pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>소재지</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:45pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>설립연도</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:32pt; border-bottom:solid windowtext 1.0pt; width:20pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>신용</br>등급</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:32pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>현금</br>흐름</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:26pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>총자산</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:20pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>자본</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:20pt; border-bottom:solid windowtext 1.0pt; background:#f2f2f2; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>매출</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");
		//참여공급사수
		int vdCnt = 0;
		//공급사 배열
		String[] vdNames      = new String[5];
		for(Map<String,Object> bdvd:bdVdList) {
			if(vdCnt<=4) {
				vdNames[vdCnt]=String.valueOf(bdvd.get("VENDOR_NM"));
			}
			vdCnt++;
			str.append("			<tr>\r\n");
			str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:solid black 1.0pt; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(bdvd.get("VENDOR_NM")==null ? "": bdvd.get("VENDOR_NM"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>●\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(bdvd.get("CEO_USER_NM")==null ? "" :bdvd.get("CEO_USER_NM"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(bdvd.get("HQ_ADDR_1")==null ? "" :bdvd.get("HQ_ADDR_1"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(bdvd.get("FOUNDATION_DATE")==null ? "" : bdvd.get("FOUNDATION_DATE"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(bdvd.get("EVA1")==null ? "" : bdvd.get("EVA1"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>"+(bdvd.get("EVA2")==null ? "" : bdvd.get("EVA2"))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;text-align: right;'>"+(bdvd.get("SUM_AMT")==null ? "" : decFormat.format(bdvd.get("SUM_AMT")))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;text-align: right;'>"+(bdvd.get("CAPITAL")==null ? "" : decFormat.format(bdvd.get("CAPITAL")))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;text-align: right;'>"+(bdvd.get("INS_AMT")==null ? "" : decFormat.format(bdvd.get("INS_AMT")))+"\r\n");
			str.append("			</td>\r\n");
			str.append("			<td style='border-right:solid windowtext 1.0pt; border-bottom:solid #a6a6a6 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
			str.append("			</td>\r\n");
			str.append("		</tr>\r\n");

		}
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("		<br/>\r\n");

		str.append("			<table style='width:648pt; border-collapse:collapse; border:none' width='648'>\r\n");
		str.append("			<tbody>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:left; color:red; border:none; padding:0cm'><b>4. 공급현황</b>\r\n");
		str.append("			</td>\r\n");
		str.append("		   </tr>\r\n");
		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; width:38pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>구분</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>현장명</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:85pt; border-bottom:solid black 1.0pt;background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[0]==null ? "":vdNames[0])+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:85pt; border-bottom:solid black 1.0pt; background:#f2f2f2;border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[1]==null ? "":vdNames[1])+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:85pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[2]==null ? "":vdNames[2])+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:85pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[3]==null ? "":vdNames[3])+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:85pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>"+(vdNames[4]==null ? "":vdNames[4])+"</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; width:55pt; border-bottom:solid black 1.0pt; background:#f2f2f2; border-top:solid windowtext 1.0pt; border-left:none; border-right:solid black 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'><b>비고</b>\r\n");
		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='3' style='text-align:center; border-bottom:solid black 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>계열사\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td colspan='1' rowspan='3' style='text-align:center; border-bottom:solid black 1.0pt; border-left:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>비계열사\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid #a6a6a6 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");

		str.append("			<tr>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			<td style='text-align:center; border-bottom:solid windowtext 1.0pt; border-top:none; border-left:none; border-right:solid windowtext 1.0pt; padding:0cm 4.95pt 0cm 4.95pt;'>\r\n");
		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");

		str.append("			</td>\r\n");
		str.append("			</tr>\r\n");
		str.append("			</tbody>\r\n");
		str.append("			</table>\r\n");
		str.append("\r\n");

		//리턴값
		reData.put("PROGRESS_CD" , bdHd.get("PROGRESS_CD"));
		reData.put("EXEC_NUM"    , bdHd.get("RFX_NUM"));
		reData.put("EXEC_CNT"    , bdHd.get("RFX_CNT"));
		reData.put("BLSM_HTML"   , str);
		return reData;

	}
	public String getAmtVaild(Map<String,Object> data, String vendorNm) {
		String amt = "";
		String dataNm	= (String) data.get("VENDOR_NM");
		String vdNm		=  vendorNm;
		if(dataNm.equals(vdNm)) {
			amt=decFormat.format(data.get("QTA_UNIT_AMT"));
		}
		return amt;
	}
}