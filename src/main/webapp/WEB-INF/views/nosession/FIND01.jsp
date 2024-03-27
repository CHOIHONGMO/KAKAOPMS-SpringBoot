<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript" src="/js/ever-popup.js"></script>
    <script type="text/javascript" src="/js/ever-string.js"></script>
    <script type="text/javascript" src="/js/ever-cookie.js"></script>
    <script type="text/javascript">
    	var baseUrl = "/";
		function init() {

        }

		function doLogin() {
	            var store = new EVF.Store();
	            if(!store.validate()) { return;}
   	            store.load(baseUrl + "tmsLogin", function () {
   	            	var result = this.getResponseMessage();
//   	            	alert('====result='+result);
					if(result!='' && result!=null) {
						if(EVF.C("radio1").isChecked() == true) {
				            var params = {
				            		 TXTNO : EVF.C("TXTNO").getValue()
				            		,TXTUSEREMAIL : EVF.C("TXTUSEREMAIL").getValue()
				            		,SEQ : EVF.C("SEQ").getValue()
				            };
				            everPopup.openWindowPopup('/nosession/POLIST01/view', 1000, 780, params, '발주내역(협력사)');
						} else {
				            var params = {
				            		 TXTNO : EVF.C("TXTNO").getValue()
				            		,TXTUSEREMAIL : EVF.C("TXTUSEREMAIL").getValue()
				            		,SEQ : EVF.C("SEQ").getValue()
				            		,PO_GUBUN : result
				            };
				            everPopup.openWindowPopup('/nosession/POLIST02/view', 1000, 780, params, '발주내역(관리자)');
						}
						doClose();
					} else {
						return EVF.alert('사용자 인증에 실패했습니다.');
					}
   	            });
		}

		function doClose() {
			window.close();
		}

		function chkGoS() {
			EVF.C("TXTUSEREMAIL").setValue('');
			EVF.C("TXTUSEREMAIL").setDisabled(false);
			EVF.C("TXTUSEREMAIL").setRequired(true);
		}
		function chkGoC() {
			EVF.C("TXTUSEREMAIL").setValue('');
			EVF.C("TXTUSEREMAIL").setDisabled(true);
			EVF.C("TXTUSEREMAIL").setRequired(false);
		}

    </script>
    <e:window id="FIND01" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="1" labelWidth="${labelWidth }" onEnter="doSearch" useTitleBar="false">
        	<e:row>
				<e:label for="COM_FLAG" title="${form_COM_FLAG_N}" />
				<e:field>
                <e:radio id="radio1" name="radio" label="${form_RADIO1_N }" required="${form_RADIO1_R }" readOnly="${form_RADIO1_RO }" onClick="chkGoS" value="S" checked="true"/> <e:text>협력사</e:text>
                <e:radio id="radio2" name="radio" label="${form_RADIO1_N }" required="${form_RADIO1_R }" readOnly="${form_RADIO1_RO }" onClick="chkGoC" value="C"/> <e:text>관리자</e:text>
				</e:field>
            </e:row>
        	<e:row>
				<e:label for="TXTNO" title="${form_TXTNO_N}" />
				<e:field>
				<e:inputText id="TXTNO" name="TXTNO" value="" width="${form_TXTNO_W}" maxLength="${form_TXTNO_M}" disabled="${form_TXTNO_D}" readOnly="${form_TXTNO_RO}" required="${form_TXTNO_R}" />
				</e:field>
            </e:row>
        	<e:row>
				<e:label for="TXTUSEREMAIL" title="${form_TXTUSEREMAIL_N}" />
				<e:field>
				<e:inputText id="TXTUSEREMAIL" name="TXTUSEREMAIL" value="" width="${form_TXTUSEREMAIL_W}" maxLength="${form_TXTUSEREMAIL_M}" disabled="${form_TXTUSEREMAIL_D}" readOnly="${form_TXTUSEREMAIL_RO}" required="${form_TXTUSEREMAIL_R}" />
				</e:field>
            </e:row>
        	<e:row>
				<e:label for="SEQ" title="${form_SEQ_N}" />
				<e:field>
				<e:inputPassword id="SEQ" name="SEQ" value="" width="${form_SEQ_W}" maxLength="${form_SEQ_M}" disabled="${form_SEQ_D}" readOnly="${form_SEQ_RO}" required="${form_SEQ_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doLogin" name="doLogin" label="${doLogin_N}" onClick="doLogin" disabled="${doLogin_D}" visible="${doLogin_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>
    </e:window>
</e:ui>