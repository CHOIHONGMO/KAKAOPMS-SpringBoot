<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib uri = "http://java.sun.com/jsp/jstl/functions" prefix = "fn" %>

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
	}

	function tab_click(screenId, e) {
		//메뉴 접근 권한 체크
		var accessableScreenId = EVF.V("accessableScreenId");
		if(accessableScreenId.indexOf(screenId) == -1) {
			return EVF.alert("해당 직무에 권한이 없습니다.");
		}

		var param = {
			dashBoardFlag: 'Y',
			detailView: false,
			date2: '${date2}', 	//두달 전
			date1: '${date1}', 	//한달 전
			today: '${today}',	//오늘
			date0: '${date0}' 	//한달 후
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

			case 'voice':
				var param = {
					VC_NO: docNum,
					detailView: false
				};
				everPopup.openPopupByScreenId("BS99_021", 800, 700, param);
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
							<h3>신규상품요청 현황<br/><span>receive purchase<br/>request</span></h3>
							<dl id="IM03_010">
								<a href="javascript:tab_click('IM03_010', this);">
									<dt>신규상품 접수대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'IM03_010') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('IM03_010', this);">${form.SUMMARY1}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
							<dl id="RQ01_026">
								<a href="javascript:tab_click('RQ01_020', this);">
									<dt>신규 견적마감, 선정대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'RQ01_020') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('RQ01_020', this);">${form.SUMMARY2}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
							<dl id="RQ01_030">
								<a href="javascript:tab_click('RQ01_030', this);">
									<dt>코드상품 등록대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'RQ01_030') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('RQ01_030', this);">${form.SUMMARY3}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
						</td>
						<td>
							<h3>주문진행현황<br/><span>contract and<br/>purchase order</span></h3>
							<dl id="OD01_001">
								<a href="javascript:tab_click('OD01_001', this);">
									<dt>고객사 주문접수 대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'OD01_001') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('OD01_001', this);">${form.SUMMARY4}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
							<dl id="PO0210">
								<a href="javascript:tab_click('PO0210', this);">
									<dt>발주확정 대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'PO0210') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('PO0210', this);">${form.SUMMARY5}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
							<dl id="OD03_010">
								<a href="javascript:tab_click('OD03_010', this);">
									<dt>고객입고 대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'OD03_010') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('OD03_010', this);">${form.SUMMARY6}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
						</td>
						<td>
							<h3>소싱 및 계약/ 품의현황<br/><span>inspection<br/>management</span></h3>
							<dl id="RQ0340">
								<a href="javascript:tab_click('RQ0340', this);">
									<dt>견적 마감, 선정대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'RQ0340') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('RQ0340', this);">${form.SUMMARY7}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
							<dl id="BD0340">
								<a href="javascript:tab_click('BD0340', this);">
									<dt>입찰 마감, 선정대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'BD0340') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('BD0340', this);">${form.SUMMARY8}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
							<dl id="CN0110">
								<a href="javascript:tab_click('CN0110', this);">
									<dt>구매 품의 대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'CN0110') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('CN0110', this);">${form.SUMMARY9}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
							<dl id="CT0510">
								<a href="javascript:tab_click('CT0510', this);">
									<dt>계약서 작성대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'CT0510') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('CT0510', this);">${form.SUMMARY10}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
							<dl id="MY02_001">
								<a href="javascript:tab_click('MY02_001', this);">
									<dt>내부결재 대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'MY02_001') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('MY02_001', this);">${form.SUMMARY11}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
						</td>
						<td>
							<h3>회원사 관리현황<br/><span>supplier<br/>management</span></h3>
							<dl id="BS03_009">
								<a href="javascript:tab_click('BS03_009', this);">
									<dt>협력회사 가입대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'BS03_009') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('BS03_009', this);">${form.SUMMARY12}</a>
									</c:otherwise>
								</c:choose>
									</dd>
								</a>
							</dl>
							<dl id="BS01_090">
								<a href="javascript:tab_click('BS01_090', this);">
									<dt>고객사 가입대기</dt>
									<dd>
							 	<c:choose>
									<c:when test="${fn:indexOf(accessableScreenId, 'BS01_090') == -1}">
										<a href="#">0</a>
									</c:when>
									<c:otherwise>
										<a href="javascript:tab_click('BS01_090', this);">${form.SUMMARY13}</a>
									</c:otherwise>
								</c:choose>
									</dd>
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
					<td>
						<h2><img src="/images/kakao/mypage-icon2.png"/>고객의 소리</h2>
						<ul>
							<li class="title">
								<span class="subject">제목</span><span class="date">날짜</span></li>
							</li>
							<c:forEach items="${voiceListMain}" var="C">
								<li class="cont">
									<span class="subject"><a href="javascript:openPopup('${C.VC_NO}','','','voice');">${C.REQ_RMK}</a></span>
									<span style="display:inline-block; margin-left:35px; text-align:right;vertical-align:middle; font-size:12px;line-height:0;color:#666">${C.PH_DATE}</span>
								</li>
							</c:forEach>
						</ul>
					</td>
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