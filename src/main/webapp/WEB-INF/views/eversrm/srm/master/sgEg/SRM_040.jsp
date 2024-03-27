<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = "/eversrm/srm/master/sgEg/";
    var gridEG;
    var gridSG;

    function init() {
    	gridEG = EVF.C("gridEG");
    	gridSG = EVF.C("gridSG");

        // Grid Excel Export
        gridEG.excelExportEvent({
          allCol : "${excelExport.allCol}",
          selRow : "${excelExport.selRow}",
          fileType : "${excelExport.fileType }",
          fileName : "${screenName }",
          excelOptions : {
            imgWidth      : 0.12, 		// 이미지 너비
            imgHeight     : 0.26,		    // 이미지 높이
            colWidth      : 20,        	// 컬럼의 넓이
            rowSize       : 500,       	// 엑셀 행에 높이 사이즈
            attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
          }
        });

        // Grid Excel Export
        gridSG.excelExportEvent({
          allCol : "${excelExport.allCol}",
          selRow : "${excelExport.selRow}",
          fileType : "${excelExport.fileType }",
          fileName : "${screenName }",
          excelOptions : {
            imgWidth      : 0.12, 		// 이미지 너비
            imgHeight     : 0.26,		    // 이미지 높이
            colWidth      : 20,        	// 컬럼의 넓이
            rowSize       : 500,       	// 엑셀 행에 높이 사이즈
            attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
          }
        });

    	gridEG.setProperty('shrinkToFit', true);
    	gridSG.setProperty('shrinkToFit', true);

    	gridSG.setColFooter(
        		{
        	           'merge'      : true
        			, 'groupField' :
        				[
        					'CLS01'
        					,'CLS02'
        					,'CLS03'
        					,'CLS04'
        				]
        		}
        );
    }

    function getContentTab(uu) {
        if (uu == '1') {
        	delType = 'sg'
        }
        if (uu == '2') {
        	delType = 'eg'
        }
      }

    $(document.body).ready(function() {
        $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
                {
                  activate: function(event, ui) {
                    <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                    $(window).trigger('resize');
                  }
                }
        );
        $('#e-tabs').tabs('option', 'active', 0);
        //getContentTab('1');
      });

    function chSg() {
        var store = new EVF.Store;
        var sg_type = this.getData();

        if (sg_type=='2') {
            store.setParameter('PARENT_SG_NUM',EVF.getComponent('CLS01').getValue());
            clearY('3');
            clearY('4');
        }
        if (sg_type=='3') {
            store.setParameter('PARENT_SG_NUM',EVF.getComponent('CLS02').getValue());
            clearY('4');
        }
        if (sg_type=='4') {
            store.setParameter('PARENT_SG_NUM',EVF.getComponent('CLS03').getValue());
        }
        store.load('/eversrm/srm/master/sgItemClass' + '/SRM_030/chSg', function() {
          EVF.getComponent('CLS0'+sg_type).setOptions(this.getParameter("sgData"));
        });
    }
	function clearY( cls_typef ) {
		EVF.C('CLS0'+ cls_typef ).setOptions( JSON.parse('[]')    );
	}



    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([gridEG,gridSG]);
        store.load(baseUrl + "SRM_040/doSearch", function() {
        });
    }
    var delType ='sg';

    function doDelete() {
    	var store = new EVF.Store();
		var method = '';
    	if (delType == 'sg') {
			if ((gridSG.jsonToArray(gridSG.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }
			store.setGrid([gridSG]);
			method = 'doDelete';
			store.getGridData(gridSG, 'sel');
    	}

    	if (delType == 'eg') {
			if ((gridEG.jsonToArray(gridEG.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }
			store.setGrid([gridEG]);
			method = 'doDelete';
			store.getGridData(gridEG, 'sel');
    	}


    	if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}
		store.load(baseUrl + '/SRM_030/'+method+'', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }

</script>

<e:window id="SRM_040" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearchTree">
            <e:row>
				<e:label for="CLS01" title="${form_CLS01_N}"/>
				<e:field>
				<e:select id="CLS01" onChange="chSg" data='2' name="CLS01" value="${form.CLS01}" options="${refClass1 }" width="${inputTextWidth}" disabled="${form_CLS01_D}" readOnly="${form_CLS01_RO}" required="${form_CLS01_R}" placeHolder="" />
				<e:text>&nbsp;</e:text>
				<e:select id="CLS02" onChange="chSg" data='3' name="CLS02" value="${form.CLS02}" options="" width="${inputTextWidth}" disabled="${form_CLS02_D}" readOnly="${form_CLS02_RO}" required="${form_CLS02_R}" placeHolder="" />
				<e:text>&nbsp;</e:text>
				<e:select id="CLS03" onChange="chSg" data='4' name="CLS03" value="${form.CLS03}" options="" width="${inputTextWidth}" disabled="${form_CLS03_D}" readOnly="${form_CLS03_RO}" required="${form_CLS03_R}" placeHolder="" />
				<e:text>&nbsp;</e:text>
				<e:select id="CLS04" name="CLS04" value="${form.CLS04}" options="" width="${inputTextWidth}" disabled="${form_CLS04_D}" readOnly="${form_CLS04_RO}" required="${form_CLS04_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="EG_NM" title="${form_EG_NM_N}"/>
				<e:field>
				<e:select id="EG_NM" name="EG_NM" value="${form.EG_NM}" options="${refEGName}" width="${inputTextWidth}" disabled="${form_EG_NM_D}" readOnly="${form_EG_NM_RO}" required="${form_EG_NM_R}" placeHolder="" />
				</e:field>
			</e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>

    <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
        <tr><td><div>
          <ul>
            <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">소싱그룹별</a></li>
            <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">평가분류별</a></li>
          </ul>

          <div id="ui-tabs-1">
			<div style="height: auto;">
			<e:gridPanel gridType="${_gridType}" id="gridSG" name="gridSG" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridSG.gridColData}"/>
				</div>
          </div>

          <div id="ui-tabs-2">
			<div style="height: auto;">
				<e:gridPanel gridType="${_gridType}" id="gridEG" name="gridEG" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridEG.gridColData}"/>
			</div>
          </div>
		</div></td></tr>
	</div>

</e:window>
</e:ui>