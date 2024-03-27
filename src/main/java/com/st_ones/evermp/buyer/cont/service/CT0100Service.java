package com.st_ones.evermp.buyer.cont.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.enums.econtract.ContType;
import com.st_ones.common.enums.system.Code;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.ContStringUtil;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.CT0100Mapper;
import com.st_ones.evermp.buyer.cont.CT0300Mapper;
import net.htmlparser.jericho.FormControl;
import net.htmlparser.jericho.OutputDocument;
import net.htmlparser.jericho.Source;
import org.apache.commons.lang3.StringUtils;
import org.joda.time.Days;
import org.joda.time.LocalDate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "CT0100Service")
public class CT0100Service  extends BaseService {

	@Autowired MessageService msg;
	@Autowired LargeTextService largeTextService;
	@Autowired private DocNumService docNumService;


	@Autowired private CT0100Mapper ct0100mapper;
	@Autowired private CT0300Mapper ct0300mapper;



    public List<Map<String, Object>> formManagementDoSearch(Map<String, String> param) {
        return ct0100mapper.formManagementDoSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String formManagementDoCopy(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> gridRow : gridData) {

            String formNum = docNumService.getDocNumber("FORMNO");
            gridRow.put("NEW_FORM_NUM", formNum);

        	ct0100mapper.formManagementDoCopyCF(gridRow);
        	ct0100mapper.formManagementDoCopyCR(gridRow);
        }
        return msg.getMessageByScreenId("CT0110", "002");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String formManagementDoDelete(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> gridRow : gridData) {

            int checkCnt = ct0100mapper.getCheckCnt(gridRow);
            if (checkCnt > 0) {
                throw new Exception(msg.getMessageByScreenId("CT0110", "003"));
            }

        	ct0100mapper.formManagementDoDeleteEccf(gridRow);
        	ct0100mapper.formManagementDoDeleteEccr(gridRow);
        }
        return msg.getMessage("0017");
    }

    public void doReplace() {

        List<Map<String, Object>> maps = ct0100mapper.doSearchAllForms();

        for (Map<String, Object> data : maps) {
            String formText = (String)data.get("FORM_TEXT");
            formText = formText.replaceAll("readonly=\"readonly\"", "");
            formText = StringUtils.replace(formText,"onclick=\"getDate('setChangeVal03')\" ", "");
            formText = StringUtils.replace(formText, "style=\"background-color: rgb(253, 240, 218);\" ", "");
            data.put("FORM_TEXT", formText);
            ct0100mapper.doUpdateForm(data);
        }
    }

    /* @formatter:on */
    @AuthorityIgnore
    public void setFormSelectionInitData(EverHttpRequest req) throws Exception {

        String tBaseDataType = req.getParameter("baseDataType");
        if (tBaseDataType == null || "".equals(tBaseDataType)) {
            tBaseDataType = "manualContract";
        }

        Map<String, String> dataFormMap = new HashMap<String, String>();
        //BaseDataType.java
        //ContType contType = ContType.fromString(req.getParameter("baseDataType"));

        //ContType.java
        ContType contType = ContType.fromString(tBaseDataType);
        switch (contType) {
            case CONSULTATION:
                dataFormMap.put("GATE_CD", req.getParameter("GATE_CD"));
                dataFormMap.put("EXEC_NUM", req.getParameter("EXEC_NUM"));
                Map<String, String> consultationMap = ct0100mapper.getConsultationInformation(dataFormMap);
                dataFormMap.putAll(consultationMap);
                break;
            default:
        }

        dataFormMap.put("GATE_CD", req.getParameter("GATE_CD"));
        dataFormMap.put("CONT_USER_ID", UserInfoManager.getUserInfo().getUserId());
        dataFormMap.put("CONT_USER_NM", UserInfoManager.getUserInfo().getUserNm());
        dataFormMap.put("BUYER_CD", UserInfoManager.getUserInfo().getCompanyCd());
        dataFormMap.put("BUYER_NM", UserInfoManager.getUserInfo().getCompanyNm());
        dataFormMap.put("CONT_DATE", EverDate.getDate());

        dataFormMap.remove("ses");
        req.setAttribute("searchParam", dataFormMap);
    }

    public List<Map<String, Object>> doSearchMainForm(Map<String, String> param) {
        return ct0100mapper.doSearchMainForm(param);
    }

    public List<Map<String, Object>> doSearchAdditionalForm(Map<String, String> param) {
        return ct0100mapper.doSearchAdditionalForm(param);
    }

    public List<Map<String, Object>> doSearchSupAttachFileInfo(Map<String, String> param) {
        return ct0100mapper.doSearchSupAttachFileInfo(param);
    }

    public List<Map<String, Object>> doSearchPayInfo(Map<String, String> param) {
        return ct0100mapper.doSearchPayInfo(param);
    }

    public List<Map<String, Object>> doSearchPayInfoForERP(Map<String, String> param) {
        return ct0100mapper.doSearchPayInfoForERP(param);
    }

    /**
     * 조회한 서식을 화면에 입력한 데이터로 치환한 후 리턴합니다.
     *
     * @param req
     * @param resp
     * @param paramMap
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String getFormWithManualContractInfo(EverHttpRequest req, EverHttpResponse resp, Map<String, String> paramMap) throws Exception {
        String resultContractForm = "";
        String contNum = paramMap.get("contNum");
        String contCnt = paramMap.get("contCnt");
        String appDocNum = paramMap.get("appDocNum");
        String appDocCnt = paramMap.get("appDocCnt");
        String type = EverString.nullToEmptyString(paramMap.get("type"));

        // 화면에서 넘어온 서식 데이터 (입력폼에 입력된 값을 유지하기 위해 화면에서 받아옴)
        String contractForm     = (req.getParameter("formContents") == null ? paramMap.get("formContents") : req.getParameter("formContents"));
        String selectedFormNum  = (req.getParameter("selectedFormNum") == null ? paramMap.get("selectedFormNum") : req.getParameter("selectedFormNum"));    // 화면에서 넘어온 서식번호
        String isUpdatedFormNum = (req.getParameter("isUpdatedFormNum") == null ? paramMap.get("isUpdatedFormNum") : req.getParameter("isUpdatedFormNum")); // 서식번호가 바뀌었는지 여부

        // 화면에서 받은 서식이 없거나 서식을 변경했으면 DB에서 서식을 조회한다.
        if(type.equals("M")) {
        	if (StringUtils.isEmpty(contractForm) || StringUtils.equals(isUpdatedFormNum, "true")) {
                if (selectedFormNum != null) {
                    Map<String, String> formContents = ct0300mapper.getFormContents(selectedFormNum);
                    contractForm = formContents.get("FORM_TEXT");
                }
            }
//            Map<String, String> formContents = ct0300mapper.getFormContents(selectedFormNum);
//            contractForm = formContents.get("FORM_TEXT");

        }
        else if(type.equals("S")) {
            if (StringUtils.isEmpty(contractForm)) {
                if (selectedFormNum != null) {
//                    Map<String, String> formContents = ct0300mapper.getFormContents(selectedFormNum);
//                    contractForm = formContents.get("FORM_TEXT");
                }
                Map<String, String> formContents = ct0300mapper.getFormContents(selectedFormNum);
                contractForm = formContents.get("FORM_TEXT");

            }
        }

        resultContractForm = contractForm;
        Map<String, String> vendorInformation = new HashMap<String, String>();
        Map<String, String> buyerInformation  = new HashMap<String, String>();

        if(paramMap.get("APAR_TYPE").equals("S")) {
        	vendorInformation = ct0300mapper.getVendorCustInformation(paramMap);
        	buyerInformation  = ct0300mapper.getBuyerCustInformation(paramMap);

        }else {
        	vendorInformation = ct0300mapper.getVendorInformation(paramMap);
        	buyerInformation  = ct0300mapper.getBuyerInformation(null);

        }

        if ((StringUtils.isNotEmpty(contNum) && StringUtils.isNotEmpty(contCnt)) ||
        	 StringUtils.isNotEmpty(appDocNum) && StringUtils.isNotEmpty(appDocCnt)) {

            paramMap.put("CONT_NUM", contNum);
            paramMap.put("CONT_CNT", contCnt);
            paramMap.put("APP_DOC_NUM", appDocNum);
            paramMap.put("APP_DOC_CNT", appDocCnt);

            Map<String, String> contInfo = ct0300mapper.getContractInformation(paramMap);
            String progressCd = contInfo.get("PROGRESS_CD");
            String signStatus = contInfo.get("SIGN_STATUS");
            String signStatus2 = contInfo.get("SIGN_STATUS2");

            // 수정불가상태
            if( !((progressCd.equals("") || progressCd.equals(Code.CONT_TEMP_SAVE) || progressCd.equals(Code.CONT_SUPPLY_REJECT)) ||
                  (progressCd.equals(Code.M135_4203) && (StringUtils.equals(signStatus, Code.M020_R) || StringUtils.equals(signStatus, Code.M020_C))) ||
                  (progressCd.equals(Code.M135_4240) && (StringUtils.equals(signStatus2, Code.M020_R) || StringUtils.equals(signStatus2, Code.M020_C))))) {
                resultContractForm = ContStringUtil.getHtmlContents(resultContractForm, true);
            } else {
            	if ("true".equals(paramMap.get("first_view")) && StringUtils.equals(isUpdatedFormNum, "true")) {
                    if(StringUtils.isNotEmpty(selectedFormNum)) {
                        paramMap.put("FORM_NUM", selectedFormNum);
                        Map<String, String> formInfo = ct0300mapper.getContractFormBySelectedFormNum(paramMap);
                        resultContractForm = (formInfo == null ? resultContractForm : formInfo.get("ORI_CONTRACT_TEXT"));
                	}
            	}
            }
        }

        // 품목정보
        List<Map<String, Object>> gridItem = req.getGridData("gridItem");
        try {
        	if(gridItem.size()!=0) {
        		StringBuffer itemList = new StringBuffer();
        		itemList.append("	      <table border=1 width=100% style=border-collapse:collapse;>      \n");
        		itemList.append("	    	<tr height=10>           \n");
        		itemList.append("	    		<td width=361 align=center><span style=font-size:12px;><font  face=맑은 고딕>자재명</font></span></td>                                          \n");
        		itemList.append("	    		<td width=147 align=center><span style=font-size:12px;><font  face=맑은 고딕>수량</font></span></td>                                          \n");
        		itemList.append("	    		<td width=147 align=center><span style=font-size:12px;><font  face=맑은 고딕>수량단위</font></span></td>                                          \n");
        		itemList.append("	    		<td width=124 align=center><span style=font-size:12px;><font  face=맑은 고딕>단가</font></span></td>                                           \n");
        		itemList.append("	    		<td width=65 align=center><span style=font-size:12px;><font  face=맑은 고딕>단가단위</font></span></td>                                          \n");
        		itemList.append("	    		<td width=144 align=center><span style=font-size:12px;><font  face=맑은 고딕>공급가액</font></span></td>                                          \n");
        		itemList.append("	    		<td width=144 align=center><span style=font-size:12px;><font  face=맑은 고딕>VAT</font></span></td>                                          \n");
        		itemList.append("	    		<td width=144 align=center><span style=font-size:12px;><font  face=맑은 고딕>Tax</font></span></td>                                          \n");

        		itemList.append("	    	</tr>                                                                                                               \n");

        		double vatAmt = 0d;
        		String taxNm = "";
        		for(Map<String,Object> data : gridItem) {
		        	if("T1".equals(data.get("VAT_CD"))) {
		        		vatAmt = Double.parseDouble( String.valueOf(data.get("ITEM_AMT"))  )/10;
		  	            taxNm = "과세";
		        	} else if("E1".equals(data.get("VAT_CD"))) {
		        		vatAmt = 0;
		  	            taxNm = "면세";
		        	} else {
		        		vatAmt = 0;
		  	            taxNm = "영세";
		        	}
		  	        itemList.append("	    	<tr> \n");
		  	        itemList.append("	    		<td> <span style=font-size:12px;> <font  face=맑은 고딕>"+data.get("ITEM_DESC")+"</font></span></td>            \n");
		  	        itemList.append("	    		<td align=right> <span style=font-size:12px;><font  face=맑은 고딕>"+EverMath.EverNumberType(String.valueOf(data.get("ITEM_QT")),"###,###.###")+"&nbsp;</font></span></td>        \n");
		  	        itemList.append("	    		<td align=center> <span style=font-size:12px;><font  face=맑은 고딕>"+EverString.nullToEmptyString(data.get("UNIT_CD"))+"</font></span></td>           \n");
		  	        itemList.append("	    		<td align=right><span style=font-size:12px;><font  face=맑은 고딕>"+EverMath.EverNumberType(String.valueOf(data.get("UNIT_PRC")),"###,###.###")+"&nbsp;</font></span></td>    \n");
		  	        itemList.append("	    		<td align=center> <span style=font-size:12px;><font  face=맑은 고딕>"+EverString.nullToEmptyString(data.get("CUR"))+"</font></span></td>           \n");
		  	        itemList.append("	    		<td align=right><span style=font-size:12px;><font  face=맑은 고딕>"+EverString.nullToEmptyString(EverMath.EverNumberType(String.valueOf(data.get("ITEM_AMT")),"###,###.###"))+"&nbsp;</font></span></td>                                                          \n");
		  	        itemList.append("	    		<td align=right><span style=font-size:12px;><font  face=맑은 고딕>"+EverString.nullToEmptyString(EverMath.EverNumberType(String.valueOf(vatAmt),"###,###.###"))+"&nbsp;</font></span></td>                                                          \n");
		  	        itemList.append("	    		<td align=center><span style=font-size:12px;><font  face=맑은 고딕>"+taxNm+"</font></span></td>                                                          \n");
		  	        itemList.append("	    	</tr>   \n");
        		}
        		itemList.append("	    	</table>                                                                                                                                             \n");
        		resultContractForm = ContStringUtil.initString(resultContractForm, "&lt;div id=\"aaa\"&gt;", "&lt;/div&gt;", "[[ITEM_LIST]]");
        		resultContractForm = ContStringUtil.initStringTag(resultContractForm, "<div id=\"aaa\">", "</div>", "[[ITEM_LIST]]");
        		resultContractForm = EverString.replace(resultContractForm, "[[ITEM_LIST]]", itemList.toString());
        	}

        	// 견적품목리스트
        	if(gridItem.size()!=0) {
        		StringBuffer itemList = new StringBuffer();
        		itemList.append("	      <table border=1 width=100% style=border-collapse:collapse;>      \n");
        		itemList.append("	    	<tr height=10>                                                                   \n");
        		itemList.append("	    		<td width=361 align=center><span style=font-size:12px;><font  face=맑은 고딕>제품명</font></span></td>     \n");
        		itemList.append("	    		<td width=247 align=center><span style=font-size:12px;><font  face=맑은 고딕>규격</font></span></td>     \n");
        		itemList.append("	    		<td width=100 align=center><span style=font-size:12px;><font  face=맑은 고딕>수량</font></span></td>     \n");
        		itemList.append("	    		<td width=124 align=center><span style=font-size:12px;><font  face=맑은 고딕>수량단위</font></span></td>   \n");
        		itemList.append("	    		<td width=100 align=center><span style=font-size:12px;><font  face=맑은 고딕>단가</font></span></td>     \n");
        		itemList.append("	    		<td width=65 align=center><span style=font-size:12px;><font  face=맑은 고딕>단가단위</font></span></td>   \n");
        		itemList.append("	    		<td width=144 align=center><span style=font-size:12px;><font  face=맑은 고딕>공급가액</font></span></td>     \n");
        		itemList.append("	    		<td align=center><span style=font-size:12px;><font  face=맑은 고딕>VAT</font></span></td>     \n");
        		itemList.append("	    	</tr>      \n");

        		double vatAmt = 0d;
        		for(Map<String,Object> data : gridItem) {
        			if("T1".equals(data.get("VAT_CD"))) {
        				vatAmt = Double.parseDouble( String.valueOf(data.get("ITEM_AMT"))  )/10;
        			} else {
        				vatAmt = 0;
        			}
		  	        itemList.append("	    	<tr> \n");
		  	        itemList.append("	    		<td> <span style=font-size:12px;> <font  face=맑은 고딕>"+data.get("ITEM_DESC")+"</font></span></td>            \n");
		  	        itemList.append("	    		<td> <span style=font-size:12px;> <font  face=맑은 고딕>"+data.get("ITEM_SPEC")+"</font></span></td>            \n");
		  	        itemList.append("	    		<td align=right> <span style=font-size:12px;><font  face=맑은 고딕>"+EverMath.EverNumberType(String.valueOf(data.get("ITEM_QT")),"###,###.###")+"</font></span></td>        \n");
		  	        itemList.append("	    		<td align=center> <span style=font-size:12px;><font  face=맑은 고딕>"+EverString.nullToEmptyString(data.get("UNIT_CD"))+"</font></span></td>           \n");
		  	        itemList.append("	    		<td align=right><span style=font-size:12px;><font  face=맑은 고딕>"+EverMath.EverNumberType(String.valueOf(data.get("UNIT_PRC")),"###,###.###")+"</font></span></td>    \n");
		  	        itemList.append("	    		<td align=center> <span style=font-size:12px;> <font  face=맑은 고딕>"+data.get("CUR")+"</font></span></td>            \n");
		  	        itemList.append("	    		<td align=right><span style=font-size:12px;><font  face=맑은 고딕>"+EverMath.EverNumberType(String.valueOf(data.get("ITEM_AMT")),"###,###.###")+"</font></span></td>                                                          \n");
		  	        itemList.append("	    		<td align=right><span style=font-size:12px;><font  face=맑은 고딕>"+EverMath.EverNumberType(String.valueOf(vatAmt),"###,###.###")+"</font></span></td>    \n");
		  	        itemList.append("	    	</tr>   \n");
        		}
        		itemList.append("	    	</table>                                                                                                                                             \n");
        		resultContractForm = ContStringUtil.initString(resultContractForm, "&lt;div id=\"ccc\"&gt;", "&lt;/div&gt;", "[[RFQITEM_LIST]]");
        		resultContractForm = ContStringUtil.initStringTag(resultContractForm, "<div id=\"ccc\">", "</div>", "[[RFQITEM_LIST]]");
        		resultContractForm = EverString.replace(resultContractForm, "[[RFQITEM_LIST]]", itemList.toString());
        	}

    	  	// 시방리스트
    	  	if(gridItem.size()!=0) {
    	  		StringBuffer itemList = new StringBuffer();
    	  		itemList.append("	      <table border=1 width=100% style=border-collapse:collapse;>      \n");
    	  		itemList.append("	    	<tr height=10>                                                                   \n");
    	  		itemList.append("	    		<td width=361 align=center><span style=font-size:12px;><font  face=맑은 고딕>기계/설비 내역</font></span></td>     \n");
    	  		itemList.append("	    		<td width=147 align=center><span style=font-size:12px;><font  face=맑은 고딕>금액 단위</font></span></td>     \n");
    	  		itemList.append("	    		<td width=147 align=center><span style=font-size:12px;><font  face=맑은 고딕>공급가액</font></span></td>     \n");
    	  		itemList.append("	    		<td width=124 align=center><span style=font-size:12px;><font  face=맑은 고딕>VAT</font></span></td>   \n");
    	  		itemList.append("	    	</tr>      \n");

    	  		double vatAmt = 0d;
    	  		for(Map<String,Object> data : gridItem) {
		        	if("T1".equals(data.get("VAT_CD"))) {
		        		vatAmt = Double.parseDouble( String.valueOf(data.get("ITEM_AMT"))  )/10;
		        	} else {
		        		vatAmt = 0;
		        	}
		  	        itemList.append("	    	<tr> \n");
		  	        itemList.append("	    		<td> <span style=font-size:12px;> <font  face=맑은 고딕>&nbsp;"+data.get("ITEM_DESC")+"</font></span></td>            \n");
		  	        itemList.append("	    		<td align=center> <span style=font-size:12px;> <font  face=맑은 고딕>"+data.get("CUR")+"</font></span></td>            \n");
		  	        itemList.append("	    		<td align=right><span style=font-size:12px;><font  face=맑은 고딕>"+EverMath.EverNumberType(String.valueOf("22222"),"###,###.###")+"&nbsp;</font></span></td>                                                          \n");
		  	        itemList.append("	    		<td align=right><span style=font-size:12px;><font  face=맑은 고딕>"+EverMath.EverNumberType(String.valueOf(vatAmt),"###,###.###")+"&nbsp;</font></span></td>    \n");
		  	        itemList.append("	    	</tr>   \n");
	          	}
	          	itemList.append("	    	</table>                                                                                                                                             \n");
	          	resultContractForm = ContStringUtil.initString(resultContractForm, "&lt;div id=\"ddd\"&gt;", "&lt;/div&gt;", "[[SIBANG_LIST]]");
	          	resultContractForm = ContStringUtil.initStringTag(resultContractForm, "<div id=\"ddd\">", "</div>", "[[SIBANG_LIST]]");
	          	resultContractForm = EverString.replace(resultContractForm, "[[SIBANG_LIST]]", itemList.toString());
    	  	}

    	  	//대금지급정보
          	List<Map<String, Object>> gridP = req.getGridData("gridP");
    	  	if(gridP.size()!=0) {
	          	StringBuffer payInfoList = new StringBuffer();
	          	payInfoList.append("	      <table border=1 width=100% style=border-collapse:collapse;>      \n");
	          	payInfoList.append("	    	<tr height=10>       \n");
	          	payInfoList.append("	    		<td width=121 align=center><span style=font-size:12px;><font  face=맑은 고딕>구분</font></span></td>                                          \n");
	          	payInfoList.append("	    		<td width=174 align=center><span style=font-size:12px;><font  face=맑은 고딕>지급시기</font></span></td>                                        \n");
	          	payInfoList.append("	    		<td width=100 align=center><span style=font-size:12px;><font  face=맑은 고딕>지급비율(%)</font></span></td>                                          \n");
	          	payInfoList.append("	    		<td align=center><span style=font-size:12px;><font  face=맑은 고딕>지급금액(￦)</font></span></td>                                          \n");
	          	payInfoList.append("	    	</tr>    \n");

	          	for(Map<String,Object> data : gridP) {
		  	        payInfoList.append("	    	<tr> \n");
		  	        payInfoList.append("	    		<td align=center> <span style=font-size:12px;> <font  face=맑은 고딕>"+data.get("PAY_CNT_NM")+"</font></span></td>            \n");
		  	        payInfoList.append("	    		<td> <span style=font-size:12px;><font  face=맑은 고딕>&nbsp;"+EverString.nullToEmptyString(EverString.nullToEmptyString(data.get("PAY_METHOD_NM")))+"</font></span></td>       \n");
		  	        payInfoList.append("	    		<td align=center><span style=font-size:12px;><font  face=맑은 고딕>"+EverString.nullToEmptyString(String.valueOf(data.get("PAY_PERCENT")))+"</font></span></td>    \n");
		  	        payInfoList.append("	    		<td align=right><span style=font-size:12px;><font  face=맑은 고딕>"+EverString.nullToEmptyString(EverMath.EverNumberType(String.valueOf(data.get("PAY_AMT")),"###,###.###"))+"&nbsp;</font></span></td>  \n");
	  	        	payInfoList.append("	    	</tr>   \n");
	          	}

	          	payInfoList.append("	    	</table>                                                                                                                                             \n");
	          	resultContractForm = ContStringUtil.initString(resultContractForm, "&lt;div id=\"bbb\"&gt;", "&lt;/div&gt;", "[[PAYINFO_LIST]]");
	          	resultContractForm = ContStringUtil.initStringTag(resultContractForm, "<div id=\"bbb\">", "</div>", "[[PAYINFO_LIST]]");
	          	resultContractForm = EverString.replace(resultContractForm, "[[PAYINFO_LIST]]", payInfoList.toString());
    	  	}
        } catch (Exception e) {
        	e.printStackTrace();
      	}

        resultContractForm = getReplacedContentsWithInformation(resultContractForm, buyerInformation, vendorInformation, paramMap);
        resultContractForm = resultContractForm.replaceAll("&#37[;]", "%");
        resultContractForm = resultContractForm.replaceAll("&#39[;]", "'");

        paramMap.put("formContents", resultContractForm);
        req.setAttribute("form", paramMap);

        return resultContractForm;
    }

    /**
     * 계약서 서식을 넘겨받은 정보로 내용을 치환하여 리턴
     *
     * @param contents          대상데이터(서식)
     * @param buyerInformation  조회한 구매사 정보
     * @param vendorInformation 조회한 협력회사 정보
     * @param formData          화면의 입력폼
     * @return
     * @throws ParseException
     * @throws UserInfoNotFoundException
     */
    public String getReplacedContentsWithInformation(String contents, Map<String, String> buyerInformation, Map<String, String> vendorInformation, Map<String, String> formData) throws ParseException {
        Source source = new Source(contents.replaceAll("&lt;", "<").replaceAll("&gt;", ">"));
        OutputDocument outputDocument = new OutputDocument(source);

        List<FormControl> formControls = source.getFormControls();
        for (FormControl formControl : formControls) {
            String name = formControl.getName();

            if (EverString.isNotEmpty(name)) {

                /* 서식선택 팝업에서 입력한 정보들과 동일한 이름들이 있는 지 체크 후 치환 */
                if (formData.containsKey(name)) {
                    if(!name.equals("PAY_RMK_KR")) {
                        formControl.setValue(EverString.defaultIfEmpty(String.valueOf(formData.get(name)), ""));
                        ContStringUtil.makeupFormValue(formControl);
                    }
                }
                //보증 여부 표시
                if(name.equals("CONT_CHECK")) {
                	if(formData.get("CONT_INSU_BILL_FLAG").equals("1")) {
                		formControl.setValue("O");
                	}

                }
                if(name.equals("WARR_CHECK")) {
                	if(formData.get("WARR_INSU_BILL_FLAG").equals("1")) {
                		formControl.setValue("O");
                	}

                }
                if(name.equals("ADV_CHECK")) {
                	if(formData.get("ADV_INSU_BILL_FLAG").equals("1")) {
                		formControl.setValue("O");
                	}

                }
                /* 계약금액(한글)일 경우 한글로 숫자를 표기하도록 치환 */
                if (name.equals("CONT_AMT_KR")) {
                    if(formData.get("CONT_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_AMT")))) {
                        formControl.setValue("일금" + ContStringUtil.numberToKorean(String.valueOf(formData.get("CONT_AMT")))+"원整");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("CONT_AMT")) {
                    if(formData.get("CONT_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_AMT"))) && !"0".equals(String.valueOf(formData.get("CONT_AMT")))) {
                        formControl.setValue("(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("CONT_AMT_KR_VAT")) {
                    if(formData.get("CONT_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_AMT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M100");
                        cParam.put("CODE", formData.get("VAT_TYPE"));
                        String vatTypeLoc = ct0300mapper.getCodeDesc(cParam);

                        BigDecimal contAmtBD = new BigDecimal(String.valueOf(formData.get("CONT_AMT")));
                        String contAmt = contAmtBD.toString().replace(".00", "");
                        formControl.setValue("金 " + ContStringUtil.numberToKorean(contAmt) + "원整(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_AMT")), "###,###") + "), " + vatTypeLoc);
                    } else {
                        formControl.setValue("");
                    }
                }

                if (name.equals("SUPPLY_AMT_KR")) {
                    if(formData.get("SUPPLY_AMT") != null && !"".equals(String.valueOf(formData.get("SUPPLY_AMT"))) && !"null".equals(String.valueOf(formData.get("SUPPLY_AMT")))) {
                        formControl.setValue("일금" +ContStringUtil.numberToKorean(String.valueOf(formData.get("SUPPLY_AMT")))+"원整");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("SUPPLY_AMT")) {
                    if(formData.get("SUPPLY_AMT") != null && !"".equals(String.valueOf(formData.get("SUPPLY_AMT"))) && !"null".equals(String.valueOf(formData.get("SUPPLY_AMT"))) && !"0".equals(String.valueOf(formData.get("SUPPLY_AMT")))) {
                        formControl.setValue("(￦" + EverMath.EverNumberType(String.valueOf(formData.get("SUPPLY_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("VAT_AMT_KR")) {
                    if(formData.get("VAT_AMT") != null && !"0".equals(String.valueOf(formData.get("VAT_AMT"))) && !"".equals(String.valueOf(formData.get("VAT_AMT"))) && !"null".equals(String.valueOf(formData.get("VAT_AMT")))) {
                        formControl.setValue("일금" +ContStringUtil.numberToKorean(String.valueOf(formData.get("VAT_AMT")))+"원整");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("VAT_AMT")) {
                    if(formData.get("VAT_AMT") != null && !"".equals(String.valueOf(formData.get("VAT_AMT"))) && !"null".equals(String.valueOf(formData.get("VAT_AMT"))) && !"0".equals(String.valueOf(formData.get("VAT_AMT")))) {
                        formControl.setValue("(￦" + EverMath.EverNumberType(String.valueOf(formData.get("VAT_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("VAT_TYPE_KR")) {
                	String vatTypeKr = "";
                	if("0".equals(formData.get("VAT_TYPE"))) {
                		vatTypeKr = "부가세 별도";
                	}
                	if("1".equals(formData.get("VAT_TYPE"))) {
                		vatTypeKr = "부가세 포함";
                	}
                	if("2".equals(formData.get("VAT_TYPE"))) {
                		vatTypeKr = "비과세";
                	}
                    formControl.setValue(vatTypeKr);
                }






                if (name.equals("CONT_AMT_KR_NUM")) {
                    if(formData.get("CONT_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_AMT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M100");
                        cParam.put("CODE", formData.get("VAT_TYPE"));
                        String vatTypeLoc = ct0300mapper.getCodeDesc(cParam);

                        String contAmt = String.valueOf(formData.get("CONT_AMT"));
                        formControl.setValue("금 " + ContStringUtil.numberToKorean(contAmt) + "원정(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_AMT")), "###,###") + "), " + vatTypeLoc);
                    } else { formControl.setValue(""); }
                }
                if (name.equals("VAT_AMT_KR_NUM")) {
                    if(formData.get("VAT_AMT") != null && !"0".equals(String.valueOf(formData.get("VAT_AMT"))) && !"".equals(String.valueOf(formData.get("VAT_AMT"))) && !"null".equals(String.valueOf(formData.get("VAT_AMT")))) {
                        BigDecimal vatAmtBD = new BigDecimal(String.valueOf(formData.get("VAT_AMT")));
                        String vatAmt = vatAmtBD.toString().replace(".00", "").replace(".0", "");
                        formControl.setValue("금 " + ContStringUtil.numberToKorean(vatAmt) + "원정(￦" + EverMath.EverNumberType(String.valueOf(formData.get("VAT_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("CONT_VAT_KR")) {
                    if(formData.get("VAT_TYPE") != null && !"".equals(String.valueOf(formData.get("VAT_TYPE"))) && !"null".equals(String.valueOf(formData.get("VAT_TYPE")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M100");
                        cParam.put("CODE", formData.get("VAT_TYPE"));
                        String vatTypeLoc = ct0300mapper.getCodeDesc(cParam);
                        formControl.setValue(vatTypeLoc);
                    } else {
                        formControl.setValue("");
                    }
                }

                /* 계약보증(한글)일 경우 한글로 숫자를 표기하도록 치환 */
                if (name.equals("TOT_GUAR_AMT_KR_VAT")) {
                    if(formData.get("CONT_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_GUAR_AMT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M100");
                        cParam.put("CODE", formData.get("CONT_VAT_TYPE"));
                        String contVatTypeLoc = ct0300mapper.getCodeDesc(cParam);

                        BigDecimal contGuarAmtBD = new BigDecimal(String.valueOf(formData.get("CONT_GUAR_AMT")));
                        String contGuarAmt = contGuarAmtBD.toString().replace(".00", "");
                        formControl.setValue("金 " + ContStringUtil.numberToKorean(contGuarAmt) + "원整(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_GUAR_AMT")), "###,###") + "), " + contVatTypeLoc);
                    } else {
                        formControl.setValue("");
                    }
                }
                if (name.equals("ADV_GUAR_AMT_INFO")) {
                    if(formData.get("ADV_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("ADV_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("ADV_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("ADV_GUAR_AMT")))
                            && formData.get("ADV_GUAR_PERCENT") != null && !"".equals(String.valueOf(formData.get("ADV_GUAR_PERCENT"))) && !"null".equals(String.valueOf(formData.get("ADV_GUAR_PERCENT"))) && !"0".equals(String.valueOf(formData.get("ADV_GUAR_PERCENT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M217");
                        cParam.put("CODE", formData.get("ADV_GUAR_TYPE"));
                        String advGuarTypeLoc = ct0300mapper.getCodeDesc(cParam);
                        if(EverString.nullToEmptyString(formData.get("ADV_GUAR_TYPE")).equals("") || EverString.nullToEmptyString(formData.get("ADV_GUAR_TYPE")).equals("EX")) {
                            advGuarTypeLoc = "해당사항 없음";
                        }
                        formControl.setValue("금 " + EverMath.EverNumberType(String.valueOf(formData.get("ADV_GUAR_AMT")), "###,###") + "원정(" + advGuarTypeLoc + ")");
                    }
                    else { formControl.setValue("해당사항 없음"); }
                }
                if (name.equals("ADV_GUAR_AMT_KR")) {
                    if(formData.get("ADV_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("ADV_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("ADV_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("ADV_GUAR_AMT")))) {
                        String advguarAmt = String.valueOf(formData.get("ADV_GUAR_AMT"));
                        formControl.setValue("일금" + ContStringUtil.numberToKorean(advguarAmt) + "원整");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("ADV_GUAR_AMT")) {
                    if(formData.get("ADV_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("ADV_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("ADV_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("ADV_GUAR_AMT")))) {
                        formControl.setValue("(￦" + EverMath.EverNumberType(String.valueOf(formData.get("ADV_GUAR_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("CONT_GUAR_AMT_INFO")) {
                    if(formData.get("CONT_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("CONT_GUAR_AMT")))
                            && formData.get("CONT_GUAR_PERCENT") != null && !"".equals(String.valueOf(formData.get("CONT_GUAR_PERCENT"))) && !"null".equals(String.valueOf(formData.get("CONT_GUAR_PERCENT"))) && !"0".equals(String.valueOf(formData.get("CONT_GUAR_PERCENT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M217");
                        cParam.put("CODE", formData.get("CONT_GUAR_TYPE"));
                        String contGuarTypeLoc = ct0300mapper.getCodeDesc(cParam);
                        if(EverString.nullToEmptyString(formData.get("CONT_GUAR_TYPE")).equals("") || EverString.nullToEmptyString(formData.get("CONT_GUAR_TYPE")).equals("EX")) {
                            contGuarTypeLoc = "해당사항 없음";
                        }

                        formControl.setValue("금 " + EverMath.EverNumberType(String.valueOf(formData.get("CONT_GUAR_AMT")), "###,###") + "원정(" + contGuarTypeLoc + ")");
                    } else { formControl.setValue("해당사항 없음"); }
                }
                if (name.equals("CONT_GUAR_AMT_KR")) {
                	System.out.println("============:"+formData.get("WARR_GUAR_AMT")+":");
                    if(formData.get("CONT_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("CONT_GUAR_AMT")))) {
                        String contGuarAmt = String.valueOf(formData.get("CONT_GUAR_AMT"));
                        formControl.setValue("일금" + ContStringUtil.numberToKorean(contGuarAmt) + "원整");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("CONT_GUAR_AMT")) {
                    if(formData.get("CONT_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("CONT_GUAR_AMT")))) {
                        formControl.setValue("(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_GUAR_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("WARR_GUAR_AMT_INFO")) {
                    if(formData.get("WARR_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("WARR_GUAR_AMT")))
                            && formData.get("WARR_GUAR_PERCENT") != null && !"".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT"))) && !"null".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT"))) && !"0".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M217");
                        cParam.put("CODE", formData.get("WARR_GUAR_TYPE"));
                        String warrGuarTypeLoc = ct0300mapper.getCodeDesc(cParam);
                        if(EverString.nullToEmptyString(formData.get("WARR_GUAR_TYPE")).equals("") || EverString.nullToEmptyString(formData.get("WARR_GUAR_TYPE")).equals("EX")) {
                            warrGuarTypeLoc = "해당사항 없음";
                        }

                        formControl.setValue("금 " + EverMath.EverNumberType(String.valueOf(formData.get("WARR_GUAR_AMT")), "###,###") + "원정(" + warrGuarTypeLoc + ")");
                    } else { formControl.setValue("해당사항 없음"); }
                }
                if (name.equals("WARR_GUAR_AMT_KR")) {
                    if(formData.get("WARR_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("WARR_GUAR_AMT")))) {
                        String warrGuarAmt = String.valueOf(formData.get("WARR_GUAR_AMT"));
                        formControl.setValue("일금" + ContStringUtil.numberToKorean(warrGuarAmt) + "원整");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("WARR_GUAR_AMT")) {
                    if(formData.get("WARR_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("WARR_GUAR_AMT")))) {
                        formControl.setValue("(￦" + EverMath.EverNumberType(String.valueOf(formData.get("WARR_GUAR_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("WARR_GUAR_PERCENT_INFO")) {
                    if(formData.get("WARR_GUAR_PERCENT") != null && !"".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT"))) && !"null".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT"))) && !"0".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT")))) {
                        formControl.setValue("계약금액의 (" + EverMath.EverNumberType(String.valueOf(formData.get("WARR_GUAR_PERCENT")), "###,###.###") + ")％");
                    } else { formControl.setValue("해당사항 없음"); }
                }

                /* 지연 배상금 률을 표기하도록 치환 */
                if (name.equals("DELAY_INFO")) {
                    if(formData.get("DELAY_RMK") != null && !String.valueOf(formData.get("DELAY_RMK")).equals("") && formData.get("DELAY_DENO_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_DENO_RATE"))) && formData.get("DELAY_NUME_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_NUME_RATE")))) {
                        formControl.setValue(formData.get("DELAY_RMK") + " " + EverMath.EverNumberType(String.valueOf(formData.get("DELAY_DENO_RATE")), "###,###") + "분의 " + EverMath.EverNumberType(String.valueOf(formData.get("DELAY_NUME_RATE")), "###,###.##"));
                    } else {
                        formControl.setValue("");
                    }
                }
                if (name.equals("DELAY_RATE_INFO")) {
                    if(formData.get("DELAY_NUME_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_NUME_RATE"))) && formData.get("DELAY_DENO_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_DENO_RATE"))) && !"0".equals(String.valueOf(formData.get("DELAY_DENO_RATE")))) {
                        BigDecimal delayNumeRateBD = new BigDecimal(String.valueOf(formData.get("DELAY_NUME_RATE")));
                        String delayNumeRate = delayNumeRateBD.toString().replace(".00", "");
                        BigDecimal delayDenoRateBD = new BigDecimal(String.valueOf(formData.get("DELAY_DENO_RATE")));
                        String delayDenoRate = delayDenoRateBD.toString().replace(".00", "");
                        formControl.setValue(formData.get("DELAY_RMK") + " " + EverMath.EverNumberType(delayNumeRate, "###,###.##") + " / " + EverMath.EverNumberType(delayDenoRate, "###,###.##"));
                    } else {
                        formControl.setValue("");
                    }
                }
                if (name.equals("DELAY_RATE_CAL")) {
                    if(formData.get("DELAY_NUME_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_NUME_RATE"))) && formData.get("DELAY_DENO_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_DENO_RATE")))) {
                        BigDecimal delayNumeRateBD = new BigDecimal(String.valueOf(formData.get("DELAY_NUME_RATE")));
                        double delayNumeRate = Double.parseDouble(delayNumeRateBD.toString().replace(".00", ""));
                        BigDecimal delayDenoRateBD = new BigDecimal(String.valueOf(formData.get("DELAY_DENO_RATE")));
                        double delayDenoRate = Double.parseDouble(delayDenoRateBD.toString().replace(".00", ""));
                        double calDelayRate = delayNumeRate / delayDenoRate;
                        formControl.setValue(EverMath.EverNumberType(String.valueOf(calDelayRate), "###,###.####"));
                    } else {
                        formControl.setValue("");
                    }
                }
                if (name.equals("DELAY_RATE")) {
                    if(formData.get("DELAY_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_RATE"))) && !"null".equals(String.valueOf(formData.get("DELAY_RATE"))) && !"0".equals(String.valueOf(formData.get("DELAY_RATE")))) {
                        formControl.setValue(formData.get("DELAY_RATE") + "%");
                    } else { formControl.setValue(""); }
                }
                /* 대금지급조건을 표기하도록 치환 */
                if (name.equals("PAY_METHOD")) {
                    if(formData.get("PAY_METHOD") != null && !String.valueOf(formData.get("PAY_METHOD")).equals("")) {
                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M018");
                        cParam.put("CODE", formData.get("PAY_METHOD"));
                        String payMethodLoc = ct0300mapper.getCodeDesc(cParam);
                        formControl.setValue(payMethodLoc);
                    } else {
                        formControl.setValue("");
                    }
                }

                /* 계약이행보증증권의 내용을 표기하도록 치환 */
                if (name.equals("CONT_GUAR_TYPE")) {
                    if(formData.get("CONT_GUAR_AMT") == null || "".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) || "0".equals(String.valueOf(formData.get("CONT_GUAR_AMT")))) {
                        formControl.setValue("");
                    } else {
                        if (formData.get("CONT_GUAR_TYPE") != null && !String.valueOf(formData.get("CONT_GUAR_TYPE")).equals("")) {
                            Map<String, String> cParam = new HashMap<String, String>();
                            cParam.put("CODE_TYPE", "M217");
                            cParam.put("CODE", formData.get("CONT_GUAR_TYPE"));
                            String contGuarType = ct0300mapper.getCodeDesc(cParam);
                            formControl.setValue(contGuarType);
                        } else {
                            formControl.setValue("");
                        }
                    }
                }

                /* 선급금,중도금,잔금 */
                if (name.equals("CONT_PAY_AMT_KR")) {
                    if(formData.get("CONT_PAY_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_PAY_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_PAY_AMT"))) && !"0".equals(String.valueOf(formData.get("CONT_PAY_AMT")))) {
                        String contpayamt = String.valueOf(formData.get("CONT_PAY_AMT"));
                        formControl.setValue("일금" +ContStringUtil.numberToKorean(contpayamt) + "원整");
                    } else { formControl.setValue(""); }
                }

                if (name.equals("CONT_PAY_AMT")) {
                    if(formData.get("CONT_PAY_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_PAY_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_PAY_AMT"))) && !"0".equals(String.valueOf(formData.get("CONT_PAY_AMT")))) {
                        formControl.setValue("(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_PAY_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }

                if (name.equals("ADV_PAY_AMT_KR")) {
                    if(formData.get("ADV_PAY_AMT") != null && !"".equals(String.valueOf(formData.get("ADV_PAY_AMT"))) && !"null".equals(String.valueOf(formData.get("ADV_PAY_AMT"))) && !"0".equals(String.valueOf(formData.get("ADV_PAY_AMT")))) {
                        String advpayamtKR = String.valueOf(formData.get("ADV_PAY_AMT"));
                        formControl.setValue("일금" +ContStringUtil.numberToKorean(advpayamtKR) + "원整");
                    } else { formControl.setValue(""); }
                }

                if (name.equals("ADV_PAY_AMT")) {
                    if(formData.get("ADV_PAY_AMT") != null && !"".equals(String.valueOf(formData.get("ADV_PAY_AMT"))) && !"null".equals(String.valueOf(formData.get("ADV_PAY_AMT"))) && !"0".equals(String.valueOf(formData.get("ADV_PAY_AMT")))) {
                        formControl.setValue("(￦" + EverMath.EverNumberType(String.valueOf(formData.get("ADV_PAY_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }

                if (name.equals("WARR_PAY_AMT_KR")) {
                    if(formData.get("WARR_PAY_AMT") != null && !"".equals(String.valueOf(formData.get("WARR_PAY_AMT"))) && !"null".equals(String.valueOf(formData.get("WARR_PAY_AMT"))) && !"0".equals(String.valueOf(formData.get("WARR_PAY_AMT")))) {
                        String warrpayamt = String.valueOf(formData.get("WARR_PAY_AMT"));
                        formControl.setValue("일금" +ContStringUtil.numberToKorean(warrpayamt) + "원整");
                    } else { formControl.setValue(""); }
                }

                if (name.equals("WARR_PAY_AMT")) {
                    if(formData.get("WARR_PAY_AMT") != null && !"".equals(String.valueOf(formData.get("WARR_PAY_AMT"))) && !"null".equals(String.valueOf(formData.get("WARR_PAY_AMT"))) && !"0".equals(String.valueOf(formData.get("WARR_PAY_AMT")))) {
                        formControl.setValue("(￦" + EverMath.EverNumberType(String.valueOf(formData.get("WARR_PAY_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }

                /* 구매사 정보와 동일한 이름이 있으면 치환 */
                if (buyerInformation != null) {
                    if (buyerInformation.containsKey(name)) {
                        formControl.setValue(EverString.defaultIfEmpty(buyerInformation.get(name), ""));
                        ContStringUtil.makeupFormValue(formControl);
                    }
                }
                if (vendorInformation != null) {
                    if (vendorInformation.containsKey(name)) {
                        formControl.setValue(EverString.defaultIfEmpty(vendorInformation.get(name), ""));
                        ContStringUtil.makeupFormValue(formControl);
                    }
                }

                if (name.equals("CONT_LAST_DAYS")) {
                    if(StringUtils.isNotEmpty(formData.get("CONT_START_DATE")) && StringUtils.isNotEmpty(formData.get("CONT_END_DATE"))) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                        Date contStartDate = sdf.parse(formData.get("CONT_START_DATE"));
                        Date contEndDate = sdf.parse(formData.get("CONT_END_DATE"));
                        formControl.setValue(ContStringUtil.toPositionalNumber(String.valueOf(Days.daysBetween(new LocalDate(contStartDate), new LocalDate(contEndDate)).getDays()+1 )));
                        ContStringUtil.makeupFormValue(formControl);
                    }
                }
            }
            /* 각각의 formControl에 setValue() 한 결과가 적용되기 위한 필수코드입니다. */
            outputDocument.replace(formControl);
        }
        return outputDocument.toString();
    }




    public Map<String, String> becf040_doSearch(String formNum)  throws Exception {

        Map<String, String> formData = ct0100mapper.becf040_doSearch(formNum);
        formData.put("formContents", formData.get("FORM_TEXT"));

        return formData;
    }

    public List<Map<String, Object>> becf040_doSearchECCR(Map<String, String> param) {
        return ct0100mapper.becf040_doSearchECCR(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String becf040_doSave(Map<String, String> formData, List<Map<String, Object>> grid) throws Exception {

        String formNum = formData.get("FORM_NUM");
        String copyYn = "N";
        if (StringUtils.isEmpty(formNum)) {
            formNum = docNumService.getDocNumber("FORMNO");
            formData.put("FORM_NUM", formNum);
            ct0100mapper.becf040_doInsertForm(formData);
            //서식 복사시 채번하더라고 부서식 로직처리때문에
            copyYn = "Y";
        } else {
            ct0100mapper.becf040_doUpdateForm(formData);
        }

        for (Map<String, Object> gridData : grid) {
            boolean isSelected = false;
            if (String.valueOf(gridData.get("SELECTED")).equals("1")) {
                isSelected = true;
            }

            if (gridData.get("FORM_NUM") == null || "Y".equals(copyYn)) {
                gridData.put("FORM_NUM", "");
            }

            boolean hasFormNo = EverString.isNotEmpty(String.valueOf(gridData.get("FORM_NUM")));

            if (hasFormNo && isSelected) {
                ct0100mapper.newFormRegistrationDoUpdateGridData(gridData);
            } else if (hasFormNo && !isSelected) {
                ct0100mapper.newFormRegistrationDoDeleteGridData(gridData);
            } else if (!hasFormNo && isSelected) {
                gridData.put("FORM_NUM", formNum);
                int existCount = ct0100mapper.newFormRegistrationGetExistCount(gridData);
                if (existCount == 0) {
                    ct0100mapper.newFormRegistrationDoInsertGridData(gridData);
                } else if (existCount == 1) {
                    gridData.put("updateRelFormSeq", "true");
                    ct0100mapper.newFormRegistrationDoUpdateGridData(gridData);
                } else {
                    throw new NoResultException("Unexpected Case");
                }
            } else if (!hasFormNo && !isSelected) {
                continue;
            } else {
                throw new NoResultException("Unexpected Case");
            }
        }
        return formNum;
    }






}
