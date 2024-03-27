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

		//발주승인 권한이 없을시 발주 승인 대기목록 안보이게.
		if("${ses.ctrlCd}".indexOf("P100") == -1) {
			$('#PO0230').css('display', 'none');
		}
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
			date2: '${date2}', //두달 전
			date1: '${date1}', //한달 전
			today: '${today}',//오늘
			date0: '${date0}' //한달 후
		}

		switch (screenId){
			case 'PR0340': //구매요청접수 > 미접수
				param['PROGRESS_CD'] = '0';
				param['FROM_DATE'] = '${date1}';
				param['TO_DATE'] = '${today}';
				break;
			case 'CT0510':
				param['FROM_DATE'] = '${date2}';
				param['TO_DATE'] = '${today}'
				break;
			case 'CT0330':
				param['FROM_DATE'] = '${today}';
				param['TO_DATE'] = '${date0}';
				break;
			case 'PO0230':
				param['FROM_DATE'] = '${date1}';
				param['TO_DATE'] = '${date0}';
				param['PROGRESS_CD'] = '5120';
				param['SIGN_STATUS'] = 'P';
				break;
			case 'VD0110':
				param['VENDOR_TYPE'] = 'T';
				param['PROGRESS_CD'] = 'A';
				param['CTRL_USER_ID1'] = '${ses.userId}';
				break;
			case 'GR0110':
				param['FROM_DATE'] = '${date1}';
				param['TO_DATE'] = '${date0}';
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
		<div class="mypage-wrapper clearfix">
			<section>
				<div class="worklist-wrap ">
					<h2><img src="/images/samyangfoods/mypage-icon1.png"/>WORK LIST</h2>
					<table>
						<tr>
							<td>
								<h3>구매요청/선정품의<br/><span>receive purchase<br/>request</span></h3>
								<dl id="PR0340">
									<a href="javascript:tab_click('PR0340', this);">
										<dt>구매요청 접수 대기</dt>
										<dd><a href="javascript:tab_click('PR0340', this);">${form.summary1}</a></dd>
									</a>
								</dl>
								<dl id="CN0110">
									<a href="javascript:tab_click('CN0110', this);">
										<dt>협력업체 선정품의 대기</dt>
										<dd><a href="javascript:tab_click('CN0110', this);">${form.summary2}</a></dd>
									</a>
								</dl>
							</td>
							<td>
								<h3>계약 및 발주 관리<br/><span>contract and<br/>purchase order</span></h3>
								<dl id="CT0510">
									<a href="javascript:tab_click('CT0510', this);">
										<dt>계약 대기 목록</dt>
										<dd><a href="javascript:tab_click('CT0510', this);">${form.summary3}</a></dd>
									</a>
								</dl>
								<dl id="PO0210">
									<a href="javascript:tab_click('PO0210', this);">
										<dt>발주 대기 목록</dt>
										<dd><a href="javascript:tab_click('PO0210', this);">${form.summary4}</a></dd>
									</a>
								</dl>
								<dl id="PO0230">
									<a href="javascript:tab_click('PO0230', this);">
										<dt>발주 승인 대기 목록</dt>
										<dd><a href="javascript:tab_click('PO0230', this);">${form.summary5}</a></dd>
									</a>
								</dl>
								<dl id="CT0330">
									<a href="javascript:tab_click('CT0330', this);">
										<dt>단가 계약 만기 전 목록</dt>
										<dd><a href="javascript:tab_click('CT0330', this);">${form.summary6}</a></dd>
									</a>
								</dl>
							</td>
							<td>
								<h3>입고 관리<br/><span>inspection<br/>management</span></h3>
								<%--<dl id="GR0310">
									<a href="javascript:tab_click('GR0310', this);">
										<dt>검수 대기 목록</dt>
										<dd><a href="javascript:tab_click('GR0310', this);">${form.summary7}</a></dd>
									</a>
								</dl>--%>
								<dl id="GR0110">
									<a href="javascript:tab_click('GR0110', this);">
										<dt>입고 대기 목록</dt>
										<dd><a href="javascript:tab_click('GR0110', this);">${form.summary8}</a></dd>
									</a>
								</dl>
							</td>
							<td>
								<h3>협력업체 관리<br/><span>supplier<br/>management</span></h3>
								<dl id="VD0110">
									<a href="javascript:tab_click('VD0110', this);">
										<dt>신규업체 가입 요청</dt>
										<dd><a href="javascript:tab_click('VD0110', this);">${form.summary9}</a></dd>
									</a>
								</dl>
								<dl id="VD0210">
									<a href="javascript:tab_click('VD0210', this);">
										<dt>업체정보 변경 접수</dt>
										<dd><a href="javascript:tab_click('VD0210', this);">${form.summary10}</a></dd>
									</a>
								</dl>
								<dl id="VD0130">
									<a href="javascript:tab_click('VD0130', this);">
										<dt>사용자 추가 요청</dt>
										<dd><a href="javascript:tab_click('VD0130', this);">${form.summary11}</a></dd>
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
							<h2><img src="/images/samyangfoods/mypage-icon2.png"/>공지사항</h2>
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
							<h2><img src="/images/samyangfoods/mypage-icon3.png"/>입찰공고</h2>
							<ul>
								<li class="title"><span class="subject">제목</span><span class="date">날짜</span></li>
								<c:forEach items="${biddingListMain}" var="B">
									<li class="cont">
										<span class="subject"><a href="javascript:openPopup('${B.RFX_NUM}', '${B.RFX_CNT}', '${B.BUYER_CD}', 'bidding');">${B.SUBJECT}</a></span><span class="date">${B.REG_DATE}</span>
									</li>
								</c:forEach>
							</ul>
						</td>
					</tr>
				</table>
			</section>
		</div>
	</e:window>
</e:ui>