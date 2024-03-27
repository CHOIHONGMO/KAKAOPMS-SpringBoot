<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-05-18
  Time: 오후 1:44
  Scrren ID : DH0560(신용평가I/F현황)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script src="/js/nicednb/aes.js"></script>
  <script src="/js/nicednb/AesUtil.js"></script>
  <script src="/js/nicednb/pbkdf2.js"></script>
  <script>

    var grid;
    var baseUrl = "/eversrm/master/bom/DH0560";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
     // grid.setProperty("shrinkToFit", true);
	grid.setProperty('panelVisible', ${panelVisible});
      // Grid Excel Event
      grid.excelExportEvent({
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

      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
    	  if (celname.indexOf('_SAYU') > -1) {
				if (grid.getCellValue(rowid,celname) != '') {
					var url = baseUrl + "BBM_090/view.wu";
					var param = {
						ITEM_CD: grid.getCellValue(rowid, "ITEM_CD"),
						ITEM_DESC: grid.getCellValue(rowid, "ITEM_DESC"),
						popupFlag: true,
						detailView : true
					};
					everPopup.openPopupByScreenId('BBM_090', 900, 600, param);
				}
    	  }




      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});
      setColNameCh(EVF.getComponent("FROM_DATE").getValue())

    }

    // 조회
    function doSearch() {
        // 품번/차종 필수입력
        if(EVF.getComponent('ITEM_CD').getValue() == '' && EVF.getComponent('MAT_CD').getValue() == '') {
            alert("${DH0560_003}"); // 품번/차종 중 하나는 필수입력 입니다.

            var ids = {
                '품번': 'ITEM_CD',
                '차종': 'MAT_CD'
            };

            formUtil.animateFor(ids, 'form');

            return;
        }

        var store = new EVF.Store();

        // form validation Check
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl+'/doSearch', function() {
            if(grid.getRowCount() == 0) {
              return alert('${msg.M0002}');
            }
        });
    }
    function searchITEM_CD() {
        var param = {
          callBackFunction: 'selectItemCd'
        };
        everPopup.openCommonPopup(param, 'SP0018');
      }

      function selectItemCd(data) {
        EVF.getComponent('ITEM_CD').setValue(data.ITEM_CD);
        EVF.getComponent('ITEM_NM').setValue(data.ITEM_DESC);
      }

      function setColNameCh(yyyymm) {

          grid.setColName('PRICE1',  fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 0));
          grid.setColName('PRICE2',  fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 1));
          grid.setColName('PRICE3',  fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 2));
          grid.setColName('PRICE4',  fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 3));
          grid.setColName('PRICE5',  fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 4));
          grid.setColName('PRICE6',  fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 5));
          grid.setColName('PRICE7',  fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 6));
          grid.setColName('PRICE8',  fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 7));
          grid.setColName('PRICE9',  fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 8));
          grid.setColName('PRICE10', fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 9));
          grid.setColName('PRICE11', fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 10));
          grid.setColName('PRICE12', fn_addMonth( yyyymm.substring(0,4), (Number(yyyymm.substring(4,6))-1), 1, 11));

 	 }
		function fn_addMonth(pYear, pMonth, pDay, pAddMonthCnt) {
			var oDate = new Date(pYear, pMonth, 1);
			oDate.setMonth(oDate.getMonth() + pAddMonthCnt);
			var iLastDate = (new Date(oDate.getFullYear(), oDate.getMonth()+2, 0).getDate());
			oDate.setDate((parseInt(pDay)>iLastDate)?iLastDate:parseInt(pDay));
			return oDate.getFullYear() + "년 " + fn_lpad(oDate.getMonth()+1,2,"0") + "월";
		}
        function fn_lpad(mmm )  {
        	return mmm;
        }

        function chMonthNm(a,b){


        	for(var k =1;k<=12 ;k++)  {
	        	grid.hideCol('PRICE'+k,true);
	        	grid.hideCol('PRICE'+k+'_CHA',true);
	        	grid.hideCol('PRICE'+k+'_SAYU',true);
        	}
        	var from_date = EVF.getComponent("FROM_DATE").getValue();
        	var to_date = EVF.getComponent("TO_DATE").getValue();

        	if (from_date.substring(0,6) > to_date.substring(0,6)) {
        		alert('${DH0560_001}');
        		return;
        	}

        	var fDate = new Date(from_date.substring(0,4), (Number(from_date.substring(4,6))-1), 1);
        	var tDate = new Date(to_date.substring(0,4), (Number(to_date.substring(4,6))-1), 1);

        	var oneDay = 24 * 60 * 60 * 1000;
        	var diffDays = Math.round(Math.abs((fDate.getTime() - tDate.getTime()) / (oneDay)));

        	if ( diffDays > 365 ) {
        		alert('${DH0560_002}');
        		return;
        	}


        	setColNameCh(from_date);


        	//alert(diffDays)

           	for(var k =1;k<=12 ;k++)  {
//       			alert(tDate.getYear()+'==='+tDate.getMonth()+'=================='+fDate.getYear()+'==='+fDate.getMonth());
           		if (tDate.getYear()+'==='+tDate.getMonth() ==  fDate.getYear()+'==='+fDate.getMonth()) {
    	        	grid.hideCol('PRICE'+k,false);
    	        	grid.hideCol('PRICE'+k+'_CHA',false);
    	        	grid.hideCol('PRICE'+k+'_SAYU',false);
           			break;
           		}
	        	grid.hideCol('PRICE'+k,false);
	        	grid.hideCol('PRICE'+k+'_CHA',false);
	        	grid.hideCol('PRICE'+k+'_SAYU',false);
           		fDate.setMonth(fDate.getMonth()+1);
        	}

        }



    </script>

  <e:window id="DH0560" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
      <e:row>
        <e:label for="">
            <e:select id="DATE_TYPE" name="DATE_TYPE" usePlaceHolder="false" width="100" required="${form_DATE_TYPE_R}" disabled="${form_DATE_TYPE_D }" readOnly="${form_DATE_TYPE_RO}" >
            <e:option text="${form_B_N}" value="B">B</e:option>
            <e:option text="${form_A_N}" value="A">A</e:option>
            </e:select>
        </e:label>

		<e:field>
		<e:inputDate id="FROM_DATE" toDate="TO_DATE" onChange="chMonthNm" onSelectDate="chMonthNm"  name="FROM_DATE" value="${fromDate}"  width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
		<e:text> ~ </e:text>
		<e:inputDate id="TO_DATE"  fromDate="TO_DATE" onChange="chMonthNm" onSelectDate="chMonthNm" name="TO_DATE" value="${toDate}"  datePicker="true" width="${inputDateWidth}" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
		</e:field>
		<e:label for="MAT_CD" title="${form_MAT_CD_N}"/>
		<e:field>
			<e:select id="MAT_CD" name="MAT_CD" value="${form.MAT_CD}" options="${matCdOptions}" width="${inputTextWidth}" disabled="${form_MAT_CD_D}" readOnly="${form_MAT_CD_RO}" required="${form_MAT_CD_R}" placeHolder="" />
		</e:field>
		<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
		<e:field>
		<e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="" width="40%" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
		<e:text>&nbsp;</e:text>
		<e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${form.ITEM_NM}" width="50%" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
		</e:field>
      </e:row>
      <e:row>
		<e:label for="ITEM_GROUP" title="${form_ITEM_GROUP_N}"/>
		<e:field>
			<e:select id="ITEM_GROUP" name="ITEM_GROUP" value="${form.ITEM_GROUP}" options="${refITEM_CLASS1}" width="${inputTextWidth}" disabled="${form_ITEM_GROUP_D}" readOnly="${form_ITEM_GROUP_RO}" required="${form_ITEM_GROUP_R}" placeHolder="" />
		</e:field>
        <e:label for="GUBUN" title="${form_GUBUN_N}"/>
        <e:field colSpan="3">
        <e:radioGroup id="radio" name="radio" disabled="" readOnly="" required="">
          	<e:text>&nbsp;&nbsp;</e:text>
          	<e:radio id="DIV" name="DIV" label="${form_DIV_N}" value="D" checked="true"/>
          	<e:text>&nbsp;&nbsp;</e:text>
          	<e:radio id="ALL" name="ALL" label="${form_ALL_N}" value="A"/>
        </e:radioGroup>
        </e:field>



      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>