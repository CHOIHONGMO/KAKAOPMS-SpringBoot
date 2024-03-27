<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid1 = {};
        var grid2 = {};
        var addParam = [];
        var baseUrl = "/eversrm/basic/messate/";

        function init() {
            //alert('${param.sendType}')


            var editor = EVF.C('CAPTION').getInstance();
            editor.config.contentsCss  = "/css/richText.css";
            editor.config.allowedContent = true;
        }

        function do2Close() {
            window.close();
        }
    </script>
    <e:window id="BSN_080" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="1">
            <c:choose>
                <c:when test="${param.sendType == 'M'}">
                    <e:row>
                        <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
                        <e:field>
                            <e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
                        </e:field>
                    </e:row>
                </c:when>
                <c:otherwise>
                </c:otherwise>
            </c:choose>
            <e:row>
                <e:label for="CAPTION" title="${form_CAPTION_N }"/>
                <e:field>
                    <e:richTextEditor height="530px" id="CAPTION" name="CAPTION" width="100%" required="${form_CAPTION_R }" readOnly="${form_CAPTION_RO }" disabled="${form_CAPTION_D }" value="${form.CONTENTS }"/>
                    <%--<e:inputText id="CONTENTS" name="CONTENTS" value="${form.CONTENTS}" width="100%"  height="490px" maxLength="${form_CONTENTS_M}" disabled="${form_CONTENTS_D}" readOnly="${form_CONTENTS_RO}" required="${form_CONTENTS_R}"/>--%>

                </e:field>
            </e:row>
        </e:searchPanel>
    </e:window>
</e:ui>