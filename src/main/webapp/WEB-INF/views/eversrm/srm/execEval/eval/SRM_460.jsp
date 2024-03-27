<%--
  Date: 2016/01/07
  Time: 16:56:46
  Scrren ID : SRM_460
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var baseUrl = '/eversrm/srm/execEval/eval/SRM_460';
    var selRow;

    function init() {
      //EVF.getComponent('TH_NUM').setDisabled(false);
      //EVF.getComponent('TH_NUM').setReadOnly(false);
      if('${param.popupFlag}' == 'true') {
        doSearch();
      }
    }

    // Search
    function doSearch() {
      var store = new EVF.Store();

      if(EVF.getComponent('TH_NUM').getValue() == "") {
        alert("${SRM_460_0001}"); // 관리번호를 입력하여 주시기 바랍니다.
        formUtil.animate('TH_NUM', 'form');
        return;
      }

      store.load(baseUrl+'/doSearch', function() {
        formUtil.setFormData(this.getParameter("form"));
      });
    }

    // Save
    function doSave() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;

      // 평가점수
      var ev_score = EVF.getComponent('EV_SCORE').getValue();
      if(ev_score > 100 || ev_score < 0) {
        alert("${SRM_460_0002}"); // 평가점수는 100을 초과할 수 없고 0 보다 커야합니다.
      }

      if (!confirm("${msg.M0021}")) return;
      store.doFileUpload(function() {
        store.load(baseUrl + '/doSave', function() {
          alert(this.getResponseMessage());

          EVF.getComponent('TH_NUM').setValue(this.getParameter("thNum"));
          doSearch();
        });
      });
    }

    // Delete
    function doDelete() {

      if (!confirm("${msg.M0013 }")) return;

      var store = new EVF.Store();
      store.load(baseUrl + '/doDelete', function(){
        alert(this.getResponseMessage());

        if('${param.popupFlag}' != true) {
          infoClear();
        } else {
          doClose();
        }
        opener.doSearch();
      });
    }

    // Close
    function doClose() {
      window.close();
    }

    // 폼 값 삭제
    function infoClear() {
      EVF.getComponent("form").iterator(function() {
        EVF.getComponent(this.getID()).setValue('');
        EVF.getComponent("ATT_FILE_NUM").setValue('');
      });
    }

    // 협력회사명 팝업(Form)
    function searchVendor() {
      var param = {
        callBackFunction : 'doSetVendorForm'
      };
      everPopup.openCommonPopup(param, 'SP0013');
    }

    // 협력회사명 팝업 셋팅(Form)
    function doSetVendorForm(data) {
      EVF.getComponent("VENDOR_CD").setValue(data.VENDOR_CD);
      EVF.getComponent("VENDOR_NM").setValue(data.VENDOR_NM);
    }

    // 구매담당자 선택 팝업
    function doSelectUser() {
      var param = {
        GATE_CD:  '${ses.gateCd}'
        , callBackFunction: 'selectUser'
      };
      everPopup.openCommonPopup(param,"SP0001");
    }

    // 구매담당자 세팅
    function selectUser(data) {
      EVF.getComponent("EV_USER_NM").setValue(data.USER_NM);
      EVF.getComponent("EV_USER_ID").setValue(data.USER_ID);
    }
  </script>

  <e:window id="SRM_460" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="2" useTitleBar="false" >
      <e:buttonBar width="100%" align="right">
        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        <c:if test="${param.EV_USER_ID eq ses.userId}">
          <e:button id="doSave"   name="doSave"   label="${doSave_N}"   onClick="doSave"   disabled="${doSave_D}"   visible="${doSave_V}"/>
          <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </c:if>
        <c:if test="${param.popupFlag ne true}">
          <e:button id="doSave"   name="doSave"   label="${doSave_N}"   onClick="doSave"   disabled="${doSave_D}"   visible="${doSave_V}"/>
          <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </c:if>
        <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${param.popupFlag eq true ? true : false}"/>
      </e:buttonBar>
      <e:row>
        <%--관리번호--%>
        <e:label for="TH_NUM" title="${form_TH_NUM_N}"/>
        <e:field colSpan="3">
          <e:inputText id="TH_NUM" style="ime-mode:inactive" name="TH_NUM" value="${param.popupFlag eq true ? param.TH_NUM : form.TH_NUM}" width="${inputTextWidth}" maxLength="${form_TH_NUM_M}" disabled="${form_TH_NUM_D}" readOnly="${form_TH_NUM_RO}" required="${form_TH_NUM_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--제목--%>
        <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
        <e:field colSpan="3">
          <e:inputText id="SUBJECT" style="${imeMode}" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--평가일자--%>
        <e:label for="EV_DATE" title="${form_EV_DATE_N}"/>
        <e:field>
          <e:inputDate id="EV_DATE" name="EV_DATE" value="${form.EV_DATE}" width="${inputTextDate}" datePicker="true" required="${form_EV_DATE_R}" disabled="${form_EV_DATE_D}" readOnly="${form_EV_DATE_RO}" />
        </e:field>
        <%--협력회사--%>
        <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
        <e:field>
          <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
          <e:text> / </e:text>
          <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--구매담당자--%>
        <e:label for="EV_USER_ID" title="${form_EV_USER_ID_N}"/>
        <e:field>
          <e:search id="EV_USER_ID" style="ime-mode:inactive" name="EV_USER_ID" value="" width="${inputTextWidth}" maxLength="${form_EV_USER_ID_M}" onIconClick="${form_EV_USER_ID_RO ? 'everCommon.blank' : 'doSelectUser'}" disabled="${form_EV_USER_ID_D}" readOnly="${form_EV_USER_ID_RO}" required="${form_EV_USER_ID_R}" />
          <e:text> / </e:text>
          <e:inputText id="EV_USER_NM" style="${imeMode}" name="EV_USER_NM" value="${form.EV_USER_NM}" width="${inputTextWidth}" maxLength="${form_EV_USER_NM_M}" disabled="${form_EV_USER_NM_D}" readOnly="${form_EV_USER_NM_RO}" required="${form_EV_USER_NM_R}"/>
        </e:field>
        <%--평가점수--%>
        <e:label for="EV_SCORE" title="${form_EV_SCORE_N}"/>
        <e:field>
          <e:inputNumber id="EV_SCORE" name="EV_SCORE" value="${form.EV_SCORE}" maxValue="${form_EV_SCORE_M}" decimalPlace="${form_EV_SCORE_NF}" disabled="${form_EV_SCORE_D}" readOnly="${form_EV_SCORE_RO}" required="${form_EV_SCORE_R}" />
        </e:field>
      </e:row>
      <e:row>
        <%--비고--%>
        <e:label for="REMARK" title="${form_REMARK_N}"/>
        <e:field colSpan="3">
          <e:textArea id="REMARK" style="${imeMode}" name="REMARK" height="100px" value="${form.REMARK}" width="100%" maxLength="${form_REMARK_M}" disabled="${form_REMARK_D}" readOnly="${form_REMARK_RO}" required="${form_REMARK_R}" />
        </e:field>
      </e:row>
      <e:row>
        <%--등록일자--%>
        <e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
        <e:field>
          <e:inputDate id="REG_DATE" name="REG_DATE" value="${form.REG_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
        </e:field>
        <%--등록자--%>
        <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
        <e:field>
          <e:inputText id="REG_USER_NM" style="${imeMode}" name="REG_USER_NM" value="${form.REG_USER_NM}" width="${inputTextWidth}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--첨부파일--%>
        <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
        <e:field colSpan="3">
            <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="EV" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
        </e:field>
      </e:row>
    </e:searchPanel>
  </e:window>
</e:ui>
