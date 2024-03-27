<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script src='/js/everuxf/lib/date-ko-KR.js'>
	
	</script>
	<script>
    function init() {
        frameWindow.location.href='/eversrm/board/notice/BBON_010/view.so?NOTICE_NUM=${param.NOTICE_NUM}&detailView=true&popupFlag=true';
    }

    function close2() {
    	new EVF.ModalWindow().close(null);
    }

    function Confirm() {
        var days = EVF.C('selectDays').getValue();
        if (everString.isEmpty(days)) {
             alert('${BSN_031_CHOOSE_DAYS}');
            return;
        }
        var cookieKey = 'screenNoticeDelayUntil${param.NOTICE_NUM}';
        	console.log('set cookieKey: ' + cookieKey);$.cookie(cookieKey, new Date().addDays(Number(days)).getTime(), {
            expires: 32,
            path: '/'
        });
        close2();
    }
	</script>

	<e:window id="window" onReady="init" initData="${initData}">
		<iframe id="frameWindow"  name="frameWindow"   frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" width="100%" height="540" src=""></iframe>
		<e:row>
			<e:text>&nbsp;&nbsp;■&nbsp;${BSN_031_COMBO_MSG_PREFIX}&nbsp;</e:text>
			<e:select width="80" id="selectDays" name="selectDays"  readOnly="false" disabled="false" required="false" placeHolder="" >
					<e:option text="1" value="1" />
					<e:option text="7" value="7" />
					<e:option text="31" value="31" />
					<e:option text="Never" value="9999" />
			</e:select>
			<e:text>&nbsp;${BSN_031_COMBO_MSG_POSTFIX}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
			<e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="Confirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="close2" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:row>

	</e:window>
</e:ui>
