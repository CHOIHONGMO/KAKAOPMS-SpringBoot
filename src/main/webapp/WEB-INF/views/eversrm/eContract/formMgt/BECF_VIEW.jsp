<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<style>
		#view {
			width: 604px;
			height: 421px;
			overflow: auto;
			border: 2px solid #d7d7d7;
			word-wrap: break-word;
		}

		.indexList {
			width: 604px;
			height: 421px;
			overflow: auto;
			border: 2px solid #d7d7d7;
			word-wrap: break-word;
		}

		.a {
		}

	</style>
	<script src="/js/ever-util.js"></script>
	<script src="/js/jquery.wordexport.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/2014-11-29/FileSaver.min.js"></script>
	<script type="text/javascript">

        /*if (typeof jQuery !== "undefined" && typeof saveAs !== "undefined") {
            (function($) {
                $.fn.wordExport = function(fileName) {
                    fileName = typeof fileName !== 'undefined' ? fileName : "jQuery-Word-Export";
                    var static = {
                        mhtml: {
                            top: "Mime-Version: 1.0\nContent-Base: " + location.href + "\nContent-Type: Multipart/related; boundary=\"NEXT.ITEM-BOUNDARY\";type=\"text/html\"\n\n--NEXT.ITEM-BOUNDARY\nContent-Type: text/html; charset=\"utf-8\"\nContent-Location: " + location.href + "\n\n<!DOCTYPE html>\n<html>\n_html_</html>",
                            head: "<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n<style>\n_styles_\n</style>\n</head>\n",
                            body: "<body>_body_</body>"
                        }
                    };
                    var options = {
                        maxWidth: 624
                    };
                    // Clone selected element before manipulating it
                    var markup = $(this).clone();

                    // Remove hidden elements from the output
                    markup.each(function() {
                        var self = $(this);
                        if (self.is(':hidden'))
                            self.remove();
                    });

                    // Embed all images using Data URLs
                    var images = Array();
                    var img = markup.find('img');
                    for (var i = 0; i < img.length; i++) {
                        // Calculate dimensions of output image
                        var w = Math.min(img[i].width, options.maxWidth);
                        var h = img[i].height * (w / img[i].width);
                        // Create canvas for converting image to data URL
                        var canvas = document.createElement("CANVAS");
                        canvas.width = w;
                        canvas.height = h;
                        // Draw image to canvas
                        var context = canvas.getContext('2d');
                        context.drawImage(img[i], 0, 0, w, h);
                        // Get data URL encoding of image
                        var uri = canvas.toDataURL("image/png");
                        $(img[i]).attr("src", img[i].src);
                        img[i].width = w;
                        img[i].height = h;
                        // Save encoded image to array
                        images[i] = {
                            type: uri.substring(uri.indexOf(":") + 1, uri.indexOf(";")),
                            encoding: uri.substring(uri.indexOf(";") + 1, uri.indexOf(",")),
                            location: $(img[i]).attr("src"),
                            data: uri.substring(uri.indexOf(",") + 1)
                        };
                    }

                    // Prepare bottom of mhtml file with image data
                    var mhtmlBottom = "\n";
                    for (var i = 0; i < images.length; i++) {
                        mhtmlBottom += "--NEXT.ITEM-BOUNDARY\n";
                        mhtmlBottom += "Content-Location: " + images[i].location + "\n";
                        mhtmlBottom += "Content-Type: " + images[i].type + "\n";
                        mhtmlBottom += "Content-Transfer-Encoding: " + images[i].encoding + "\n\n";
                        mhtmlBottom += images[i].data + "\n\n";
                    }
                    mhtmlBottom += "--NEXT.ITEM-BOUNDARY--";

                    //TODO: load css from included stylesheet
                    var styles = "";

                    // Aggregate parts of the file together
                    var fileContent = static.mhtml.top.replace("_html_", static.mhtml.head.replace("_styles_", styles) + static.mhtml.body.replace("_body_", markup.html())) + mhtmlBottom;

                    // Create a Blob with the file contents
                    var blob = new Blob([fileContent], {
                        type: "application/msword;charset=utf-8"
                    });
                    saveAs(blob, fileName + ".doc");
                };
            })(jQuery);
        } else {
            if (typeof jQuery === "undefined") {
                console.error("jQuery Word Export: missing dependency (jQuery)");
            }
            if (typeof saveAs === "undefined") {
                console.error("jQuery Word Export: missing dependency (FileSaver.js)");
            }
        }*/

        function init() {
            $('div[style="page-break-after: always"]').attr({class: 'con cke_pagebreak', "aria-label": "패이지 나누기", contenteditable: false, "data-cke-display-name": "pagebreak", "data-cke-pagebreak": "1", title: "패이지 나누기"})
		}

		function doSave() {
		    /*
		     * jquery html() 을 가져 올 경우 화면상에 value 값이 존재해도 가져오지 못하는 현상이 있음
		     * for 문을 돌면서 input, textarea 값을 다시 설정해준다.
		    */
            $('#view').find('input').each(function(i, e){
                $(e).attr('value', e.value);
            });

            $('#view').find('textarea').each(function(i, e){
                $(e).text(e.value);
            });

            console.log($('.indexList').html());

            opener['${param.callBackFunction}']($('.indexList').html() + $('#view').html());
            //opener['${param.callBackFunction}']($('#view').html());
		}

		function doClose() {
		    window.close();
		}

		function doContents() {
            var strIndex = "";
            var number = 1;
            var indexCnt = 0;

            // 한번 출력 후 넘버 셋팅
            //var ul = $('<ul />').css({'list-style': 'none', 'padding-left': '5px'});
            //var li = "";
            $("div[class^=con]").each(function(indexNumber, obj){

				if(obj.style['break-after'] == 'page') {
                    number++;
				} else {
                    //strIndex += '<li><span>'+indexH2+'</span><span>..............................................................'+number+'</span></li>'; // strIndex에 순차적으로 li생성하여 넣기 = 링크값 + h2 텍스트값 속성 넣어서.
					var indexH2 = $("div[class^=con]").eq(indexNumber).text(); // 각 목차 인덱스 텍스트 값 가지고 오기

					//var li = $('<li / >').appendTo(ul);
					//$('<span />', {id: "idx_"+indexCnt}).css({'font-size': '16px'}).text(indexH2 + everUtil.pad(number, 2)).appendTo();

					var spanHd = $('<span id="'+ "idx_"+indexCnt +'" style="font-size: 16px;">'+ indexH2 + everUtil.pad(number, 2) +'</span><br>');
					spanHd.appendTo($(".indexList"));
					indexCnt++;
				}

                //$(".indexList").html(ul);
            });

            // 페이지 번호 셋팅
            $("span[id^=idx_]").each(function(number, obj){
                // 두번째 span width 값을 구한다.
                var idxWidth = 604 - $('#idx_'+number).width() - 166;
				// 위에서 파싱한 원문 문자열을 구해온다.
                var objText = $(obj).text();
				// 페이지 번호를 제외하고 원문만 구해온다.
                var subText = objText.substr(0, objText.length - 2);
                // 페이지 번호를 구해온다.
                var subNum = objText.substr(objText.length - 2, objText.length);
				// 원문 삽입
				$(obj).text(subText);

				console.log(getTextLength(subText));
				var dotted = 98;

                // 페이지 번호 span 삽입
				var spans = $('<span class="a" style="width: ' + idxWidth + 'px; display: inline-block; text-align: left; ">'+ new Array(dotted).join('.') + ' ' + subNum +'</span>');
				//var spans = $('<span style="width: ' + idxWidth + 'px; display: inline-block; text-align: left; font-size: 16px;"></span><span style="width: 20px;">' + subNum + '</span>');
				spans.appendTo($('#idx_'+number));
            });
		}

        function getTextLength(str) {
            var len = 0;
            for (var i = 0; i < str.length; i++) {
                if (escape(str.charAt(i)).length == 6) {
                    len++;
                }
                len++;
            }
            return len;
        }

        function doWord() {
            // 문서 만드는 부분
            $('.indexList').wordExport();
        }
	</script>

	<e:window id="BECF_VIEW" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" margin="0 4px">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSave" name="doSave" label="완료" disabled="false" onClick="doSave" />
			<e:button id="doClose" name="doClose" label="닫기" disabled="false" onClick="doClose" />
			<e:button id="doContents" name="doContents" label="목차" disabled="false" onClick="doContents" />
			<e:button id="doWord" name="doWord" label="워드" disabled="${doClose_D }" onClick="doWord" />
		</e:buttonBar>


		<div id="view">
			${ckEditorHtml}
			<%--<iframe id="speller" src="http://speller.cs.pusan.ac.kr/" width="860px" height="710px" frameborder="0" scrolling="no"></iframe>--%>
		</div>
		<div class="indexList"></div>
	</e:window>
</e:ui>