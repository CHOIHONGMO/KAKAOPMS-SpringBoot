<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var grid = {};
		var baseUrl = "/eversrm/eContract/formMgt/BECF_020/";

		function init() {

			EVF.C('FORM_NUM').setValue('${param.formNo}');
			if (window.focus) {
				window.focus();
			}

			grid = EVF.C("grid");
			doSelect();
		}

		function doSelect() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

			store.setGrid([ grid ]);
			store.load(baseUrl + 'doSelect', function() {
				if (this.getParameter('formText') !== undefined) {
					formText.setContents(this.getParameter('formText'));
				}
			});
		}

		function onSave() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

			if (!confirm("${msg.M0021 }")) {
				return;
			}

			store.setGrid([ grid ]);
			store.getGridData(grid, 'sel');
			store.setParameter('formText', formText.getContents());
			store.load(baseUrl + 'doSave', function() {
				alert(this.getResponseMessage());
				doSelect();
			});
		}

		function openDeptCodePopup() {
			everPopup.openCommonPopup({
				callBackFunction : 'deptCodeCallback',
				BUYER_CD : '${ses.companyCd}'
			}, 'SP0002');
		}

		function deptCodeCallback(result) {
			EVF.C('DEPT_CD').setValue(result.DEPT_CD);
			EVF.C('DEPT_NM').setValue(result.DEPT_NM);
		}

		function onClose() {
			window.close();
		}
	</script>

	<e:window id="BECF_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="onSave" name="onSave" label="${onSave_N }" disabled="${onSave_D }" onClick="onSave" />
			<e:button id="onClose" name="onClose" label="${onClose_N }" disabled="${onClose_D }" onClick="onClose" />
			<e:button id="doSelect" name="doSelect" label="${doSelect_N }" disabled="${doSelect_D }" onClick="doSelect" />
		</e:buttonBar>

		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" labelWidth="${labelWidth }" onEnter="doSearch">
			<e:inputHidden id="FORM_NUM" name="FORM_NUM" value="" />
			<e:inputHidden id="FORM_TEXT_NUM" name="FORM_TEXT_NUM" value="" />
			<e:row>
				<e:label for="FORM_TYPE" title="${form_FORM_TYPE_N }" />
				<e:field>
					<e:select id="FORM_TYPE" name="FORM_TYPE" value="0" options="${formTypes}" readOnly="${form_FORM_TYPE_RO }" width="160" required="${form_FORM_TYPE_R }" disabled="${form_FORM_TYPE_D }" />
				</e:field>
				<e:label for="FORM_NM" title="${form_FORM_NM_N }" />
				<e:field>
					<e:inputText id="FORM_NM" name="FORM_NM" width="80%" required="${form_FORM_NM_R }" disabled="${form_FORM_NM_D }" value="" readOnly="${form_FORM_NM_RO }" maxLength="${form_FORM_NM_M}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="DEPT_CD" title="${form_DEPT_CD_N }" />
				<e:field>
					<e:inputText id="DEPT_CD" name="DEPT_CD" width="80%" required="${form_DEPT_CD_R }" disabled="${form_DEPT_CD_D }" value="" readOnly="${form_DEPT_CD_RO }" maxLength="${form_DEPT_CD_M}" />
				</e:field>
				<e:label for="DEPT_NM" title="${form_DEPT_NM_N }" />
				<e:field>
					<e:search id="DEPT_NM" name="DEPT_NM" width="80%" maxLength="${form_DEPT_NM_M }" required="${form_DEPT_NM_R }" disabled="${form_DEPT_NM_D }" readOnly="${form_DEPT_NM_RO }" value="" onIconClick="openDeptCodePopup" />
				</e:field>
			</e:row>
			<%--         	
        	<e:row>
				<c:import url="/wisec/common/generator/contEditorGen.wu">
					<c:param name="contentId">formText</c:param>
					<c:param name="langCd">${ses.langCd}</c:param>
				</c:import>
        	</e:row>
			--%>
		</e:searchPanel>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
