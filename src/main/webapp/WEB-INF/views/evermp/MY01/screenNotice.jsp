<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<link rel="stylesheet" href="/css/index.css" type="text/css"/>
<style>
    html {
        padding: 5px;
    }
    #file_container .file_name:hover {
        color: #dc2c34 !important;
    }
</style>
<script type="text/javascript">
<!--
	$(window).ready(function () {
	 	$(window).on('beforeunload', function() {
	    	<c:if test="${param.loginPopupNotice == 'loginPopupNotice' }">
				var cookieChk = EVF.C('cookieChk').getValue();
				if(cookieChk == 'on') {
					opener.closeWinAt00('div_laypopup' + '${param.NOTICE_NUM}', 1); // div_laypopup : 공지사항 레이어 팝업
				}
			</c:if>
	    });
	});

    function downloadFile(uuid, uuidSq) {
        if(!top['hidden_workspace']) {
            var $iframe = $("<iframe id=\"hidden_workspace\" style=\"position: absolute; width: 0; height: 0; display: none;\"></iframe>");
            $iframe.appendTo(top.document.body);
        }
        top.$("#hidden_workspace").attr("src", "/common/file/fileAttach/download.so?EVER_REQUEST_DATA_TYPE=FILE_DOWNLOAD&UUID=" + uuid + "&UUID_SQ=" + uuidSq);
    }
// -->
</script>

    <e:window id="commonRichTextContents" onReady="init" initData="${initData}" title="">
        <div>
            <div style="display: inline-block; width: 4px; height: 14px; background-color: #dc2c34;"></div>
            <span style="font-family: 'Noto Sans Korean'; font-weight: 500; font-size: 18px; color: #111; line-height: 40px;">${formData.SUBJECT}</span>
        </div>

		<e:richTextEditor id="TEXT_CONTENTS" name="TEXT_CONTENTS" value="${formData.NOTICE_CONTENTS }" height="380" width="99%" disabled="false" required="false" readOnly="${param.detailView}" />
		
		<e:text><div style="display: inline-block; width: 4px; height: 13px; background-color: #dc2c34;"></div><span style="font-family: 'Noto Sans Korean'; font-weight: 300; font-size: 13px; color: #111; line-height: 40px;">&nbsp;첨부파일</span></e:text>
        <div id="file_container" style="height: 90px; overflow-y: auto; overflow-x: hidden; width: 99%; border: 1px solid #c5c8ca; margin-top: 3px; padding: 4px;">
            <c:forEach items="${attachedFiles}" var="file">
                <p style="font-size: 13px;" onclick="downloadFile('${file.UUID}', '${file.UUID_SQ}');"><span class="file_name" style="color: #000; cursor: pointer; font-weight: normal; font-family: 'Noto Sans Korean'" title="${file.REAL_FILE_NM}">${file.REAL_FILE_NM}</span></p>
            </c:forEach>
        </div>
        
        <br>
        <c:if test="${param.mainYn == 'Y'}">
        <p style="font-weight: normal; color: #111; line-height: 22px; font-size: 10px; user-select: none; font-size: 11px;">
            <e:check id="cookieChk" name="cookieChk" style="width: 15px; margin:-5px 0 0 0;"/>&nbsp;하루동안 열지않기
        </p>
        </c:if>
    </e:window>
</e:ui>

