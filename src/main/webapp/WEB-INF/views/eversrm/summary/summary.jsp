<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<script type="text/javascript">
	function doSearch() {
		console.log('doSearch');
	}

	function doUpdate() {
		console.log('doUpdate');
	}

	function doDelete() {
		console.log('doDelete');
	}

	function testInit() {
		alert('init!');
	}

	function doTestButton() {
		var store = new EVF.Store();

		store.setParam('fdata', EVF.getComponents());
		store.setParam('gdata', "[{\"a\": \"a11\", \"b\": \"b11\"}, {\"a\": \"a22\", \"b\": \"b22\"}]");
		store.load('/common/sample/doSearch', function() {
            store.setFormData("formData");
            store.setGridData('gridData');
		});
	}

    function init() {

		var grid1 = {};

        var gridSelect = {
            '1': 'test1',
            '2': 'test2',
            '3': 'test3',
            '4': 'test4'
        };

        var imgData = {
            src : '/images/eversrm/buttons/btn_user.gif',
            text : ''
        };

        grid1 = new EVF.GridPanel('grid1');

        grid1.createColumn('숫자형', 50, 'left', 'number', 10, false);
        grid1.createColumn('텍스트형 컬럼', 50, 'right', 'text', 20, true);
        grid1.createColumn('선택형 컬럼', 50, 'left', 'select', 20, true, gridSelect);
        grid1.createColumn('날짜 컬럼', 50, 'left', 'date', 20, false, 'yyyy-MM-dd');
        grid1.createColumn('체크박스 컬럼', 50, 'center', 'check', 20, true);
        grid1.createColumn('이미지 컬럼', 90, 'center', 'image', 20, true, imgData);
        grid1.createColumn('imageColumn2', 90, 'center', 'image', 20, true, imgData);
        grid1.createColumn('imageColumn3', 90, 'center', 'image', 20, true, imgData);
        grid1.boundColumns();

        grid1.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
            alert('grid1 = ' + grid1.getCellValue(rowid, celname));
        });
        grid1.cellChangeEvent(function(rowid, celname, value, iRow, iCol){
            console.log(grid1.getRowValue(iRow));
            console.log('grid1 = celName : ' + celname + ', value : ' + value);
        });


    }

</script>
<e:window id="testwindow" onReady="init" initData="${initData}" title="샘플 페이지" breadCrumbs="홈">
	<e:fieldPanel id="form" fieldName="조회조건" columnCount="2">
		<e:fieldRow>
			<e:inputText label="가나다라마바사" id="form1" name="form1" width="500px" disabled="" maxLength="" readOnly="" required=""/>
			<e:inputText label="가나다라마바사" id="form2" name="form2" disabled="" maxLength="" readOnly="" required=""/>
		</e:fieldRow>
		<e:fieldRow>
			<e:inputDate label="ABCDEFG" id="form3" name="form3" disabled="" maxLength="" readOnly="" required=""/>
			<e:inputPassword label="가나다라마바사" id="form4" name="form4" disabled="" maxLength="" readOnly="" required=""/>
		</e:fieldRow>
		<e:fieldRow>
			<e:inputDate label="가나다라마바사" id="form5" name="form5" disabled="" maxLength="" readOnly="" required=""/>
			<e:inputPassword label="ABCASDFS" id="form6" name="form6" disabled="" maxLength="" readOnly="" required=""/>
		</e:fieldRow>
	</e:fieldPanel>
	<e:buttonBar align="right" width="100%">
		<e:button id="testButton" name="testButton" label="테스트" readonly="true" disabled="false" onClick="doTestButton" />
		<e:button id="testButton2" name="testButton2" label="테스트" readonly="true" disabled="false" onClick="doTestButton" />
		<e:button id="testButton3" name="testButton3" label="테스트" readonly="true" disabled="false" onClick="doTestButton" />
	</e:buttonBar>
	<e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" width="100%" height="500px" fit="true" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}" />
</e:window>