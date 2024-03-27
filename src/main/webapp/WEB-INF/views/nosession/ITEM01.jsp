<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<link rel="stylesheet" href="/css/richText.css" type="text/css"/>
    <link href="/js/jquery/jquery.fs.stepper.css" rel="stylesheet" type="text/css">
    <script src="/js/jquery/jquery.fs.stepper.min.js"></script>
    <script>
        var baseUrl = "/evermp/IM03/IM0301/";
        var gridat;
        document.oncontextmenu = function () { alert("우클릭 버튼을 사용할 수 없습니다."); return false; } // 우클릭 방지

        function init() {
            gridat = EVF.C("gridat");
            _setImages();

        }

        function _setImages(){

            var fileManager = EVF.V("IMG_ATT_FILE_NUM");

                if(fileManager!=""){
                    var store = new EVF.Store();
                    store.setParameter('fileManagerId', 'MTGL_IMG_MAIN');
                    store.setParameter('bizType', 'IMG');
                    store.setParameter('fileId', fileManager);

                    var mainId ="";

                    store.load('/fileAttach/getUploadedFileInfo', function() {
                        var fileInfoJson = JSON.parse(this.getParameter('fileInfo'));
                        $('#MTGL_IMG_MAIN').empty();
                        $('#MTGL_IMG1').empty();
                        $('#MTGL_IMG2').empty();
                        $('#MTGL_IMG3').empty();
                        console.log(fileInfoJson);

                        $.each(fileInfoJson, function(i, datum) {
                            if(EVF.V("MAIN_IMG_SQ")==datum.UUID_SQ){
                                var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id="IMG0" data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width: 175px; height:175px; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                                var $hiddenMain = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id="ORIGIN" data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width: 100%; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                                $('#MTGL_IMG_MAIN').append($itemImage);
                                $('#HIDDEN_IMG_MAIN').append($hiddenMain);
                                mainId = i;
                            }
                        });
                        var k=0;
                        $.each(fileInfoJson, function(i, datum) {
                            if(i!=mainId){
                                if(k==0){
                                    var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id=IMG1 data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width:98px; height:55px; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                                    $('#MTGL_IMG1').append($itemImage);
                                }else if(k==1){
                                    var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id=IMG2 data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width:98px; height:55px; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                                    $('#MTGL_IMG2').append($itemImage);
                                }else if(k==2){
                                    var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id=IMG3 data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width:98px; height:55px; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                                    $('#MTGL_IMG3').append($itemImage);
                                }
                                k++;
                            }
                        });
                    });
                }else{
                    $('#MTGL_IMG_MAIN').empty();
                    var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img src="/images/noimage_02.jpg" id="MAIN_IMAGE" style="width: 175px; height: 175px; cursor: pointer; display: block;"/></div>');
                    $('#MTGL_IMG_MAIN').append($itemImage);
                }
        }

        function detail_IMG_MAIN(){
            var img_width = document.getElementById("ORIGIN").naturalWidth +10;
            var img_height = document.getElementById('ORIGIN').naturalHeight +10;
            var OpenWindow=window.open('','_blank', 'width='+img_width+', height='+img_height+', menubars=no, scrollbars=auto');
            OpenWindow.document.write("<style>body{margin:0px;}</style><img src='"+jQuery('#ORIGIN').attr("src")+"' width='"+img_width+"'>");

        }

        function detail_IMG1() {
            var main = jQuery('#IMG0').attr("src");
            var item = jQuery('#IMG1').attr("src");
            jQuery("#IMG0").attr("src", item);
            jQuery("#ORIGIN").attr("src", item);
            jQuery("#IMG1").attr("src", main);
        }

        function detail_IMG2() {
            var main = jQuery('#IMG0').attr("src");
            var item = jQuery('#IMG2').attr("src");
            jQuery("#ORIGIN").attr("src", item);
            jQuery("#IMG0").attr("src", item);
            jQuery("#IMG2").attr("src", main);
        }

        function detail_IMG3() {
            var main = jQuery('#IMG0').attr("src");
            var item = jQuery('#IMG3').attr("src");
            jQuery("#ORIGIN").attr("src", item);
            jQuery("#IMG0").attr("src", item);
            jQuery("#IMG3").attr("src", main);
        }

        function checkQt(){

            var mouQty = Number(EVF.V("MOQ_QTY")); // 최소주문량
            var rvQty  = Number(EVF.V("RV_QTY")); // 주문배수
            var cartQt = Number(EVF.V("CART_QT")); // 주문수량
            var itemtotAmt = 0;

            if(cartQt >= mouQty && (cartQt === mouQty || cartQt % mouQty === 0)) {
                itemtotAmt = parseInt(EVF.V("CART_QT") * parseInt(EVF.V("UNIT_PRC")));
                EVF.C("ITEM_TOT_AMT").setValue(comma(String(itemtotAmt)));

            }else{
                EVF.V("CART_QT",EVF.V("MOQ_QTY"));
                itemtotAmt = parseInt(EVF.V("CART_QT") * parseInt(EVF.V("UNIT_PRC")));
                EVF.C("ITEM_TOT_AMT").setValue(comma(String(itemtotAmt)));
                return alert("${IM03_014_011}");
            }

        }
        function comma(obj) {
            var regx = new RegExp(/(-?\d+)(\d{3})/);
            var bExists = obj.indexOf(".", 0);//0번째부터 .을 찾는다.
            var strArr = obj.split('.');
            while (regx.test(strArr[0])) {//문자열에 정규식 특수문자가 포함되어 있는지 체크
                //정수 부분에만 콤마 달기
                strArr[0] = strArr[0].replace(regx, "$1,$2");//콤마추가하기
            }
            if (bExists > -1) {
                //. 소수점 문자열이 발견되지 않을 경우 -1 반환
                obj = strArr[0] + "." + strArr[1];
            } else { //정수만 있을경우 //소수점 문자열 존재하면 양수 반환
                obj = strArr[0];
            }
            return obj;//문자열 반환
        }
    </script>

    <e:window id="ITEM01" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:panel id="leftPanelB" height="fit" width="30%">
            <e:title title="${IM03_014_CAPTION1 }" depth="1"/>
        </e:panel>
        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
            <e:row>

                <e:inputHidden id="SIGN_DATE" name="SIGN_DATE" value="${formData.SIGN_DATE }" />
                <e:inputHidden id="approvalFormData" name="approvalFormData" />
                <e:inputHidden id="approvalGridData" name="approvalGridData" />
                <e:inputHidden id="attachFileDatas" name="attachFileDatas" />
                <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${formData.PROGRESS_CD }" />
                <e:inputHidden id="CONT_NO" name="CONT_NO" value="${formData.CONT_NO }" />
                <e:inputHidden id="CONT_SEQ" name="CONT_SEQ" value="${formData.CONT_SEQ }" />
                <e:inputHidden id="APPLY_COM" name="APPLY_COM" value="${formData.APPLY_COM }" />
                <e:inputHidden id="APPLY_PLANT" name="APPLY_PLANT" value="${formData.APPLY_PLANT }" />



                <e:field colSpan="2" rowSpan="6" align="center">
                    <e:inputHidden id="IMG_ATT_FILE_NUM" name="IMG_ATT_FILE_NUM" value="${formData.IMG_ATT_FILE_NUM}" />
                    <e:inputHidden id="MAIN_IMG_SQ" name="MAIN_IMG_SQ" value="${formData.MAIN_IMG_SQ}" />
                        <div style="width: 200px; height: 145px; vertical-align: center">
                            <a href="javascript:detail_IMG_MAIN();">
                                <div id="MTGL_IMG_MAIN" name="MTGL_IMG_MAIN" style="width: 100%; height: 100%; display: block; margin-left: auto; margin-right: auto;"></div>
                            </a>
                        </div>
                    <e:panel width="0px" height="0px">
                        <div id="HIDDEN_IMG_MAIN" name="HIDDEN_IMG_MAIN" ></div>
                    </e:panel>
                </e:field>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                <e:field colSpan="3">
                    <e:text>${formData.ITEM_CLS_NM }</e:text>
                    <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="${formData.ITEM_CLS1}"/>
                    <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" value="${formData.ITEM_CLS2}"/>
                    <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" value="${formData.ITEM_CLS3}"/>
                    <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" value="${formData.ITEM_CLS4}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:text>${formData.ITEM_CD }</e:text>
                    <e:inputHidden id="ITEM_CD" name="ITEM_CD" value="${formData.ITEM_CD}"/>
                </e:field>
                <e:label for="ITEM_KIND_NM" title="${form_ITEM_KIND_NM_N}"/>
                <e:field>
                    <e:text>${formData.ITEM_KIND_NM } / ${formData.ITEM_STATUS_NM }</e:text>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field colSpan="3">
                    <e:text>${formData.ITEM_DESC }</e:text>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}"/>
                <e:field colSpan="3">
                	<e:text>${formData.ITEM_SPEC}</e:text>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MAKER_CD" title="${form_MAKER_CD_N}"/>
                <e:field>
                    <e:text>${formData.MAKER_NM }</e:text>
                </e:field>
                <e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}" />
                <e:field>
                    <e:text>${formData.MAKER_PART_NO }</e:text>
                </e:field>
            </e:row>

            <e:row>
                <e:label for="BRAND_CD" title="${form_BRAND_CD_N}"/>
                <e:field>
                    <e:text>${formData.BRAND_CD }</e:text>
                </e:field>
                <e:label for="ORIGIN_CD" title="${form_ORIGIN_CD_N}" />
                <e:field>
                    <e:text>${formData.ORIGIN_NM }</e:text>
                </e:field>
            </e:row>
            <e:row>
                <e:field colSpan="2" rowSpan="3">
                    <e:panel height="fit" width="100%">
                        <e:panel width="33%" height="55px">
                            <a href="javascript:detail_IMG1();">
                                <div id="MTGL_IMG1" name="MTGL_IMG1" style="width: 100%; display: block; margin-left: auto; margin-right: auto; border-right: 1px solid; border-right-color: grey"></div>
                            </a>
                        </e:panel>
                        <e:panel width="33%" height="55px">
                            <a href="javascript:detail_IMG2();">
                                <div id="MTGL_IMG2" name="MTGL_IMG2" style="width: 100%; display: block; margin-left: auto; margin-right: auto; border-right: 1px solid; border-right-color: grey"></div>
                            </a>
                        </e:panel>
                        <e:panel width="33%" height="55px">
                            <a href="javascript:detail_IMG3();">
                                <div id="MTGL_IMG3" name="MTGL_IMG3" style="width: 100%; display: block; margin-left: auto; margin-right: auto;"></div>
                            </a>
                        </e:panel>
                    </e:panel>
                </e:field>
                <e:label for="UNIT_CD" title="${form_UNIT_CD_N}" />
                <e:field>
                    <e:text>${formData.UNIT_NM }</e:text>
                </e:field>
                <e:label for="VAT_CD" title="${form_VAT_CD_N}" />
                <e:field>
                    <e:text>${formData.VAT_NM }</e:text>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CMS_CTRL_USER_ID" title="${form_CMS_CTRL_USER_ID_N}"/>
                <e:field>
                        <e:text id="CMS_CTRL_USER_NM" name="CMS_CTRL_USER_NM" style="">${formData.CMS_CTRL_USER_NM}</e:text>
                    <e:inputHidden id="CMS_CTRL_USER_ID" name="CMS_CTRL_USER_ID" value="${formData.CMS_CTRL_USER_ID}"/>
                </e:field>
                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
                <e:field>
                        <e:text id="SG_CTRL_USER_NM" name="SG_CTRL_USER_NM" style="">${formData.SG_CTRL_USER_NM}</e:text>
                    <e:inputHidden id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${formData.SG_CTRL_USER_ID}"/>
                </e:field>
            </e:row>

            <e:row>
                <e:label for="MOQ_QTY" title="${form_MOQ_QTY_N}"/>
                <e:field>
                    <e:text style="float: right;">${formData.MOQ_QTY }</e:text>
                    <e:inputHidden id="MOQ_QTY" name="MOQ_QTY" value="${formData.MOQ_QTY}"/>
                </e:field>
               <e:label for="RV_QTY" title="${form_RV_QTY_N}"/>
                <e:field>
                    <e:text style="float: right;">${formData.RV_QTY }</e:text>
                    <e:inputHidden id="RV_QTY" name="RV_QTY" value="${formData.RV_QTY}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:panel id="lastPanel" height="fit" width="30%">
            <e:title title="${IM03_014_CAPTION3 }" depth="1"/>
        </e:panel>
        <e:searchPanel id="searchPanel3" title="" labelWidth="${labelWidth}" width="100%" columnCount="1" useTitleBar="false">
            <e:row>
            <e:field colSpan="2">
                <e:inputHidden id="ITEM_DETAIL_TEXT_NUM" name="ITEM_DETAIL_TEXT_NUM" value="${formData.ITEM_DETAIL_TEXT_NUM}" />
                <div id="divHtml">
                    <%--품목상세이미지--%>
                <c:if test="${not empty formData.ITEM_DETAIL_URL}">
                    <div style="text-align: center;">
                        <img src="${formData.ITEM_DETAIL_URL}">
                    </div>
                </c:if>
                    <div style="text-align: center;">
                        <img src="${ITEM_DETAIL_FILE_PATH}">
                    </div>
                    <%--상세정보--%>
                    <br>
                    <div>
		                <e:richTextEditor height="200px" useToolbar="false" width="100%" disabled="false" required="false" id="TEXT_CONTENTS" readOnly="true" name="TEXT_CONTENTS" value="${TEXT_CONTENTS}"/>
						<br/>
                    </div>

					<e:br/>
					<e:br/>
					<e:br/>


                    <c:if test="${not empty formData.ITEM_NOTC_DESC}">
                    <br>
                    <%--상품고시--%>
                        <div>
                            <h3 class="itemTitle">상품정보고시 <span class="itemTitleSub">(본 내용은 상품정보제공 고시에 따라 작성되었습니다.)</span></h3>

                            <table style="width: 100%; border-collapse: collapse;">
                                <colgroup>
                                    <col width="238" />
                                    <col width="*" />
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="itemTH itemTop">품명 및 모델명</th>
                                    <td class="itemTD itemTop">${formData.ITEM_NOTC_DESC}</td>
                                </tr>
                                <tr>
                                    <th class="itemTH">법에 의한 인증&middot;허가 등의 사항</th>
                                    <td class="itemTD">${formData.ITEM_NOTC_CERT}</td>
                                </tr>
                                <tr>
                                    <th class="itemTH">제조국 또는 원산지</th>
                                    <td class="itemTD">${formData.ITEM_NOTC_ORIGIN}</td>
                                </tr>
                                <tr>
                                    <th class="itemTH">제조사</th>
                                    <td class="itemTD">${formData.ITEM_NOTC_MAKER}</td>
                                </tr>
                                <tr>
                                    <th class="itemTH">A/S 책임자와 전화번호 또는 소비자상담 관련 전화번호</th>
                                    <td class="itemTD">${formData.ITEM_NOTC_AS}</td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </c:if>
                </div>
            </e:field>
            </e:row>
        </e:searchPanel>


        <e:panel id="hiddenP" height="0" width="0%">
            <e:gridPanel gridType="${_gridType}" id="gridat" name="gridat" height="0px" readOnly="${param.detailView}" columnDef="${gridInfos.gridat.gridColData}"/>
        </e:panel>


    </e:window>
</e:ui>