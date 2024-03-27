<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var addParam = [];
    	var baseUrl = "/eversrm/srm/screening/vendorRegScreeningMgt/";
    	
		function init() {

        }

        function doSearch() {

            if (!chceckSearchCondition()) {
                alert("${msg.M0035 }");
                return;
            }

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'BBM_030/doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        
        

		function getSg() {
            var store = new EVF.Store();
            var cls_type = this.data;
            parent_sg_num='';
	    	if (cls_type=='2') {
	    		parent_sg_num= EVF.C("SG_NUM").getValue();
	    		clearX('3');
	    		clearX('4');
	    	}
	    	if (cls_type=='3') {
	    		parent_sg_num= EVF.C("SG_NUM2").getValue();
	    		clearX('4');
	    	}	    	
	    	if (cls_type=='4') {
	    		parent_sg_num= EVF.C("SG_NUM3").getValue();
	    	}
   	    	store.load(baseUrl + 'getSG.so?PARENT_SG_NUM='+parent_sg_num, function() {
	    		EVF.C('SG_NUM'+ cls_type ).setOptions(this.getParameter("refSg"));
            });        
		}
		
		function clearX( cls_typef ) {
    		EVF.C('SG_NUM'+ cls_typef ).setOptions( JSON.parse('[]')    );
		}
		
		
	    function doSearch() {
	    	var store = new EVF.Store();
	    	if(!store.validate()) return;
	      	var url = baseUrl + "SRM_171/view.so?";
//	      	var params = {
//	      		SG_NUM : EVF.C("SG_NUM4").getValue(),
//	      	};
	      	document.getElementById('mmm').src = url + 'SG_NUM='+EVF.C("SG_NUM2").getValue();

	    }
		
		
		

    </script>
	<e:window id="SRM_170" onReady="init" title="${fullScreenName}" breadCrumbs="${breadCrumb }" initData="${initData}">
       <e:panel id="xxx" name="xxx" width="100%">
	        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelWidth }" onEnter="doSearch">

	        	<e:row>
					<e:label for="SG_NUM" title="${form_SG_NUM_N}"/>
					<e:field colSpan="5">
						<e:select id="SG_NUM" name="SG_NUM" data="2" onChange="getSg" value="${form.SG_NUM}" options="${sgNumOptions }" width="${inputTextWidth}" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" placeHolder="" />
						<e:select id="SG_NUM2" name="SG_NUM2"   data="3"   onChange="getSg"        value="${form.SG_NUM}" options="" width="${inputTextWidth}" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" placeHolder="" />
						<e:select id="SG_NUM3" name="SG_NUM3"   data="4"   onChange="getSg"       value="${form.SG_NUM}" options="" width="${inputTextWidth}" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" placeHolder="" />
						<e:select id="SG_NUM4" name="SG_NUM4"   value="${form.SG_NUM}" options="" width="${inputTextWidth}" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" placeHolder="" />
					</e:field>

					<e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}"/>
					<e:field>
						<e:inputText id="CEO_USER_NM" name="CEO_USER_NM" value="${formData.CEO_USER_NM }" width="100%" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}" style="${imeMode}"/>
					</e:field>

				</e:row>            
	        </e:searchPanel>
	        <e:buttonBar id="buttonBar" align="right" width="100%">
					<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
	        </e:buttonBar>
		</e:panel>

       <e:panel id="yyy" name="yyy" width="100%" height="550px">
			<iframe id="mmm" name="mmm" src="" width="100%" height="550px"  style="border:0px" />
		</e:panel>


    </e:window>
</e:ui>