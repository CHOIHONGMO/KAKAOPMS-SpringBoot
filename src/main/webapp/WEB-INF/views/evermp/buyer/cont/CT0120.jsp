<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui>
	<script type="text/javascript" src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="/js/everuxf/lib/ckeditor/econt_plugins_n.js"></script>
	<script type="text/javascript">

		var grid;
		var baseUrl = "/evermp/buyer/cont/CT0120/";
		var gwUseFlag = 'N';   <%-- GW 결재여부--%>

        CKEDITOR.disableAutoInline = true;  // 인라인에디터를 자동으로 초기화하는 것을 방지(원하는 영역만 수동으로 에디터를 로드하기 위해)

		function init() {

			$('#gridDiv').attr('style', 'display: block;');

			grid = EVF.C("grid");

			<%-- CK editor를 textarea안에 넣는 부분 --%>
            var editor = CKEDITOR.replace('cont_content', {
                customConfig : '/js/everuxf/lib/ckeditor/ep_configs_n.js?var=3',
				<c:if test="${param.detailView eq 'true'}">
                	readOnly: true,
                	toolbarStartupExpanded: false,
				</c:if>
                allowedContent: true,
                width: '100%',
                height: 330
            });


            editor.on('instanceReady', function(ev){

                var editor = ev.editor;
                editor.resize('100%', $('body').height() - 230, true, false);

                $(window).resize(function() {
                    editor.resize('100%', $('body').height() - 230, true, false);
                });
            });

			grid.setProperty('shrinkToFit', true);

			onChangeFormType();
			doSearchECCR();

        	if('${param.COPY_YN}' == 'Y') {
       		 	EVF.getComponent("FORM_NUM").setValue('');
	       	}


//            var values = $.map($('#BUYER_CD option'), function(e) { return e.value; });
//            EVF.V('BUYER_CD',values.join(','));

            EVF.V('BUYER_CD','${form.BUYER_CD}');

        }

		// 첨부서식 조회
	    function doSearchECCR() {

	        var store = new EVF.Store();
	        store.setParameter("SEL_FLAG", ("${param.detailView}" == "true" ? "1" : "0"));
	        store.setGrid([grid]);
	        store.load(baseUrl + "doSearchECCR", function() {
	            if (grid.getRowCount() != 0) {

	            }
	        });
	    }

        <c:if test="${ses.superUserFlag eq '1'}">
		function doSave() {

			var store = new EVF.Store();
			if (!store.validate()) { return; }

			var formType = EVF.V('FORM_TYPE'); // == '100';
			if(formType == "100") {

				grid.checkAll(true);

				var selRowId = grid.getSelRowId();
                for(var i in selRowId) {
                    var rowId = selRowId[i];
                    if(grid.getCellValue(rowId, 'SELECTED') == '1' && grid.getCellValue(rowId, 'USE_FLAG') != '1') {
                    	return EVF.alert('현재 사용하지 않는 부서식은 선택할 수 없습니다.');
                    }
                }

				store.setGrid([grid]);
				store.getGridData(grid, 'all');
			}
			store.setParameter("formType", formType);

			EVF.confirm("${msg.M0021 }", function () {
				store.setParameter('formContents', CKEDITOR.instances.cont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
				store.load(baseUrl + 'doSave', function() {
					var formNum = this.getParameter('formNum');
					EVF.alert(this.getResponseMessage(), function() {
						location.href = baseUrl + 'view.so?formNum=' + formNum;
						opener.doSearch();
					});
				});
			});
		}
		</c:if>

		function doWord() {
            // 문서 만드는 부분
            $('#ckExport').hide();
            $('#ckExport').html(CKEDITOR.instances.cont_content.getData());
            $('#ckExport').wordExport();
		}

		function onChangeFormType() {

		    var isMainForm = EVF.V('FORM_TYPE') == '100';

			EVF.C('APPROVAL_FLAG').setDisabled(!isMainForm);
			EVF.C('BUNDLE_FLAG').setDisabled(!isMainForm);
			EVF.C('DEPT_FLAG').setDisabled(!isMainForm);
			EVF.C('ECONT_FLAG').setDisabled(!isMainForm);
            EVF.C('CONTRACT_FORM_TYPE').setDisabled(!isMainForm);



			EVF.C('CONTRACT_FORM_TYPE').setRequired(isMainForm);
			EVF.C('ECONT_FLAG').setRequired(isMainForm);

            EVF.C('BUYER_CD').setDisabled(!isMainForm);
			EVF.C('BUYER_CD').setRequired(isMainForm);


			if(isMainForm) {
                EVF.V('APPROVAL_FLAG', (EVF.isEmpty("${form.APPROVAL_FLAG}") ? "0" : "${form.APPROVAL_FLAG}"));
                EVF.V('BUNDLE_FLAG', (EVF.isEmpty("${form.BUNDLE_FLAG}") ? "0" : "${form.BUNDLE_FLAG}"));
                EVF.V('DEPT_FLAG', (EVF.isEmpty("${form.DEPT_FLAG}") ? "0" : "${form.DEPT_FLAG}"));
                EVF.V('ECONT_FLAG', (EVF.isEmpty("${form.ECONT_FLAG}") ? "1" : "${form.ECONT_FLAG}"));
                EVF.V('CONTRACT_FORM_TYPE', "${form.CONTRACT_FORM_TYPE}");
                EVF.V('BUYER_CD', "${form.BUYER_CD}");


                $('#gridDiv').attr('style', 'display: block;');
			} else {
				EVF.V('APPROVAL_FLAG', '');
				EVF.V('BUNDLE_FLAG', '');
				EVF.V('DEPT_FLAG', '');
				EVF.V('ECONT_FLAG', '');
				EVF.V('CONTRACT_FORM_TYPE', '');
                EVF.V('BUYER_CD', '');



				if(!EVF.isEmpty(EVF.V('FORM_TYPE'))) {
					$('#gridDiv').attr('style', 'display: none;');
				}
			}
		}

		function doClose() {
			window.close();
		}

	</script>

	<e:window id="CT0120" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" margin="0 4px">

		<e:buttonBar id="buttonBar" align="right" width="100%" title="기본정보">
			<c:if test="${ses.superUserFlag eq '1'}"><%-- 시스템관리자일 경우만 --%>
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			</c:if>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" labelWidth="140" onEnter="doSearch" useTitleBar="false">
			<e:inputHidden id="FORM_NUM" name="FORM_NUM" value="${empty form.FORM_NUM ? param.formNum : form.FORM_NUM}" />
			<e:inputHidden id="FORM_TEXT_NUM" name="FORM_TEXT_NUM" value="${form.FORM_TEXT_NUM}" />
			<e:inputHidden id="FORM_ROLE_TYPE" name="FORM_ROLE_TYPE" value="${form.FORM_ROLE_TYPE}" />
			<e:inputHidden id="APPROVAL_FLAG" name="APPROVAL_FLAG" value="${form.APPROVAL_FLAG}" />
			<e:inputHidden id="DEPT_FLAG" name="DEPT_FLAG" value="${form.DEPT_FLAG}" />
			<e:inputHidden id="BUNDLE_FLAG" name="BUNDLE_FLAG" value="${form.BUNDLE_FLAG}" />
			<e:row>
				<e:label for="FORM_TYPE" title="${form_FORM_TYPE_N }"/>
				<e:field>
					<e:select id="FORM_TYPE" name="FORM_TYPE" value="${form.FORM_TYPE}" options="${formTypes}" readOnly="${form_FORM_TYPE_RO }" width="100%" required="${form_FORM_TYPE_R }" disabled="${form_FORM_TYPE_D }" onChange="onChangeFormType"/>
				</e:field>
				<e:label for="CONTRACT_FORM_TYPE" title="${form_CONTRACT_FORM_TYPE_N}"/>
				<e:field>
					<e:select id="CONTRACT_FORM_TYPE" name="CONTRACT_FORM_TYPE" value="${form.CONTRACT_FORM_TYPE}" options="${contractFormTypeOptions}" width="${form_CONTRACT_FORM_TYPE_W}" disabled="${form_CONTRACT_FORM_TYPE_D}" readOnly="${form_CONTRACT_FORM_TYPE_RO}" required="${form_CONTRACT_FORM_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="FORM_NM" title="${form_FORM_NM_N }"/>
				<e:field colSpan="3">
					<e:inputText id="FORM_NM" style="${imeMode}" name="FORM_NM" width="100%" required="${form_FORM_NM_R }" disabled="${form_FORM_NM_D }" value="${form.FORM_NM}" readOnly="${form_FORM_NM_RO }" maxLength="${form_FORM_NM_M}"/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="USE_FLAG" title="${form_USE_FLAG_N}"/>
				<e:field>
					<e:inputHidden id="ECONT_FLAG" name="ECONT_FLAG" value="1"/>
					<e:select id="USE_FLAG" name="USE_FLAG" value="${empty form.USE_FLAG ? '1' : form.USE_FLAG}" options="${useFlagOptions}" width="170px" disabled="${form_USE_FLAG_D}" readOnly="${form_USE_FLAG_RO}" required="${form_USE_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="EXAM_FLAG" title="${form_EXAM_FLAG_N}"/>
				<e:field>
					<e:select id="EXAM_FLAG" name="EXAM_FLAG" value="${empty form.EXAM_FLAG ? '0' : form.EXAM_FLAG}" options="${examFlagOptions}" width="170px" disabled="${form_EXAM_FLAG_D}" readOnly="${form_EXAM_FLAG_RO}" required="${form_EXAM_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--회사--%>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field colSpan="3">
				<e:select id="BUYER_CD" name="BUYER_CD" value="" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}"  usePlaceHolder="false" useMultipleSelect="true"/>
				</e:field>
			</e:row>
            <e:row>
                <e:field colSpan="4">
                    <textarea id=cont_content style="${imeMode}" name="cont_content" style="width:100%;">${form.formContents}</textarea>
                </e:field>
            </e:row>
		</e:searchPanel>

		<div id="gridDiv">
			<e:gridPanel id="grid" name="grid" width="100%" height="240" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		</div>

	</e:window>
</e:ui>
