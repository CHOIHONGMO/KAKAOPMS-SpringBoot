<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var baseUrl = "/eversrm/system/batch/batchLog";

	function init() {

    }

    function doExecute() {

        var store = new EVF.Store();
        if(!store.validate()) return;

    	if (!confirm("${msg.M8888 }")) return;

    	store.load(baseUrl + '/doExecute', function(){
    		alert(this.getResponseMessage());
    	});
    }

    </script>

	<e:window id="batchLog" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false">
			<e:row>
				<e:label for="EXEC_CD" title="${form_EXEC_CD_N}" />
				<e:field colSpan="5">
					<e:select id="EXEC_CD" name="EXEC_CD" value="" options="${refExecCd }" width="${form_EXEC_CD_W}" disabled="${form_EXEC_CD_D}" readOnly="${form_EXEC_CD_RO}" required="${form_EXEC_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doExecute" name="doExecute" label="${doExecute_N}" onClick="doExecute" disabled="${doExecute_D}" visible="${doExecute_V}" />
		</e:buttonBar>

	</e:window>
</e:ui>
