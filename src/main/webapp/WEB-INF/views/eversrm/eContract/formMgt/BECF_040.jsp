<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="/js/ckeditor/econt_plugins_n.js?var=1"></script>
	<script type="text/javascript" src="/js/everuxf/lib/ckeditor/plugins/lite/lite-interface.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/2014-11-29/FileSaver.min.js"></script>
	<script src="/js/jquery.wordexport.js"></script>
	<script src="/js/FileSaver.js"></script>
	<script type="text/javascript">

		var grid;
		var baseUrl = "/eversrm/eContract/formMgt/BECF_040/";

		function init() {

			grid = EVF.C("grid");

            var editor = CKEDITOR.replace('cont_content', {
                /* customConfig : '/js/ckeditor/ep_configs_n.js?var=3', 편집기 기능 수정 확인 */
               	// customConfig : '/js/ckeditor/ep_configs.js?var=3',
            	customConfig : '/js/ckeditor/ep_config.js',
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

            // 버튼 ICON 생성
              editor.ui.addButton('Newplugin',
                {
                    label: 'Html View',
                    command: 'OpenWindow',
                    icon: '/images/icon/grid_file.gif'
                });
 	            editor.addCommand('OpenWindow', { exec: showMyDialog });

            doSearchECCR();
        }


        function showMyDialog(e) {
            var param = {
                callBackFunction: "setHtmlView",
				ckEditorHtml: CKEDITOR.instances.cont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')
            };

            console.log(CKEDITOR.instances);
            console.log(CKEDITOR.instances.cont_content);

            everPopup.openPopupByScreenId('BECF_VIEW', 800, 900, param);
        }

        function setHtmlView(html) {
		    console.log(html);
            CKEDITOR.instances.cont_content.setData(html);
        }

		//첨부서식 조회
	    function doSearchECCR() {
	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.load(baseUrl + "doSearchECCR", function() {
	            if (grid.getRowCount() != 0) {
	            }
	        });
	    }

		function doSave() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

			grid.checkAll(true);
			store.setGrid([grid]);
	    	store.getGridData(grid, 'all');

			if (!confirm("${msg.M0021 }")) {
				return;
			}

            store.setParameter('formContents', CKEDITOR.instances.cont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
			store.load(baseUrl + 'doSave', function() {
				alert(this.getResponseMessage());
                location.href=baseUrl+'view.so?formNum='+this.getParameter('formNum');
			});
		}

		function doClose() {
			window.close();
		}

		function doWord() {
            // 문서 만드는 부분
            $('#ckExport').hide();
            $('#ckExport').html(CKEDITOR.instances.cont_content.getData());
            $('#ckExport').wordExport();
		}
	</script>

	<e:window id="BECF_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" margin="0 4px">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="doSave" />
	 <%-- 	<e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="doClose" /> --%>
     <%-- 	<e:button id="doWord" name="doWord" label="워드" disabled="${doClose_D }" onClick="doWord" /> --%>
		</e:buttonBar>
		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" labelWidth="${labelWidth }" onEnter="doSearch" useTitleBar="false">
			<e:inputHidden id="FORM_NUM" name="FORM_NUM" value="${empty form.FORM_NUM ? param.formNum : form.FORM_NUM}" />
			<e:inputHidden id="FORM_TEXT_NUM" name="FORM_TEXT_NUM" value="${form.FORM_TEXT_NUM}" />
			<e:row>
				<e:label for="FORM_TYPE" title="${form_FORM_TYPE_N}"/>
					<e:field>
						<e:select id="FORM_TYPE" name="FORM_TYPE" value="${form.FORM_TYPE}" options="${formTypeOptions}" width="${form_FORM_TYPE_W}" disabled="${form_FORM_TYPE_D}" readOnly="${form_FORM_TYPE_RO}" required="${form_FORM_TYPE_R}" placeHolder="" />
					</e:field>
				<e:label for="FORM_GUBUN" title="${form_FORM_GUBUN_N}"/>
					<e:field>
						<e:select id="FORM_GUBUN" name="FORM_GUBUN" value="${form.FORM_GUBUN}" options="${formGubunOptions}" width="${form_FORM_GUBUN_W}" disabled="${form_FORM_GUBUN_D}" readOnly="${form_FORM_GUBUN_RO}" required="${form_FORM_GUBUN_R}" placeHolder="" />
					</e:field>
			</e:row>
			<e:row>
				<e:label for="FORM_NM" title="${form_FORM_NM_N }" />
				<e:field>
					<e:inputText id="FORM_NM" style="${imeMode}" name="FORM_NM" width="100%" required="${form_FORM_NM_R }" disabled="${form_FORM_NM_D }" value="${form.FORM_NM}" readOnly="${form_FORM_NM_RO }" maxLength="${form_FORM_NM_M}" />
				</e:field>
				<e:label for="FORM_USE_FLAG" title="${form_FORM_USE_FLAG_N}"/>
				<e:field>
					<e:select id="FORM_USE_FLAG" name="FORM_USE_FLAG" value="${form.USE_FLAG}" options="${formUseFlagOptions}" width="${form_FORM_USE_FLAG_W}" disabled="${form_FORM_USE_FLAG_D}" readOnly="${form_FORM_USE_FLAG_RO}" required="${form_FORM_USE_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>

			<e:row>
                <e:field colSpan="4">
             <%--        <textarea id=cont_content style="${imeMode}" name="cont_content" style="width:100%;">${form.formContents}</textarea> --%>
                         <textarea id=cont_content name="cont_content" style="width:100%;">${form.formContents}</textarea>
                </e:field>
            </e:row>

			<div id="ckExport"></div>
		</e:searchPanel>
		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="240" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>
