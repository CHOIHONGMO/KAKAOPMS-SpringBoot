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
	}
</style>
<script>
	function init() {
		$('.dl2').each(function(){
			if($(this).find('dt').length === 0){
				$(this).css('display','none');
			}
		});
	}

	function tab_click(screenId, e) {
		var param = {
			dashBoardFlag: 'Y',
			detailView: false
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
				everPopup.openPopupByScreenId('BQ0310P01', 1600, 1000, param);

				break;
		}
	}

</script>
</head>

<e:window id="SMY01_010" onReady="init" initData="${initData}" title="">
	<div class="mypage-wrapper clearfix" style="background:white">
		<section>
			<dl class="worklist-wrap ">
				<h2><img src="/images/kakao/mypage-icon1.png"/>WORK LIST</h2>
				<table>
					<tr>
						<td style="width:24%">
							<h3>견적/입찰관리<br/><span>quotation<br/>management</span></h3>
							<a href="javascript:tab_click('SSO1_010', this);">
								<dl>
									<dt>코드상품 견적대기</dt>
									<dd><a href="javascript:tab_click('SSO1_010', this);">${form.SUMMARY1}</a></dd>
								</dl>
							</a>
							<a href="javascript:tab_click('QT0310', this);">
								<dl>
									<dt>일반 견적대기</dt>
									<dd><a href="javascript:tab_click('QT0310', this);">${form.SUMMARY2}</a></dd>
								</dl>
							</a>
							<a href="javascript:tab_click('BQ0310', this);">
								<dl>
									<dt>입찰대기</dt>
									<dd><a href="javascript:tab_click('BQ0310', this);">${form.SUMMARY3}</a></dd>
								</dl>
							</a>
							<BR/>
							<BR/>
						</td>
						<td style="width:24%">
							<h3>납품관리<br/><span>contract and<br/>purchase order</span></h3>
							<a href="javascript:tab_click('SIV1_020', this);">
								<dl>
									<dt>납품대기</dt>
									<dd><a href="javascript:tab_click('SIV1_020', this);">${form.SUMMARY4}</a></dd>
								</dl>
							</a>
							<a href="javascript:tab_click('SIV1_050', this);">
								<dl>
									<dt>납품완료처리대기</dt>
									<dd><a href="javascript:tab_click('SIV1_050', this);">${form.SUMMARY5}</a></dd>
								</dl>
							</a>
						</td>
						<td style="width:24%">
							<h3>계약관리<br/><span>inspection<br/>management</span></h3>
							<a href="javascript:tab_click('CT0610', this);">
								<dl>
									<dt>계약서명대기</dt>
									<dd><a href="javascript:tab_click('CT0610', this);">${form.SUMMARY6}</a></dd>
								</dl>
							</a>
						</td>
					</tr>
				</table>
			</dl>
		</section>
		<section class="clearfix">
			<table class="list-wrap">
				<tr>
					<td>
						<h2><img src="/images/kakao/mypage-icon2.png"/>${ses.langCd eq "KO" ? "공지사항" : "Notice"}</h2>
						<ul>
							<li class="title"><span class="subject">${ses.langCd eq "KO" ? "제목" : "Subject"}</span><span class="date">${ses.langCd eq "KO" ? "날짜" : "Date"}</span></li>
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