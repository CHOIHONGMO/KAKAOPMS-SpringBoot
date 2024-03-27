<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    if ('${param.callback}' === '') {
        alert('You must set callbackFuntion Name!!');
    }

    function init() {

        if ('${param.uuid}' !== '') {
			EVF.C("UUID").setValue('${param.uuid}');
	    	EVF.C('attFile').getUploadedFileInfo('${param.bizType}', '${param.uuid}');
	    } else {
        	EVF.C('attFile').getUploadedFileInfo('${param.bizType}', '');
	    }

        if (${param.detailView} === true;) {
            EVF.C('attFileUpload').setVisible(false);
            EVF.C('OnSave').setVisible(false);

        	EVF.C('attFile').setReadOnly(${param.detailView});
        }
    }

	function fileUpload() {

		var store = new EVF.Store();
		store.doFileUpload(function() {
			var attaUuid = EVF.C('attFile').getFileId();

			if( attaUuid != '' ) {
				EVF.C('UUID').setValue( attaUuid );
			}
		});

	}

	function onSave() {

		var resp = {
			UUID : EVF.C('UUID').getValue(),
			FILE_COUNT : EVF.C('attFile').getFileCount()
		};

		var nRow  = '${param.nRow}';
		if (nRow !== '') {
			resp.nRow = Number(nRow);
            resp.rowId = Number(nRow);
        }

        opener['${param.callback}'](JSON.stringify(resp));
	    onClose();
	}

    function onClose() {
		window.close();
    }

    </script>

    <e:window id="fileAttach" onReady="init" initData="${initData}" title="첨부파일" breadCrumbs="${breadCrumb }">

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="attFileUpload" onClick="fileUpload" label="파일업로드"/>
            <e:button id="OnSave"  name="OnSave"   label="저장" disabled="${onSave_D }"  onClick="onSave" />
            <e:button id="onClose" name="onClose" label="닫기" disabled="${onClose_D }" onClick="onClose" />
        </e:buttonBar>

		<e:searchPanel id="form" title="파일첨부" labelWidth="${labelWidth}" width="80%" columnCount="2">
    		<row>
                <e:field colSpan="4">
                    <e:fileManager id="attFile" name="attFile" downloadable="true" bizType="${param.bizType}" height="100%" readOnly="true" onSuccess="onSuccess" required="${form_ATT_FILE_NUM_R}"/>
               </e:field>
			</row>
		</e:searchPanel>

	    <e:inputHidden id="UUID" name="UUID"/>

    </e:window>
</e:ui>