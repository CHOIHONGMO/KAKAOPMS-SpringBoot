<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
    var baseUrl = "/eversrm/main/MSI_040/";

    function init() {
		window.resizeTo(850, 500);
    }

    function doRequestUserID() {
        document.location.href = "/eversrm/main/MSI_050/view";

    }

    function doClose() {
        if (opener) {
            window.close();
        }
    }
    </script>
    <e:window id="MSI_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    	<e:title title="${MSI_040_CAPTION_LINE1}"></e:title>
        <e:searchPanel id="form" title="${MSI_040_CAPTION_LINE2}" onEnter="doSearch" columnCount="1" labelWidth="100%">
        <row>
        	    <e:field>
	                    <e:text>${MSI_040_LINE1}</e:text><e:br/>
		                <e:text>&nbsp;&nbsp;&nbsp;${MSI_040_LINE2}</e:text>
						<e:button id="doDownloadManual" name="doDownloadManual" label="${doDownloadManual_N}"  onClick="doDownloadManual" disabled="${doDownloadManual_D}" visible="${doDownloadManual_V}"/>
	                    <e:text>${MSI_040_LINE3}</e:text><e:br/>
	                    <e:text>${MSI_040_LINE5}</e:text><e:br/>
	                    <e:text>&nbsp;&nbsp;&nbsp;${MSI_040_LINE6}</e:text><e:br/>
	                    <e:text>&nbsp;&nbsp;&nbsp;${MSI_040_LINE7}</e:text><e:br/>
	                    <e:text>${MSI_040_LINE8}</e:text><e:br/>
	                    <e:text>&nbsp;&nbsp;&nbsp;${MSI_040_LINE9}</e:text><e:br/>
	                    <e:text>${MSI_040_LINE10}</e:text><e:br/>
	                    <e:text>&nbsp;&nbsp;&nbsp;${MSI_040_LINE11}</e:text>
	            </e:field>
	     </row>

        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="center" width="100%">
                 <e:button id="doRequestUserID" name="doRequestUserID" label="${doRequestUserID_N}" onClick="doRequestUserID" disabled="${doRequestUserID_D}" visible="${doRequestUserID_V}"/>
                 <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>
    </e:window>
    </e:ui>