<%--기준정보 > 고객사정보관리 > 고객사관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;

        function init() {
            grid = EVF.C("${form.gridID}");
            grid.setProperty('multiSelect', false);
            grid.cellClickEvent(function(rowId, colId, value) {

            });

            grid.excelExportEvent({
                fileName : "${screenName }"
            });

            // 데이터 셋팅
            var val = opener.${form.gridID}.getAllRowValue();
            for(var i in val) {
                grid.addRow(val[i])
            }

            var columns = grid._gvo.getColumnNames();
            for(var i in columns) {
                if(columns[i].indexOf('$TP') > -1) {
                    var oli = columns[i].replace('_$TP', '');
                    var tp = columns[i];
                    var oli_width = grid._gvo.getColumnProperty(oli, 'width');

                    grid.setColWidth(tp, oli_width);
                    grid.setColWidth(oli, 0);

                    var index = grid._gdp.getFieldIndex(oli);
                    grid._gvo.setColumnProperty(tp, "displayIndex", index);
                }
            }
        }

    </script>

    <e:window id="${form.SCREEN_ID}" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:gridPanel id="${form.gridID}" name="${form.gridID}" width="100%" height="fit" gridType="${_gridType}"/>
    </e:window>
</e:ui>