<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<head>
<link rel="stylesheet" href="/css/kakao/mypage.css" media="all">
<style>
	.e-window-container {
		width: 1588px;
		overflow-x: auto;
	}

	.worklist-wrap a:hover{
		text-decoration: none;
	}
</style>
<script>
	var baseUrl = "/eversrm/buyer/bmy";

	function init() {
		/* 권한이 없는 메뉴 숨기기
		$('td > dl ').each(function(index, b) {
			var screenId = EVF.V("accessableScreenId");
			if(screenId.indexOf(b.id) == -1) {
				$('#'+b.id).css('display', 'none');
			}
		});*/
		
		// 견적서 합의대기
		if("${ses.ctrlCd}".indexOf("T100") == -1 && "${ses.ctrlCd}".indexOf("M100") == -1 && "${ses.mngYn}" != "1") {
			$('#BNM1_031').css('display', 'none');
		}
		// 입고대상 조회
		if("${ses.ctrlCd}".indexOf("T100") == -1 && "${ses.ctrlCd}".indexOf("M100") == -1 && "${ses.mngYn}" != "1" && "${ses.grFlag}" != "1") {
			$('#BGA1_010').css('display', 'none');
		}
	}

	function tab_click(screenId, e) {
		//메뉴 접근 권한 체크
		/* var accessableScreenId = EVF.V("accessableScreenId");
		if(accessableScreenId.indexOf(screenId) == -1) {
			return EVF.alert("해당 직무에 권한이 없습니다.");
		} */

		var param = {
			dashBoardFlag: 'Y',
			detailView: false,
			date2: '${date2}', 	//두달 전
			date1: '${date1}', 	//한달 전
			today: '${today}',	//오늘
			date0: '${date0}' 	//한달 후
		}

		switch (screenId){
			case 'BNM1_040':
				param['PROGRESS_CD'] = '400';
				break;
			case 'BOD1_050':
				param['PROGRESS_CD'] = '400';
				break;
			default :
				break;
		}
		
		top.pageRedirectByScreenId(screenId, param);
	}

	//popup창 호출
	function openPopup(docNum, docCnt, buyerCd, docType){
		var url = '';
		switch (docType){
			case 'notice':
				var param = {
					NOTICE_NUM: docNum,
					NOTICE_TYPE: 'PCN',
					detailView: true
				};
				everPopup.openPopupByScreenId("BBD01_021", 1000, 770, param);
				break;

			case 'bidding':
			    var param = {
					BUYER_CD: buyerCd,
					RFX_NUM: docNum,
					RFX_CNT: docCnt,
					detailView: true
				};
				everPopup.openPopupByScreenId('BD0310', 1200, 900, param);
				break;

			/*case 'qna':
				url = "/eversrm/buyer/qna/BQNA01_030/view";
				var param = {
					QNA_NUM: docNum,
					onClose: 'closePopup',
					detailView: true
				};
				everPopup.openWindowPopup(url, 1000, 630, param, "everSrmreplyQna");
				break;

			case 'faq':
				var param = {
					NOTICE_NUM: docNum,
					NOTICE_TYPE: 'PCF',
					detailView: true
				};
				everPopup.openPopupByScreenId("BBD01_021", 1000, 770, param);
				break;*/
		}
	}

</script>
</head>

<%--구매사메인--%>
<e:window id="BMY01_010" onReady="init" initData="${initData}" title="">
	<e:inputHidden id="accessableScreenId" name="accessableScreenId" value="${accessableScreenId}"/>
	<div class="mypage-wrapper clearfix" style="background:white">
		<section>
			<div class="worklist-wrap ">
				<h2><img src="/images/kakao/mypage-icon1.png"/>WORK LIST</h2>
				<table>
					<tr>
						<td>
							<h3>신규상품요청현황<br/><span>receive purchase<br/>request</span></h3>
							<dl id="BNM1_040">
								<a href="javascript:tab_click('BNM1_040', this);">
									<dt>신규상품 요청현황</dt>
									<dd><a href="javascript:tab_click('BNM1_040', this);">${form.SUMMARY1}</a></dd>
								</a>
							</dl>
							<dl id="BNM1_031">
								<a href="javascript:tab_click('BNM1_031', this);">
									<dt>견적서 합의대기</dt>
									<dd><a href="javascript:tab_click('BNM1_031', this);">${form.SUMMARY2}</a></dd>
								</a>
							</dl>
							<BR/>
							<BR/>
							<BR/>
							<BR/>
						</td>
						<td>
							<h3>주문진행현황<br/><span>contract and<br/>purchase order</span></h3>
							<dl id="BOD1_050">
								<a href="javascript:tab_click('BOD1_050', this);">
									<dt>주문 진행현황</dt>
									<dd><a href="javascript:tab_click('BOD1_050', this);">${form.SUMMARY3}</a></dd>
								</a>
							</dl>
							<dl id="BGA1_010">
								<a href="javascript:tab_click('BGA1_010', this);">
									<dt>입고대상 조회</dt>
									<dd><a href="javascript:tab_click('BGA1_010', this);">${form.SUMMARY4}</a></dd>
								</a>
							</dl>
						</td>
						<td>
							<h3>결재현황<br/><span>inspection<br/>management</span></h3>
							<dl id="MY02_001">
								<a href="javascript:tab_click('MY02_001', this);">
									<dt>내부결재 대기</dt>
									<dd><a href="javascript:tab_click('MY02_001', this);">${form.SUMMARY5}</a></dd>
								</a>
							</dl>
						</td>
						<td>
							<h3>회원사 관리현황<br/><span>supplier<br/>management</span></h3>
							<dl id="EV0240">
								<a href="javascript:tab_click('EV0240', this);">
									<dt>평가대기</dt>
									<dd><a href="javascript:tab_click('EV0240', this);">${form.SUMMARY6}</a></dd>
								</a>
							</dl>
						</td>
					</tr>
				</table>
			</div>
		</section>
		<section class="clearfix">
			<table class="list-wrap">
				<tr>
					<td>
						<h2><img src="/images/kakao/mypage-icon2.png"/>공지사항</h2>
						<ul>
							<li class="title"><span class="subject">제목</span><span class="date">날짜</span></li>
							<c:forEach items="${noticeListMain}" var="C">
								<li class="cont">
									<span class="subject"><a href="javascript:openPopup('${C.NOTICE_NUM }','','','notice');">${C.SUBJECT}</a></span><span class="date">${C.REG_DATE}</span>
								</li>
							</c:forEach>
						</ul>
					</td>
					<td></td>
					<%--
					<td valign="top" align="center">
						<iframe src="/dal.html" frameBorder=0 width=420 scrolling=no height=304 topmargin="0" marginWidth=0 name=irate marginHeight=0></iframe>
					</td>
					<td valign="top">
						<iframe src="https://spot.wooribank.com/pot/Dream?withyou=FXCNT0002&rc=0&divType=1&lang=KOR" frameBorder=0 width=264 scrolling=no height=164 topmargin="0" marginWidth=0 name=irate marginHeight=0></iframe>
					</td>
					--%>
				</tr>
			</table>
		</section>
	</div>
</e:window>
</e:ui>