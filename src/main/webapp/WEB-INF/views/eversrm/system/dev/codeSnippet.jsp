<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.11.0/styles/androidstudio.min.css">
    <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.11.0/highlight.min.js"></script>

    <script type="text/javascript">

        var grid;
        var gridB2;
        var gridB3;
        var gridTree;
        var baseUrl = "/eversrm/system/";

        function init() {

            gridB2 = EVF.C("gridB2");
            gridB2.delRowEvent(function() {
                if(!gridB2.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridB2.delRow();
            });

            gridB2.setProperty('shrinkToFit', true);

            //grid
            gridB2.delRowEvent(function () {
                gridB2.delRow();
            });


            $('pre code').each(function(i, block) {
                hljs.highlightBlock(block);
            });

            gridB3 = EVF.C("gridB3");
            EVF.C('gridB3').addRow();
            EVF.C('gridB3').addRow();
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'm99001_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        /**
         * 선택된 옵션의 첨부파일번호로 템플릿 다운로드 팝업창을 띄운다.
         */
        function getTmplDownloadPopup() {
            var store = new EVF.Store();
            store.setParameter('tmplNum', EVF.C('TMPL_NM').getValue());
            store.load('/siis/M99/m99004_getTmplAttFileNum', function() {
//          alert(this.getParameter('attFileNum'));
                everPopup.readOnlyFileAttachPopup('tmplMng', this.getParameter('attFileNum'), null, null);
            })
        }

        //sendBill 사용자 정보 팝업
        function dosendBillSearch() {
            var param = {
                callBackFunction : "setsendBill",
                'detailView': false
            };
            everPopup.sendBillUser(param);

        }

        function setsendBill(data) {
            console.log(data);
        }


        function getBsCd() {
            var param = {
                callBackFunction : "setBsCd",
                detailView : false
            };
            everPopup.openPopupByScreenId("M99_006", 900, 500, param);
        }

        function setBsCd(dataJsonArray) {
            EVF.C("BS_CD").setValue(dataJsonArray.BS_CD);
            EVF.C("BS_NM").setValue(dataJsonArray.BS_NM);
        }

        function getItems() {
            var param = {
                callBackFunction : "setItems",
                dupItemAllow: true,     /* 중복상품 허용여부 */
                returnType: 'S',        /* 단일선택 여부 */
                treeView: false,        /* 품목분류 보이기 여부 */
                BUSINESS_TYPE: '200',   /* 100:IT, 200:리테일 */
                PACKAGE_TYPE: '200',    /* 100:일반, 200:패키지상품 */
                ITEM_CLS1: '',        /* 대분류 코드 */
                ITEM_CLS2: '',          /* 중분류 코드 */
                ITEM_CLS3: '',          /* 소분류 코드 */
                ITEM_CLS4: '',          /* 세분류 코드 */
                detailView : false
            };
            everPopup.openPopupByScreenId("BPR_041", 1300, 700, param);
        }

        function setItems(data) {
            console.log(JSON.parse(data));
            EVF.V('CONSOLE', data);
        }


        //팀찾기_멀티
        function doTeamSearch_M() {

            var param = {
                callBackFunction : "setTeam",
                'detailView': false,
                'multiYN' : true,
                'custCd' : '${ses.companyCd}',
                'custNm' : '${ses.companyNm}'
            };
            //윈도우팝업테스트
            everPopup.openPopupByScreenId("SY01_003", 500, 450, param);
        }
        //팀셋팅_멀티
        function setTeam(data) {

            var dataArr = [];

            for(idx in data) {
                if(data[idx].ITEM_CLS2=='*'){	//전체 선택시 (전사)
                    var arr = {
                        //'PARENT_DEPT_NM': data[idx].ITEM_CLS_NM,
                        'DEPT_NM': data[idx].ITEM_CLS_NM,
                        'PARENT_DEPT_CD': data[idx].ITEM_CLS1,
                        'DEPT_CD': data[idx].ITEM_CLS1,
                        'BUYER_CD': ${ses.companyCd}
                    };
                    dataArr.push(arr);
                }else if(data[idx].ITEM_CLS3!='*'){
                    var arr = {
                        //'PARENT_DEPT_NM': data[idx].PARENT_DEPT_NM,
                        'DEPT_NM': data[idx].ITEM_CLS_NM,
                        'PARENT_DEPT_CD': data[idx].ITEM_CLS2,
                        'DEPT_CD': data[idx].ITEM_CLS3,
                        'BUYER_CD': ${ses.companyCd}
                    };
                    dataArr.push(arr);
                }
            }
            var validData = valid.equalPopupValid(JSON.stringify(dataArr), gridB2, "DEPT_NM");
            gridB2.addRow(validData);

            gridB2.setColMerge(['PARENT_DEPT_NM']);
        }

        //팀찾기_싱글
        function doTeamSearch_S() {
            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "setTeam_S",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : '${ses.companyCd}',
                'custNm' : '${ses.companyNm}'
            };
            everPopup.openModalPopup(popupUrl, 500, 450, param, "SearchTeamPopup");
        }
        //싱글일경우
        function setTeam_S(data) {
            data = JSON.parse(data);

            var dataArr = [];
            var arr = {
               // 'PARENT_DEPT_NM': data.PARENT_DEPT_NM,
                'DEPT_NM': data.ITEM_CLS_NM,
                'PARENT_DEPT_CD': data.ITEM_CLS2,
                'DEPT_CD': data.ITEM_CLS3,
                'BUYER_CD': ${ses.companyCd}
            };
            dataArr.push(arr);

            var validData = valid.equalPopupValid(JSON.stringify(dataArr), gridB2, "DEPT_CD");
            gridB2.addRow(validData);

            gridB2.setColMerge(['PARENT_DEPT_NM']);
        }


        //동적콤보 - 콤보변경시
        function getDEPT_TYPE() {
            var store = new EVF.Store();

            var dept_type = this.data;
            deptTypeNo='';
            if (dept_type=='2') {
                deptTypeNo= EVF.C("DEPT_TYPE").getValue();
                clearX('3');
            }
            if (dept_type=='3') {
                deptTypeNo= EVF.C("DEPT_TYPE2").getValue();
            }
            //하위콤보 조회시
            store.load('/siis/M99/codeSnippet_ComboList.so?DEPT_TYPE='+dept_type+'&DEPT_TYPE_NO='+deptTypeNo, function() {
                //조회후 넘겨받은 리스트를 해당 콤보다음에 셋팅한다.
                EVF.C('DEPT_TYPE'+ dept_type ).setOptions(this.getParameter("deptTypes"));
            });
        }

        //상위 콤보변경시 초기화
        function clearX( deptTypeNo ) {
            EVF.C('DEPT_TYPE'+ deptTypeNo ).setOptions( JSON.parse('[]')    );
        }

        function getGateCd() {
            var param = {
                callBackFunction : "setBsCd",
                detailView : false
            };
            everPopup.openCommonPopup(param, "SP0096");
        }


        function _getItemClsNm()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "_setItemClassNm",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '${ses.companyCd}',  // 고객사코드or회사코드
                'custNm' : '${ses.companyNm}'  // 고객사코드or회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }


        function _getPtItemClsNm()  {

            var popupUrl = "/evermp/IM04/IM0403/IM04_011/view";
            var param = {
                callBackFunction : "_setPtItemClassNm",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setItemClassNm(data) {
            if(data!=null){
                data = JSON.parse(data);
                //EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
                //if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2").setValue("");}else{EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);}
                //if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3").setValue("");}else{EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);}
                //if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4").setValue("");}else{EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                //EVF.C("ITEM_CLS1").setValue("");
                //EVF.C("ITEM_CLS2").setValue("");
                //EVF.C("ITEM_CLS3").setValue("");
                //EVF.C("ITEM_CLS4").setValue("");
                EVF.C("ITEM_CLS_NM").setValue("");
            }
        }


        function _setPtItemClassNm(data) {
            if(data!=null){
                data = JSON.parse(data);
//                EVF.C("ITEM_CLS1").setValue(data.PT_ITEM_CLS1);
//                if(data.PT_ITEM_CLS2=="*"){EVF.C("ITEM_CLS2").setValue("");}else{EVF.C("ITEM_CLS2").setValue(data.PT_ITEM_CLS2);}
//                if(data.PT_ITEM_CLS3=="*"){EVF.C("ITEM_CLS3").setValue("");}else{EVF.C("ITEM_CLS3").setValue(data.PT_ITEM_CLS3);}
//                EVF.C("ITEM_CLS4").setValue("");
                EVF.C("PT_ITEM_CLS_NM").setValue(data.PT_ITEM_CLS_PATH_NM);
            } else {
//                EVF.C("ITEM_CLS1").setValue("");
//                EVF.C("ITEM_CLS2").setValue("");
//                EVF.C("ITEM_CLS3").setValue("");
//                EVF.C("ITEM_CLS4").setValue("");
                EVF.C("PT_ITEM_CLS_NM").setValue("");
            }
        }

        function ajaxCall() {
            var url = baseUrl + "/ajaxTest";
            var formData = formUtil.getFormData();
            formData['send123'] = '123';
            data.ajaxJson(url, formData, function(result) {
                //console.log(result)
                $('#spenText').text(result.msg);
            });
        }

    </script>
    <e:window id="codeSnippet" onReady="init" title="${fullScreenName}" breadCrumbs="${breadCrumb }" initData="${initData}">

        <e:title title="템플릿 관리" />
        <%--<pre><code class="agate">var store = new EVF.Store();</code></pre>--%>
        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="1" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="TMPL_NM" title="${form_TMPL_NM_N}"/>
                <e:field>
                    <e:select id="TMPL_NM" name="TMPL_NM" value="${form.TMPL_NM}" options="${tmplNmOptions}" width="${inputTextWidth}" disabled="${form_TMPL_NM_D}" readOnly="${form_TMPL_NM_RO}" required="${form_TMPL_NM_R}" placeHolder="" />
                    &nbsp;
                    <e:button id="DOWNLOAD_TMPL" onClick="getTmplDownloadPopup" label="템플릿 다운로드" />
                    <e:button id="ajaxTest" onClick="ajaxCall" label="ajax Test" />
                    <span id="spenText"></span>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="sendBill" title="${form_sendBill_N}"/>
                <e:field>
                    <e:inputText id="sendBill" name="sendBill" maxLength="${form_sendBill_M}" width="${inputTextWidth }" required="${form_sendBill_R }" readOnly="${form_sendBill_RO }" disabled="${form_sendBill_D }" />
                    &nbsp;
                    <e:button id="sendBillSearch" onClick="dosendBillSearch" label="sendBill 담당자" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="BS_CD" title="${form_BS_CD_N}"/>
                <e:field>
                    <e:search id="BS_CD" name="BS_CD" value="" width="20%" maxLength="${form_BS_CD_M}" onIconClick="getBsCd" disabled="${form_BS_CD_D}" readOnly="${form_BS_CD_RO}" required="${form_BS_CD_R}" />
                    <e:inputText id="BS_NM" name="BS_NM" value="" width="80%" maxLength="${form_BS_NM_M}" disabled="${form_BS_NM_D}" readOnly="${form_BS_NM_RO}" required="${form_BS_NM_R}"/>

                    <e:search id="BS_CD2" name="BS_CD2" value="" width="20%" maxLength="${form_BS_CD_M}" onIconClick="getGateCd" disabled="${form_BS_CD_D}" readOnly="${form_BS_CD_RO}" required="${form_BS_CD_R}" />
                </e:field>
            </e:row>
            <e:row>
                <%--조직정보 동적콤보--%>
                <e:label for="DEPT_TYPE" title="${form_DEPT_TYPE_N}" />
                <e:field>
                    <e:select id="DEPT_TYPE" name="DEPT_TYPE" data="2" onChange="getDEPT_TYPE" value="${form.DEPT_TYPE}" options="${deptTypeOptions }" width="${inputTextWidth}" disabled="${form_DEPT_TYPE_D}" readOnly="${form_DEPT_TYPE_RO}" required="${form_DEPT_TYPE_R}" placeHolder="" />
                    <e:text>&nbsp;</e:text>
                    <e:select id="DEPT_TYPE2" name="DEPT_TYPE2" data="3" onChange="getDEPT_TYPE" value="${form.DEPT_TYPE}" options="" width="${inputTextWidth}" disabled="${form_DEPT_TYPE_D}" readOnly="${form_DEPT_TYPE_RO}" required="${form_DEPT_TYPE_R}" placeHolder="" />
                    <e:text>&nbsp;</e:text>
                    <e:select id="DEPT_TYPE3" name="DEPT_TYPE3" value="${form.DEPT_TYPE}" options="" width="${inputTextWidth}" disabled="${form_DEPT_TYPE_D}" readOnly="${form_DEPT_TYPE_RO}" required="${form_DEPT_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                <e:field>
                    <e:search id="ITEM_CD" name="ITEM_CD" value="" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="getItems" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                    <e:br/>
                    <e:text>옵션: {dupItemAllow: true/false (중복허용여부), stockItemYn: 1/0 (재고여부), disabledId: 'A,B,C' (비활성화할 검색조건ID), soleItemYn: 1/0 (총판품목여부), returnType: S/M (싱글/다중 품목선택)} </e:text>
                </e:field>
            </e:row>

            <e:row>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                <e:field>
                    <e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="40%" maxLength="${form_ITEM_CLS_NM_M}" onIconClick="_getItemClsNm" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PT_ITEM_CLS_NM" title="${form_PT_ITEM_CLS_NM_N}"/>
                <e:field>
                    <e:search id="PT_ITEM_CLS_NM" name="PT_ITEM_CLS_NM" value="" width="40%" maxLength="${form_PT_ITEM_CLS_NM_M}" onIconClick="_getPtItemClsNm" disabled="${form_PT_ITEM_CLS_NM_D}" readOnly="${form_PT_ITEM_CLS_NM_RO}" required="${form_PT_ITEM_CLS_NM_R}" />
                </e:field>
            </e:row>

        </e:searchPanel>

        <e:textArea id="CONSOLE" name="CONSOLE" required="false" disabled="false" readOnly="false" maxLength="" width="100%" height="150px" placeHolder="CONSOLE" />

        <e:panel id="leftPanelB" height="225px" width="100%">
            <e:panel width="50%">
                <e:buttonBar id="buttonBar" align="right" width="100%">
                    <e:button id="TeamSearch" onClick="doTeamSearch_M" label="부서검색_멀티" />
                    <e:button id="TeamSearchS" onClick="doTeamSearch_S" label="부서검색_싱글" />
                </e:buttonBar>
            </e:panel>
            <e:panel width="50%">

            </e:panel>

            <e:gridPanel id="gridB2" name="gridB2" width="100%" height="160px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridB2.gridColData}" />
        </e:panel>

        <e:gridPanel id="gridB3" name="gridB3" width="100%" height="170px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridB3.gridColData}" />

    </e:window>
</e:ui>