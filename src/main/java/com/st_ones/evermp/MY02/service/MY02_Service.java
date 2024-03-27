package com.st_ones.evermp.MY02.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.MY02.MY02_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
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
 * @File Name : MY02_Service.java
 * @author  이연무
 * @date 2018. 02. 06.
 * @version 1.0
 * @see
 */

@Service(value = "my02_Service")
public class MY02_Service extends BaseService {

	@Autowired MY02_Mapper my02_Mapper;

	@Autowired MessageService msg;

	@Autowired LargeTextService largeTextService;

	@Autowired private DocNumService docNumService;

	@Autowired private EApprovalService eApprovalService;

	/** ******************************************************************************************
     * 미결함
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my02001_doSearch(Map<String, String> param) throws Exception {
		return my02_Mapper.mailBox_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my02001_doApproval(Map<String, Object> gridData) throws Exception {

		Map<String, String> appParam = new HashMap<String, String>();
		appParam.put("APP_DOC_NUM", String.valueOf(gridData.get("APP_DOC_NUM")));
		appParam.put("APP_DOC_CNT", String.valueOf(gridData.get("APP_DOC_CNT")));
		appParam.put("DOC_TYPE", String.valueOf(gridData.get("DOC_TYPE")));
		appParam.put("SIGN_STATUS", "E");
		eApprovalService.approve(appParam);
		appParam.clear();
		return "S";
	}

	/** ******************************************************************************************
     * 기결함
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my02003_doSearch(Map<String, String> param) throws Exception {
		return my02_Mapper.mailBox_doSearch(param);
	}

	/** ******************************************************************************************
     * 상신함
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my02005_doSearch(Map<String, String> param) throws Exception {
		return my02_Mapper.my02005_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my02005_doCancel(List<Map<String, Object>> gridDatas) throws Exception {

		for(Map<String, Object> gridData : gridDatas) {
			Map<String, String> appParam = new HashMap<String, String>();
			appParam.put("APP_DOC_NUM", String.valueOf(gridData.get("APP_DOC_NUM")));
			appParam.put("APP_DOC_CNT", String.valueOf(gridData.get("APP_DOC_CNT")));
			appParam.put("DOC_TYPE", String.valueOf(gridData.get("DOC_TYPE")));
			appParam.put("SIGN_STATUS", String.valueOf(gridData.get("SIGN_STATUS")));
			eApprovalService.cancelApprovalProcess(appParam);
		}
		return msg.getMessage("0061");
	}

	/** ******************************************************************************************
     * 결재경로관리
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my02007_doSearch(Map<String, String> param) throws Exception {
		return my02_Mapper.my02007_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my02007_doDelete(List<Map<String, Object>> gridDatas) throws Exception {
		for(Map<String, Object> gridData : gridDatas) {
			my02_Mapper.deletePath(gridData);
			my02_Mapper.deletePathDetail(gridData);
		}
		return msg.getMessage("0017");
	}

	/** ******************************************************************************************
     * 결재경로등록
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my02008_doSearchDT(Map<String, String> param) throws Exception {
		return my02_Mapper.my02008_doSearchDT(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my02008_doSave(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

		String saveType = formData.get("saveType");
		String pathNum = formData.get("PATH_NUM");

		if(saveType.equals("R")) {
			pathNum = my02_Mapper.getPathNo(formData);
			formData.put("PATH_NUM", pathNum);
			my02_Mapper.insertPath(formData);
		}
		else {
			my02_Mapper.updatePath(formData);
		}

		my02_Mapper.deleteLULP(formData);
		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("PATH_NUM", pathNum);
			my02_Mapper.insertPathDetail(gridData);
		}
		return msg.getMessage("0031");
	}

}
