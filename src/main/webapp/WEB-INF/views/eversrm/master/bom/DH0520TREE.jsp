<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>


<e:ui locale="${ses.countryCd}">
	<link rel="StyleSheet" href="/js/dtree/dtree.css" type="text/css" />
	<script type="text/javascript" src="/js/dtree/dtree.js"></script>
	<script>
		var baseUrl = "/eversrm/master/bom/DH0520TREE";

		var rootId, rootRev;

		function init() {
			rootId = '${param.BOM_ID}';
			rootRev = '${param.BOM_REV}';

			doSearch();
		}

		function doSearch() {
			var store = new EVF.Store();
			store.setParameter('BOM_ID', rootId);
			store.setParameter('BOM_REV', rootRev);

			store.load(baseUrl + '/doSearch', function() {
				var treeData = this.getParameter("treeData");
				var jsontree = JSON.parse(treeData);
				d = new dTree('d');

				for (var k = 0; k < jsontree.length; k++) {
					if (k == 0) {
						d.add(0, -1, jsontree[k].MAT_GROUP, '', '');
					}

					d.add(jsontree[k].BOM_ID,
						  jsontree[k].PARENT_BOM_ID,
						  jsontree[k].ITEM_DESC + ' [' + jsontree[k].ITEM_CD + '] (' + jsontree[k].ITEM_QT + ')',
						  jsontree[k].BOM_ID,
						  JSON.stringify(jsontree[k]));
				}

				document.getElementById("tree").innerHTML = d;

				d.openAll();
			});
		}

		function goTarget(bom_id) {

			var nodeData = JSON.parse(d.aNodes[d.selectedNode].data);

			if (nodeData == null)
				return;

			EVF.getComponent('CUR_BOM_ID').setValue(nodeData.BOM_ID);
			EVF.getComponent('CUR_PARENT_BOM_ID').setValue(nodeData.PARENT_BOM_ID);
			EVF.getComponent('CUR_BOM_SQ').setValue(nodeData.BOM_SQ);

			<%-- hidden --%>
			EVF.getComponent('BOM_ID').setValue(nodeData.BOM_ID);
			EVF.getComponent('PARENT_BOM_ID').setValue(nodeData.PARENT_BOM_ID);
			EVF.getComponent('TOP_ITEM_CD').setValue(nodeData.TOP_ITEM_CD);
			EVF.getComponent('OLD_BOM_REV').setValue(nodeData.OLD_BOM_REV);

			<%-- Node Data --%>
			EVF.getComponent('ITEM_CD').setValue(nodeData.ITEM_CD);
			EVF.getComponent('ITEM_DESC').setValue(nodeData.ITEM_DESC);
			EVF.getComponent('MAT_GROUP').setValue(nodeData.MAT_GROUP);
			EVF.getComponent('PARENT_ITEM_CD').setValue(nodeData.PARENT_ITEM_CD);
			EVF.getComponent('ITEM_QT').setValue(nodeData.ITEM_QT);
			EVF.getComponent('UNIT_CD').setValue(nodeData.UNIT_CD);
			EVF.getComponent('BOM_REV').setValue(nodeData.BOM_REV);
			EVF.getComponent('BOM_SQ').setValue(nodeData.BOM_SQ);
			EVF.getComponent('EO_NO').setValue(nodeData.EO_NO);
			EVF.getComponent('EO_DATE').setValue(nodeData.EO_DATE);

			EVF.getComponent('MATERIAL_GRADE').setValue(nodeData.MATERIAL_GRADE);
			EVF.getComponent('MATERIAL_SPEC').setValue(nodeData.MATERIAL_SPEC);
			EVF.getComponent('MATERIAL_THICKNESS').setValue(nodeData.MATERIAL_THICKNESS);
			EVF.getComponent('SURFACE_TR_GRADE').setValue(nodeData.SURFACE_TR_GRADE);
			EVF.getComponent('SURFACE_TR_SPEC').setValue(nodeData.SURFACE_TR_SPEC);
			EVF.getComponent('DESIGN_WEIGHT').setValue(nodeData.DESIGN_WEIGHT);
			EVF.getComponent('SHOW_ON_DRAWING').setValue(nodeData.SHOW_ON_DRAWING);
			EVF.getComponent('REMARK').setValue(nodeData.REMARK);
			EVF.getComponent('ITEM_REV').setValue(nodeData.ITEM_REV);
			EVF.getComponent('SUPPLIER').setValue(nodeData.SUPPLIER);
			EVF.getComponent('SUPPLIER_CODE').setValue(nodeData.SUPPLIER_CODE);
			EVF.getComponent('COMPLETE_PROJ_NO').setValue(nodeData.COMPLETE_PROJ_NO);
			EVF.getComponent('PART_PROJ_NO').setValue(nodeData.PART_PROJ_NO);
			EVF.getComponent('EO_CHILD_NO').setValue(nodeData.EO_CHILD_NO);
			EVF.getComponent('EA').setValue(nodeData.EA);
			EVF.getComponent('GR_FLAG').setValue(nodeData.GR_FLAG);

			<%-- Add Data --%>
			EVF.getComponent('MAT_CD').setValue(nodeData.MAT_CD);
			EVF.getComponent('NET_WGT').setValue(nodeData.NET_WGT);
			EVF.getComponent('SPEC').setValue(nodeData.SPEC);
			EVF.getComponent('WEIGHT').setValue(nodeData.WEIGHT);
			EVF.getComponent('THICK').setValue(nodeData.THICK);
			EVF.getComponent('COLL_LOSS_RTO').setValue(nodeData.COLL_LOSS_RTO);
			EVF.getComponent('WIDTH').setValue(nodeData.WIDTH);
			EVF.getComponent('HEIGHT').setValue(nodeData.HEIGHT);
			EVF.getComponent('BL_WIDTH').setValue(nodeData.BL_WIDTH);
			EVF.getComponent('BL_HEIGHT').setValue(nodeData.BL_HEIGHT);
			EVF.getComponent('CVT').setValue(nodeData.CVT);
		}

	    // 저장
	    function doSave() {

			if (EVF.getComponent('CUR_BOM_ID').getValue() == "") {
				alert('${msg.M0004}');
				return;
			}

 			var store = new EVF.Store();
			if(!store.validate()) { return; }

			if(!confirm('${msg.M0021}')) { return; }

			if (EVF.getComponent('BOM_REV').getValue() != EVF.getComponent('OLD_BOM_REV').getValue()) {
				if (Number(rootRev) < Number(EVF.getComponent('BOM_REV').getValue())) {
					rootRev = EVF.getComponent('BOM_REV').getValue();
				}
			}

			store.load(baseUrl+'/doSave', function() {
 		    	alert(this.getResponseMessage());
 		        doSearch();
 		    });
	    }

	    // 초기화
	    function doReset() {
			if (EVF.getComponent('CUR_BOM_ID').getValue() == "") {
				alert('${DH0520TREE_0001}');
				return;
			}

			<%-- Node Data --%>
			EVF.getComponent('ITEM_CD').setValue("");
			EVF.getComponent('ITEM_DESC').setValue("");
			EVF.getComponent('MAT_GROUP').setValue("");
			EVF.getComponent('PARENT_ITEM_CD').setValue("");
			EVF.getComponent('ITEM_QT').setValue("");
			EVF.getComponent('UNIT_CD').setValue("");
			EVF.getComponent('BOM_REV').setValue("");
			EVF.getComponent('BOM_SQ').setValue("");
			EVF.getComponent('EO_NO').setValue("");
			EVF.getComponent('EO_DATE').setValue("");

			EVF.getComponent('MATERIAL_GRADE').setValue("");
			EVF.getComponent('MATERIAL_SPEC').setValue("");
			EVF.getComponent('MATERIAL_THICKNESS').setValue("");
			EVF.getComponent('SURFACE_TR_GRADE').setValue("");
			EVF.getComponent('SURFACE_TR_SPEC').setValue("");
			EVF.getComponent('DESIGN_WEIGHT').setValue("");
			EVF.getComponent('SHOW_ON_DRAWING').setValue("");
			EVF.getComponent('REMARK').setValue("");
			EVF.getComponent('ITEM_REV').setValue("");
			EVF.getComponent('SUPPLIER').setValue("");
			EVF.getComponent('SUPPLIER_CODE').setValue("");
			EVF.getComponent('COMPLETE_PROJ_NO').setValue("");
			EVF.getComponent('PART_PROJ_NO').setValue("");
			EVF.getComponent('EO_CHILD_NO').setValue("");
			EVF.getComponent('EA').setValue("");
			EVF.getComponent('GR_FLAG').setValue("");

			<%-- Add Data --%>
			EVF.getComponent('MAT_CD').setValue("");
			EVF.getComponent('NET_WGT').setValue("");
			EVF.getComponent('SPEC').setValue("");
			EVF.getComponent('WEIGHT').setValue("");
			EVF.getComponent('THICK').setValue("");
			EVF.getComponent('COLL_LOSS_RTO').setValue("");
			EVF.getComponent('WIDTH').setValue("");
			EVF.getComponent('HEIGHT').setValue("");
			EVF.getComponent('BL_WIDTH').setValue("");
			EVF.getComponent('BL_HEIGHT').setValue("");
			EVF.getComponent('CVT').setValue("");

	    }

	    // 동등레벨추가
	    function doSameLevelInsert() {

			if (EVF.getComponent('CUR_BOM_ID').getValue() == "") {
				alert('${msg.M0004}');
				return;
			}

 			var store = new EVF.Store();
			if(!store.validate()) { return; }

			if(!confirm('${msg.M0011}')) { return; }

			EVF.getComponent('BOM_ID').setValue("");
			EVF.getComponent('PARENT_BOM_ID').setValue(EVF.getComponent('CUR_PARENT_BOM_ID').getValue());

			EVF.getComponent('OLD_BOM_REV').setValue(EVF.getComponent('BOM_REV').getValue());
			if (Number(rootRev) < Number(EVF.getComponent('BOM_REV').getValue())) {
				rootRev = EVF.getComponent('BOM_REV').getValue();
			}
			if (EVF.getComponent('BOM_SQ').getValue() == "") {
				EVF.getComponent('BOM_SQ').setValue("1");
			}

			store.load(baseUrl+'/doSameLevelInsert', function() {
 		    	alert(this.getResponseMessage());
 		        doSearch();
 		    });

	    }

	    // 하위레벨추가
	    function doLowLevelInsert() {

			if (EVF.getComponent('CUR_BOM_ID').getValue() == "") {
				alert('${msg.M0004}');
				return;
			}

 			var store = new EVF.Store();
			if(!store.validate()) { return; }

			if(!confirm('${msg.M0011}')) { return; }

			EVF.getComponent('BOM_ID').setValue("");
			EVF.getComponent('PARENT_BOM_ID').setValue(EVF.getComponent('CUR_BOM_ID').getValue());

			EVF.getComponent('OLD_BOM_REV').setValue(EVF.getComponent('BOM_REV').getValue());
			if (Number(rootRev) < Number(EVF.getComponent('BOM_REV').getValue())) {
				rootRev = EVF.getComponent('BOM_REV').getValue();
			}
			EVF.getComponent('BOM_SQ').setValue("1");

			store.load(baseUrl+'/doSameLevelInsert', function() {
 		    	alert(this.getResponseMessage());
 		        doSearch();
 		    });

	    }

	    // 삭제
	    function doDelete() {

			if (EVF.getComponent('CUR_BOM_ID').getValue() == "") {
				alert('${msg.M0004}');
				return;
			}

 			var store = new EVF.Store();

			if(!confirm('${msg.M0013}')) { return; }

			store.load(baseUrl+'/doDelete', function() {
 		    	alert(this.getResponseMessage());
 		        doSearch();
 		    });
	    }

	</script>

	<e:window id="DH0520TREE" onReady="init" initData="${initData}" title="${fullScreenName}"
		breadCrumbs="${breadCrumb }">
		<e:panel id="leftPanel" width="40%">
			<div id="tree" style="height: 710px; overflow: auto;"></div>
		</e:panel>

		<e:panel width="1%">&nbsp;</e:panel>
		<e:panel id="rightPanel" width="58%">
			<e:buttonBar width="100%" align="right">
				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
				<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}" />
				<e:button id="doReset" name="doReset" label="${doReset_N}" onClick="doReset" disabled="${doReset_D}" visible="${doReset_V}" />
				<e:button id="doSameLevelInsert" name="doSameLevelInsert" label="${doSameLevelInsert_N}" onClick="doSameLevelInsert" disabled="${doSameLevelInsert_D}" visible="${doSameLevelInsert_V}" />
				<e:button id="doLowLevelInsert" name="doLowLevelInsert" label="${doLowLevelInsert_N}" onClick="doLowLevelInsert" disabled="${doLowLevelInsert_D}" visible="${doLowLevelInsert_V}" />
			</e:buttonBar>

			<e:searchPanel id="form" title="${form_NODE_INFO_N }" labelWidth="130" width="100%" columnCount="2" useTitleBar="true" onEnter="">
				<e:inputHidden id="CUR_BOM_ID" name="CUR_BOM_ID" value="${form.CUR_BOM_ID}" />
				<e:inputHidden id="CUR_PARENT_BOM_ID" name="CUR_PARENT_BOM_ID" value="${form.CUR_PARENT_BOM_ID}" />
				<e:inputHidden id="CUR_BOM_SQ" name="CUR_BOM_SQ" value="${form.CUR_BOM_SQ}" />

				<e:inputHidden id="BOM_ID" name="BOM_ID" value="${form.BOM_ID}" />
				<e:inputHidden id="PARENT_BOM_ID" name="PARENT_BOM_ID" value="${form.PARENT_BOM_ID}" />
				<e:inputHidden id="TOP_ITEM_CD" name="TOP_ITEM_CD" value="${form.TOP_ITEM_CD}" />
				<e:inputHidden id="OLD_BOM_REV" name="OLD_BOM_REV" value="${form.OLD_BOM_REV}" />

				<e:row>
					<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
					<e:field>
						<e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
					</e:field>
					<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
					<e:field>
						<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}" />
					<e:field>
						<e:inputText id="MAT_GROUP" style="ime-mode:inactive" name="MAT_GROUP" value="${form.MAT_GROUP}" width="${inputTextWidth}" maxLength="${form_MAT_GROUP_M}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" />
					</e:field>
					<e:label for="PARENT_ITEM_CD" title="${form_PARENT_ITEM_CD_N}" />
					<e:field>
						<e:inputText id="PARENT_ITEM_CD" style="ime-mode:inactive" name="PARENT_ITEM_CD" value="${form.PARENT_ITEM_CD}" width="${inputTextWidth}" maxLength="${form_PARENT_ITEM_CD_M}" disabled="${form_PARENT_ITEM_CD_D}" readOnly="${form_PARENT_ITEM_CD_RO}" required="${form_PARENT_ITEM_CD_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="ITEM_QT" title="${form_ITEM_QT_N}" />
					<e:field>
						<e:inputNumber id="ITEM_QT" name="ITEM_QT" value="${form.ITEM_QT}" maxValue="${form_ITEM_QT_M}" decimalPlace="${form_ITEM_QT_NF}" disabled="${form_ITEM_QT_D}" readOnly="${form_ITEM_QT_RO}" required="${form_ITEM_QT_R}" />
					</e:field>
	                <e:label for="UNIT_CD" title="${form_UNIT_CD_N}" />
    	            <e:field>
        	            <e:select id="UNIT_CD" name="UNIT_CD" value="${form.UNIT_CD}" options="${unitCdOptions}" width="${inputTextWidth}" disabled="${form_UNIT_CD_D}" readOnly="${form_UNIT_CD_RO}" required="${form_UNIT_CD_R}" placeHolder="" />
            	    </e:field>
				</e:row>
				<e:row>
					<e:label for="BOM_REV" title="${form_BOM_REV_N}" />
					<e:field>
						<e:inputNumber id="BOM_REV" name="BOM_REV" value="${form.BOM_REV}" maxValue="${form_BOM_REV_M}" decimalPlace="${form_BOM_REV_NF}" disabled="${form_BOM_REV_D}" readOnly="${form_BOM_REV_RO}" required="${form_BOM_REV_R}" />
					</e:field>
					<e:label for="BOM_SQ" title="${form_BOM_SQ_N}" />
					<e:field>
						<e:inputNumber id="BOM_SQ" name="BOM_SQ" value="${form.BOM_SQ}" maxValue="${form_BOM_SQ_M}" decimalPlace="${form_BOM_SQ_NF}" disabled="${form_BOM_SQ_D}" readOnly="${form_BOM_SQ_RO}" required="${form_BOM_SQ_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="EO_NO" title="${form_EO_NO_N}" />
					<e:field>
						<e:inputText id="EO_NO" style="ime-mode:inactive" name="EO_NO" value="${form.EO_NO}" width="${inputTextWidth}" maxLength="${form_EO_NO_M}" disabled="${form_EO_NO_D}" readOnly="${form_EO_NO_RO}" required="${form_EO_NO_R}" />
					</e:field>
					<e:label for="EO_DATE" title="${form_EO_DATE_N}" />
					<e:field>
						<e:inputDate id="EO_DATE" name="EO_DATE" value="${form.EO_DATE}" width="${inputTextDate}" datePicker="true" required="${form_EO_DATE_R}" disabled="${form_EO_DATE_D}" readOnly="${form_EO_DATE_RO}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="MATERIAL_GRADE" title="${form_MATERIAL_GRADE_N}" />
					<e:field>
						<e:inputText id="MATERIAL_GRADE" style="ime-mode:inactive" name="MATERIAL_GRADE" value="${form.MATERIAL_GRADE}" width="${inputTextWidth}" maxLength="${form_MATERIAL_GRADE_M}" disabled="${form_MATERIAL_GRADE_D}" readOnly="${form_MATERIAL_GRADE_RO}" required="${form_MATERIAL_GRADE_R}" />
					</e:field>
					<e:label for="MATERIAL_SPEC" title="${form_MATERIAL_SPEC_N}" />
					<e:field>
						<e:inputText id="MATERIAL_SPEC" style="ime-mode:inactive" name="MATERIAL_SPEC" value="${form.MATERIAL_SPEC}" width="100%" maxLength="${form_MATERIAL_SPEC_M}" disabled="${form_MATERIAL_SPEC_D}" readOnly="${form_MATERIAL_SPEC_RO}" required="${form_MATERIAL_SPEC_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="MATERIAL_THICKNESS" title="${form_MATERIAL_THICKNESS_N}" />
					<e:field>
						<e:inputText id="MATERIAL_THICKNESS" style="ime-mode:inactive" name="MATERIAL_THICKNESS" value="${form.MATERIAL_THICKNESS}" width="100%" maxLength="${form_MATERIAL_THICKNESS_M}" disabled="${form_MATERIAL_THICKNESS_D}" readOnly="${form_MATERIAL_THICKNESS_RO}" required="${form_MATERIAL_THICKNESS_R}" />
					</e:field>
					<e:label for="SURFACE_TR_GRADE" title="${form_SURFACE_TR_GRADE_N}" />
					<e:field>
						<e:inputText id="SURFACE_TR_GRADE" style="ime-mode:inactive" name="SURFACE_TR_GRADE" value="${form.SURFACE_TR_GRADE}" width="100%" maxLength="${form_SURFACE_TR_GRADE_M}" disabled="${form_SURFACE_TR_GRADE_D}" readOnly="${form_SURFACE_TR_GRADE_RO}" required="${form_SURFACE_TR_GRADE_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="SURFACE_TR_SPEC" title="${form_SURFACE_TR_SPEC_N}" />
					<e:field>
						<e:inputText id="SURFACE_TR_SPEC" style="ime-mode:inactive" name="SURFACE_TR_SPEC" value="${form.SURFACE_TR_SPEC}" width="100%" maxLength="${form_SURFACE_TR_SPEC_M}" disabled="${form_SURFACE_TR_SPEC_D}" readOnly="${form_SURFACE_TR_SPEC_RO}" required="${form_SURFACE_TR_SPEC_R}" />
					</e:field>
					<e:label for="DESIGN_WEIGHT" title="${form_DESIGN_WEIGHT_N}" />
					<e:field>
						<e:inputText id="DESIGN_WEIGHT" style="ime-mode:inactive" name="DESIGN_WEIGHT" value="${form.DESIGN_WEIGHT}" width="100%" maxLength="${form_DESIGN_WEIGHT_M}" disabled="${form_DESIGN_WEIGHT_D}" readOnly="${form_DESIGN_WEIGHT_RO}" required="${form_DESIGN_WEIGHT_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="SHOW_ON_DRAWING" title="${form_SHOW_ON_DRAWING_N}" />
					<e:field>
						<e:inputText id="SHOW_ON_DRAWING" style="ime-mode:inactive" name="SHOW_ON_DRAWING" value="${form.SHOW_ON_DRAWING}" width="100%" maxLength="${form_SHOW_ON_DRAWING_M}" disabled="${form_SHOW_ON_DRAWING_D}" readOnly="${form_SHOW_ON_DRAWING_RO}" required="${form_SHOW_ON_DRAWING_R}" />
					</e:field>
					<e:label for="REMARK" title="${form_REMARK_N}" />
					<e:field>
						<e:inputText id="REMARK" style="${imeMode}" name="REMARK" value="${form.REMARK}" width="100%" maxLength="${form_REMARK_M}" disabled="${form_REMARK_D}" readOnly="${form_REMARK_RO}" required="${form_REMARK_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="ITEM_REV" title="${form_ITEM_REV_N}" />
					<e:field>
						<e:inputText id="ITEM_REV" style="ime-mode:inactive" name="ITEM_REV" value="${form.ITEM_REV}" width="100%" maxLength="${form_ITEM_REV_M}" disabled="${form_ITEM_REV_D}" readOnly="${form_ITEM_REV_RO}" required="${form_ITEM_REV_R}" />
					</e:field>
					<e:label for="SUPPLIER" title="${form_SUPPLIER_N}" />
					<e:field>
						<e:inputText id="SUPPLIER" style="${imeMode}" name="SUPPLIER" value="${form.SUPPLIER}" width="100%" maxLength="${form_SUPPLIER_M}" disabled="${form_SUPPLIER_D}" readOnly="${form_SUPPLIER_RO}" required="${form_SUPPLIER_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="SUPPLIER_CODE" title="${form_SUPPLIER_CODE_N}" />
					<e:field>
						<e:inputText id="SUPPLIER_CODE" style="ime-mode:inactive" name="SUPPLIER_CODE" value="${form.SUPPLIER_CODE}" width="100%" maxLength="${form_SUPPLIER_CODE_M}" disabled="${form_SUPPLIER_CODE_D}" readOnly="${form_SUPPLIER_CODE_RO}" required="${form_SUPPLIER_CODE_R}" />
					</e:field>
					<e:label for="COMPLETE_PROJ_NO" title="${form_COMPLETE_PROJ_NO_N}" />
					<e:field>
						<e:inputText id="COMPLETE_PROJ_NO" style="ime-mode:inactive" name="COMPLETE_PROJ_NO" value="${form.COMPLETE_PROJ_NO}" width="100%" maxLength="${form_COMPLETE_PROJ_NO_M}" disabled="${form_COMPLETE_PROJ_NO_D}" readOnly="${form_COMPLETE_PROJ_NO_RO}" required="${form_COMPLETE_PROJ_NO_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="PART_PROJ_NO" title="${form_PART_PROJ_NO_N}" />
					<e:field>
						<e:inputText id="PART_PROJ_NO" style="ime-mode:inactive" name="PART_PROJ_NO" value="${form.PART_PROJ_NO}" width="100%" maxLength="${form_PART_PROJ_NO_M}" disabled="${form_PART_PROJ_NO_D}" readOnly="${form_PART_PROJ_NO_RO}" required="${form_PART_PROJ_NO_R}" />
					</e:field>
					<e:label for="EO_CHILD_NO" title="${form_EO_CHILD_NO_N}" />
					<e:field>
						<e:inputText id="EO_CHILD_NO" style="ime-mode:inactive" name="EO_CHILD_NO" value="${form.EO_CHILD_NO}" width="100%" maxLength="${form_EO_CHILD_NO_M}" disabled="${form_EO_CHILD_NO_D}" readOnly="${form_EO_CHILD_NO_RO}" required="${form_EO_CHILD_NO_R}" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="EA" title="${form_EA_N}" />
					<e:field>
						<e:inputNumber id="EA" name="EA" value="${form.EA}" maxValue="${form_EA_M}" decimalPlace="${form_EA_NF}" disabled="${form_EA_D}" readOnly="${form_EA_RO}" required="${form_EA_R}" />
					</e:field>
			        <e:label for="GR_FLAG" title="${form_GR_FLAG_N}"/>
			        <e:field>
			          <e:select id="GR_FLAG" name="GR_FLAG" value="${form.GR_FLAG}" options="${grFlagOptions}" width="${inputTextWidth}" disabled="${form_GR_FLAG_D}" readOnly="${form_GR_FLAG_RO}" required="${form_GR_FLAG_R}" placeHolder="" />
			        </e:field>
				</e:row>
			</e:searchPanel>
            <e:searchPanel id="form2" useTitleBar="true" title="${form_ADD_INFO_N }" labelWidth="${labelWidth}" width="100%" columnCount="2">
                <e:row>
                    <%--재질코드--%>
                    <e:label for="MAT_CD" title="${form_MAT_CD_N}"/>
                    <e:field>
                        <e:select id="MAT_CD" name="MAT_CD" value="${form.MAT_CD}" options="${matCdOptions}" width="${inputTextWidth}" disabled="${form_MAT_CD_D}" readOnly="${form_MAT_CD_RO}" required="${form_MAT_CD_R}" placeHolder="" />
                    </e:field>
                    <%--NET중량--%>
                    <e:label for="NET_WGT" title="${form_NET_WGT_N}"/>
                    <e:field>
                        <e:inputNumber id="NET_WGT" name="NET_WGT" value="${form.NET_WGT}" maxValue="${form_NET_WGT_M}" decimalPlace="${form_NET_WGT_NF}" disabled="${form_NET_WGT_D}" readOnly="${form_NET_WGT_RO}" required="${form_NET_WGT_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <%--규격--%>
                    <e:label for="SPEC" title="${form_SPEC_N}"/>
                    <e:field>
                        <e:inputText id="SPEC" style="ime-mode:auto" name="SPEC" value="${form.SPEC}" width="100%" maxLength="${form_SPEC_M}" disabled="${form_SPEC_D}" readOnly="${form_SPEC_RO}" required="${form_SPEC_R}"/>
                    </e:field>
                    <%--비중--%>
                    <e:label for="WEIGHT" title="${form_WEIGHT_N}"/>
                    <e:field>
                        <e:inputNumber id="WEIGHT" name="WEIGHT" value="${form.WEIGHT}" maxValue="${form_WEIGHT_M}" decimalPlace="${form_WEIGHT_NF}" disabled="${form_WEIGHT_D}" readOnly="${form_WEIGHT_RO}" required="${form_WEIGHT_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <%--두께--%>
                    <e:label for="THICK" title="${form_THICK_N}"/>
                    <e:field>
                        <e:inputNumber id="THICK" name="THICK" value="${form.THICK}" maxValue="${form_THICK_M}" decimalPlace="${form_THICK_NF}" disabled="${form_THICK_D}" readOnly="${form_THICK_RO}" required="${form_THICK_R}" />
                    </e:field>
                    <%--COLL LOSS율--%>
                    <e:label for="COLL_LOSS_RTO" title="${form_COLL_LOSS_RTO_N}"/>
                    <e:field>
                        <e:inputNumber id="COLL_LOSS_RTO" name="COLL_LOSS_RTO" value="${form.COLL_LOSS_RTO}" maxValue="${form_COLL_LOSS_RTO_M}" decimalPlace="${form_COLL_LOSS_RTO_NF}" disabled="${form_COLL_LOSS_RTO_D}" readOnly="${form_COLL_LOSS_RTO_RO}" required="${form_COLL_LOSS_RTO_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <%--가로--%>
                    <e:label for="WIDTH" title="${form_WIDTH_N}"/>
                    <e:field>
                        <e:inputNumber id="WIDTH" name="WIDTH" value="${form.WIDTH}" maxValue="${form_WIDTH_M}" decimalPlace="${form_WIDTH_NF}" disabled="${form_WIDTH_D}" readOnly="${form_WIDTH_RO}" required="${form_WIDTH_R}" />
                    </e:field>
                    <%--세로--%>
                    <e:label for="HEIGHT" title="${form_HEIGHT_N}"/>
                    <e:field>
                        <e:inputNumber id="HEIGHT" name="HEIGHT" value="${form.HEIGHT}" maxValue="${form_HEIGHT_M}" decimalPlace="${form_HEIGHT_NF}" disabled="${form_HEIGHT_D}" readOnly="${form_HEIGHT_RO}" required="${form_HEIGHT_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <%--BL SIZE(가로)--%>
                    <e:label for="BL_WIDTH" title="${form_BL_WIDTH_N}"/>
                    <e:field>
                        <e:inputNumber id="BL_WIDTH" name="BL_WIDTH" value="${form.BL_WIDTH}" maxValue="${form_BL_WIDTH_M}" decimalPlace="${form_BL_WIDTH_NF}" disabled="${form_BL_WIDTH_D}" readOnly="${form_BL_WIDTH_RO}" required="${form_BL_WIDTH_R}" />
                        <e:text>(mm)</e:text>
                    </e:field>
                    <%--BL SIZE(세로)--%>
                    <e:label for="BL_HEIGHT" title="${form_BL_HEIGHT_N}"/>
                    <e:field>
                        <e:inputNumber id="BL_HEIGHT" name="BL_HEIGHT" value="${form.BL_HEIGHT}" maxValue="${form_BL_HEIGHT_M}" decimalPlace="${form_BL_HEIGHT_NF}" disabled="${form_BL_HEIGHT_D}" readOnly="${form_BL_HEIGHT_RO}" required="${form_BL_HEIGHT_R}" />
                        <e:text>(mm)</e:text>
                    </e:field>
                </e:row>
                <e:row>
                    <%--CVT--%>
                    <e:label for="CVT" title="${form_CVT_N}"/>
                    <e:field colSpan="3">
                        <e:inputNumber id="CVT" name="CVT" value="${form.CVT}" maxValue="${form_CVT_M}" decimalPlace="${form_CVT_NF}" disabled="${form_CVT_D}" readOnly="${form_CVT_RO}" required="${form_CVT_R}" />
                    </e:field>
                </e:row>
            </e:searchPanel>

		</e:panel>
		</div>
	</e:window>
</e:ui>
