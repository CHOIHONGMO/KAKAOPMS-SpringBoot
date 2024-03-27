<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var baseUrl = "/eversrm/master/catalog/BPR_040/";
    var gridTree;
    var grid;
    var prevInfo = {'rowid' : '', 'cellNm' : ''};

    function init() {
        gridTree = EVF.C("gridTree");

        // Tree Grid를 사용하기 위한 메소드.
        gridTree.setTreeGrid('TEXT');

        grid = EVF.C('grid');
        grid.setProperty('multiselect', false);

        gridTree.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
        	/*
        	* 트리 노드 클릭 시 bold 스타일 적용 하는 코드.
        	*/
			if( !gridTree.isEmpty( treeInfo ) ) {
				if( prevInfo.rowid == '' ) {
					prevInfo.rowid = rowid;
					prevInfo.cellNm = celname;
				} else if( prevInfo.rowid != rowid ) {
					gridTree.setCellFontWeight(prevInfo.rowid, prevInfo.cellNm, false);
				} else ;

				gridTree.setCellFontWeight(rowid, celname, true);
				prevInfo.rowid = rowid;
				prevInfo.cellNm = celname;
			}

        	if( celname == 'TEXT' ) {
        		EVF.C('text1').setValue( gridTree.getCellValue(rowid, celname));
        		EVF.C('text2').setValue( gridTree.getCellValue(rowid, 'VALUE'));
        	}
		});

        doSearchTree();
    }

    function doSearchTree() {
        var store = new EVF.Store();
        store.setGrid([gridTree]);
        store.load(baseUrl + "doSearchTree", function() {});
    }

    function doSend() {
    	var gridDatas = gridTree.getAllRowValue()
    		, sendData = []
    		, chkFlag = true;

    	for( var i = 0, len = gridDatas.length; i < len; i++ ) {
     		if( gridDatas[i].CHECK == 1 ) {
     			chkFlag = false;
     			delete gridDatas[i]['CHECK'];
    			sendData.push( gridDatas[i] );
    		}
    	}

    	if( chkFlag ) { alert('선택된 행이 없습니다.'); return; }

        var store = new EVF.Store();
        store.setParameter('grid', JSON.stringify(sendData) );
        store.setGrid([grid]);
        store.load("/common/sample/gridTree/copy", function() {}); // SampleController.java
    }
</script>

</br>&nbsp;&nbsp;트리 그리드를 이용하게 되면 아래 컬럼들이 자동으로 생성된다.</br>
&nbsp;&nbsp;&nbsp;&nbsp;STONES_GRID_LV : 노드 레벨 지정. ( 정수 )</br>
&nbsp;&nbsp;&nbsp;&nbsp;STONES_GRID_PAR : 부모노트 지정. ( 행 ID )</br>
&nbsp;&nbsp;&nbsp;&nbsp;STONES_GRID_ISLEAF : 리프 여부 ( true / false )</br>
&nbsp;&nbsp;&nbsp;&nbsp;STONES_GRID_EXP : 자동 expanded ( true / false)</br>
&nbsp;&nbsp;서버에서 조회시 위 4개의 컬럼에 데이터를 설정해줘야 한다.</br></br>

<e:window id="GRID_TREE" onReady="init" initData="${initData}" title="${fullScreenName}">

	<e:panel id="leftPanel" height="fit" width="29%">
		<e:gridPanel gridType="${_gridType}" id="gridTree" name="gridTree" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridTree.gridColData}"/>
	</e:panel>

	<e:panel id="rightPanel" height="fit" width="71%">
		<e:searchPanel id="form" title="gridTree" labelWidth="30%" labelAlign="center" columnCount="2">
			<e:row>
				<e:label for="text1" title="클릭한 트리 노드 텍스트"/>
				<e:field>
					<e:inputText disabled="false" maxLength="100" required="false" id="text1" readOnly="true" name="text1" width="100%"/>
				</e:field>

				<e:label for="text2" title="클릭한 트리 노드 값"/>
				<e:field>
					<e:inputText disabled="false" maxLength="100" required="false" id="text2" readOnly="true" name="text2" width="100%"/>
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar>
			<e:button align="right" label='선택된 데이터 서버로 전송' id='doSend' onClick='doSend' disabled='false' visible='true' data='' />
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:panel>
</e:window>
</e:ui>