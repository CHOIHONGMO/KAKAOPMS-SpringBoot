<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

    var grid;
    var baseUrl = "/eversrm/srm/screening/vendorRegScreeningMgt/SRM_171/";
    var screenData,basicData =  "";
    var EvIdScoreSum =0;
 	
    function init() {
    }
    
    function doSave(){
        var dataArr = [];
        var basicArr = [];
        var store = new EVF.Store();
        if(!store.validate()) return;

        <c:forEach items="${mycontent}" var="one">
        	var radioValue = EVF.C("rg_${one.EV_ITEM_NUM}").getValue();
        	var splitedValue = radioValue.split("_");
        	var evItemNo = "${one.EV_ITEM_NUM}";

        	if(radioValue.length > 0){
	        	dataArr.push({'EV_ITEM_NUM' : splitedValue[0],
	        				  'EV_TPL_NUM'  : splitedValue[1],
	        				  'EV_ID_SQ'  : splitedValue[2],
	        				  'EV_ID_SCORE'  : splitedValue[3],
							  'SG_NUM' : EVF.C('SG_NUM').getValue(),
							  'EV_SCORE' : EvIdScoreSum,
							  'KEY' : EVF.C('SG_NUM').getValue()+splitedValue[0]
	        				   });
        	}
        </c:forEach>
         basicArr.push({'EV_SCORE' : EvIdScoreSum});
         basicArr.push({'SG_NUM' : EVF.C('SG_NUM').getValue()});
//        basicArr.push({'EV_CTRL_USER_ID' : EVF.C('EV_CTRL_USER_ID').getValue()});
//        basicArr.push({'SCRE_EV_TPL_NUM' : EVF.C('SCRE_EV_TPL_NUM').getValue()});
//        basicArr.push({'SITE_EV_TPL_NUM' : EVF.C('SITE_EV_TPL_NUM').getValue()});

        screenData = JSON.stringify(dataArr);
//        basicData = JSON.stringify(basicArr);

        if (parent['${param.callBackFunction}']) {
            parent['${param.callBackFunction}'](screenData);
            new EVF.ModalWindow().close(null);
        } else if(opener) {
            opener['${param.callBackFunction}'](screenData);
            window.close();
        }

    }
    
    function doCancel(){
    	screenData = "";
    	if(confirm("${msg.M0024 }")) {	
    		parent.doSearch();
    	}
    }
    
    function doNext(){

    	
        var store = new EVF.Store();
        if(!store.validate()) return;

        <c:forEach items="${mycontent}" var="sumc">
        	var radioValue = EVF.C("rg_${sumc.EV_ITEM_NUM}").getValue();
			var splitedValue = radioValue.split("_");
			if(radioValue.length > 0){
				EvIdScoreSum += Number(splitedValue[3]);
			}
		</c:forEach>
        doSave();

    }


    </script>
    <e:window id="SRM_171"  onReady="init" title="" breadCrumbs="${breadCrumb }"   >

	        <e:panel id="pnl2_sub" width="100%">

	        <e:buttonBar id="buttonBar" align="right" width="100%">
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
				<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
				<e:button id="doNext" name="doNext" label="${doNext_N}" onClick="doNext" disabled="${doNext_D}" visible="${doNext_V}"/>
			</e:buttonBar>

					<c:set var="contentWidth" value="30" />
					<c:set var="iconWidth" value="18" />
					<c:set var="subjectWidth" value="50" />

					<c:set var="id" value="0" />
					<c:forEach items="${myheader }" var="oneHeader" varStatus="counter">
						<c:set var="id" value="${id + counter.count }" />

						<e:text style="font-weight: bold">&nbsp;${oneHeader.EV_ITEM_TYPE_CD_NM}</e:text>
						<e:br/>

						<c:forEach items="${mycontent }" var="oneContent">
							<c:if test="${oneContent.EV_ITEM_TYPE_CD  == oneHeader.EV_ITEM_TYPE_CD  }">
										<e:text style="color:blue;font-weight: bold">&nbsp;&nbsp;&nbsp;&nbsp;*${oneContent.EV_ITEM_SUBJECT} </e:text>
										<e:text>&nbsp;&nbsp;&nbsp;${oneContent.EV_ITEM_CONTENTS }</e:text>
									<e:br/>
									<e:radioGroup id="rg_${oneContent.EV_ITEM_NUM}"  name="rg_${oneContent.EV_ITEM_NUM}"  disabled=""  readOnly="" required="true">
										<c:forEach items="${myoption}" var="oneOption"  varStatus="optionCounter">
											<c:if test="${oneOption.EV_ITEM_NUM == oneContent.EV_ITEM_NUM && oneOption.EV_ITEM_NUM != null }">

												<e:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
												<e:radio label="${oneOption.EV_ID_CONTENTS }"
													id="r_${oneContent.EV_ITEM_NUM}_${oneOption.EV_ID_SQ }" name="r_${oneContent.EV_ITEM_NUM}"
													value="${oneContent.EV_ITEM_NUM}_${oneOption.EV_TPL_NUM}_${oneOption.EV_ID_SQ}_${oneOption.EV_ID_SCORE}" />
											</c:if>
										</c:forEach>
									</e:radioGroup>

											<e:br/>

							</c:if>
						</c:forEach>
					</c:forEach>

						<e:inputHidden id="SG_NUM" name="SG_NUM" value="${sgNo}"/>
						<e:inputHidden id="EV_NUM" name="EV_NUM" value=""/>
						<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${EV_CTRL_USER_ID }"/>
						<e:inputHidden id="SCRE_EV_TPL_NUM" name="SCRE_EV_TPL_NUM" value="${SCRE_EV_TPL_NUM }"/>
						<e:inputHidden id="SITE_EV_TPL_NUM" name="SITE_EV_TPL_NUM" value="${SITE_EV_TPL_NUM }"/>
		</e:panel>
	</e:window>
</e:ui>