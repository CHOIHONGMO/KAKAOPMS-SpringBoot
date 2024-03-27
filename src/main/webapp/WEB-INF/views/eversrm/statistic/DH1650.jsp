<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var grid2;
    var baseUrl = "/eversrm/statistic/DH1650";
    var selRow;
	var currrow;

    function init() {
      grid = EVF.getComponent('grid');
      grid2 = EVF.getComponent('grid2');
      grid.setProperty('panelVisible', ${panelVisible});
      grid2.setProperty('panelVisible2', true);
      grid.excelExportEvent({
          allCol : "${excelExport.allCol}",
          selRow : "${excelExport.selRow}",
          fileType : "${excelExport.fileType }",
          fileName : "${screenName }",
          excelOptions : {
               imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
              ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
              ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
              ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
              ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
          }
      });



      grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {


	      if (celName == "EXEC_NUM") {
	    	  if (grid.getCellValue(rowId, "EXEC_NUM")=='' ) return;
	          var param = {
	              gateCd: '${ses.gateCd}',
	              EXEC_NUM: grid.getCellValue(rowId, "EXEC_NUM"),
	              popupFlag: true,
	              detailView: true,
					EXEC_TYPE: grid.getCellValue(rowId,'EXEC_TYPE')
	          };

	          var exec_type = grid.getCellValue(rowId,'EXEC_TYPE');

	          var screenId='';
	          if(exec_type == "G") {
	          	screenId='BFAR_020';
	  		} else if(exec_type == "C") {
	          	screenId='DH0630';
	  		} else if(exec_type == "O") {
	          	screenId='DH0600';
	  		} else if(exec_type == "S") {
	          	screenId='DH0540';
	  		} else if(exec_type == "U") {
	          	screenId='DH0550';
	  		}

	          everPopup.openPopupByScreenId(screenId, 1200, 800, param);

	  	}

      });


      grid2.excelExportEvent({
          allCol : "${excelExport.allCol}",
          selRow : "${excelExport.selRow}",
          fileType : "${excelExport.fileType }",
          fileName : "${screenName }",
          excelOptions : {
               imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
              ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
              ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
              ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
              ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
          }
      });

    }

    var tab_id = '1';
    // 조회
    function doSearch() {
      var store = new EVF.Store();
      if(!store.validate()) return;
      store.setGrid([grid,grid2]);
      store.load(baseUrl+'/doSearch', function() {

      });
    }

	function searchVendorCd() {
		var param = {
			callBackFunction : "selectVendorCd"
		};
		everPopup.openCommonPopup(param, 'SP0013');
	}

	function selectVendorCd(dataJsonArray) {
		EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
		EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
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

        if ('${param.TAP_ID}' == '2') {
            getContentTab('2');
        } else {
            getContentTab('1');
        }
	});

    function getContentTab(uu) {
		if (uu == '1') {
			window.scrollbars = true;
			$('#tab1').focus();
			var e = jQuery.Event( 'keydown', { keyCode: 13 } );
			$("#tab1").trigger(e);
		}
		if (uu == '2') {
			window.scrollbars = true;
            $('#tab2').focus();
            // 이동된 위치에서 엔터
            var e = jQuery.Event( 'keydown', { keyCode: 13 } );
            $("#tab2").trigger(e);
		}
		tab_id = uu;
	}




    function doSave() {
        if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        if(!grid.validate().flag) { return alert(grid.validate().msg); }
        if(!confirm('${msg.M0021}')) { return; }
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doSave', function() {
          alert(this.getResponseMessage());
          doSearch();
        });
      }

    </script>

  <e:window id="DH1650" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>

		<e:label for="START_DATE" title="${form_START_DATE_N}"/>
		<e:field>
		<e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
		<e:text> ~ </e:text>
		<e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${END_DATE}" width="${inputTextDate}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
		</e:field>

        <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
        <e:field>
        <e:select id="PLANT_CD" name="PLANT_CD" useMultipleSelect="true" value="${param.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
        </e:field>
        		<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
					<e:search id="VENDOR_NM" name="VENDOR_NM" value="${param.VENDOR_NM}" width="65%" maxLength="${form_VENDOR_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" style="${imeMode}"/>
					<e:text>&nbsp;</e:text>
					<e:inputText id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}" width="30%" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" style='ime-mode:inactive'/>
				</e:field>
      </e:row>


      <e:row>
		<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
		<e:field colSpan="5">
		<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="${inputTextWidth}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
		</e:field>
      </e:row>



    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
    </e:buttonBar>

            <div id="e-tabs" class="e-tabs">
                <ul>
                    <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">${form_TEXT1_N }</a></li>
                    <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">${form_TEXT2_N }</a></li>
                </ul>
                <div id="ui-tabs-1">
				    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    			</div>

                <div id="ui-tabs-2">
				    <e:gridPanel gridType="${_gridType}" id="grid2" name="grid2" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid2.gridColData}"/>
    			</div>
            </div>
  </e:window>
</e:ui>