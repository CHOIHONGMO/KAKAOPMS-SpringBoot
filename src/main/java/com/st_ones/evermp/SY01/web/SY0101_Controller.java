package com.st_ones.evermp.SY01.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.SY01.service.SY0101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/SY01/SY0101")
public class SY0101_Controller extends BaseController {

    @Autowired
    SY0101_Service sy0101Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;

    /** ****************************************************************************************************************
     * 조직정보 현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/SY01_001/view")
    public String SY01_001(EverHttpRequest req) throws Exception {

    	// 고객사 운영사 관리자 사용메뉴
    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	  if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
    	req.setAttribute("yyyymm", EverDate.getShortDateString().substring(0, 6));
        return "/evermp/SY01/SY01_001";
    }


    /** ****************************************************************************************************************
     * 조직정보 현황(운영사)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/SY01_001O/view")
    public String SY01_001O(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

        req.setAttribute("yyyymm", EverDate.getShortDateString().substring(0, 6));
        return "/evermp/SY01/SY01_001O";
    }







    @RequestMapping(value="/sy01001_doSearch")
    public void sy01001_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("PLANT_CD",EverString.nullToEmptyString(req.getParameter("PLANT_CD")));

        if(!param.get("DEPT_NM").equals("")){
            param.put("DEPT_TYPE", "300");
            resp.setGridObject("gridB", sy0101Service.sy01001_doSearch(param));

            param.put("DEPT_TYPE", "200");
            param.put("STEP2", "Y");
            resp.setGridObject("gridM", sy0101Service.sy01001_doSearch_parent(param));

            param.put("DEPT_TYPE", "100");
            param.put("STEP2", "");
            param.put("STEP1", "Y");
            resp.setGridObject("gridT", sy0101Service.sy01001_doSearch_parent(param));

        }else{
            param.put("DEPT_TYPE", "100");
            resp.setGridObject("gridT", sy0101Service.sy01001_doSearch(param));
        }
    }

    @RequestMapping(value="/sy01001_doSearchT")
    public void sy01001_doSearchT(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("DEPT_TYPE", "100");

        resp.setGridObject("gridT", sy0101Service.sy01001_doSearch(param));
    }

    @RequestMapping(value="/sy01001_doSearchM")
    public void sy01001_doSearchM(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("PARENT_DEPT_CD", req.getParameter("PARENT_DEPT_CD"));
        param.put("DEPT_TYPE", "200");

        resp.setGridObject("gridM", sy0101Service.sy01001_doSearch(param));
    }

    @RequestMapping(value="/sy01001_doSearchB")
    public void sy01001_doSearchB(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("PARENT_DEPT_CD", req.getParameter("PARENT_DEPT_CD"));
        param.put("DEPT_TYPE", "300");

        resp.setGridObject("gridB", sy0101Service.sy01001_doSearch(param));
    }

    @RequestMapping(value="/sy01001_doSearchDP")
    public void sy01001_doSearchDP(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("PARENT_DEPT_CD", req.getParameter("PARENT_DEPT_CD"));
        param.put("DEPT_TYPE", "400");

        resp.setGridObject("gridDP", sy0101Service.sy01001_doSearch(param));
    }

    //부서저장
    @RequestMapping(value="/sy01001_doSave")
    public void sy01001_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        String radioVal = EverString.nullToEmptyString(req.getParameter("radioVal"));

        List<Map<String, Object>> gridList = null;
        if(radioVal.equals("R1")) { gridList = req.getGridData("gridT"); }
        else if(radioVal.equals("R2")) { gridList = req.getGridData("gridM"); }
        else if(radioVal.equals("R3")) { gridList = req.getGridData("gridB"); }
        else if(radioVal.equals("R4")) { gridList = req.getGridData("gridDP"); }

        String returnMsg = sy0101Service.sy01001_doSave(formData, gridList);
        resp.setResponseMessage(returnMsg);
    }

    //팀-영업점조회
    @RequestMapping(value = "/sy01001_doSelect_DP")
    public void e99003_doSearchStore(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridDP", sy0101Service.sy01001_doSelect_DP(req.getFormData()));
    }

    //팀-영업점저장
    @RequestMapping(value = "/sy01001_doSave_DP")
    public void sy01001_doSave_DP(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> gridData = req.getGridData("gridDP");
        String returnMsg =  sy0101Service.sy01001_doSave_DP(formData, gridData);
        resp.setResponseMessage(returnMsg);
    }

    //팀-영업점 삭제
    @RequestMapping(value = "/sy01001_doDelete_DP")
    public void sy01001_doDelete_DP(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("gridDP");
        String returnMsg =  sy0101Service.sy01001_doDelete_DP(gridData);
        resp.setResponseMessage(returnMsg);
    }

    /** ******************************************************************************************
     * 조직현황(TREE)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/SY01_002/view")
    public String SY01_002(EverHttpRequest req) throws Exception {
        req.setAttribute("yyyymm", EverDate.getShortDateString().substring(0, 6));
        return "/evermp/SY01/SY01_002";
    }

    //부서검색-트리
    @RequestMapping(value = "/sy01001_doSelect_deptTree")
    public void sy01001_doSelect_deptTree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String,Object>> treeData = sy0101Service.sy01001_doSelect_deptTree(req.getFormData());
        resp.setParameter("treeData", EverConverter.getJsonString(treeData));
    }

    /** ******************************************************************************************
     * 팀 검색_TREE
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/SY01_003/view")
    public String SY01_003(EverHttpRequest req) throws Exception {

        Map<String, String> formTree = req.getFormData();

        //손익분류 트리조회
        List<Map<String, Object>> list = sy0101Service.sy01003_doSelect_deptTree(formTree);
        req.setAttribute("treeData", new ObjectMapper().writeValueAsString(list));

        return "/evermp/SY01/SY01_003";
    }

    //팀검색 조회

    @RequestMapping(value = "/SY01_003_doSearch")
    public void SY01_003_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formTree = req.getFormData();
        List<Map<String,Object>> treeData = sy0101Service.sy01003_doSelect_deptTree(formTree);
        resp.setParameter("treeData", EverConverter.getJsonString(treeData));
    }


    //부서정보 저장 --트리
    @RequestMapping(value="/sy01001_doSave_tree")
    public void sy01001_doSave_tree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> grid = req.getGridData("grid");

        String msg = sy0101Service.sy01001_doSave_tree(formData, grid);
        resp.setResponseMessage(msg);

    }

	@RequestMapping(value = "/getPlantCd")
	public void changeComboItemKindR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
        UserInfo userInfo = UserInfoManager.getUserInfo();
		param.put("GATE_CD", userInfo.getGateCd());
		if ( param.get("CUST_CD") == null || "".equals(param.get("CUST_CD"))) {
			param.put("CUST_CD",param.get("CUST_CD_L"));
			if ( param.get("CUST_CD") == null || "".equals(param.get("CUST_CD"))) {
				param.put("CUST_CD",param.get("COMPANY_CD"));
			}
		}
		resp.setParameter("plantCds",  commonComboService.getCodeComboAsJson2("CB0100",param) );
		resp.setResponseCode("true");
	}
	@RequestMapping(value = "/findPlant")
	public void findPlant(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		 resp.setGridObject("gridDP", sy0101Service.findPlant(req.getFormData()));
	}




	@RequestMapping(value = "/getDivisionDeptPartCd")
	public void getDivisionDeptPartCd(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		param.put("DEPT_TYPE",req.getParameter("DEPT_TYPE"));
        UserInfo userInfo = UserInfoManager.getUserInfo();
		param.put("GATE_CD", userInfo.getGateCd());
		if ( param.get("CUST_CD") == null || "".equals(param.get("CUST_CD"))) {
			param.put("CUST_CD",param.get("CUST_CD_L"));
			if ( param.get("CUST_CD") == null || "".equals(param.get("CUST_CD"))) {
				param.put("CUST_CD",param.get("COMPANY_CD"));
			}
		}
		System.err.println(commonComboService.getCodeComboAsJson2("CB0118",param));

		resp.setParameter("divisionDeptPartCd",  commonComboService.getCodeComboAsJson2("CB0118",param) );
		resp.setResponseCode("true");
	}















	 /** ******************************************************************************************
     * 팀 검색_TREE
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/SY01_004/view")
    public String SY01_004(EverHttpRequest req) throws Exception {

        Map<String, String> formTree = req.getFormData();
        formTree.put("custCd",req.getParameter("custCd"));
        req.setAttribute("plantCdOptions", commonComboService.getCodesAsJson("CB0115", formTree));
        //손익분류 트리조회
        List<Map<String, Object>> list = sy0101Service.sy01004_doSelect_deptTree(formTree);
        req.setAttribute("treeData", new ObjectMapper().writeValueAsString(list));

        return "/evermp/SY01/SY01_004";
    }

    //팀검색 조회

    @RequestMapping(value = "/SY01_004_doSearch")
    public void SY01_004_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formTree = req.getFormData();

        List<Map<String,Object>> treeData = sy0101Service.sy01004_doSelect_deptTree(formTree);
        resp.setParameter("treeData", EverConverter.getJsonString(treeData));
    }
    @RequestMapping(value = "/SY01_004_changePlantCd")
    public void SY01_004_changePlantCd(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	 Map<String, String> formTree = req.getFormData();
         formTree.put("custCd",req.getParameter("custCd"));
         formTree.put("plantCd",req.getParameter("plantCd"));
         resp.setParameter("divisionCdOptions", commonComboService.getCodesAsJson("CB0116", formTree));

    }
    @RequestMapping(value = "/SY01_004_changeDivisionCd")
    public void SY01_004_changeDivisionCd(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	 Map<String, String> formTree = req.getFormData();
         formTree.put("custCd",req.getParameter("custCd"));
         formTree.put("plantCd",req.getParameter("plantCd"));
         formTree.put("divisionCd",req.getParameter("divisionCd"));
         resp.setParameter("deptCdOptions", commonComboService.getCodesAsJson("CB0117", formTree));

    }


}