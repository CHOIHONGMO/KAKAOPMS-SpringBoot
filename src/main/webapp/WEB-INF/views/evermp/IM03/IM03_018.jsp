
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<link rel="stylesheet" href="/css/richText.css" type="text/css"/>
    <script>

        var baseUrl = "/evermp/IM03/IM0301/";
        var gridat;

        function init() {

        }


        function doSave(){

            var params = {
                rowId: '${param.rowId}',
                'ITEM_NOTC_DESC': EVF.V('ITEM_NOTC_DESC'),
                'ITEM_NOTC_CERT': EVF.V('ITEM_NOTC_CERT'),
                'ITEM_NOTC_ORIGIN': EVF.V('ITEM_NOTC_ORIGIN'),
                'ITEM_NOTC_MAKER': EVF.V('ITEM_NOTC_MAKER'),
                'ITEM_NOTC_AS': EVF.V('ITEM_NOTC_AS')
            };


            if(${param.ModalPopup == true}){
                parent['${param.callBackFunction}'](params);
            }else{
                opener['${param.callBackFunction}'](params);
            }
            doClose();
        }


        function doClose() {
            if(${param.ModalPopup == true}){
                new EVF.ModalWindow().close(null);
            } else {
                window.close();
            }
        }
    </script>

    <e:window id="IM03_018" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:buttonBar align="right" width="100%">
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
        </e:buttonBar>
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="350px" labelAlign="${labelAlign}" columnCount="1" useTitleBar="false">
            <e:row>
                <e:label for="ITEM_NOTC_DESC" title="${form_ITEM_NOTC_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_DESC" name="ITEM_NOTC_DESC" value="${param.ITEM_NOTC_DESC}" width="${form_ITEM_NOTC_DESC_W}" maxLength="${form_ITEM_NOTC_DESC_M}" disabled="${form_ITEM_NOTC_DESC_D}" readOnly="${form_ITEM_NOTC_DESC_RO}" required="${form_ITEM_NOTC_DESC_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_CERT" title="${form_ITEM_NOTC_CERT_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_CERT" name="ITEM_NOTC_CERT" value="${param.ITEM_NOTC_CERT}" width="${form_ITEM_NOTC_CERT_W}" maxLength="${form_ITEM_NOTC_CERT_M}" disabled="${form_ITEM_NOTC_CERT_D}" readOnly="${form_ITEM_NOTC_CERT_RO}" required="${form_ITEM_NOTC_CERT_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_ORIGIN" title="${form_ITEM_NOTC_ORIGIN_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_ORIGIN" name="ITEM_NOTC_ORIGIN" value="${param.ITEM_NOTC_ORIGIN}" width="${form_ITEM_NOTC_ORIGIN_W}" maxLength="${form_ITEM_NOTC_ORIGIN_M}" disabled="${form_ITEM_NOTC_ORIGIN_D}" readOnly="${form_ITEM_NOTC_ORIGIN_RO}" required="${form_ITEM_NOTC_ORIGIN_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_MAKER" title="${form_ITEM_NOTC_MAKER_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_MAKER" name="ITEM_NOTC_MAKER" value="${param.ITEM_NOTC_MAKER}" width="${form_ITEM_NOTC_MAKER_W}" maxLength="${form_ITEM_NOTC_MAKER_M}" disabled="${form_ITEM_NOTC_MAKER_D}" readOnly="${form_ITEM_NOTC_MAKER_RO}" required="${form_ITEM_NOTC_MAKER_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_AS" title="${form_ITEM_NOTC_AS_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_AS" name="ITEM_NOTC_AS" value="${param.ITEM_NOTC_AS eq '' ? IM03_018_015 : param.ITEM_NOTC_AS }" width="${form_ITEM_NOTC_AS_W}" maxLength="${form_ITEM_NOTC_AS_M}" disabled="${form_ITEM_NOTC_AS_D}" readOnly="${form_ITEM_NOTC_AS_RO}" required="${form_ITEM_NOTC_AS_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
    </e:window>
</e:ui>