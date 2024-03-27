/**
 * Description : common scripts for OZ.
 * Author : JYP
 * Remark : some functions, not used, will remove.
 **************************************************************************
 * DATE			: Author		: Desc.
 **************************************************************************
 * 2017.03.23	: JYP       	: for first edition.
  **************************************************************************
 */
var paging = new function() {};

paging.renderPaging = function(param) {

	var pre10Img = "/images/icon/paging_first.gif";
    var preImg = "/images/icon/paging_prev.gif";
    var next10Img = "/images/icon/paging_last.gif";
    var nextImg = "/images/icon/paging_next.gif";

    if (param.totalCount > 0) {
        //전체페이지
        var totalPage = parseInt((param.totalCount - 1) / param.listScale + 1);

        //이전10개, 다음10개
        //이전 마지막 페이지 0 이면 이전10개 없음
        var prev10 = parseInt(((param.pageNo - 1) / 10.0) * 10);
        //다음 첫페이지 totalPage 보다 크면 다음10개 없음
        var next10 = parseInt(prev10 + 11);

        var pagingHtml = '<a class="page-button-html" href="javascript:goPage('+ 1 +');" class="first"><img src="'+ pre10Img +'" alt="처음"></a>';

        if(prev10 > 0) {
            pagingHtml += '<a class="page-button-html" href="javascript:goPage('+ prev10 +')" class="prev"><img src="'+ preImg +'" alt="이전"></a>';
        } // end if 이전10개

        for (var i = 1 + prev10; i < next10 && i <= totalPage; i++) {
            pagingHtml += '<a class="page-button-html" href="javascript:goPage('+ i +')" class="prev">'+ i +'</a>';
        } // end for

        if(totalPage >= next10) {
            pagingHtml += '<a class="page-button-html" href="javascript:goPage('+ next10 +')" class="next"><img src="'+ nextImg +'" alt="다음"></a>';
        } // end if 다음10개

        pagingHtml += '<a class="page-button-html" href="javascript:goPage('+ totalPage +')" class="last"><img src="'+ next10Img +'" alt="마지막"></a>';

        $('.div-pagenav-html').html(pagingHtml)
    }
};