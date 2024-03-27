<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui dateFmt="">

    <script type="text/javascript" src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>

    <!-- KTNET 공인인증서 모듈 연결(SCORE_PKI_for_OpenWeb_v1.0.1.5_2.0.7.8) -->
    <script src="/toolkit/tradesign/js/nxts/nxts.min.js"></script>
    <script src="/toolkit/tradesign/js/nxts/nxtspki_config.js"></script>
    <script src="/toolkit/tradesign/js/nxts/nxtspki.js"></script>
    <script src="/toolkit/tradesign/js/demo.js"></script>

    <script type="text/javascript">

        var userType = '${ses.userType}';
        var baseUrl = '/evermp/vendor/cont/CT0611';
        var gridItem;

        function init() {

            gridItem = EVF.C("gridItem");

            gridItem.setProperty('shrinkToFit', true);
            gridItem.setProperty('multiSelect', false);

            var editor = CKEDITOR.replace('cont_content', {
                customConfig : '/js/everuxf/lib/ckeditor/ep_configs_v.js?var=3',
                width: '100%',
                height: 514
            });

            editor.on('instanceReady', function (ev) {
                var editor = ev.editor;

                $(window).resize(function () {
                    editor.resize('100%', (document.body.clientHeight - $('#cke_cont_content').offset().top - 53), true, false);
                });

                editor.setReadOnly(true);
            });

            <%-- TradeSign 공인인증서 --%>
            nxTSPKI.onInit(function(){ });
            nxTSPKI.init(true);

            doSearchContItem();
            setButtons();
        }

        function doSearchContItem() {
            var store = new EVF.Store();
            store.setGrid([gridItem]);
            store.load(baseUrl + '/doSearchContItem', function () {
            });
        }

        function setButtons() {

            var progressCd = EVF.V('PROGRESS_CD');
            if(${not param.detailView eq 'true'}) {
                EVF.C('doConfirm').setVisible(false);
                EVF.C('doSign').setVisible(false);
//                 EVF.C('doReject').setVisible(false);

                /*
                 [전자계약 진행상태] 임시저장  public static final String CONT_TEMP_SAVE = "4110";
                 [전자계약 진행상태] 법무팀 검토  public static final String M135_4203 = "4203";
                 [전자계약 진행상태] 계약서최종확인  public static final String M135_4205 = "4205";
                 [전자계약 진행상태] 협력사서명대기  public static final String CONT_SUPPLY_READY = "4200";
                 [전자계약 진행상태] 협력사서명반려  public static final String CONT_SUPPLY_REJECT = "4210";
                 [전자계약 진행상태] 협력사서명완료  public static final String CONT_SUPPLY_SIGN = "4220";
                 [전자계약 진행상태] 계약체결기안  public static final String M135_4240 = "4240";
                 [전자계약 진행상태] 계약체결완료  public static final String M135_4300 = "4300";
				*/
                <%-- 4110 : 임시저장, 4200 : 협력업체 서명대기, 4210 : 협력업체 서명반려 , 4220 : 협력업체 서명완료, 4300 : 계약체결완료,  --%>
                if (progressCd == '4200') {
                    if ('${form.RECEIPT_YN}' == '0') {
                        EVF.C('doConfirm').setVisible(true);
                    } else {
//                         EVF.C('doReject').setVisible(true);
                        EVF.C('doSign').setVisible(true);
                    }
                }
            }
        }

        function doConfirm() {
            var store = new EVF.Store();
			if (!store.validate()) { return; }


            store.load(baseUrl + '/doConfirm', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    if (opener) {
                        opener['doSearch']();
                    }
                    EVF.closeWindow();
                });
            });
        }

        function doSign() {

             EVF.confirm("${CT0611_0005 }", function () {
                 var store = new EVF.Store();
                 store.load(baseUrl + '/getContractsToSign', function() {

             <c:choose>
                 <c:when test="${isDevEnv}">
                     var data = this.getParameter('formContents');
                     var options = {
                         ssn: '1234567890'
                     }
                     nxTSPKI.signData(data, options, signCompleteCallback);
                 </c:when>
                 <c:otherwise>
                     var data = this.getParameter('formContents');
                     var options = {
                         ssn: EVF.V('IRS_NUM').replace(/[^0-9]/gi, '')
                     }
                     nxTSPKI.signData(data, options, signCompleteCallback);
                 </c:otherwise>
             </c:choose>
                 }, false);
             });
        }

        function signCompleteCallback(res) {

            if (res.code == 0) {
                EVF.V('SIGN_VALUE', res.data.signedData);

                var store = new EVF.Store();
                store.load(baseUrl + '/doSaveSignedData', function() {
                    EVF.alert(this.getResponseMessage(), function() {
                        if (opener) {
                            opener['doSearch']();
                        }
                        EVF.closeWindow();
                    });
                });
            } else {
				return EVF.alert(res.errorMessage);
            }
        }

        function doReject() {

            var param = {
                "screenName": "계약서 반려 사유를 입력해주세요.",
                "callBackFunction": 'setRejectReason',
                "havePermission": 'true',
                "detailView": false
            };
            everPopup.openModalPopup('/common/commonTextContents/view', 700, 350, param, 'commonTextInput');
        }

        function setRejectReason(text) {

            if(text == undefined || text.trim() == '') {
                return EVF.alert('${CT0611_0004}')
            }

            EVF.confirm("${CT0611_0002 }", function () {
                var store = new EVF.Store();
                store.setParameter('rejectRemark', text);
                store.load(baseUrl+'/doRejectContract', function() {
                    EVF.alert('${CT0611_0003}', function() {
                        location.href=baseUrl+"/view.so?contNum=${form.CONT_NUM}&contCnt=${form.CONT_CNT}";
                        if(opener) {
                            opener['doSearch']();
                        }
                    });
                });
            });
        }

        function onActiveTab(newTabId, oldTabId, event) {
            if(newTabId === '1') {

            } else if(newTabId === '2') {

            } else {    <%-- 부서식탭 활성화 --%>
                if(CKEDITOR.instances[newTabId] == null) {
                    var editor = CKEDITOR.replace(newTabId, {
                        customConfig : '/js/everuxf/lib/ckeditor/ep_configs_v.js?var=3',
                        width: '100%',
                        height: 380
                    });

                    editor.on('instanceReady', function (ev) {
                        var editor = ev.editor;

                        $(window).resize(function () {
                            editor.resize('100%', (document.body.clientHeight - $('#cke_'+newTabId).offset().top - 53), true, false);
                        });
                        $(window).trigger('resize');
                    });
                }
            }
        }

        function doPrint() {
            fileFrame.location.href = '/common/file/fileAttach/downloadContPdf.so?contNum=${empty form.CONT_NUM ? param.contNum : form.CONT_NUM}&contCnt=${empty form.CONT_CNT ? param.contCnt : form.CONT_CNT}';
        }

    </script>

    <e:window id="CT0611" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" margin="0 4px">

        <e:tabPanel id="T1" onActive="onActiveTab">
            <e:tab id="1" title="기본정보">

                <e:inputHidden id="CONT_NUM" name="CONT_NUM" value="${empty form.CONT_NUM ? param.contNum : form.CONT_NUM}"/>
                <e:inputHidden id='CONT_CNT' name='CONT_CNT' value='${empty form.CONT_CNT ? param.contCnt : form.CONT_CNT}'/>
                <e:inputHidden id='PROGRESS_CD' name='PROGRESS_CD' value='${form.PROGRESS_CD}'/>
                <e:inputHidden id='CONTRACT_TYPE' name='CONTRACT_TYPE' value='${form.CONTRACT_TYPE}'/>
                <e:inputHidden id='CONTRACT_TEXT_NUM' name='CONTRACT_TEXT_NUM' value='${form.CONTRACT_TEXT_NUM}'/>
                <e:inputHidden id='FORM_NUM' name='FORM_NUM' value='${form.MAIN_FORM_NUM}' alt="주계약서 서식번호" />
                <e:inputHidden id='IRS_NUM' name='IRS_NUM' value='${form.IRS_NUM}'/>
                <e:inputHidden id="SIGN_VALUE" name="SIGN_VALUE" />
                <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${empty form.BUYER_CD ? param.BUYER_CD : form.BUYER_CD}"/>
                <e:inputHidden id="BUYER_NM" name="BUYER_NM" value="${empty form.BUYER_NM ? param.BUYER_NM : form.BUYER_NM}"/>
                <e:inputHidden id="CONT_USER_ID" name="CONT_USER_ID" value="${empty form.CONT_USER_ID ? param.CONT_USER_ID : form.CONT_USER_ID}"/>
                <e:inputHidden id="contractContentsToSign" name="contractContentsToSign" />
                <e:inputHidden id='MANUAL_CONT_FLAG' name='MANUAL_CONT_FLAG' value='${form.MANUAL_CONT_FLAG}'/>

                <e:inputHidden id="VENDOR_PIC_TEL_NUM" name="VENDOR_PIC_TEL_NUM" />

                <e:inputHidden id="LOC_BUYER_CD" name="LOC_BUYER_CD" value="${form.LOC_BUYER_CD}"/>
                <e:inputHidden id="LOC_BUYER_NM" name="LOC_BUYER_NM" value="${form.LOC_BUYER_NM}"/>

                <e:title title="기본정보" />
                <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="140" onEnter="doSearch" useTitleBar="false">
                    <e:row>
                        <e:label for="CONT_NUM" title="${form_CONT_NUM_N}"/>
                        <e:field>
                            <e:text>${form.CONT_NUM} / ${form.CONT_CNT}</e:text>
                        </e:field>
                        <e:label for="CONT_DESC" title="${form_CONT_DESC_N }"/>
                        <e:field colSpan="3">
                            <e:text>${form.CONT_DESC}</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="CONT_DATE" title="${form_CONT_DATE_N }"/>
                        <e:field>
                            <e:text>${form.CONT_DATE}</e:text>
                        </e:field>
                        <e:label for="CONT_START_DATE" title="${form_CONT_START_DATE_N }"/>
                        <e:field>
                            <e:text>${form.CONT_START_DATE}</e:text><e:text>~</e:text><e:text>${form.CONT_END_DATE}</e:text>
                        </e:field>
                        <e:label for="CONT_REQ_CD" title="${form_CONT_REQ_CD_N}"/>
                        <e:field>
                            <e:text>${form.CONT_REQ_CD_LOC}</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="CONT_AMT" title="${form_CONT_AMT_N }"/>
                        <e:field colSpan="3">
                            <e:text>${(empty form.CONT_AMT or form.CONT_AMT == 'null') ? '' : form.CONT_AMT} ${form.CUR_LOC} ${form.VAT_TYPE_LOC}</e:text>
                        </e:field>
                        <e:label for="CONT_USER_NM" title="${form_CONT_USER_ID_N }"/>
                        <e:field>
                            <e:text>${form.CONT_USER_NM}</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="VENDOR_NM" title="${form_VENDOR_CD_N }"/>
                        <e:field colSpan="3">
                            <e:text>${form.VENDOR_NM}</e:text>
                        </e:field>
                        <e:label for="MANUAL_CONT_FLAG" title="${form_MANUAL_CONT_FLAG_N}"/>
                        <e:field>
                            <e:text>${form.MANUAL_CONT_FLAG_LOC}</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="VENDOR_PIC_USER_NM" title="${form_VENDOR_PIC_USER_NM_N}"/>
                        <e:field>
                            <e:inputText id="VENDOR_PIC_USER_NM" name="VENDOR_PIC_USER_NM" value="${form.VENDOR_PIC_USER_NM}" width="${form_VENDOR_PIC_USER_NM_W}" maxLength="${form_VENDOR_PIC_USER_NM_M}" disabled="${form_VENDOR_PIC_USER_NM_D}" readOnly="${form_VENDOR_PIC_USER_NM_RO}" required="${form_VENDOR_PIC_USER_NM_R}"/>
                        </e:field>
                        <e:label for="VENDOR_PIC_USER_EMAIL" title="${form_VENDOR_PIC_USER_EMAIL_N}"/>
                        <e:field>
                            <e:inputText id="VENDOR_PIC_USER_EMAIL" name="VENDOR_PIC_USER_EMAIL" value="${form.VENDOR_PIC_USER_EMAIL}" width="${form_VENDOR_PIC_USER_EMAIL_W}" maxLength="${form_VENDOR_PIC_USER_EMAIL_M}" disabled="${form_VENDOR_PIC_USER_EMAIL_D}" readOnly="${form_VENDOR_PIC_USER_EMAIL_RO}" required="${form_VENDOR_PIC_USER_EMAIL_R}"/>
                        </e:field>

						<%--담당자 핸드폰 번호--%>
						<e:label for="VENDOR_PIC_CELL_NUM" title="${form_VENDOR_PIC_CELL_NUM_N}" />
						<e:field>
						<e:inputText id="VENDOR_PIC_CELL_NUM" name="VENDOR_PIC_CELL_NUM" value="${form.VENDOR_PIC_CELL_NUM}" width="${form_VENDOR_PIC_CELL_NUM_W}" maxLength="${form_VENDOR_PIC_CELL_NUM_M}" disabled="${form_VENDOR_PIC_CELL_NUM_D}" readOnly="${form_VENDOR_PIC_CELL_NUM_RO}" required="${form_VENDOR_PIC_CELL_NUM_R}" />
						</e:field>


                    </e:row>
                    <e:row>
                        <e:label for="CONT_REQ_RMK" title="${form_CONT_REQ_RMK_N}"/>
                        <e:field colSpan="5">
                            <e:textArea id="CONT_REQ_RMK" style="${imeMode}" name="CONT_REQ_RMK" height="70" value="${empty form.CONT_REQ_RMK ? param.CONT_REQ_RMK : form.CONT_REQ_RMK}" width="100%" maxLength="${form_CONT_REQ_RMK_M}" disabled="${form_CONT_REQ_RMK_D}" readOnly="${form_CONT_REQ_RMK_RO}" required="${form_CONT_REQ_RMK_R}"/>
                        </e:field>
                    </e:row>
                    <c:if test="${form.PROGRESS_CD eq '4220'}">
                        <e:row>
                            <e:label for="VENDOR_REJECT_RMK" title="${form_VENDOR_REJECT_RMK_N}"/>
                            <e:field colSpan="5">
                                <e:textArea id="VENDOR_REJECT_RMK" name="VENDOR_REJECT_RMK" value="${form.VENDOR_REJECT_RMK}" height="100px" width="100%" maxLength="${form_VENDOR_REJECT_RMK_M}" disabled="${form_VENDOR_REJECT_RMK_D}" readOnly="${form_VENDOR_REJECT_RMK_RO}" required="${form_VENDOR_REJECT_RMK_R}" />
                            </e:field>
                        </e:row>
                    </c:if>
                </e:searchPanel>

                <e:title title="첨부파일"/>
                <e:searchPanel id="form2" title="${form_CAPTION_N }" columnCount="1" labelWidth="135" useTitleBar="false">
                    <e:row>
                        <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                        <e:field>
                            <e:fileManager id="ATT_FILE_NUM" height="130" width="100%" fileId="${form.ATT_FILE_NUM}" readOnly="true" bizType="EC" required="false" uploadable="false" autoUpload="true" />
                        </e:field>
                    </e:row>
                </e:searchPanel>

                    <c:if test="${itemCnt eq 0}">
						<div style="display : none">
					</c:if>
		                <e:title title="자재정보"/>
		                <e:gridPanel id="gridItem" name="gridItem" width="100%" height="240px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridItem.gridColData}" />
                    <c:if test="${itemCnt eq 0}">
						</div>
					</c:if>

            </e:tab>

            <e:tab id="2" title="계약서">
                    <e:buttonBar width="100%" align="right">
                    <c:if test="${not param.detailView eq 'true'}">
                        <e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>
                        <e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/>
<%--                    <e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/> --%>
                    </c:if>
                        <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
                    </e:buttonBar>
                <textarea id=cont_content name="cont_content" style="width:100%;">${form.formContents}</textarea>
            </e:tab>

            <c:forEach items="${subFormList}" var="subForm">
                <e:tab id="${subForm.REL_FORM_NUM}" title="부서식: ${subForm.REL_FORM_NM}">
                    <textarea id="${subForm.REL_FORM_NUM}" name="${subForm.REL_FORM_NUM}" style="width:100%;">${subForm.ADDITIONAL_CONTENTS}</textarea>
                </e:tab>
            </c:forEach>

        </e:tabPanel>
        <iframe id="fileFrame" name="fileFrame" style="display: block;" height="0"></iframe>
    </e:window>

</e:ui>