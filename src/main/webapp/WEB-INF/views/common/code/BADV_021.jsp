<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<link rel="stylesheet" type="text/css" href="/css/juso/common.css?dt=20200805"/>
<link rel="stylesheet" type="text/css" href="/css/juso/addrlink.css?dt=20200805"/>
<script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
<script type="text/javascript">

    $(document).ready(function() {
        self.resizeTo(570, 520);

        var docHeight = $("#resultList").height(); // 결과 DIV 높이 가져옴

        if(docHeight > 300){ // 높이가 310인 경우 로고 위치 조정
            docHeight += 60;
            $("#searchContentBox").css("height",docHeight+"px");// 로고 위치 지정
        }else{
            $("#searchContentBox").css("360px");// 로고 위치 지정
        }

        $("#keyword").focus();

        $("#keyword").on("keydown", function(event){
            if (event.which == 13) {
                event.keyCode = 0;
                searchUrlJuso();
            }
        });
    });

    function makeList(xmlStr){


        var htmlStr = "";

        if( $(xmlStr).find("totalCount").text() == "0" ){

            htmlStr +=' ';
            htmlStr += '<div class="popSearchNoResult" style="margin-top:10px; margin-bottom:5px;">';
            htmlStr += '	검색된 내용이 없습니다.';
            htmlStr += '</div>';
            htmlStr +='';

        }else{

            htmlStr += '<p class="text-guide">도로명주소 검색 결과 <strong>('+ $(xmlStr).find("totalCount").text()+'건)</strong></p>';
            htmlStr += '<table class="data-col" style="margin-top:3px;">';
            htmlStr += '	<caption>검색 결과</caption>';
            htmlStr += '	<colgroup>';
            htmlStr += '		<col style="width:8%">';
            htmlStr += '		<col>';
            htmlStr += '		<col style="width:11%">';
            htmlStr += '		<col style="width:14%">';
            htmlStr += '	</colgroup>';
            htmlStr += '	<thead>';
            htmlStr += '		<tr>';
            htmlStr += '			<th scope="col">No</th>';
            htmlStr += '			<th scope="col">도로명주소</th>';
            htmlStr += '			<th scope="col">&nbsp;</th>';
            htmlStr += '			<th scope="col">우편번호</th>';
            htmlStr += '		</tr>';
            htmlStr += '	</thead>';
            htmlStr += '	<tbody>';

            var currentPage = parseInt($(xmlStr).find("currentPage").text());
            var countPerPage = parseInt($(xmlStr).find("countPerPage").text());
            var listNum = (currentPage*countPerPage)-(--countPerPage);
            var num = 0;
            $(xmlStr).find("juso").each(function(){
                num++;

                var resultType = "4";

                htmlStr += '<tr>';
                htmlStr +='	<td class="subj" style="text-align:center;">'+(listNum++)+'</td>';

                if( resultType == "1" ){

                    htmlStr += '	<td class="subj" colspan="2" id="roadAddrTd'+num+' style="text-align:left; padding-left: 5px; line-height: 0.5em;">';
                    htmlStr += '		<a href="javascript:setMaping(\''+num+'\')">';
                    htmlStr += '			<div tabindex="6">';
                    htmlStr += '				<div id="roadAddrDiv'+num+'"><b>'+$(this).find('roadAddr').text()+'</b></div>';
                    htmlStr += '			</div>';
                    htmlStr += '		</a>';
                    htmlStr += '		<span id="jibunAddrDiv'+num+'" style="display:none;">'+$(this).find('jibunAddr').text()+'</span>';
                    htmlStr +='		<div id="roadAddrPart1Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart1').text()+'</div>';
                    htmlStr +='		<div id="roadAddrPart2Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart2').text()+'</div>';
                    htmlStr +='		<div id="engAddrDiv'+num+'" style="display:none;">'+$(this).find('engAddr').text()+'</div>';
                    htmlStr += '	</td>';

                }else if( resultType == "2" ){

                    htmlStr += '	<td class="subj" colspan="2" id="roadAddrTd'+num+' style="text-align:left; padding-left: 5px; line-height: 0.5em;">';
                    htmlStr += '		<a href="javascript:setMaping(\''+num+'\')">';
                    htmlStr += '			<div tabindex="6">';
                    htmlStr += '				<div id="roadAddrDiv'+num+'"><b>'+$(this).find('roadAddr').text()+'</b></div>';
                    htmlStr +='				<span style="font-size:11px;">[지번] <span id="jibunAddrDiv'+num+'">'+$(this).find('jibunAddr').text()+'</span></span>';
                    htmlStr += '			</div>';
                    htmlStr += '		</a>';
                    htmlStr +='		<div id="roadAddrPart1Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart1').text()+'</div>';
                    htmlStr +='		<div id="roadAddrPart2Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart2').text()+'</div>';
                    htmlStr +='		<div id="engAddrDiv'+num+'" style="display:none;">'+$(this).find('engAddr').text()+'</div>';
                    htmlStr += '	</td>';

                }else if( resultType == "3" ){

                    htmlStr +='	<td class="subj" id="roadAddrTd'+num+' style="text-align:left; padding-left: 5px; line-height: 0.5em;">';
                    htmlStr +='		<a href="javascript:setMaping(\''+num+'\')">';
                    htmlStr +='			<div tabindex="6">';
                    htmlStr +='				<div id="roadAddrDiv'+num+'"><b>'+$(this).find('roadAddr').text()+'</b></div>';
                    htmlStr +='			</div>';
                    htmlStr +='		</a>';
                    htmlStr +='		<div id="detListDivX'+num+'" style="display:none;"><span style="font-size:11px;"> [상세건물명]'+$(this).find('detBdNmList').text()+' </span></div>';
                    htmlStr += '		<span id="jibunAddrDiv'+num+'" style="display:none;">'+$(this).find('jibunAddr').text()+'</span>';
                    htmlStr +='		<div id="roadAddrPart1Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart1').text()+'</div>';
                    htmlStr +='		<div id="roadAddrPart2Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart2').text()+'</div>';
                    htmlStr +='		<div id="engAddrDiv'+num+'" style="display:none;">'+$(this).find('engAddr').text()+'</div>';
                    htmlStr +='	</td>';
                    htmlStr +='	<td class="subj" style="text-align:center;">';
                    htmlStr +='		<div id="detDiv'+num+'" style="font-size:12px;">';
                    if($(this).find('detBdNmList').text() != ""){
                        htmlStr +='<a href="javascript:addrJuminRenew('+num+');">상세건물</br>보기</a>';
                    }
                    htmlStr +='		</div>';
                    htmlStr +='		<div id="detDivX'+num+'" style="display:none;"><a href="javascript:addrJuminRenewX('+num+');">닫기</a></div>';
                    htmlStr +='	</td>';

                }else{

                    htmlStr +='	<td class="subj" id="roadAddrTd'+num+' style="text-align:left; padding-left: 5px; line-height: 0.5em;">';
                    htmlStr +='		<a href="javascript:setMaping(\''+num+'\')">';
                    htmlStr +='			<div tabindex="6">';
                    htmlStr +='				<div id="roadAddrDiv'+num+'"><b>'+$(this).find('roadAddr').text()+'</b></div>';
                    htmlStr +='				<span style="font-size:11px;">[지번] <span id="jibunAddrDiv'+num+'">'+$(this).find('jibunAddr').text()+'</span></span>';
                    htmlStr +='			</div>';
                    htmlStr +='		</a>';
                    htmlStr +='		<div id="detListDivX'+num+'" style="display:none;"><span style="font-size:11px;"> [상세건물명]'+$(this).find('detBdNmList').text()+' </span></div>';
                    htmlStr +='		<div id="roadAddrPart1Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart1').text()+'</div>';
                    htmlStr +='		<div id="roadAddrPart2Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart2').text()+'</div>';
                    htmlStr +='		<div id="engAddrDiv'+num+'" style="display:none;">'+$(this).find('engAddr').text()+'</div>';
                    htmlStr +='	</td>';
                    htmlStr +='	<td class="subj" style="text-align:center;">';
                    htmlStr +='		<div id="detDiv'+num+'" style="font-size:12px;">';
                    if($(this).find('detBdNmList').text() != ""){
                        htmlStr +='<a href="javascript:addrJuminRenew('+num+');">상세건물</br>보기</a>';
                    }
                    htmlStr +='		</div>';
                    htmlStr +='		<div id="detDivX'+num+'" style="display:none;"><a href="javascript:addrJuminRenewX('+num+');">닫기</a></div>';
                    htmlStr +='	</td>';

                }

                htmlStr +='	<td class="subj" style="text-align:center" id="zipNoTd'+num+'"> ';
                htmlStr +='		<div id="zipNoDiv'+num+'">'+$(this).find('zipNo').text()+'</div>';
                htmlStr +='	</td>';
                htmlStr +='	<input type="hidden" id="admCdHid'+num+'" value="'+$(this).find('admCd').text()+'">';
                htmlStr +='	<input type="hidden" id="rnMgtSnHid'+num+'" value="'+$(this).find('rnMgtSn').text()+'">';
                htmlStr +='	<input type="hidden" id="bdMgtSnHid'+num+'" value="'+$(this).find('bdMgtSn').text()+'">';
                htmlStr +='	<input type="hidden" id="detBdNmListHid'+num+'" value="'+$(this).find('detBdNmList').text()+'"> ';
                htmlStr +='	<input type="hidden" id="bdNmHid'+num+'" value="'+$(this).find('bdNm').text()+'"> ';
                htmlStr +='	<input type="hidden" id="bdKdcdHid'+num+'" value="'+$(this).find('bdKdcd').text()+'"> ';
                htmlStr +='	<input type="hidden" id="siNmHid'+num+'" value="'+$(this).find('siNm').text()+'">';
                htmlStr +='	<input type="hidden" id="sggNmHid'+num+'" value="'+$(this).find('sggNm').text()+'"> ';
                htmlStr +='	<input type="hidden" id="emdNmHid'+num+'" value="'+$(this).find('emdNm').text()+'"> ';
                htmlStr +='	<input type="hidden" id="liNmHid'+num+'" value="'+$(this).find('liNm').text()+'"> ';
                htmlStr +='	<input type="hidden" id="rnHid'+num+'" value="'+$(this).find('rn').text()+'"> ';
                htmlStr +='	<input type="hidden" id="udrtYnHid'+num+'" value="'+$(this).find('udrtYn').text()+'">  ';
                htmlStr +='	<input type="hidden" id="buldMnnmHid'+num+'" value="'+$(this).find('buldMnnm').text()+'">  ';
                htmlStr +='	<input type="hidden" id="buldSlnoHid'+num+'" value="'+$(this).find('buldSlno').text()+'">  ';
                htmlStr +='	<input type="hidden" id="mtYnHid'+num+'" value="'+$(this).find('mtYn').text()+'">  ';
                htmlStr +='	<input type="hidden" id="lnbrMnnmHid'+num+'" value="'+$(this).find('lnbrMnnm').text()+'">   ';
                htmlStr +='	<input type="hidden" id="lnbrSlnoHid'+num+'" value="'+$(this).find('lnbrSlno').text()+'">  ';
                htmlStr +='	<input type="hidden" id="emdNoHid'+num+'" value="'+$(this).find('emdNo').text()+'">  ';
                htmlStr +='</tr> ';
            });

            htmlStr += '	</tbody>';
            htmlStr += "</table>";
            htmlStr += '<div class="paginate" id="pageApi"></div>';
        }
        $(".popSearchNoResult").addClass("result");
        $(".popSearchNoResult").html(htmlStr);
        $(".result").show();
        $("#resultData").hide();
        $("#searchContentBox").css("height","");
        $("#searchContentBox").css("min-height","360px");
        pageMake(xmlStr);

    }

    // xml타입 페이지 처리 (주소정보 리스트 makeList(xmlData); 다음에서 호출)
    function pageMake(xmlStr){
        var total = $(xmlStr).find("totalCount").text(); // 총건수
        var pageNum =  $(xmlStr).find("currentPage").text();// 현재페이지
        var paggingStr = "";
        if(total < 1){
        }else{
            var PAGEBLOCK= parseInt( $(xmlStr).find("countPerPage").text() );
            var pageSize= parseInt( $(xmlStr).find("countPerPage").text() );
            var totalPages = Math.floor((total-1)/pageSize) + 1;
            var firstPage = Math.floor((pageNum-1)/PAGEBLOCK) * PAGEBLOCK + 1;
            if( firstPage <= 0 ) firstPage = 1;
            var lastPage = firstPage-1 + PAGEBLOCK;
            if( lastPage > totalPages ) lastPage = totalPages;
            var nextPage = lastPage+1 ;
            var prePage = firstPage-5 ;
            if( firstPage > PAGEBLOCK ){
                paggingStr +=  "<a href='javascript: $(\"#currentPage\").val("+prePage+");  searchUrlJuso();'>◁</a>  " ;
            }
            for( i=firstPage; i<=lastPage; i++ ){
                if( pageNum == i )
                    paggingStr += "<a style='font-weight:bold;color:blue;font-size:15px;' href='javascript:$(\"#currentPage\").val("+i+");  searchUrlJuso();'>" + i + "</a>  ";
                else
                    paggingStr += "<a href='javascript:$(\"#currentPage\").val("+i+");  searchUrlJuso();'>" + i + "</a>  ";
            }
            if( lastPage < totalPages ){
                paggingStr +=  "<a href='javascript: $(\"#currentPage\").val("+nextPage+");  searchUrlJuso();'>▷</a>";
            }

            $("#pageApi").html(paggingStr);
        }
    }

    // 주소 검색
    function searchUrlJuso() {

        // 검색API URL은 프로토콜(http/https) 맞춰서 설정한다.
        var strUrl = window.location.protocol + "//www.juso.go.kr/addrlink/addrLinkApiJsonp.do";

        if (!searchJuso()) {
            try {
                $.ajax({
                    url : strUrl  //인터넷망
                    ,type:"post"
                    ,data: ({ currentPage: $("#currentPage").val(), countPerPage: $("#countPerPage").val(), keyword: $("#keyword").val(), confmKey: $("#confmKey").val() })
                    ,dataType:"jsonp"
                    ,crossDomain:true
                    ,success:function(xmlStr){
                        if(navigator.appName.indexOf("Microsoft") > -1){
                            var xmlData = new ActiveXObject("Microsoft.XMLDOM");
                            xmlData.loadXML(xmlStr.returnXml)
                        }else{
                            var xmlData = xmlStr.returnXml;
                        }
                        // $(".popSearchNoResult").html("");
                        var errCode = $(xmlData).find("errorCode").text();
                        var errDesc = $(xmlData).find("errorMessage").text();

                        var totalCount = $(xmlData).find("totalCount").text();
                        var currentPage = $(xmlData).find("currentPage").text();

                        if( parseInt(totalCount) > 1000 && currentPage == "1" )
                            alert("검색 결과가 너무 많습니다(1,000건 이상)\n검색어 예를 참조하여 검색하시기 바랍니다.");

                        if(errCode != "0"){
                            alert(errDesc);
                        }else{
                            if(xmlStr != null){
                                makeList(xmlData);
                            }
                        }
                    }
                    ,error: function(xhr,status, error){
                        //alert("에러발생");
                        alert("검색에 실패하였습니다 \n 다시 검색하시기 바랍니다.");
                    }
                });
            } catch (e) {
                ErrorJuso();
            }
        }
        return;
    }

    // 검색 API 서비스 오류
    function ErrorJuso() {
        alert("에러발생 시 코드 작성");
    }

    // 검색 API 호출 전 검색어 체크
    function searchJuso() {
        if (!checkSearchedWord($("#keyword").val().toUpperCase())) {
            return true;
        } else {
            return false;
        }
    }

    // 특수문자, 특정문자열(sql예약어의 앞뒤공백포함) 제거
    function checkSearchedWord(obj) {

        if (obj != null && obj != "") {

            //특수문자 제거
            var expText = /[%=><+!^*]/;
            if (expText.test(obj) == true) {
                alert("특수문자를 입력 할수 없습니다.");
                $("#keyword").val(obj.replace(expText, ""));
                return false;
            }

            //특정문자열(sql예약어의 앞뒤공백포함) 제거
            var sqlArray = new Array("AND", "OR", "SELECT", "INSERT", "DELETE", "UPDATE", "CREATE", "ALTER", "DROP", "EXEC", "UNION", "FETCH", "DECLARE", "TRUNCATE", "SHUTDOWN");

            for (var i = 0; i < sqlArray.length; i++) {
                if (obj.match(sqlArray[i])) {
                    alert(sqlArray[i] + "와(과) 같은 특정문자로 검색할 수 없습니다.");
                    $("#keyword").val(obj.replace(sqlArray[i], ""));
                    return false;
                }
            }
        }
        return true;
    }

    // 임시 페이징
    function PageLink(curPage, totalPages, funName) {

        pageUrl = "";

        var pageLimit = 5;
        var startPage = parseInt((curPage - 1) / pageLimit) * pageLimit + 1;
        var endPage = startPage + pageLimit - 1;

        if (totalPages < endPage) {
            endPage = totalPages;
        }

        var nextPage = endPage + 1;

        if (curPage > 1 && pageLimit < curPage) {
            pageUrl += "<a class='first' href='javascript:" + funName + "(1);'><img src='/images_new/common/2016/btn_paging_first.gif' alt='처음' /></a>";
        }
        if (curPage > pageLimit) {
            pageUrl += " <a class='prev' href='javascript:" + funName + "(" + (startPage == 1 ? 1 : startPage - 1) + ");'><img src='/images_new/common/2016/btn_paging_prev.gif' alt='이전' /></a>";
        }

        for (var i = startPage; i <= endPage; i++) {
            if (i == curPage) {
                pageUrl += " <a href='#'><strong>" + i + "</strong></a>"
            } else {
                pageUrl += " <a href='javascript:" + funName + "(" + i + ");'> " + i + " </a>";
            }
        }

        if (nextPage <= totalPages) {
            pageUrl += "<a class='next' href='javascript:" + funName + "(" + (nextPage < totalPages ? nextPage : totalPages) + ");'><img src='/images_new/common/2016/btn_paging_next.gif' alt='다음' /></a>";
        }
        if (curPage < totalPages && nextPage < totalPages) {
            pageUrl += "<a class='last' href='javascript:" + funName + "(" + totalPages + ");'><img src='/images_new/common/2016/btn_paging_last.gif' alt='끝' /></a>";
        }

        return pageUrl;
    }

    /* 주소 API 적용 끝 */

    function popClose(){
        window.close();
    }

    function addrJuminRenew(idx){
        $("#detDivX"+idx).show();
        $("#detListDivX"+idx).show();
        $("#detDiv"+idx).hide();

        var docHeight = $("#resultList").height(); // 결과 DIV 높이 가져옴
        if(docHeight > 300){ // 높이가 310인 경우 로고 위치 조정
            docHeight += 60;
            $("#searchContentBox").css("height",docHeight+"px");// 로고 위치 지정
        }else{
            $("#searchContentBox").css("360px");// 로고 위치 지정
        }
    }
    function addrJuminRenewX(idx){
        $("#detDivX"+idx).hide();
        $("#detListDivX"+idx).hide();
        $("#detDiv"+idx).show();

        var docHeight = $("#resultList").height(); // 결과 DIV 높이 가져옴
        if(docHeight > 300){ // 높이가 310인 경우 로고 위치 조정
            docHeight += 60;
            $("#searchContentBox").css("height",docHeight+"px");// 로고 위치 지정
        }else{
            $("#searchContentBox").css("360px");// 로고 위치 지정
        }
    }

    function setMaping(idx){
        $("#searchContentBox").css("height","360px");  // 로고 위치 지정

        var roadAddr = $("#roadAddrDiv"+idx).text();
        var addrPart1 = $("#roadAddrPart1Div"+idx).text();
        var addrPart2 = $("#roadAddrPart2Div"+idx).text();
        var engAddr = $("#engAddrDiv"+idx).text();
        var jibunAddr = $("#jibunAddrDiv"+idx).text();
        var zipNo = $("#zipNoDiv"+idx).text();

        var admCd = $("#admCdHid"+idx).val();
        var rnMgtSn = $("#rnMgtSnHid"+idx).val();
        var bdMgtSn = $("#bdMgtSnHid"+idx).val();

        // 20170208 API 서비스 제공항목 확대
        var detBdNmList = $("#detBdNmListHid"+idx).val();
        var bdNm = $("#bdNmHid"+idx).val();
        var bdKdcd = $("#bdKdcdHid"+idx).val();
        var siNm = $("#siNmHid"+idx).val();
        var sggNm = $("#sggNmHid"+idx).val();
        var emdNm = $("#emdNmHid"+idx).val();
        var liNm = $("#liNmHid"+idx).val();
        var rn = $("#rnHid"+idx).val();
        var udrtYn = $("#udrtYnHid"+idx).val();
        var buldMnnm = $("#buldMnnmHid"+idx).val();
        var buldSlno = $("#buldSlnoHid"+idx).val();
        var mtYn = $("#mtYnHid"+idx).val();
        var lnbrMnnm = $("#lnbrMnnmHid"+idx).val();
        var lnbrSlno = $("#lnbrSlnoHid"+idx).val();
        var emdNo = $("#emdNoHid"+idx).val();

        $("#rtRoadAddr").val(roadAddr);
        $("#rtAddrPart1").val(addrPart1);
        $("#rtAddrPart2").val(addrPart2);
        $("#rtEngAddr").val(engAddr);
        $("#rtJibunAddr").val(jibunAddr);
        $("#rtZipNo").val(zipNo);
        $("#rtAdmCd").val(admCd);
        $("#rtRnMgtSn").val(rnMgtSn);
        $("#rtBdMgtSn").val(bdMgtSn);

        // 20170208 API 서비스 제공항목 확대
        $("#rtDetBdNmList").val(detBdNmList);
        $("#rtBdNm").val(bdNm);
        $("#rtBdKdcd").val(bdKdcd);
        $("#rtSiNm").val(siNm);
        $("#rtSggNm").val(sggNm);
        $("#rtEmdNm").val(emdNm);
        $("#rtLiNm").val(liNm);
        $("#rtRn").val(rn);
        $("#rtUdrtYn").val(udrtYn);
        $("#rtBuldMnnm").val(buldMnnm);
        $("#rtBuldSlno").val(buldSlno);
        $("#rtMtYn").val(mtYn);
        $("#rtLnbrMnnm").val(lnbrMnnm);
        $("#rtLnbrSlno").val(lnbrSlno);
        $("#rtEmdNo").val(emdNo);


        if( "Y" == "null" ){
            $(".result").hide();
        }else{
            $("#resultList").hide();
        }
        $("#resultData").show();

        $("#addrPart1").html(addrPart1);
        $("#addrPart2").html(addrPart2);
        $("#rtAddrDetail").focus();
    }

    function setParent(){
        /*var encodingType = "";
        if(encodingType=="EUC-KR"){
            document.charset ="EUC-KR";//파이어폭스에서 이것만쓰면 깨진다고함
            $("#rtForm").attr("accept-charset","EUC-KR");//이것만사용하면 ie에서 깨진다고함
        }*/
        var rtRoadAddr = $.trim($("#rtRoadAddr").val());
        var rtAddrPart1 = $.trim($("#rtAddrPart1").val());
        var rtAddrPart2 = $.trim($("#rtAddrPart2").val());
        var rtEngAddr = $.trim($("#rtEngAddr").val());
        var rtJibunAddr = $.trim($("#rtJibunAddr").val());
        var rtAddrDetail = $.trim($("#rtAddrDetail").val());
        var rtZipNo = $.trim($("#rtZipNo").val());
        var rtAdmCd = $.trim($("#rtAdmCd").val());
        var rtRnMgtSn = $.trim($("#rtRnMgtSn").val());
        var rtBdMgtSn = $.trim($("#rtBdMgtSn").val());

        // 20170208 API 서비스 제공항목 확대
        var rtDetBdNmList = $.trim($("#rtDetBdNmList").val());
        var rtBdNm = $.trim($("#rtBdNm").val());
        var rtBdKdcd = $.trim($("#rtBdKdcd").val());
        var rtSiNm = $.trim($("#rtSiNm").val());
        var rtSggNm = $.trim($("#rtSggNm").val());
        var rtEmdNm = $.trim($("#rtEmdNm").val());
        var rtLiNm = $.trim($("#rtLiNm").val());
        var rtRn = $.trim($("#rtRn").val());
        var rtUdrtYn = $.trim($("#rtUdrtYn").val());
        var rtBuldMnnm = $.trim($("#rtBuldMnnm").val());
        var rtBuldSlno = $.trim($("#rtBuldSlno").val());
        var rtMtYn = $.trim($("#rtMtYn").val());
        var rtLnbrMnnm = $.trim($("#rtLnbrMnnm").val());
        var rtLnbrSlno = $.trim($("#rtLnbrSlno").val());
        var rtEmdNo = $.trim($("#rtEmdNo").val());

        var rtRoadFullAddr = rtAddrPart1;
        if(rtAddrDetail != "" && rtAddrDetail != null){
            rtRoadFullAddr += ", " + rtAddrDetail;
        }
        if(rtAddrPart2 != "" && rtAddrPart2 != null){
            rtRoadFullAddr += " " + rtAddrPart2;
        }

        $("#roadFullAddr").val(rtRoadFullAddr);
        $("#roadAddrPart1").val(rtAddrPart1);
        $("#roadAddrPart2").val(rtAddrPart2);
        $("#engAddr").val(rtEngAddr);
        $("#jibunAddr").val(rtJibunAddr);
        $("#addrDetail").val(rtAddrDetail);
        $("#zipNo").val(rtZipNo);
        $("#admCd").val(rtAdmCd);
        $("#rnMgtSn").val(rtRnMgtSn);
        $("#bdMgtSn").val(rtBdMgtSn);

        // 20170208 API 서비스 제공항목 확대
        $("#detBdNmList").val(rtDetBdNmList);
        $("#bdNm").val(rtBdNm);
        $("#bdKdcd").val(rtBdKdcd);
        $("#siNm").val(rtSiNm);
        $("#sggNm").val(rtSggNm);
        $("#emdNm").val(rtEmdNm);
        $("#liNm").val(rtLiNm);
        $("#rn").val(rtRn);
        $("#udrtYn").val(rtUdrtYn);
        $("#buldMnnm").val(rtBuldMnnm);
        $("#buldSlno").val(rtBuldSlno);
        $("#mtYn").val(rtMtYn);
        $("#lnbrMnnm").val(rtLnbrMnnm);
        $("#lnbrSlno").val(rtLnbrSlno);
        $("#emdNo").val(rtEmdNo);

        var param = {
            "ZIP_CD": rtZipNo,
            "ADDR": rtRoadFullAddr,
            "ADDR1": rtAddrPart1,
            "ADDR2": rtAddrDetail + rtAddrPart2,
            "ZIP_CD_5": rtZipNo,
            "rowId": '${param.rowId}'
        };

        <%-- 다음API 사용 시 iframe을 사용하므로 parent는 항상 존재하기 때문에
             parent에 setZipCode 함수가 존재하는 지를 확인해야한다. --%>
        if (parent['${param.callBackFunction}']) {
            parent['${param.callBackFunction}'](param);
            //new EVF.ModalWindow().close(null);
            popClose();
        } else if(opener) {
            opener['${param.callBackFunction}'](param);
            popClose();
        }

        /*var iframeFlg = "null";
        if(iframeFlg == "Y"){

            var jusoJson = {
                "roadAddr": rtRoadFullAddr,
                "addrDetail":  rtAddrDetail,
                "roadAddrPart1": rtAddrPart1,
                "roadAddrPart2": rtAddrPart2,
                "jibunAddr": rtJibunAddr,
                "engAddr": rtEngAddr,
                "zipNo": rtZipNo,
                "admCd": rtAdmCd,
                "rnMgtSn": rtRnMgtSn,
                "bdMgtSn": rtBdMgtSn,
                "detBdNmList": rtDetBdNmList,
                "bdNm": rtBdNm,
                "bdKdcd": rtBdKdcd,
                "siNm": 	rtSiNm,
                "sggNm": rtSggNm,
                "emdNm": rtEmdNm,
                "liNm": rtLiNm,
                "rn": rtRn,
                "udrtYn": rtUdrtYn,
                "buldMnnm": rtBuldMnnm,
                "buldSlno": rtBuldSlno,
                "mtYn": rtMtYn,
                "lnbrMnnm": rtLnbrMnnm,
                "lnbrSlno": rtLnbrSlno,
                "emdNo": rtEmdNo
            };
        }*/
    }

    function addrDetailChk(){
        var evtCode = (window.netscape) ? ev.which : event.keyCode;
        if(evtCode == 63 || evtCode == 35 || evtCode == 38 || evtCode == 43 || evtCode == 92 || evtCode == 34){ // # & + \ " 문자제한
            alert('특수문자 ? # & + \\ " 를 입력 할 수 없습니다.');
            if(event.preventDefault){
                event.preventDefault();
            }else{
                event.returnValue=false;
            }
        }
    }

    function addrDetailChk1(obj){
        if(obj.value.length > 0){
            var expText = /^[^?#&+\"\\]+$/;
            if(expText.test(obj.value) != true){
                alert('특수문자 ? # & + \\ " 를 입력 할 수 없습니다.');
                obj.value="";
            }
        }
    }
</script>
<html>
<body>
<form id="AKCFrm" onsubmit="return false;" >
    <input type="hidden" id="confmKey" name="confmKey" value="U01TX0FVVEgyMDIwMDgwNjEwNTgzNjExMDAyOTM=" />
    <input type="hidden" id="resultType" name="resultType" value="4" />
    <input type="hidden" id="currentPage" name="currentPage" value="1" />
    <input type="hidden" id="countPerPage" name="countPerPage" value="10" />
    <!-- iframe 추가 E-->
    <input type="hidden" name="rtRoadAddr"  id="rtRoadAddr"  />
    <input type="hidden" name="rtAddrPart1" id="rtAddrPart1" />
    <input type="hidden" name="rtAddrPart2" id="rtAddrPart2" />
    <input type="hidden" name="rtEngAddr"   id="rtEngAddr"   />
    <input type="hidden" name="rtJibunAddr" id="rtJibunAddr" />
    <input type="hidden" name="rtZipNo" id="rtZipNo" />
    <input type="hidden" name="rtAdmCd" id="rtAdmCd" />
    <input type="hidden" name="rtRnMgtSn" id="rtRnMgtSn" />
    <input type="hidden" name="rtBdMgtSn" id="rtBdMgtSn" />

    <input type="hidden" name="rtDetBdNmList" id="rtDetBdNmList" />
    <input type="hidden" name="rtBdNm" id="rtBdNm" />
    <input type="hidden" name="rtBdKdcd" id="rtBdKdcd" />
    <input type="hidden" name="rtSiNm" id="rtSiNm" />
    <input type="hidden" name="rtSggNm" id="rtSggNm" />
    <input type="hidden" name="rtEmdNm" id="rtEmdNm" />
    <input type="hidden" name="rtLiNm" id="rtLiNm" />
    <input type="hidden" name="rtRn" id="rtRn" />
    <input type="hidden" name="rtUdrtYn" id="rtUdrtYn" />
    <input type="hidden" name="rtBuldMnnm" id="rtBuldMnnm" />
    <input type="hidden" name="rtBuldSlno" id="rtBuldSlno" />
    <input type="hidden" name="rtMtYn" id="rtMtYn" />
    <input type="hidden" name="rtLnbrMnnm" id="rtLnbrMnnm" />
    <input type="hidden" name="rtLnbrSlno" id="rtLnbrSlno" />
    <input type="hidden" name="rtEmdNo" id="rtEmdNo" />

    <input type="hidden" name ="searchType"    id="searchType" />
    <input type="hidden" name ="dsgubuntext"   id="dsgubuntext" />
    <input type="hidden" name ="dscity1text"   id="dscity1text" />
    <input type="hidden" name ="dscounty1text" id="dscounty1text" />
    <input type="hidden" name ="dsemd1text"    id="dsemd1text" />
    <input type="hidden" name ="dsri1text"     id="dsri1text" />
    <input type="hidden" name ="dsrd_nm1text"  id="dsrd_nm1text" />
    <input type="hidden" name ="dssan1text"    id="dssan1text" />
    <div class="pop-address-search" style="width: 100%;">
        <div class="pop-address-search-inner" style="border: 0px;">
            <div style="height: 363px;" id="searchContentBox">
                <fieldset>
                    <legend>도로명주소 검색</legend>
                    <span class="wrap">
						<input type="text" class="popSearchInput"
                               style="font-size: 13px; font-weight: bold; ime-mode:active;" title="검색어를 입력하세요"
                               name="keyword" id="keyword" placeholder="도로명주소, 건물명 또는 지번입력" value="" tabindex="1">
						<input type="button" title="검색" tabindex="2" onclick="searchUrlJuso();" style=" cursor: pointer;">
					</span>
                    <a class="close" href="javascript:popClose();" title="창닫기" tabindex="3">닫기</a>
                </fieldset>
                <p class="guide" style="margin-top:3px;">검색어 예 : 도로명(반포대로 58), 건물명(독립기념관), 지번(삼성동 25)</p>

                <div class="popSearchNoResult" id="resultList" style="margin-top:10px; margin-bottom:5px;"></div>
                <div class="detail"  style="display:none;" id="resultData">

                    <p><strong>상세주소 입력</strong></p>
                    <table class="data-row">
                        <caption>주소 입력</caption>
                        <colgroup>
                            <col style="width:20%"></col>
                            <col></col>
                        </colgroup>
                        <tbody>
                        <tr>
                            <th scope="row">도로명주소</th>
                            <td id="addrPart1" style="font-size:15px; height:20px; line-height:20px;"></td>
                        </tr>
                        <tr>
                            <th scope="row"><label>상세주소입력</label></th>
                            <td>
                                <input type="text" name="rtAddrDetail" id="rtAddrDetail" style="width: 100%; font-size: 13px;" onkeypress="addrDetailChk();" onkeyup="addrDetailChk1(this);" title="상세주소"/>
                                <div id="addrPart2" style="font-size: 13px; line-height: 2em;"></div>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                    <div class="btns-submit">
                        <a class="btn-bl" href="javascript:setParent();">주소입력</a>
                    </div>
                </div>
            </div>
            <div class="logo" style="display: block;" >&nbsp;</div>
        </div>
    </div>

</form>
</body>
</html>