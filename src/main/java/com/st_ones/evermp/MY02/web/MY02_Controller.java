package com.st_ones.evermp.MY02.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.MY02.service.MY02_Service;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : MY02_Controller.java
 * @author  이연무
 * @date 2018. 02. 06.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/MY02")
public class MY02_Controller extends BaseController {

	@Autowired private MY02_Service my02_Service;

    @Autowired private CommonComboService commonComboService;

    @Autowired MessageService msg;

	/** ******************************************************************************************
     * 미결함
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY02_001/view")
	public String my02001_view(EverHttpRequest req) throws Exception {
		
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType()) ) {
			return "/eversrm/noSuperAuth";
		}
		
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("toDate", EverDate.getDate());
		req.setAttribute("loginStatus", "P");
		req.setAttribute("form", req.getParamDataMap());

		return "/evermp/MY02/MY02_001";
	}

	@RequestMapping(value = "/my02001_doSearch")
	public void my02001_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my02_Service.my02001_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/my02001_doApproval")
	public void my02001_doApproval(EverHttpRequest req, EverHttpResponse resp) throws Exception {

	    String rtnMsg = "";
	    List<Map<String, Object>> gridDatas = req.getGridData("grid");
	    for(Map<String, Object> gridData : gridDatas) {
            rtnMsg = my02_Service.my02001_doApproval(gridData);
        }
		resp.setResponseMessage(msg.getMessage("0057"));
	}

	/** ******************************************************************************************
     * 기결함
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY02_003/view")
	public String my02003_view(EverHttpRequest req) throws Exception {
		
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType()) ) {
			return "/eversrm/noSuperAuth";
		}
		
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("toDate", EverDate.getDate());
		req.setAttribute("loginStatus", "E");
		return "/evermp/MY02/MY02_003";
	}

	@RequestMapping(value = "/my02003_doSearch")
	public void my02003_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my02_Service.my02003_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
     * 상신함
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY02_005/view")
	public String my02005_view(EverHttpRequest req) throws Exception {
		
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType()) ) {
			return "/eversrm/noSuperAuth";
		}
		
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("toDate", EverDate.getDate());
		return "/evermp/MY02/MY02_005";
	}

	@RequestMapping(value = "/my02005_doSearch")
	public void my02005_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my02_Service.my02005_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/my02005_doCancel")
	public void my02005_doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = my02_Service.my02005_doCancel(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
     * 결재경로관리
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY02_007/view")
	public String my02007_view(EverHttpRequest req) throws Exception {
		
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType()) ) {
			return "/eversrm/noSuperAuth";
		}
		
		return "/evermp/MY02/MY02_007";
	}

	@RequestMapping(value = "/my02007_doSearch")
	public void my02007_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my02_Service.my02007_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/my02007_doDelete")
	public void my02007_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = my02_Service.my02007_doDelete(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
     * 결재경로등록
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY02_008/view")
	public String my02008_view(EverHttpRequest req) throws Exception {
		return "/evermp/MY02/MY02_008";
	}

	@RequestMapping(value = "/my02008_doSearchDT")
	public void my02008_doSearchDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my02_Service.my02008_doSearchDT(req.getFormData()));
	}

	@RequestMapping(value = "/my02008_doSave")
	public void my02008_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		formData.put("saveType", EverString.nullToEmptyString(req.getParameter("saveType")));
		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		String rtnMsg = my02_Service.my02008_doSave(formData, gridDatas);
		resp.setResponseMessage(rtnMsg);
	}

	/**
     * 공통으로 사용하는 결재순서 변경 컨트롤러이므로 프로그램 변경 시 아래의 화면을 모두 테스트해야합니다.
     * - 사용하는 화면: 결재요청팝업, 결재경로관리
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/getRealignmentApprovalList")
    public void approvalHelper(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String sortType = req.getParameter("sortType");
        List<Map<String, Object>> grid = req.getGridData("grid");
        if(sortType.equals("up")) {
            int maxSize = grid.size();
            for(int i = maxSize-1; i >= 0; i--) {
                Map<String, Object> currData = grid.get(i);
                String checkFlag = (String)currData.get("CHECK_FLAG");
                if(StringUtils.equals(checkFlag, "1")) {
                    if(i != 0) {
                        Map<String, Object> prevData = grid.get(i-1);
                        String signReqType = StringUtils.defaultIfEmpty((String)prevData.get("SIGN_REQ_TYPE"), "");
                        // 이전의 결재타입이 병렬합의, 병렬결재라면
                        if(signReqType.equals("4") || signReqType.equals("7")) {
                            for(int j = i; j > 0; j--) {

                                if(j-1 >= 0) {
                                    Map<String, Object> beforePrevData = grid.get(j-1);
                                    String beforePrevSignReqType = StringUtils.defaultIfEmpty((String)beforePrevData.get("SIGN_REQ_TYPE"), "");

                                    if(beforePrevSignReqType.equals("4") || beforePrevSignReqType.equals("7")) {
                                        grid.set(j, beforePrevData);
                                        if(j-1 == 0) {
                                            grid.set(j - 1, currData);
                                        }
                                    } else {
                                        grid.set(j, currData);
                                        grid.set(j - 1, beforePrevData);
                                        i = j-1;
                                        break;
                                    }
                                } else {
                                    grid.set(1, grid.get(0));
                                    grid.set(0, currData);
                                    i = j;
                                    break;
                                }

                            }
                        } else {
                            grid.set(i - 1, currData);
                            grid.set(i, prevData);
                            i--;
                            break;
                        }
                    }
                } else {
                    grid.set(i, currData);
                }
            }

        } else if(sortType.equals("down")) {
            int maxSize = grid.size();
            for(int i = 0; i < maxSize; i++) {
                Map<String, Object> currData = grid.get(i);
                String checkFlag = (String)currData.get("CHECK_FLAG");
                if(StringUtils.equals(checkFlag, "1")) {
                    if(i != maxSize-1) {
                        Map<String, Object> prevData = grid.get(i+1);
                        String signReqType = StringUtils.defaultIfEmpty((String)prevData.get("SIGN_REQ_TYPE"), "");
                        // 이전의 결재타입이 병렬합의, 병렬결재라면
                        if(signReqType.equals("4") || signReqType.equals("7")) {
                            for(int j = i; j < maxSize; j++) {

                                if(j+1 < maxSize) {
                                    Map<String, Object> afterNextData = grid.get(j+1);
                                    String beforePrevSignReqType = StringUtils.defaultIfEmpty((String)afterNextData.get("SIGN_REQ_TYPE"), "");

                                    if(beforePrevSignReqType.equals("4") || beforePrevSignReqType.equals("7")) {
                                        grid.set(j, afterNextData);
                                    } else {
                                        grid.set(j, currData);
                                        i = j;
                                        break;
                                    }
                                } else {
                                    grid.set(maxSize - 2, grid.get(maxSize - 1));
                                    grid.set(maxSize - 1, currData);
                                    i = j;
                                    break;
                                }

                            }
                        } else {
                            grid.set(i, prevData);
                            grid.set(i + 1, currData);
                            i++;
                        }
                    }
                } else {
                    grid.set(i, currData);
                }
            }
        }
        resp.setGridObject("grid", grid);
    }

}
