<%--
  Created by IntelliJ IDEA.
  User: azure
  Date: 2015-10-12
  Time: 오후 5:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype>
<script>
    function createController() {
        var url = "/generator/source/createController";
        $.post( url, $('#form').serialize(), "", "json" );
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>
    <meta charset="utf-8"/>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="Content-Script-Type" content="text/javascript"/>
    <meta http-equiv="Content-Style-Type" content="text/css"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    
    <link rel="stylesheet" href="/css/everuxf/kakao/everuxf.min.css"/>
    
    <script src="/js/everuxf/everuxf.min.js"></script>
    <script src="/js/everuxf/lic/licenseKey.js"></script>
    <script src="/js/everuxf/lib/tinymce/tiny_mce.js"></script>
    <script src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>
    <script src="/js/everuxf/lib/dynaTree/jquery.dynatree.min.js"></script>
    <script src="/js/everuxf/lib/plupload/moxie.min.js"></script>
    <script src="/js/everuxf/lib/plupload/plupload.full.min.js"></script>
    <script src="/js/everuxf/lib/plupload/jquery.ui.plupload/jquery.ui.plupload.min.js"></script>
    <script src="/js/everuxf/lib/plupload/i18n/ko.js"></script>
    <script src="/js/ever-event.js"></script>
    <script src="/js/ever-popup.js"></script>
    <script src="/js/ever-string.js"></script>
    <script src="/js/ever-date.js"></script>
    <script src="/js/ever-formutils.js"></script>
    <script src="/js/ever-common.js"></script>
    <script src="/js/ever-alarm.js"></script>
    <script src="/js/ever-dwr.js"></script>
    <script src="/js/ever-math.js"></script>
    <script src="/js/ever-valid.js"></script>

    <style type="text/css">
        pre {
            font-size: 8px;
            font-family: Consolas, Inconsolata, Monaco, "Courier New";
        }

        .code {
            font-size: 8px;
            font-family: Consolas, Inconsolata, Monaco, "Courier New";
            width: 100%;
            height: 300px;
            -ms-text-overflow: ellipsis;
            text-overflow: ellipsis;
            overflow: auto;
        }
    </style>

</head>
<form id="form" name="form">
<body>

<fieldset>
    <legend>JSP 기본 소스</legend>
    <div>
        <textarea class="code" style="overflow-y: scroll;">
&lt;%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
&lt;%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
&lt;%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

&lt;e:ui>
    &lt;script type="text/javascript">

    var baseUrl = '/';
    var grid;
	
    function init() {
    	
        grid = EVF.C('grid');
        
        grid.setProperty('shrinkToFit', true); 					// 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
	    grid.setProperty('rowNumbers', ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
	    grid.setProperty('sortable', ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
	    grid.setProperty('panelVisible', ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
	    grid.setProperty('enterToNextRow', ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
	    grid.setProperty('acceptZero', ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
	    grid.setProperty('multiSelect', ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]
		
    }
	
    function doSearch() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                alert("\${msg.M0002 }");
            }
        }
    }

    function doSave() {

        if(!grid.isExistsSelRow()) { return alert('\${msg.M0004}'); }
        if(!grid.validate().flag) { return alert("\${msg.M0014}"); }

        var gridData = grid.getSelRowValue();
        for(var idx in gridData) {
            var rowData = gridData[idx];
            if(!rowData['PO_NUM']) {
                return alert('로직을 구현할 게 없으면 이 부분을 삭제바랍니다.');
            }
        }

        var store = new EVF.Store();
        if(!store.validate()) { return; }
        if(!confirm('\${msg.M0021}')) { return; }

        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doSave', function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    function doDelete() {

        if(!grid.isExistsSelRow()) { return alert('\${msg.M0004}'); }
        if(!confirm('\${msg.M0013}')) { return; }

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doDelete', function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }
}

    &lt;/script>
&lt;e:window id="${param.screenId}" onReady="init" initData="${initData}" title="\${screenName }" breadCrumbs="\${breadCrumb }">
    &lt;e:searchPanel id="form" title="\${msg.M9999}" columnCount="3" labelWidth="\${labelWidth}" onEnter="doSearch">
    &lt;e:row>
<c:forEach var="formData" items="${formData}" varStatus="sts"><c:if test="${formData.MULTI_TYPE == 'F'}">${formData.TAG_GUIDE}</c:if><c:if test="${formData.MULTI_TYPE == 'F' and (sts.index+1) % 3 == 0}">
    &lt;/e:row>
    &lt;e:row></c:if></c:forEach>
    &lt;/e:row>
    &lt;/e:searchPanel>

    &lt;e:buttonBar align="right">
    <c:forEach var="buttonData" items="${buttonData}" varStatus="sts">${buttonData.BUTTON_TAG}</c:forEach>
    &lt;/e:buttonBar>

    <c:if test="${not empty gridId}">&lt;e:gridPanel id="${gridId}" name="${gridId}" width="100%" height="fit" /></c:if>

&lt;/e:window>
&lt;/e:ui>
        </textarea>
    </div>
</fieldset>

<fieldset>
    <legend>그리드 이벤트</legend>
    <div>
        <textarea class="code" style="overflow-y: scroll;">
    // Grid 클릭 이벤트
    grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
        if(colId == '') {

        }
    });
	
	// Grid 변경 이벤트
    grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
        switch(colId) {
        	case '':
				
        	default:
    });
	
	// 행추가
    grid.addRowEvent(function () {
        grid.addRow();
    });
	
	// 행삭제
    grid.delRowEvent(function () {
        grid.delRow();
    });

    grid.excelExportEvent({
        allItems : "${excelExport.allCol}",
        fileName : "${screenName}"
    });

        </textarea>
    </div>
</fieldset>

<input type="text" id="createFolder" name="createFolder" placeholder="C:\ST-OnesIDE\workspace\KAKAO\src\main\java\com\st_ones\evermp\OD01\" style="width: 100%;"/>
<input type="text" id="fileName" name="fileName" placeholder="DH0000" />
<input type="button" value="파일 생성" onclick="createController()"/>
</body>
</form>
</html>



