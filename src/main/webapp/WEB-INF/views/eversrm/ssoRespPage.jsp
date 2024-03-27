<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%--<c:set var="returnParam" value="<%=returnParam%>" />--%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
		function init() {
			var param = JSON.parse(window.atob('${returnParam}'));

            var store = new EVF.Store();
            store.setParameter('SCREEN_ID', param.screenId);
            store.load('/common/menu/getScreenInfo', function() {
                var url = this.getParameter('SCREEN_URL');

                if(url.indexOf('?') === -1){
                    url = url + '?';
                }

                everPopup.openWindowPopup(url, 700, 600, param, '_self', true);
            });
		}
	</script>
	<e:window id="ssoRespPage" onReady="init" initData="${initData}" title="" breadCrumbs="${breadCrumb }" >

	</e:window>
</e:ui>