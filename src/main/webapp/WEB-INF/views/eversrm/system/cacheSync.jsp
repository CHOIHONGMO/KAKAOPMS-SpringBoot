<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var baseUrl = "/eversrm/system/";
		function init() {

		}

		function doCacheReload() {
            var store = new EVF.Store();
            if(!store.validate()) return;

            if (!confirm("캐시데이터를 모두 초기화하시겠습니까?")) return;
            var store = new EVF.Store();

            store.load(baseUrl + 'cacheSync', function(){
                alert(this.getResponseMessage());
            });
		}

    </script>
    <e:window id="cacheSync" onReady="init" initData="${initData}" title="CACHE ReLoad" breadCrumbs="${breadCrumb }">

        <e:text style="font-weight: bold;">항목별 캐시적용 상태입니다.</e:text><e:br/>
        <e:text>- Combo: ${everF_cacheEnable_combo}   </e:text><e:br/>
        <e:text>- BreadCrumb: ${everF_cacheEnable_breadCrumb} </e:text><e:br/>
        <e:text>- Popup: ${everF_cacheEnable_popup}   </e:text><e:br/>
        <e:text>- Code: ${everF_cacheEnable_code} </e:text><e:br/>
        <e:text>- Button: ${everF_cacheEnable_button} </e:text><e:br/>
        <e:text>- Message: ${everF_cacheEnable_message}   </e:text><e:br/>
        <e:text>- Scrn: ${everF_cacheEnable_scrn} </e:text><e:br/>
        <e:text>- Form: ${everF_cacheEnable_form} </e:text><e:br/>
        <e:text>- Grid: ${everF_cacheEnable_grid} </e:text><e:br/>

         <e:buttonBar id="buttonBar1" align="left" width="100%">
            <e:button id="doCacheReload" name="doCacheReload" label="전체캐시 초기화하기"  onClick="doCacheReload" />
        </e:buttonBar>
    </e:window>
</e:ui>