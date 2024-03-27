<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    pageContext.setAttribute("gubun", "@");
    pageContext.setAttribute("br", "<br/>");
%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">
    var baseUrl = "/evermp/BS03/BS0301/";
    var Total = parseInt(0);

    function init() {

        SetTotal();

    }


    function doSave() {

        var store = new EVF.Store();
        if(!store.validate()) { return; }

        if (!confirm("${msg.M0021 }")) return;

        if(EVF.V("VENDOR_CD")==""){

            var data = {
                'VNEV_YN': "Y",
                'EVAL_ITEM_1_SCORE': EVF.V("EVAL_ITEM_1_SCORE"),
                'EVAL_ITEM_2_SCORE': EVF.V("EVAL_ITEM_2_SCORE"),
                'EVAL_ITEM_3_SCORE': EVF.V("EVAL_ITEM_3_SCORE"),
                'EVAL_ITEM_4_SCORE': EVF.V("EVAL_ITEM_4_SCORE"),
                'EVAL_ITEM_5_SCORE': EVF.V("EVAL_ITEM_5_SCORE"),
                'EVAL_ITEM_6_SCORE': EVF.V("EVAL_ITEM_6_SCORE"),
                'EVAL_ITEM_7_SCORE': EVF.V("EVAL_ITEM_7_SCORE"),
                'EVAL_ITEM_8_SCORE': EVF.V("EVAL_ITEM_8_SCORE"),
                'EVAL_ITEM_9_SCORE': EVF.V("EVAL_ITEM_9_SCORE"),
                'EVAL_ITEM_10_SCORE': EVF.V("EVAL_ITEM_10_SCORE"),
                'EVAL_ITEM_11_SCORE': EVF.V("EVAL_ITEM_11_SCORE"),
                'EVAL_ITEM_12_SCORE': EVF.V("EVAL_ITEM_12_SCORE"),
                'EVAL_GRADE_CLS': EVF.V("EVAL_GRADE_CLS"),
                'EVAL_REMARK': EVF.V("EVAL_REMARK")
            };
            opener['${param.callBackFunction}'](data);
            alert("${BS03_008_001}");
            window.close();

        }else{
            store.load(baseUrl + 'bs03008_doSave', function () {

                var param = {
                    'VENDOR_CD': EVF.V("VENDOR_CD"),
                    'detailView': false
                };
                //window.location.href = '/evermp/BS03/BS0301/BS03_008/view.so?' + $.param(param);

                var data = {
                    'VNEV_YN': "Y",
                    'EVAL_ITEM_1_SCORE': EVF.V("EVAL_ITEM_1_SCORE"),
                    'EVAL_ITEM_2_SCORE': EVF.V("EVAL_ITEM_2_SCORE"),
                    'EVAL_ITEM_3_SCORE': EVF.V("EVAL_ITEM_3_SCORE"),
                    'EVAL_ITEM_4_SCORE': EVF.V("EVAL_ITEM_4_SCORE"),
                    'EVAL_ITEM_5_SCORE': EVF.V("EVAL_ITEM_5_SCORE"),
                    'EVAL_ITEM_6_SCORE': EVF.V("EVAL_ITEM_6_SCORE"),
                    'EVAL_ITEM_7_SCORE': EVF.V("EVAL_ITEM_7_SCORE"),
                    'EVAL_ITEM_8_SCORE': EVF.V("EVAL_ITEM_8_SCORE"),
                    'EVAL_ITEM_9_SCORE': EVF.V("EVAL_ITEM_9_SCORE"),
                    'EVAL_ITEM_10_SCORE': EVF.V("EVAL_ITEM_10_SCORE"),
                    'EVAL_ITEM_11_SCORE': EVF.V("EVAL_ITEM_11_SCORE"),
                    'EVAL_ITEM_12_SCORE': EVF.V("EVAL_ITEM_12_SCORE"),
                    'EVAL_GRADE_CLS': EVF.V("EVAL_GRADE_CLS"),
                    'EVAL_REMARK': EVF.V("EVAL_REMARK")
                };
                opener['${param.callBackFunction}'](data);
                alert(this.getResponseMessage());
                window.close();


            });
        }

    }

    function doSumCH(){

        if(EVF.V("E0102")!=""){
            EVF.V("EVAL_ITEM_12_SCORE",10);
        }else{
            EVF.V("EVAL_ITEM_12_SCORE",0);
        }
        SetTotal();

    }
    function doSum(data){
        var C2Id = data.substring(0,5);
        var C2Value = data.substring(data.lastIndexOf("_")+1);

        if(C2Id=="A0101"){
            EVF.V("EVAL_ITEM_1_SCORE",C2Value);
        }else if(C2Id=="A0102"){
            EVF.V("EVAL_ITEM_2_SCORE",C2Value);
        }else if(C2Id=="A0103"){
            EVF.V("EVAL_ITEM_3_SCORE",C2Value);
        }else if(C2Id=="A0104"){
            EVF.V("EVAL_ITEM_4_SCORE",C2Value);
        }else if(C2Id=="A0105"){
            EVF.V("EVAL_ITEM_5_SCORE",C2Value);
        }else if(C2Id=="B0101"){
            EVF.V("EVAL_ITEM_6_SCORE",C2Value);
        }else if(C2Id=="B0102"){
            EVF.V("EVAL_ITEM_7_SCORE",C2Value);
        }else if(C2Id=="B0103"){
            EVF.V("EVAL_ITEM_8_SCORE",C2Value);
        }else if(C2Id=="B0104"){
            EVF.V("EVAL_ITEM_9_SCORE",C2Value);
        }else if(C2Id=="B0105"){
            EVF.V("EVAL_ITEM_10_SCORE",C2Value);
        }else if(C2Id=="E0101"){
            EVF.V("EVAL_ITEM_11_SCORE",C2Value);
        }else if(C2Id=="E0102"){
            EVF.V("EVAL_ITEM_12_SCORE",C2Value);
        }

        SetTotal();
    }

    function SetTotal(){

        if(EVF.V("EVAL_ITEM_1_SCORE")==""){EVF.V("EVAL_ITEM_1_SCORE","0")}
        if(EVF.V("EVAL_ITEM_2_SCORE")==""){EVF.V("EVAL_ITEM_2_SCORE","0")}
        if(EVF.V("EVAL_ITEM_3_SCORE")==""){EVF.V("EVAL_ITEM_3_SCORE","0")}
        if(EVF.V("EVAL_ITEM_4_SCORE")==""){EVF.V("EVAL_ITEM_4_SCORE","0")}
        if(EVF.V("EVAL_ITEM_5_SCORE")==""){EVF.V("EVAL_ITEM_5_SCORE","0")}
        if(EVF.V("EVAL_ITEM_6_SCORE")==""){EVF.V("EVAL_ITEM_6_SCORE","0")}
        if(EVF.V("EVAL_ITEM_7_SCORE")==""){EVF.V("EVAL_ITEM_7_SCORE","0")}
        if(EVF.V("EVAL_ITEM_8_SCORE")==""){EVF.V("EVAL_ITEM_8_SCORE","0")}
        if(EVF.V("EVAL_ITEM_9_SCORE")==""){EVF.V("EVAL_ITEM_9_SCORE","0")}
        if(EVF.V("EVAL_ITEM_10_SCORE")==""){EVF.V("EVAL_ITEM_10_SCORE","0")}
        if(EVF.V("EVAL_ITEM_11_SCORE")==""){EVF.V("EVAL_ITEM_11_SCORE","0")}
        if(EVF.V("EVAL_ITEM_12_SCORE")==""){EVF.V("EVAL_ITEM_12_SCORE","0")}


        Total = parseInt(EVF.V("EVAL_ITEM_1_SCORE"))+parseInt(EVF.V("EVAL_ITEM_2_SCORE"))+
            parseInt(EVF.V("EVAL_ITEM_3_SCORE"))+parseInt(EVF.V("EVAL_ITEM_4_SCORE"))+
            parseInt(EVF.V("EVAL_ITEM_5_SCORE"))+parseInt(EVF.V("EVAL_ITEM_6_SCORE"))+
            parseInt(EVF.V("EVAL_ITEM_7_SCORE"))+parseInt(EVF.V("EVAL_ITEM_8_SCORE"))+
            parseInt(EVF.V("EVAL_ITEM_9_SCORE"))+parseInt(EVF.V("EVAL_ITEM_10_SCORE"))+
            parseInt(EVF.V("EVAL_ITEM_11_SCORE"))-parseInt(EVF.V("EVAL_ITEM_12_SCORE"));

        EVF.V("RESULT_SCORE",Total);

        if(Total>=80){
            EVF.V("RESULT_RANK","A");
            EVF.V("EVAL_GRADE_CLS","A");
        }else{
            if(Total>=60){
                EVF.V("RESULT_RANK","B");
                EVF.V("EVAL_GRADE_CLS","B");
            }else{
                if(Total>=40){
                    EVF.V("RESULT_RANK","C");
                    EVF.V("EVAL_GRADE_CLS","C");
                }else{
                    EVF.V("RESULT_RANK","D");
                    EVF.V("EVAL_GRADE_CLS","D");
                }
            }
        }
    }

    </script>
    <e:window id="BS03_008" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="4" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">

            <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${formData.VENDOR_CD}"></e:inputHidden>
            <e:inputHidden id="TMP_EV_NUM" name="TMP_EV_NUM" value="${formData.TMP_EV_NUM}"/>
            <e:inputHidden id="EV_NUM" name="EV_NUM" value="${formData.EV_NUM}"/>
            <e:inputHidden id="EV_TPL_NUM" name="EV_TPL_NUM" value="${formData.EV_TPL_NUM}"/>
            <e:inputHidden id="EVVM_PROGRESS_CD" name="EVVM_PROGRESS_CD" value="${formData.EVVM_PROGRESS_CD }"/>
            <e:inputHidden id="EVAL_ITEM_1_SCORE" name="EVAL_ITEM_1_SCORE" value="${formData.EVAL_ITEM_1_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_2_SCORE" name="EVAL_ITEM_2_SCORE" value="${formData.EVAL_ITEM_2_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_3_SCORE" name="EVAL_ITEM_3_SCORE" value="${formData.EVAL_ITEM_3_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_4_SCORE" name="EVAL_ITEM_4_SCORE" value="${formData.EVAL_ITEM_4_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_5_SCORE" name="EVAL_ITEM_5_SCORE" value="${formData.EVAL_ITEM_5_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_6_SCORE" name="EVAL_ITEM_6_SCORE" value="${formData.EVAL_ITEM_6_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_7_SCORE" name="EVAL_ITEM_7_SCORE" value="${formData.EVAL_ITEM_7_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_8_SCORE" name="EVAL_ITEM_8_SCORE" value="${formData.EVAL_ITEM_8_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_9_SCORE" name="EVAL_ITEM_9_SCORE" value="${formData.EVAL_ITEM_9_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_10_SCORE" name="EVAL_ITEM_10_SCORE" value="${formData.EVAL_ITEM_10_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_11_SCORE" name="EVAL_ITEM_11_SCORE" value="${formData.EVAL_ITEM_11_SCORE}"/>
            <e:inputHidden id="EVAL_ITEM_12_SCORE" name="EVAL_ITEM_12_SCORE" value="${formData.EVAL_ITEM_12_SCORE}"/>
            <e:inputHidden id="EVAL_GRADE_CLS" name="EVAL_GRADE_CLS" value="${formData.EVAL_GRADE_CLS }"/>

        </e:searchPanel>

        <e:panel id="info" width="100%">
            <table border="1" style="font-size: 12px; font-family: 맑은 고딕; border-collapse: collapse; width: 100%; " cellpadding="6" cellspacing="0">
                <colgroup>
                    <col style="width:10%">
                    <col style="width:15%">
                    <col style="width:10%">
                    <col style="width:15%">
                    <col style="width:10%">
                    <col style="width:15%">
                    <col style="width:10%">
                    <col style="width:15%">
                    <col>
                </colgroup>
                <tbody>
                <tr>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold"> ${form_VENDOR_NM_N} </td>
                    <td align="center" style="font-weight: bold;"> ${formData.VENDOR_NM } </td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold"> ${form_FOUNDATION_DATE_N} </td>
                    <td align="center" style="font-weight: bold;"> ${formData.FOUNDATION_DATE } </td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold"> ${form_EVAL_DATE_N} </td>
                    <td align="center" style="font-weight: bold;"> ${formData.EVAL_DATE } </td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold"> ${form_EVAL_USER_NM_N} </td>
                    <td align="center" style="font-weight: bold;"> ${formData.EVAL_USER_NM } </td>
                </tr>
                </tbody>
            </table>

        </e:panel>
        <e:br/><e:br/>

        <e:panel id="leftPanelB" height="fit" width="30%">
            <e:title title="${BS03_008_TITLE1 }" depth="1"/>
        </e:panel>
        <e:panel id="rightPanelB" height="fit" width="70%">
            <e:buttonBar id="buttonTopBottom" align="right" width="100%">
                <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
            </e:buttonBar>
        </e:panel>


        <e:panel id="pnl2_sub" width="100%">
            <c:set var="contentWidth" value="30" />
            <c:set var="iconWidth" value="18" />
            <c:set var="subjectWidth" value="50" />
            <c:set var="id" value="0" />

            <table border="1" style="font-size: 12px; font-family: 맑은 고딕; border-collapse: collapse; width: 100%; border-top: 2px solid #000;" cellpadding="6" cellspacing="0">
                <colgroup>
                    <col style="width:90px">
                    <col style="width:70px">
                    <col style="width:150px">
                    <col style="width:50px">
                    <col style="width:340px">
                    <col style="width:40px">
                    <col style="width:40px">
                    <col style="width:40px">
                    <col style="width:40px">
                    <col style="width:40px">
                    <col style="width:40px">
                </colgroup>
                <tbody>
                <tr>
                    <td rowspan="2" bgcolor="#f5f7f9" align="center" style="font-weight: bold">${BS03_008_CAPTION1}</td>
                    <td rowspan="2" colspan="2" bgcolor="#f5f7f9" align="center" style="font-weight: bold">${BS03_008_CAPTION2}</td>
                    <td rowspan="2" bgcolor="#f5f7f9" align="center" style="font-weight: bold">${BS03_008_CAPTION3}</td>
                    <td rowspan="2" bgcolor="#f5f7f9" align="center" style="font-weight: bold">${BS03_008_CAPTION4}</td>
                    <td colspan="2" bgcolor="#f5f7f9" align="left" style="font-weight: bold; border-right-width: 0px">Excellent</td>
                    <td colspan="4" bgcolor="#f5f7f9" align="right" style="font-weight: bold; border-left-width: 0px">Poor</td>
                </tr>
                <tr>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold">10</td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold">8</td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold">6</td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold">4</td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold">2</td>
                    <td bgcolor="#f5f7f9" align="center" style="font-weight: bold">0</td>
                </tr>

                <c:forEach items="${CList }" var="C">
                    <tr>
                        <c:if test="${C.C1_CD != null }">
                            <td rowspan=${C.C1_COL_CNT} align="center">
                                ${fn:replace(C.C1_NM, gubun, br)}
                            </td>
                        </c:if>

                        <c:if test="${C.C2_CD != null }">

                            <c:if test="${C.C2_ETC == '' }">
                                <td rowspan=${C.C2_COL_CNT} colspan="2" align="center">${fn:replace(C.C2_NM, gubun, br)}</td>
                            </c:if>
                            <c:if test="${C.C2_ETC != '' }">
                                <td rowspan=${C.C2_COL_CNT} align="center">${C.C2_ETC}</td>
                                <td rowspan=${C.C2_COL_CNT} align="center">${fn:replace(C.C2_NM, gubun, br)}</td>
                            </c:if>
                        </c:if>
                        <td align="center">${C.C3_NM}</td>
                        <td align="left">${C.C3_ETC}</td>

                        <c:if test="${C.C2_CD != null }">

                            <c:if test="${C.C2_CD != 'E0102'}">
                            <e:radioGroup id="${C.C2_CD}"  name="${C.C2_CD}" value="${C.C2_VALUE}" disabled=""  readOnly="" required="true" >
                            <td rowspan="${C.C2_COL_CNT}" style="padding-left: 10px">
                                <e:radio id="${C.C2_CD}_10" name="${C.C2_CD}_10" value="${C.C2_CD}_10" checked="${C.C2_VALUE_10}" readOnly="${param.detailView}" onClick="doSum"/>
                            </td>
                            <td rowspan="${C.C2_COL_CNT}" style="padding-left: 10px">
                                <e:radio  id="${C.C2_CD}_8" name="${C.C2_CD}_8" value="${C.C2_CD}_8" checked="${C.C2_VALUE_8}" readOnly="${!param.detailView ? C.C2_READONLY : true }" onClick="doSum"/>
                            </td>
                            <td rowspan="${C.C2_COL_CNT}" style="padding-left: 10px">
                                <e:radio id="${C.C2_CD}_6" name="${C.C2_CD}_6" value="${C.C2_CD}_6" checked="${C.C2_VALUE_6}" readOnly="${param.detailView}" onClick="doSum"/>
                            </td>
                            <td rowspan="${C.C2_COL_CNT}" style="padding-left: 10px">
                                <e:radio id="${C.C2_CD}_4" name="${C.C2_CD}_4" value="${C.C2_CD}_4" checked="${C.C2_VALUE_4}" readOnly="${!param.detailView ? C.C2_READONLY : true }" onClick="doSum"/>
                            </td>
                            <td rowspan="${C.C2_COL_CNT}" style="padding-left: 10px">
                                <e:radio id="${C.C2_CD}_2" name="${C.C2_CD}_2" value="${C.C2_CD}_2" checked="${C.C2_VALUE_2}" readOnly="${!param.detailView ? C.C2_READONLY : true }" onClick="doSum"/>
                            </td>
                            <td rowspan="${C.C2_COL_CNT}" style="padding-left: 10px">
                                <e:radio id="${C.C2_CD}_0" name="${C.C2_CD}_0" value="${C.C2_CD}_0" checked="${C.C2_VALUE_0}" readOnly="${param.detailView}" onClick="doSum"/>
                            </td>
                            </e:radioGroup>
                            </c:if>
                            <c:if test="${C.C2_CD == 'E0102'}">
                                <td colspan="6" style="padding-left: 112px;">
                                    <e:check id="${C.C2_CD}" name="${C.C2_CD}" value="${C.C2_MINUS_VALUE}" checked="${C.C2_MINUS_VALUE}" readOnly="${param.detailView}" onClick="doSumCH"/>
                                </td>
                            </c:if>

                        </c:if>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <table border="1" style="font-size: 12px; font-family: 맑은 고딕; border-collapse: collapse; width: 100%; border-top: 2px solid #000;" cellpadding="6" cellspacing="0">
            <colgroup>
                <col style="width:89px">
                <col style="width:218px">
                <col style="width:190px">
                <col style="width:195px">
                <col style="width:112px">
                <col style="width:130px">
            </colgroup>
            <tbody>
            <tr>
                <td bgcolor="#f5f7f9" align="center" height="40px" style="font-weight: bold">${BS03_008_CAPTION5}</td>
                <td  bgcolor="#f5f7f9" align="left" height="40px" style="font-weight: bold">${BS03_008_CAPTION6}</td>
                <td  bgcolor="#f5f7f9" align="right" height="40px" style="font-weight: bold; border-right-width: 0px">점수 :</td>
                <td  bgcolor="#f5f7f9" align="center" height="40px" style="font-weight: bold; border-left-width: 0px">
                    <e:text id="RESULT_SCORE" name="RESULT_SCORE" style="font-weight:bold; color:red;">${formData.RESULT_SCORE}</e:text>
                </td>
                <td  bgcolor="#f5f7f9" align="right" height="40px" style="font-weight: bold; border-right-width: 0px">등급 :</td>
                <td  bgcolor="#f5f7f9" align="center" height="40px" style="font-weight: bold; border-left-width: 0px">
                    <e:text id="RESULT_RANK" name="RESULT_RANK" style="font-weight:bold; color:red;">${formData.RESULT_RANK}</e:text>
                </td>
            </tr>
            </tbody>
            </table>

            <e:br/><e:br/>
            <e:panel id="leftPanel2" height="fit" width="100%">
                <e:title title="${BS03_008_TITLE2 }" depth="1"/>
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