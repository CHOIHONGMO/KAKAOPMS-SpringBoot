<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var gridDO         = {};
	var gridInvoice    = {};
	var gridGR         = {};
	var gridTaxInvoice = {};

    var baseUrl = "/eversrm/po/poMgt/poProgress/BPOP_050/";

    function init() {
        gridDO         = EVF.getComponent("gridDO");
        gridInvoice    = EVF.getComponent("gridInvoice");
        gridGR         = EVF.getComponent("gridGR");
        gridTaxInvoice = EVF.getComponent("gridTaxInvoice");


        var editor = EVF.C('DO_RMK').getInstance();
        editor.config.contentsCss  = "/css/richText.css";
        editor.config.allowedContent = true;

		gridDO.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				  imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
    })
        gridInvoice.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				  imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
    })
        gridGR.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				  imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
    })
        gridTaxInvoice.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				  imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
    })
        if ("${poItemList}" != "") {
            EVF.getComponent("itemCd").selectByIndex(0);
        }

        EVF.getComponent("itemCd").setValue('${poSq}');

        doSearch();
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
		getContentTab('1');

	});

    function getContentTab(uu) {
		if (uu == '1') {
			window.scrollbars = true;
		}
		if (uu == '2') {
			window.scrollbars = true;
		}
		if (uu == '3') {
			window.scrollbars = true;
		}
		if (uu == '4') {
			window.scrollbars = true;
		}
	}

    function doSearch() {
        EVF.getComponent("poSq").setValue(EVF.getComponent("itemCd").getValue());

    	var store = new EVF.Store();
		if(!store.validate()) { return; }

    	store.setGrid([gridDO,gridInvoice,gridGR,gridTaxInvoice]);
        store.load(baseUrl + 'doSearch', function() {
            EVF.getComponent("DO_RMK").setValue(this.getParameter("rmkText"));
            EVF.getComponent("DO_ATT_FILE_NUM").setValue(this.getParameter("attFileNum"));
        });
    }

    </script>

	<e:window id="BPOP_050" onReady="init" initData="${initData}" title="" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" onEnter="doSearch">
			<e:inputHidden id="poNum" name="poNum" value="${poNum}" />
			<e:inputHidden id="poSq" name="poSq" value="${poSq}" />

			<e:row>
				<e:field>
					<e:select id="itemCd" name="itemCd" value="" options="${poItemList}" width="${inputTextWidth}" disabled="${form_itemCd_D}" readOnly="${form_itemCd_RO}" required="${form_itemCd_R}" placeHolder="" />
				</e:field>

			</e:row>
		</e:searchPanel>

		<e:panel id="pnl2" width="100%">
			<div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
				<ul>
					<li><a href="#ui-tabs-1" onclick="getContentTab('1');">${BPOP_050_DO_CAPTION }</a></li>
					<li><a href="#ui-tabs-2" onclick="getContentTab('2');">${BPOP_050_INVOICE_CAPTION }</a></li>
					<li><a href="#ui-tabs-3" onclick="getContentTab('3');">${BPOP_050_GR_CAPTION }</a></li>
					<li><a href="#ui-tabs-4" onclick="getContentTab('4');">${BPOP_050_TAX_CAPTION }</a></li>
				</ul>
				<e:panel id="pnl2_sub" width="100%">
					<div id="ui-tabs-1">

						<e:gridPanel gridType="${_gridType}" id="gridDO" name="gridDO" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridDO.gridColData}" />
						<e:searchPanel id="form2" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" height="200px" width="100%" columnCount="2">
							<e:row>
								<e:label for="DO_RMK" title="${form_DO_RMK_N}"></e:label>
								<e:field colSpan="3">
									<e:richTextEditor id="DO_RMK" width="100%" name="DO_RMK" value="${rmkText}" label="${DO_RMK_N }" height="150" disabled="${form_DO_RMK_D }" visible="${form_DO_RMK_V }" readOnly="${form_DO_RMK_RO }" required="${form_DO_RMK_R }" />
								</e:field>

								<e:inputText id="DO_ATT_FILE_NUM" name="DO_ATT_FILE_NUM" value="${attFileNum}" width="100%" maxLength="${form_DO_ATT_FILE_NUM_M}" disabled="${form_DO_ATT_FILE_NUM_D}" readOnly="${form_DO_ATT_FILE_NUM_RO}" required="${form_DO_ATT_FILE_NUM_R}" />
							</e:row>
						</e:searchPanel>

					</div>
					<div id="ui-tabs-2">
						<e:gridPanel gridType="${_gridType}" id="gridInvoice" name="gridInvoice" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridInvoice.gridColData}" />
					</div>
					<div id="ui-tabs-3">
						<e:gridPanel gridType="${_gridType}" id="gridGR" name="gridGR" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridGR.gridColData}" />
					</div>
					<div id="ui-tabs-4">
						<e:gridPanel gridType="${_gridType}" id="gridTaxInvoice" name="gridTaxInvoice" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridTaxInvoice.gridColData}" />
					</div>
				</e:panel>
			</div>

		</e:panel>

	</e:window>
</e:ui>
