<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="/js/ckeditor/econt_plugins.js"></script>
    <script type="text/javascript">

        var grid = {};
        var addGrid;
        var toolkit;

        var baseUrl = "/eversrm/eContract/eContractMgt/BECM_040/";
        var userType = '${ses.userType}';
        var baseDataType = '${param.baseDataType}';
        var additionalForm = '${param.additionalForm}';
        var contReqFlag = '${param.contReqFlag}';//Termination of contract, Resume contract 
        var TPROGRESS_CD = '${param.PROGRESS_CD}';
        var detailViewFlag = '${param.detailView}';
        var vendorEditFlag = '${param.vendorEditFlag}';

        function init() {
      
        	
            var editor = CKEDITOR.replace('addCont_content', {
                customConfig: '/js/ckeditor/ep_config.js',
                width: '100%',
                height: 330
            });

            editor.on('instanceReady', function (ev) {

                var editor = ev.editor;
                editor.resize('100%', 550, true, false);

                $(window).resize(function () {
                    editor.resize('100%', 550, true, false);
                });
                //editor.setData(EVF.C('formContents').getValue());
                //alert("detailViewFlag====="+detailViewFlag);
                if (detailViewFlag == "false" && vendorEditFlag != '1') {
                    editor.setReadOnly(true);
                } else {
                    editor.setReadOnly(false);
                }
            });

        }
        function doSave() {

            var msg = checkEdit();
            if (msg == 'NO') return;

            var params = {
                rowIndex: '${param.rowIndex}',
                relFormNum: '${param.relFormNum}',
                formTextNum: '${param.formTextNum}',
                contents: CKEDITOR.instances.addCont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')
            };
            opener.window['${param.callBackFunction}'](params);
            doClose();
        }
        function checkEdit() {
            //CKEDITOR.instances.cont_content.getData();
            //$(CKEDITOR.instances.cont_content.getData()).filter('input, textarea');
            var rtnMsg = "YES";
            var $contents = $((CKEDITOR.instances.addCont_content.getData()).replace(/&nbsp;/g, ''));
            var fields = $contents.addBack().find('input, textarea');
            //var fields = $(contents).filter('input, textarea');

            fields.each(function (idx) { // same as 'for' jQuery API
                var $t = $(this);
                var name = $t.attr('name'); 
                var value = $t.val();

                console.log(idx, name, value); 

                if (name != 'changeVal_61' && value == '') { //The signature completion statement is excluded 
                    var rename = strReplaceRtn('', name);
                    alert('${BECM_040_0036}' + rename + '${BECM_040_0037}');
                    rtnMsg = "NO";
                    return false; // - break, return true - continue;
                }
            });
            return rtnMsg;
        }

        function strReplaceRtn(formNum, code) {
            var name = "";
            //공통
            if (code == 'CONT_START_DATE') {
            	name = '${BECM_040_0038}';
                return name;
            }
            if (code == 'CONT_END_DATE') {
            	name = '${BECM_040_0039}';
                return name;
            }
            if (code == 'CONT_DATE') {
            	name = '${BECM_040_0040}';
                return name;
            }
            if (code == 'CONT_NUM') {
            	name = '${BECM_040_0041}';
                return name;
            }
            if (code == 'CONT_DESC') {
            	name = '${BECM_040_0042}';
                return name;
            }
            if (code == 'CONT_AMT') {
            	name = '${BECM_040_0043}';
                return name;
            }
            if (code == 'CONT_AMT_KR') {
            	name = '${BECM_040_0044}';
                return name;
            }
            if (code == 'changeVal_00') {
            	name = '${BECM_040_0045}';
                return name;
            }
            if (code == 'changeVal_99') {
            	name = '${BECM_040_0046}';
                return name;
            }
            if (code == 'changeTxt_00') {
            	name = '${BECM_040_0047}';
                return name;
            }

            if (name == '')    name = code;
            return name;
        }
        function doClose() {
            window.close();
        }


    </script>

    <e:window id="BECM_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" margin="0 4px">
        <e:buttonBar id="buttonBar" align="right" width="100%">
          <%--   <c:if test="${ses.userType == 'C' && ses.ctrlCd != ''}">
                <c:if test="${param.PROGRESS_CD == '' or param.PROGRESS_CD =='4200' or param.PROGRESS_CD =='4220'}"> 최초작성이거나 작성중이거나 반려일 경우만
                    <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
                </c:if>
            </c:if>
            <c:if test="${param.vendorEditFlag == '1' and param.PROGRESS_CD == '4210'}">
                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            </c:if> --%>
   		 <%--       <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/> --%>
        </e:buttonBar>

        <e:inputHidden id="contNum" name="contNum" value="${param.contNum}"/>
        <e:inputHidden id="contCnt" name="contCnt" value="${param.contCnt}"/>
        <e:inputHidden id="formContents" name="formContents" value="${form.formContents}"/>

        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelWidth }" onEnter="doSearch" useTitleBar="false">
            <e:row>
                <e:field colSpan="6">
                    <textarea id=addCont_content name="addCont_content" style="width:100%;">${form.formContents}</textarea>
                </e:field>
            </e:row>
        </e:searchPanel>
    </e:window>
</e:ui>
