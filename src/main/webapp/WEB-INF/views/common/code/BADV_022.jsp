<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0">
<link rel="stylesheet" type="text/css" href="/css/juso/mobilePopup.css?dt=20200805"/>
<script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
<script type="text/javascript">

    function makeList(xmlStr){

        var htmlStr = "";

        if( $(xmlStr).find("totalCount").text() == "0" ){

            htmlStr +=' ';
            htmlStr += '<div class="result_search">';
            htmlStr += '	검색된 내용이 없습니다.';
            htmlStr += '</div>';
            htmlStr +='';

        }else{

            var currentPage = parseInt($(xmlStr).find("currentPage").text());
            var countPerPage = parseInt($(xmlStr).find("countPerPage").text());
            var num = 0;

            htmlStr += '<div class="result_search">도로명주소 검색 결과 <p>('+ $(xmlStr).find("totalCount").text()+'건)</p></div>';

            $(xmlStr).find("juso").each(function() {
                num++;
                htmlStr += '<div id="result_table">';
                htmlStr += '	<div class="row">';
                htmlStr += '	    <div class="cell1" tabindex="6">';
                htmlStr += '	        <div class="road_name">';
                htmlStr += '	            <p class="icon_road"><span>도로명</span></p>';
                htmlStr += '	            <p class="address" id="roadAddrDiv'+num+'"><a href="javascript:setMaping(\''+num+'\')"><span>'+$(this).find('roadAddr').text()+'</span></p>';
                htmlStr += '	        </div>';
                htmlStr += '	        <div class="juso_name">';
                htmlStr += '	            <p class="icon_juso"><span>지번</span></p>';
                htmlStr += '	            <p class="address" id="jibunAddrDiv'+num+'"><a href="javascript:setMaping(\''+num+'\')"><span>'+$(this).find('jibunAddr').text()+'</span></p>';
                htmlStr += '	        </div>';
                htmlStr += '            <div class="view_address">';
                htmlStr += '                <p class="title_place"><a href="javascript:addrJuminRenew('+num+');" class="detail_view" id="detDiv'+num+'">상세건물보기</a></p>';
                htmlStr += '                <p class="title_place"><a href="javascript:addrJuminRenewX('+num+');" class="detail_close" id="detDivX'+num+'" style="display:none;" "="">상세건물닫기</a></p>';
                htmlStr += '                <p class="detail_address" id="detListDivX'+num+'" style="display:none;">'+$(this).find('detBdNmList').text()+'</p>';
                htmlStr += '            </div>';
                htmlStr += '	    </div>';

                htmlStr += '        <div class="cell2">';
                htmlStr += '            <div class="zip_code" id="zipNoDiv'+num+'">'+$(this).find('zipNo').text()+'</div>';
                htmlStr += '        </div>';
                htmlStr += '        <div id="roadAddrPart1Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart1').text()+'</div>';
                htmlStr += '        <div id="roadAddrPart2Div'+num+'" style="display:none;">'+$(this).find('roadAddrPart2').text()+'</div>';
                htmlStr += '        <div id="engAddrDiv'+num+'" style="display:none;">'+$(this).find('engAddr').text()+'</div>';
                htmlStr += '        <input type="hidden" id="admCdHid'+num+'" value="'+$(this).find('admCd').text()+'">';
                htmlStr += '        <input type="hidden" id="rnMgtSnHid'+num+'" value="'+$(this).find('rnMgtSn').text()+'">';
                htmlStr += '        <input type="hidden" id="bdMgtSnHid'+num+'" value="'+$(this).find('bdMgtSn').text()+'">';
                htmlStr += '        <input type="hidden" id="detBdNmListHid'+num+'" value="'+$(this).find('detBdNmList').text()+'">';
                htmlStr += '        <input type="hidden" id="bdNmHid'+num+'" value="'+$(this).find('bdNm').text()+'">';
                htmlStr += '        <input type="hidden" id="bdKdcdHid'+num+'" value="'+$(this).find('bdKdcd').text()+'">';
                htmlStr += '        <input type="hidden" id="siNmHid'+num+'" value="'+$(this).find('siNm').text()+'">';
                htmlStr += '        <input type="hidden" id="sggNmHid'+num+'" value="'+$(this).find('sggNm').text()+'">';
                htmlStr += '        <input type="hidden" id="emdNmHid'+num+'" value="'+$(this).find('emdNm').text()+'">';
                htmlStr += '        <input type="hidden" id="liNmHid'+num+'" value="'+$(this).find('liNm').text()+'">';
                htmlStr += '        <input type="hidden" id="rnHid'+num+'" value="'+$(this).find('rn').text()+'">';
                htmlStr += '        <input type="hidden" id="udrtYnHid'+num+'" value="'+$(this).find('udrtYn').text()+'">';
                htmlStr += '        <input type="hidden" id="buldMnnmHid'+num+'" value="'+$(this).find('buldMnnm').text()+'">';
                htmlStr += '        <input type="hidden" id="buldSlnoHid'+num+'" value="'+$(this).find('buldSlno').text()+'">';
                htmlStr += '        <input type="hidden" id="mtYnHid'+num+'" value="'+$(this).find('mtYn').text()+'">';
                htmlStr += '        <input type="hidden" id="lnbrMnnmHid'+num+'" value="'+$(this).find('lnbrMnnm').text()+'">';
                htmlStr += '        <input type="hidden" id="lnbrSlnoHid'+num+'" value="'+$(this).find('lnbrSlno').text()+'">';
                htmlStr += '        <input type="hidden" id="emdNoHid'+num+'" value="'+$(this).find('emdNo').text()+'">';
                htmlStr += '	</div>';
                htmlStr += '</div>';
            });
            htmlStr += '<div class="page_num" id="pageApi"></div>';
        }
        $(".result_list").html(htmlStr);
        $(".result").show();
        $(".guide_search").hide();
        $("#address_detail").hide();
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
    }

    function addrJuminRenewX(idx){
        $("#detDivX"+idx).hide();
        $("#detListDivX"+idx).hide();
        $("#detDiv"+idx).show();
    }

    function setMaping(idx){

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
        $("#address_detail").show();

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
    <div id="wrap">
        <!-- header -->
        <section id="header">
            <h1 class="hiddenArea">도로명 주소</h1>
            <!-- 검색 -->
            <div id="search">
                <fieldset class="search_set">
                    <legend>검색</legend>
                    <label class="hiddenArea">검색</label>
                    <input type="text" title="검색어를 입력하세요" id="keyword" style="ime-mode:active;" placeholder="도로명주소, 건물명 또는 지번입력" value="" />
                    <input type="button" value="검색" onclick="searchUrlJuso();" style="cursor: pointer;" />
                </fieldset>
                <p class="search_keyword">검색어 예 : 도로명(반포대로 58), 건물명(독립기념관), 지번(삼성동 25)</p>
            </div>
        </section>

        <!-- container -->
        <section id="container">

            <div class="guide_search">
                <h2 class="hiddenArea">도로명주소 검색</h2>
                <p>보다 정확한 검색을 위하여 다음 권장사항을 확인하여 주시기 바랍니다. </p>
                <ul>
                    <li>시·도/시·군·구 + 도로명주소 <span>예) 종로구 사직로 161</span></li>
                    <li>시·도/시·군·구/읍·면·동 + 지번 <span>예) 종로구 관훈동 198-1</span></li>
                    <li>시·도/시·군·구 + 건물명 <span>예) 역삼동 737</span></li>
                </ul>
            </div>

            <div class="result_list" id="resultList"></div>

            <!-- 주소상세검색 입력 -->
            <div id="address_detail" style="display:none;">
                <h2>상세주소 입력</h2>
                <legend class="hiddenArea">상세주소 입력</legend>
                <span class="address_title">도로명주소</span>
                <div class="address_road" id="addrPart1"></div>
                <label class="address_title">상세주소입력</label>
                <div class="address_form">
                    <div class="row">
                        <div class="cell1">
                            <input type="text" name="rtAddrDetail" id="rtAddrDetail" onkeypress="addrDetailChk();" onkeyup="addrDetailChk1(this);" title="상세주소"/>
                        </div>
                        <div class="cell2">
                            <p class="address_text" id="addrPart2"></p>
                        </div>
                    </div>
                </div>
                <div class="btn_address">
                    <input type="button" value="주소 입력" onclick="setParent();" style="cursor: pointer;">
                </div>
            </div>
        </section>

        <section id="footer">
            <p id="logo"><span>도로명주소</span></p>
            <div id="return"><a href="javascript:popClose();" title="창닫기">돌아가기</a></div>
        </section>
    </div>
</form>
</body>
</html>