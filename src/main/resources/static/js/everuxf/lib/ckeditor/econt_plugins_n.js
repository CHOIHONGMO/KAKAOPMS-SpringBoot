(function () {
    var pluginNm = 'econtInfo'
        , econtClassNm = 'econtRichCombo'
        , econtInfo = {
        'defaultInfo': {
            'text': '일반정보'
            , 'value': {
                "xxxxx_01": "----------일  반-----------"
                , "changeVal_00": "단문 입력"
                , "changeVal_99": "숫자 입력"
                , "changeTxt_00": "장문 입력"
                , "changeVal_01": "자유수정(표 붙여넣기)"
                // , "changeVal_61": "서명완료문구"
                , "xxxxx_02": "------계약기본정보------"
                , "CONT_NUM": "계약번호"
                , "CONT_DESC": "계약명"
                , "CONT_DATE": "계약일자"
                , "CONT_START_DATE": "계약시작일자"
                , "CONT_END_DATE": "계약종료일자"
//                , "CONT_GUAR_AMT": "계약보증금액"
//                , "HAJA_GUAR_AMT": "하자보증금액"
//                , "DELAY": "지체상금률"
                , "CONT_AMT": "계약금액"
                , "CONT_AMT_KR": "계약금액(한글)"
                , "SUPPLY_AMT": "공급금액"
                , "SUPPLY_AMT_KR": "공급금액(한글)"
                , "VAT_AMT": "VAT금액"
                , "VAT_AMT_KR": "VAT금액(한글)"
                , "VAT_TYPE_KR": "부가세유형(한글)"

//                , "CONT_GUAR_PERCENT": "계약보증요율"
//                , "HAJA_GUAR_PERCENT": "하자보증요율"
                , "DUE_DATE": "납품요청일"
                //, "PAYMENT_INFO_TABLE": "분할대금지불내용"
                //, "xxxxx_03": "---계약담당자정보--"
                //, "CONT_USER_DEPT_NM": "계약담당자부서"
                //, "changeVal_09": "계약담당자직위"
                //, "CONT_USER_NM": "계약담당자성명"
                //, "CONT_USER_TEL_NUM": "계약담당자전화"
                //, "xxxxx_04": "---계약금액세부정보--"
                //, "changeVal_18": "공급가액"
                //, "changeVal_19": "부가세액"
                //, "xxxxx_05": "---대금지불정보--"
                //, "changeVal_16": "대금지급조건"
                //, "changeVal_41": "선급금율"
                //, "changeVal_43": "중도금율"
                //, "changeVal_45": "잔금율"
                //, "changeVal_start_deposit": "선급금"
                //, "changeVal_middle_deposit": "중도금"
                //, "changeVal_remain_deposit": "잔금"
                //, "changeVal_46": "납품검수방법"
                //, "changeVal_17": "지체상금율"
                //, "xxxxx_06": "---보증정보--"
                //, "changeVal_48": "하자보수시작일자"
                //, "changeVal_49": "하자보수종료일자"
                //, "WARR_GUAR_QT": "하자보수기간"
                //, "CONT_GUAR_PERCENT": "계약이행보증율"
                //, "WARR_GUAR_PERCENT": "하자이행보증율"
                //, "ADV_GUAR_PERCENT": "선급이행보증율"
            }
        }
        , 'supplyInfo': {
            'text': '협력사'
            , 'value': {
                "VENDOR_NM": "협력사상호"
                , "VENDOR_ADDR": "협력사주소"
                , "VENDOR_CEO_NM": "협력사대표자"
                , "VENDOR_TEL_NUM": "협력사전화번호"
                , "VENDOR_IRS_NUM": "협력사사업자번호"
                , "COMPANY_REG_NO" : "협력사법인번호"
                , "VENDOR_CD": "협력사코드"
                , "BANK_NM": "은행"
                , "ACCOUNT_NUM": "계좌번호"
                , "DEPOSITOR_NM": "예금주"
            }
        }
        , 'buyerInfo': {
            'text': '구매사'
            , 'value': {
                "BUYER_NM": "구매사상호"
                , "BUYER_ADDR": "구매사주소"
                , "BUYER_CEO_NM": "구매사대표자"
                , "BUYER_TEL_NUM": "구매사전화번호"
                , "BUYER_IRS_NUM": "구매사사업자번호"
                , "BUYER_VENDOR_CD": "구매사코드"
                //, "BUYER_SIGN_DATE": "구매사서명일시"
                //, "BUYER_SIGN_IMAGE": "구매사서명이미지"
//                , "BUYER_NMS": "구매사상호(다중)"
            }
        }
    };

    function econtRichCombo(editor, infoObjs) {
        var config = editor.config
            , lang = editor.lang.format;

        for (var infoObjKey in infoObjs) {
            (function (paramInfoObj, paramInfoObjList) {
                var classNm = econtClassNm + '_' + infoObjKey;
                editor.ui.addRichCombo(infoObjKey, {
                    label: paramInfoObj.text
                    , title: paramInfoObj.text
                    , className: classNm
                    , multiSelect: false
                    , panel: {
                        css: [config.contentsCss, CKEDITOR.getUrl(editor.skinPath + 'editor.css')]
                    }
                    , init: function () {
                        for (var key in paramInfoObjList) {
                            this.add(key, paramInfoObjList[key], paramInfoObjList[key]);
                        }
                    }
                    , onClick: function (value) {
                        var valSplit = value.split('_');

                        if (valSplit[0] == 'xxxxx') {
                            return;
                        } else {
                            editor.focus();
                            editor.fire('saveSnapshot');
                            editor.insertHtml(getComponentHtml(value, paramInfoObjList[value]));
                            editor.fire('saveSnapshot');
                        }
                    }
                    , onOpen: function () {
                        var width = '800px'
                            , height = '150px';

                        // $('.cke_combopanel').css('width', '300px');
                    }
                });
            })(infoObjs[infoObjKey], infoObjs[infoObjKey].value);
        }
    }

    function getComponentHtml(val, name) {

        var inputStr;
        if (val == "changeVal_00") { //입력
            inputStr = "<input type='text' value='' name='" + val + "'>";
        } else if (val == "changeVal_01") { //자유롭게 수정가능한 공간 지정
            inputStr = "<div contenteditable='true' class='contentEditable'></div>";
        } else if (val == "changeVal_99") { //숫자
            inputStr = "<input type='text' value='' name='" + val + "'>";
        } else if (val == "CONT_DATE") { //계약일
            inputStr = "<input type='text' style='width:100px' value='계약일' name='" + val + "'>";
        } else if (val == "CONT_START_DATE") { //계약시작일
            inputStr = "<input type='text' style='width:100px' value='계약시작일' name='" + val + "'>";
        } else if (val == "CONT_END_DATE") { //계약종료일
            inputStr = "<input type='text' style='width:100px' value='계약종료일' name='" + val + "'>";
        } else if (val == "changeVal_15") { //납기일
            inputStr = "<input type='text' style='width:100px' value='납기일' name='" + val + "'>";
        } else if (val == "changeVal_16") { //대금지급조건
            inputStr = "<input type='text' value='대금지급조건' name='" + val + "'>";
        } else if (val == "changeVal_46") { //납품(검수)조건
            inputStr = "<input type='text' value='납품검수방법' name='" + val + "'>";
        } else if (val == "changeVal_47") { //지체상금율
            inputStr = "<input type='text' value='지체상금율' name='" + val + "'>";
        } else if (val == "changeVal_51") { //계약보증금
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "changeVal_57") { //선급보증금
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "changeVal_59") { //하자보증금
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "CONT_GUAR_PERCENT") { //계약보증율
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "ADV_GUAR_PERCENT") { //선급보증율
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "WARR_GUAR_PERCENT") { //하자보증율
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "changeVal_start_deposit") { //선급금
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "changeVal_middle_deposit") { //중도금
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "changeVal_remain_deposit") { //잔금
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "changeVal_48") { //하자시작일
            inputStr = "<input type='text' style='width:100px; value='하자시작일' name='" + val + "'>";
        } else if (val == "changeVal_49") { //하자종료일
            inputStr = "<input type='text' style='width:100px; value='하자종료일' name='" + val + "'>";
        } else if (val == "WARR_GUAR_QT") { //하자보수기간
            inputStr = "<input type='text' style='width:100px; value='하자기간' name='" + val + "'>";
        } else if (val == "changeTxt_00") {
            inputStr = "<textarea type='text' rows=2 cols=100%  name='" + val + "'></textarea>";
        } else if (val == "changeTxt_01") {
            inputStr = "<textarea type='text' rows=2 cols=100%  name='" + val + "'>== 품목내역==</textarea>";
        } else if (val == "changeTxt_02") {
            inputStr = "<textarea type='text' rows=2 cols=20  name='" + val + "'>== 첨부서류==</textarea>";
        } else if (val == "VENDOR_SIGN_DATE" || val == "BUYER_SIGN_DATE") {
            inputStr = "<input type='text' name=" + val + " value=" + name + ">";
        } else if (val == "pageBreak_00") {
            inputStr = '<div class="pageBreak_00" style="font-size: 16px; page-break-before: always; width : 100%; text-align : center;"> ==================== 페이지 분할 영역 ==================== </div>';
        } else if (val == "BUYER_SIGN_IMAGE" || val == "VENDOR_SIGN_IMAGE") {
            inputStr = '<img name="' + val + '" alt="" src="/images/Signimg_befor.gif" title="' + name + '">';
        } else if (val == "PAYMENT_INFO_TABLE") {
            inputStr = '###PAYMENT_INFO_TABLE###';
        } else if (val == "CONT_GUAR_AMT") {
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "HAJA_GUAR_AMT") {
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "DELAY") {
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "CONT_GUAR_PERCENT") {
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "HAJA_GUAR_PERCENT") {
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else if (val == "DUE_DATE") {
            inputStr = "<input type='text' value='" + name + "' name='" + val + "'>";
        } else {
            var selectedValueStr = name;
            if (val == "CONT_AMT" || val == "CONT_DESC" || val == "CONT_AMT_KR" || val == "VENDOR_") {
                inputStr = "<input type='text' name='" + val + "' value='" + selectedValueStr + "'>";
            } else {
                inputStr = "<input type='text' name='" + val + "' value='" + selectedValueStr + "'>";
            }
        }

        return inputStr;
    }


    CKEDITOR.plugins.add(pluginNm, {
        'requires': ['richcombo']
        , 'init': function (editor) {
            econtRichCombo(editor, econtInfo);
        }
    });
})();