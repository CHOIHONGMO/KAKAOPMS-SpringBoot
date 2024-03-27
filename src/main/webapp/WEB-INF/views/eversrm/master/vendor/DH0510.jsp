<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-05-18
  Time: 오후 1:44
  Scrren ID : DH0510(신용평가I/F현황)
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
    var baseUrl = "/eversrm/master/vendor/DH0510";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", true);
      grid.setProperty('panelVisible', ${panelVisible});
      //grid Column Head Merge
      grid.setProperty('multiselect', true);
      grid.setProperty('panelVisible', ${panelVisible});
      // Grid AddRow Event
      grid.addRowEvent(function() {
        addParam = [{'INSERT_FLAG': 'I'}];
        grid.addRow(addParam);
      });

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
        switch(celname) {
          case 'MAKEDATE':
                  var encry_flag = grid.getCellValue(rowid, "ENCRY_FLAG");
                  encrypt(rowid, encry_flag);
                break;
          case 'VENDOR_CD':
                  var params = {
                    VENDOR_CD: grid.getCellValue(rowid, 'VENDOR_CD'),
                    paramPopupFlag: 'Y',
                    detailView : true
                  };
                  everPopup.openSupManagementPopup(params);
                break;
        }
      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});
    }

    // 나이스디앤비 연동
    eval(function (p, a, c, k, e, r) {
        e = function (c) {
            return c.toString(a)
        };
        if (!''.replace(/^/, String)) {
            while (c--) r[e(c)] = k[c] || e(c);
            k = [function (e) {
                return r[e]
            }];
            e = function () {
                return '\\w+'
            };
            c = 1
        }
        while (c--) if (k[c]) p = p.replace(new RegExp('\\b' + e(c) + '\\b', 'g'), k[c]);
        return p
    }('0 2="5";0 1=3 4(c,6);7 8(a){b 1.9(2,a)}', 13, 13, 'var|aesUtil|authKey|new|AesUtil|59324e53536d737962487039524467|100|function|niceEncrypt|encrypt||return|128'.split('|'), 0, {}));
    function encrypt(rowId, encry_flag) {

      if(encry_flag == "1") {
        // 나이스디앤비 연동
        var bz_ins_no = grid.getCellValue(rowId, "BIZ_NO"); // 사업자번호
        var encrypted_bz_ins_no = niceEncrypt(bz_ins_no);   // 암호화 사업자번호
        //document.getElementById("e_bz_ins_no").value = encrypted_bz_ins_no;

        var url = "http://xlink.nicednb.com/weblink/toServer.do";
        var param = {
          'clp_cd': '124',
          'bz_ins_no': encrypted_bz_ins_no
        };

        everPopup.openWindowPopup(url, 1000, 750, param, "");
      } else {
        // 이크레더블 연동
        // u : 인코딩된 사용자 아이디
        // p : 인코딩된 사용자 암호
        // i : 협력업체사업자번호 - 본사사업자번호
        // k : 협력업체법인번호
        // c : 암호화방법
        //      1(암호화안함), 2(base64), 3:(128bit,시스템이 java일 경우에만), 7:(128bit, 인증정보 고정, 사업자번호암호화 X)
        // m : 통합인증서 기본 섹션
        //      1(업체검색), 2(Watch메인), 3(전자인증서메인), 4(건설실적메인), 5(거래위험메인), 8(IT실적메인)
        // g : 고정파라미터

        //var m ='3';
        //var link ='http://www.esrm.co.kr/esrm/SrmplusLogin?u='+ u +'&p='+ p +'&i='+ i +'&k='+ k +'&c=7&m='+ m +'&g=2';
        //var features ='height=768, width=1024, status=no, scrollbars=auto, resizable=yes';
        //window.open(link, 'watchwin', features);
        var ie_flag = (navigator.appName == 'Microsoft Internet Explorer') || ((navigator.appName == 'Netscape') && (new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})").exec(navigator.userAgent) != null));
        if (ie_flag) {
          var url ='http://www.esrm.co.kr/esrm/SrmplusLogin';
          var param = {
            'u': '2d2d424547494e204349504845522d2d313131310000000b303030303030303084d923ba7bc576c305450073ccb0a79e35ea370f23adcd35caf09f8c4388ae151ba8854430f89eb9549fb32a16b57a2d30302d2d454e44204349504845522d2d',
            'p': '2d2d424547494e204349504845522d2d31313131000000043030303030303030357a9e3bf444e8b6b812f7149209c9bac7c1e9ce660be573a70b9be7488016fe354b008e3fc11c852a41c867b0a2282030302d2d454e44204349504845522d2d',
            'i': grid.getCellValue(rowId, "BIZ_NO"),
            'k': '',
            'c': '7',
            'm': '3',
            'g': '2'
          };

          everPopup.openWindowPopup(url, 1000, 750, param, "");
        } else {
          alert("${DH0510_0001}"); // 인터넷 익스플로러에서 확인하여 주시기 바랍니다.
        }

      }
    }

    // 조회
    function doSearch() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;

      // 날짜 체크
      if(!everDate.checkTermDate('MAKE_FROM_DATE','MAKE_TO_DATE','${msg.M0073}')) {
        return;
      }

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    </script>

  <e:window id="DH0510" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
      <e:row>
        <%--I/F일자--%>
        <e:label for="MAKE_FROM_DATE" title="${form_MAKE_FROM_DATE_N}"/>
        <e:field>
          <e:inputDate id="MAKE_FROM_DATE" toDate="MAKE_TO_DATE" name="MAKE_FROM_DATE" value="${defaultFromDate}" width="${inputTextDate}" datePicker="true" required="${form_MAKE_FROM_DATE_R}" disabled="${form_MAKE_FROM_DATE_D}" readOnly="${form_MAKE_FROM_DATE_RO}" />
          <e:text> ~ </e:text>
          <e:inputDate id="MAKE_TO_DATE" fromDate="MAKE_FROM_DATE" name="MAKE_TO_DATE" value="${defaultToDate}" width="${inputTextDate}" datePicker="true" required="${form_MAKE_TO_DATE_R}" disabled="${form_MAKE_TO_DATE_D}" readOnly="${form_MAKE_TO_DATE_RO}" />
        </e:field>
        <%--협력회사명--%>
        <e:label for="CMP_NM" title="${form_CMP_NM_N}"/>
        <e:field>
          <e:search id="CMP_NM" style="${imeMode}" name="CMP_NM" value="" width="${inputTextWidth}" maxLength="${form_CMP_NM_M}" onIconClick="${form_CMP_NM_RO ? 'everCommon.blank' : ''}" disabled="${form_CMP_NM_D}" readOnly="${form_CMP_NM_RO}" required="${form_CMP_NM_R}" />
        </e:field>
        <%--사업자번호--%>
        <e:label for="BIZ_NO" title="${form_BIZ_NO_N}"/>
        <e:field>
          <e:inputText id="BIZ_NO" style="ime-mode:inactive" name="BIZ_NO" value="${form.BIZ_NO}" width="100%" maxLength="${form_BIZ_NO_M}" disabled="${form_BIZ_NO_D}" readOnly="${form_BIZ_NO_RO}" required="${form_BIZ_NO_R}"/>
        </e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>