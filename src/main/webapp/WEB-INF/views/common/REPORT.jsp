<%--
  Date: 2023-07-20
  Time: 14:57:19
  Scrren ID : REPORT
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<body>
    <div style="display: none;">
        <form id="report"  method="POST">
            <input type="hidden" id="json" name="json" value="">
            <input type="submit" id="reportBt" value="Submit">
        </form>
    </div>

    <script>
        var param = ${paramInfo};
        var data  = {};
        data.param  = param;

        if("${callType2}" == "J"){
            data.jsonData = ${jsonData};
        }else{
            var filem = "${filenm}".split(", ");
            data.filenm = filem;
        }

        $("#json").val(JSON.stringify(data,null,2));
        $("#report").attr('action',"${url}");
        $("#reportBt").click();
    </script>
</body>
</e:ui>
