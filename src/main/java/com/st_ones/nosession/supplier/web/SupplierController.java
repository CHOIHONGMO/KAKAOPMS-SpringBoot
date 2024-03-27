package com.st_ones.nosession.supplier.web;

import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.nosession.supplier.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/")
public class SupplierController extends BaseController {

    @Autowired
    SupplierService supplierService;

    /**
     * 메인화면 - 회원가입 - 사업자번호 체크
     */
    @RequestMapping("/register/doIrsNumCheck")
    public void doIrsNumCheck(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        
    	Map<String, String> rltMap = supplierService.doIrsNumCheck(req.getParamDataMap());
        resp.setResponseCode(rltMap.get("code"));
        resp.setResponseMessage(rltMap.get("Message"));
    }

    /**
     * 메인화면 - ID/PW 찾기
     */
    @RequestMapping("/register/doSearchInfo")
    public void doSearchInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	
        Map<String, String> param = req.getParamDataMap();
        Map<String, String> reqData = new HashMap<String, String>();
        
        // 비밀번호 찾기
        if("P".equals(param.get("sFlag"))) {
            Map<String, String> pwInfo = supplierService.doPwInfo(param);
            if (pwInfo != null) {
            	if( "0".equals(EverString.nullToEmptyString(pwInfo.get("ISPOSSIBLE_FLAG"))) ) {
                    reqData.put("responseCode", "noAccess");
            	} else {
                    param.putAll(pwInfo);
                    if(Integer.parseInt(String.valueOf(pwInfo.get("CNT"))) > 0) {
                    	if( !"".equals(EverString.nullToEmptyString(pwInfo.get("EMAIL"))) ) {
                            String code = supplierService.doPwSend(param); // PW 메일로 전송
                            reqData.put("responseCode", code);
                    	} else {
                    		reqData.put("responseCode", "noEmail");
                    	}
                    } else {
                        reqData.put("responseCode", "fail");
                    }
            	}
            } else {
                reqData.put("responseCode", "fail");
            }
        } else {
            reqData = supplierService.doIdSearch(param);	// 아이디 찾기
        }
        resp.sendJSON(reqData);
    }

}
