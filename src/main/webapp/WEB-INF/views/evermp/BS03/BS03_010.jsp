<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    pageContext.setAttribute("gubun", "@");
    pageContext.setAttribute("br", "<br/>");
%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <style>
        .e-radio {
            height: 22px;
        }
        .e-radio-wrapper {
            height: 22px;
            padding: 0;
        }
    </style>
    <script type="text/javascript">
    var baseUrl = "/evermp/BS03/BS0301/";
    var Total = parseInt(0);

    function init() {
        $(".e-window-container-header-wrapper").css("position", "fixed");
        $(".e-window-container-header-wrapper").css("z-index", "2");
        $("#pnl2_sub").css("top", "150px");
        $(".e-window-container-body").css("overflow-x", "visible");
        doSum();




    }
   function EVALcheck(data){ // 평가방법 중복체크 방지

      if($(this)[0].data=="A"){
          $('input[type="checkbox"][name="EVAL_WAY_2"]').prop('checked',false);
      }else{
          $('input[type="checkbox"][name="EVAL_WAY_1"]').prop('checked',false);
      }
   }

    function doSave() {
       if($('input[type="checkbox"][id="EVAL_WAY_1"]').is(":checked")==false && $('input[type="checkbox"][id="EVAL_WAY_2"]').is(":checked") ==false){
          return alert("${BS03_010_002}"); //평가방법 선택 안됐을 시 return
          }

         if(($("input[name=EVAL_ITEM_" + 1 + "_SCORE]:checked").val())== null){
           return alert("${BS03_010_003}"); //신용평가 선택 안됐을 시 return
          }

        if(($("input[name=EVAL_ITEM_" + 5 + "_SCORE]:checked").val())== null){
           return alert("${BS03_010_003}"); //재무관리능력 선택 안됐을 시 return
          }

       if(($("input[name=EVAL_ITEM_" + 10 + "_SCORE]:checked").val())== null){
          return alert("${BS03_010_003}"); //실적평가 선택 안됐을 시 return
         }

        if(($("input[name=EVAL_ITEM_" + 20 + "_SCORE]:checked").val())== null){
           return alert("${BS03_010_003}"); //정성평가에 설립년수 선택 안됐을 시 return
           }

        if(($("input[name=EVAL_ITEM_" + 21 + "_SCORE]:checked").val())== null){
           return alert("${BS03_010_003}"); //거래의중요도 선택 안됐을 시 return
           }

      var store = new EVF.Store();

        if (!confirm("${msg.M0021 }")) return;

        store.load(baseUrl + 'bs03010_doSave', function () {
            alert(this.getResponseMessage());
            opener.doSearch();
            window.close();
        });
    }

    function doCheck() {
		var tempData = this.data;

		var jbSplit = tempData.split('@');

//		alert(jbSplit[0])
//		alert(jbSplit[1])


		EVF.C(jbSplit[1]).setValue(jbSplit[0]);

//alert(EVF.C(jbSplit[1]).getValue())

		doSum();

    }


    function doSum(data){

        var checkSum1 = 0, checkSum2 = 0, checkSum3 = 0, checkSum4 = 0;
        for(var cnt = 1; cnt < 22; cnt++) {
            var checkVal = Number($("input[name=EVAL_ITEM_" + cnt + "_SCORE]:checked").val());
            if(!isNaN(checkVal)) {
                if(cnt > 0 && cnt < 5) {
                    checkSum1 += Number(checkVal);
                    $("#EVAL_ITEM_1_SCORE_SUM").text(checkSum1);
                }
                if(cnt > 4 && cnt < 10) {
                    checkSum2 += Number(checkVal);
                    $("#EVAL_ITEM_2_SCORE_SUM").text(checkSum2);
                }

                if(cnt > 9 && cnt < 20) {
                    checkSum3 += Number(checkVal);
                    $("#EVAL_ITEM_3_SCORE_SUM").text(checkSum3);
                }

                if(cnt > 19 && cnt <= 22) {
                    checkSum4 += Number(checkVal);
                    $("#EVAL_ITEM_4_SCORE_SUM").text(checkSum4);
                }
            }
        }

        /* 유통레벨 없애기 위해 통주석 처리 후 sum부분만 밖으로 추출
        if ("${DELIVERY_LEVEL}" == "A") {
            for(var cnt = 1; cnt < 22; cnt++) {
                var checkVal = Number($("input[name=EVAL_ITEM_" + cnt + "_SCORE]:checked").val());
                if(!isNaN(checkVal)) {
                    if(cnt > 0 && cnt < 5) {
                        checkSum1 += Number(checkVal);
                        $("#EVAL_ITEM_1_SCORE_SUM").text(checkSum1);
                    }
                    if(cnt > 4 && cnt < 10) {
                        checkSum2 += Number(checkVal);
                        $("#EVAL_ITEM_2_SCORE_SUM").text(checkSum2);
                    }

                    if(cnt > 9 && cnt < 20) {
                        checkSum3 += Number(checkVal);
                        $("#EVAL_ITEM_3_SCORE_SUM").text(checkSum3);
                    }

                    if(cnt > 19 && cnt <= 22) {
                        checkSum4 += Number(checkVal);
                        $("#EVAL_ITEM_4_SCORE_SUM").text(checkSum4);
                    }
                }
            }
        } else {
            for(var cnt = 1; cnt < 10; cnt++) {
                var checkVal = Number($("input[name=EVAL_ITEM_" + cnt + "_SCORE]:checked").val());
                if(!isNaN(checkVal)) {
                    if(cnt > 0 && cnt < 5) {
                        checkSum1 += Number(checkVal);
                        $("#EVAL_ITEM_1_SCORE_SUM").text(checkSum1);
                    }
                    if(cnt > 4 && cnt < 6) {
                        checkSum2 += Number(checkVal);
                        $("#EVAL_ITEM_2_SCORE_SUM").text(checkSum2);
                    }

                    if(cnt > 5 && cnt < 8) {
                        checkSum3 += Number(checkVal);
                        $("#EVAL_ITEM_3_SCORE_SUM").text(checkSum3);
                    }

                    if(cnt > 7 && cnt <= 10) {
                        checkSum4 += Number(checkVal);
                        $("#EVAL_ITEM_4_SCORE_SUM").text(checkSum4);
                    }
                }
            }
        }
        */

        var checkSum = checkSum1 + checkSum2  + checkSum3 + checkSum4;

        EVF.V("RESULT_SCORE", checkSum);
        EVF.C("JUDGMENT1").setDisabled(true);
        EVF.C("JUDGMENT2").setDisabled(true);

        if(checkSum >= 70) {
            EVF.C("JUDGMENT1").setChecked(true);
            EVF.C("JUDGMENT2").setChecked(false);
        } else {
            EVF.C("JUDGMENT1").setChecked(false);
            EVF.C("JUDGMENT2").setChecked(true);
        }

    }

    </script>
    <e:window id="BS03_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${formData.VENDOR_CD}"/>
<%--        <e:inputHidden id="DELIVERY_LEVEL" name="DELIVERY_LEVEL" value="${DELIVERY_LEVEL}"/>--%>
        <e:inputHidden id="SPEV_YN" name="SPEV_YN" value="${SPEV_YN}"/>


        <e:inputHidden id="EVAL_ITEM_1_ID" name="EVAL_ITEM_1_ID" value="${form.EVAL_ITEM_1_ID}"/>
        <e:inputHidden id="EVAL_ITEM_2_ID" name="EVAL_ITEM_2_ID" value="${form.EVAL_ITEM_2_ID}"/>
        <e:inputHidden id="EVAL_ITEM_3_ID" name="EVAL_ITEM_3_ID" value="${form.EVAL_ITEM_3_ID}"/>
        <e:inputHidden id="EVAL_ITEM_4_ID" name="EVAL_ITEM_4_ID" value="${form.EVAL_ITEM_4_ID}"/>
        <e:inputHidden id="EVAL_ITEM_5_ID" name="EVAL_ITEM_5_ID" value="${form.EVAL_ITEM_5_ID}"/>
        <e:inputHidden id="EVAL_ITEM_6_ID" name="EVAL_ITEM_6_ID" value="${form.EVAL_ITEM_6_ID}"/>
        <e:inputHidden id="EVAL_ITEM_7_ID" name="EVAL_ITEM_7_ID" value="${form.EVAL_ITEM_7_ID}"/>
        <e:inputHidden id="EVAL_ITEM_8_ID" name="EVAL_ITEM_8_ID" value="${form.EVAL_ITEM_8_ID}"/>
        <e:inputHidden id="EVAL_ITEM_9_ID" name="EVAL_ITEM_9_ID" value="${form.EVAL_ITEM_9_ID}"/>
        <e:inputHidden id="EVAL_ITEM_10_ID" name="EVAL_ITEM_10_ID" value="${form.EVAL_ITEM_10_ID}"/>
        <e:inputHidden id="EVAL_ITEM_11_ID" name="EVAL_ITEM_11_ID" value="${form.EVAL_ITEM_11_ID}"/>
        <e:inputHidden id="EVAL_ITEM_12_ID" name="EVAL_ITEM_12_ID" value="${form.EVAL_ITEM_12_ID}"/>
        <e:inputHidden id="EVAL_ITEM_13_ID" name="EVAL_ITEM_13_ID" value="${form.EVAL_ITEM_13_ID}"/>
        <e:inputHidden id="EVAL_ITEM_14_ID" name="EVAL_ITEM_14_ID" value="${form.EVAL_ITEM_14_ID}"/>
        <e:inputHidden id="EVAL_ITEM_15_ID" name="EVAL_ITEM_15_ID" value="${form.EVAL_ITEM_15_ID}"/>
        <e:inputHidden id="EVAL_ITEM_16_ID" name="EVAL_ITEM_16_ID" value="${form.EVAL_ITEM_16_ID}"/>
        <e:inputHidden id="EVAL_ITEM_17_ID" name="EVAL_ITEM_17_ID" value="${form.EVAL_ITEM_17_ID}"/>
        <e:inputHidden id="EVAL_ITEM_18_ID" name="EVAL_ITEM_18_ID" value="${form.EVAL_ITEM_18_ID}"/>
        <e:inputHidden id="EVAL_ITEM_19_ID" name="EVAL_ITEM_19_ID" value="${form.EVAL_ITEM_19_ID}"/>
        <e:inputHidden id="EVAL_ITEM_20_ID" name="EVAL_ITEM_20_ID" value="${form.EVAL_ITEM_20_ID}"/>
        <e:inputHidden id="EVAL_ITEM_21_ID" name="EVAL_ITEM_21_ID" value="${form.EVAL_ITEM_21_ID}"/>
        <e:inputHidden id="EVAL_ITEM_22_ID" name="EVAL_ITEM_22_ID" value="${form.EVAL_ITEM_22_ID}"/>


        <div style="position: fixed; width: 99%; z-index: 1; background: #fff; top: 30px;">
        <e:panel id="info" width="100%">

                <table border="1" style="font-size: 12px; font-family: 맑은 고딕; border-collapse: collapse; width: 100%;" cellpadding="6" cellspacing="0">
                    <colgroup>
                        <col style="width:13%">
                        <col style="width:20%">
                        <col style="width:13%">
                        <col style="width:20%">
                        <col style="width:13%">
                        <col style="width:20%">
                    </colgroup>
                    <tbody>
                    <tr>
                            <td colspan="6" style="height: 38px; text-align: center; font-size: 16px; font-weight: bold;">
                                <%--
                                <c:if test="${DELIVERY_LEVEL eq 'A'}">
                                    [협력업체조사표(제조)]
                                </c:if>
                                <c:if test="${DELIVERY_LEVEL ne 'A'}">
                                    [협력업체조사표(일반유통)]
                                </c:if>
                                --%>
                                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" style="float:right;"/>
                            </td>
                    </tr>
                    <tr style="height: 35px;">
                        <td bgcolor="#f5f7f9" align="center" style="font-weight: bold; height: 38px;"> ${form_VENDOR_NM_N} </td>
                        <td align="center" style="font-weight: bold;"> ${formData.VENDOR_NM } </td>
                        <td bgcolor="#f5f7f9" align="center" style="font-weight: bold"> ${form_EVAL_DATE_N} </td>
                        <td align="center" style="font-weight: bold; height: 38px;"> ${formData.EVAL_DATE } </td>
                        <td bgcolor="#f5f7f9" align="center" style="font-weight: bold"> ${form_EVAL_USER_NM_N} </td>
                        <td align="center" style="font-weight: bold;"> ${formData.EVAL_USER_NM } </td>
                    </tr>
                    <tr style="height: 35px;">
                        <td bgcolor="#f5f7f9" align="center" style="font-weight: bold"> ${form_EVAL_WAY_N} <small style="color :red">(필수)</small></td>
                        <td align="center" style="font-weight: bold;">
                            <e:check id="EVAL_WAY_1" name="EVAL_WAY_1" value="1" checked="${formData.EVAL_WAY_1 eq '1' ? true : false}"  onClick="EVALcheck" data="A" readOnly="${readOnly}" ></e:check><e:text>방문</e:text>
                            <e:check id="EVAL_WAY_2" name="EVAL_WAY_2" value="1" checked="${formData.EVAL_WAY_2 eq '1' ? true : false}"  onClick="EVALcheck" data="B"  style="padding-left: 10%;" readOnly="${readOnly}" ></e:check><e:text>서면</e:text>
                        </td>
                        <td bgcolor="#f5f7f9" align="center" style="font-weight: bold"> ${form_JUDGMENT_N} </td>
                        <td align="center" style="font-weight: bold;">
                            <e:check id="JUDGMENT1" name="JUDGMENT1" value="1" readOnly="${readOnly}"></e:check><e:text>70점 이상</e:text>
                            <e:check id="JUDGMENT2" name="JUDGMENT2" value="1" style="padding-left: 10%;" readOnly="${readOnly}"></e:check><e:text>70점 미만</e:text>
                        </td>
                        <td bgcolor="#f5f7f9" align="center" style="font-weight: bold"> ${form_SUM_SCORE_N} </td>
                        <td align="center" style="font-weight: bold;">
                            <e:text id="RESULT_SCORE" name="RESULT_SCORE" style="font-weight:bold; color:red; width:100%;">${formData.RESULT_SCORE}</e:text>
                        </td>
                    </tr>
                    </tbody>
                </table>

        </e:panel>
        <e:br/><e:br/>
        </div>
        <e:panel id="pnl2_sub" width="100%">
            <c:set var="contentWidth" value="30" />
            <c:set var="iconWidth" value="18" />
            <c:set var="subjectWidth" value="50" />
            <c:set var="id" value="0" />

            <table border="1" style="font-size: 12px; font-family: 맑은 고딕; border-collapse: collapse; width: 100%; border-top: 2px solid #000;" cellpadding="6" cellspacing="0">
                <colgroup>
                    <col style="width:12%">
                    <col style="width:30%">
                    <col style="width:21%">
                    <col style="width:22%">
                    <col style="width:10%">
                    <col style="width:5%">
                </colgroup>
                <tbody>
                <tr>
                    <td colspan="6" bgcolor="#f5f7f9" align="center" style="font-weight: bold; height: 38px;">${BS03_010_CAPTION6}</td>
                </tr>
                <tr>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold; height: 38px;">${BS03_010_CAPTION1}</td>
                    <td colspan="2" bgcolor="#f5f7f9" align="center" style="font-weight: bold">${BS03_010_CAPTION2}</td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold">${BS03_010_CAPTION3}</td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold">${BS03_010_CAPTION4}</td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold">${BS03_010_CAPTION5}</td>
                </tr>
                <c:forEach items="${CList }" var="C" varStatus="idx">
                    <tr style="text-align: center; border: 1px solid #000;">
                        <c:if test="${C.C1_CD != null }">
                            <td rowspan=${C.C1_COL_CNT} align="center" style="font-weight: bold;">
                                ${fn:replace(C.C1_NM, gubun, br)}
                            </td>
                        </c:if>
                        <c:if test="${C.C2_CD != null }">
                            <td rowspan="${C.C2_COL_CNT}" align="center">${fn:replace(C.C2_NM, gubun, br)}</td>
                        </c:if>
                        <c:if test="${fn:substring(C.C3_CD, 5, 7) eq '00'}">
                            <td align="center" rowspan="${C.C2_COL_CNT}">${fn:replace(C.C3_ETC, gubun, br)}</td>
                        </c:if>
                        <c:if test="${fn:substring(C.C3_CD, 5, 7) ne '00'}">
                            <td align="left">${fn:replace(C.C3_ETC, gubun, br)}</td>
                        </c:if>
                        <%-- 배점 --%>
                        <c:if test="${fn:substring(C.C3_CD, 5, 7) ne '00'}">
                            <td align="center">${C.C3_NM}</td>
                            <td style="display: inline-block; border: 0;">
                                <e:radio id="EVAL_ITEM_${C.C3_EVAL_NUM}_SCORE_${idx.count}" data="${C.C3_CD}@EVAL_ITEM_${C.C3_EVAL_NUM}_ID"  name="EVAL_ITEM_${C.C3_EVAL_NUM}_SCORE" value="${C.C3_NM}" checked="${C.C3_CD eq C.C_ID ? true : false}" readOnly="${readOnly}" onClick="doCheck" />




                            </td>
                        </c:if>
                    </tr>
                    <c:if test="${C.C3_LAST_FLAG eq 'Y'}">
                        <c:set var="count" value="${count + 1}" />
                        <tr>
                            <td colspan="5" style="text-align: center; font-weight: bold;">합계점수</td>
                            <td style="text-align: center; font-weight: bold;" id="EVAL_ITEM_${count}_SCORE_SUM">0</td>
                        </tr>
                    </c:if>
                </c:forEach>
                </tbody>
            </table>

            <e:br/><e:br/>
            <e:panel id="leftPanel3" height="fit" width="100%">
                <e:title title="${BS03_010_TITLE3 }" depth="1"/>
            </e:panel>
            <div style="height: 110px;">
                <table border="1" style="font-size: 12px; font-family: 맑은 고딕; border-collapse: collapse; width: 100%; border-top: 2px solid #000;" cellpadding="6" cellspacing="0">
                    <tr>
                        <td align="center" style="position: relative;">
                            <e:textArea id="RECOM_USER_NM" name="RECOM_USER_NM" height="60" value="${formData.RECOM_USER_NM }"  width="100%" maxLength="200" disabled="false" readOnly="${param.detailView}" required="true"/>
                        </td>
                    </tr>
                </table>
            </div>
            <e:panel id="leftPanel2" height="fit" width="100%">
                <e:title title="${BS03_010_TITLE2 }" depth="1"/>
            </e:panel>
            <div style="height: 110px;">
            <table border="1" style="font-size: 12px; font-family: 맑은 고딕; border-collapse: collapse; width: 100%; border-top: 2px solid #000;" cellpadding="6" cellspacing="0">
                <tr>
                    <td align="center" style="position: relative;">
                        <e:textArea id="EVAL_REMARK" name="EVAL_REMARK" height="60" value="${formData.EVAL_REMARK }"  width="100%" maxLength="200" disabled="false" readOnly="${param.detailView}" required="true"/>
                    </td>
                </tr>
            </table>
            </div>
        </e:panel>

    </e:window>
</e:ui>