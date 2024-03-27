package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0100Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "EV0100Service")
public class EV0100Service  extends BaseService {
    @Autowired private EV0100Mapper ev0100mapper;
	@Autowired
	private MessageService msg;

	@Autowired
	private DocNumService docNumService;



	public List<Map<String, Object>> doSearchEvalItemMgt(Map<String, String> param) throws Exception {
		return ev0100mapper.doSearchEvalItemMgt(param);
	}

	public List<Map<String, Object>> doSearchEvalItemMgtDetail(Map<String, String> param) throws Exception {
		return ev0100mapper.doSearchEvalItemMgtDetail(param);
	}

	public List<Map<String, Object>> doSearchEvalItemMgtDetail2(Map<String, String> param) throws Exception {
		return ev0100mapper.doSearchEvalItemMgtDetail2(param);
	}


	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] doSaveEvalItemMgt(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
		System.err.println("===================gridDatas="+gridDatas.size());
		String[] arr = new String[2];




		if (EverString.isEmpty(formData.get("EV_ITEM_NUM").toString())) {
			String docNo = docNumService.getDocNumber("EVI");
			formData.put("EV_ITEM_NUM", docNo);
			ev0100mapper.doInsertEvalItemMgtMaster(formData);




			if (gridDatas.size() > 0) {
				for (Map<String, Object> gridData : gridDatas) {
					gridData.put("EV_ITEM_NUM", docNo);
					ev0100mapper.doInsertEvalItemMgtDetail(gridData);
				}
			}
		} else {
			ev0100mapper.doUpdateEvalItemMgtMaster(formData);
			for (Map<String, Object> gridData : gridDatas) {
				gridData.put("EV_ITEM_NUM", formData.get("EV_ITEM_NUM").toString());
				if ("I".equals(gridData.get("INSERT_FLAG".toString()))) {
					ev0100mapper.doInsertEvalItemMgtDetail(gridData);
				} else if ("U".equals(gridData.get("INSERT_FLAG".toString()))) {
					ev0100mapper.doUpdateEvalItemMgtDetail(gridData);
				} else {
					ev0100mapper.doDeleteEvalItemMgtDetail(gridData);
				}
			}
		}
		System.err.println("============================SCALE_TYPE_CD_R=="+formData.get("SCALE_TYPE_CD_R"));
		System.err.println("============================doCheckEvalItemMgtDetail=="+ev0100mapper.doCheckEvalItemMgtDetail(formData));

		if (!formData.get("SCALE_TYPE_CD_R").equals("M") && ev0100mapper.doCheckEvalItemMgtDetail(formData) == 0)
			throw new NoResultException(msg.getMessageByScreenId("EV0110", "EXIST_DETAIL"));

		arr[0] = formData.get("EV_ITEM_NUM").toString();
		arr[1] = msg.getMessage("0001");
		return arr;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteEvalItemMgt(List<Map<String, Object>> gridData) throws Exception {

		for(Map<String, Object> grid : gridData) {
			ev0100mapper.doDeleteEvalItemMgtAllDetail(grid);
			ev0100mapper.doDeleteEvalItemMgtMaster(grid);
		}

		return msg.getMessage("0017");
	}























	public List<Map<String, Object>> doSearchLeftGrid(Map<String, String> param) throws Exception {
		return ev0100mapper.doSearchLeftGrid(param);
	}

	public List<Map<String, Object>> doSearchRightGrid(Map<String, String> param) throws Exception {
		return ev0100mapper.doSearchRightGrid(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doEdit(List<Map<String, Object>> gridData) throws Exception {
		for(Map<String,Object> grid : gridData) {
			ev0100mapper.doUpdateSTOCEVTMFlag(grid);
		}

		return msg.getMessage("0016");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDelete(List<Map<String, Object>> gridData) throws Exception {
		for(Map<String,Object> grid : gridData) {
			ev0100mapper.doDeleteAllSTOCEVTD(grid);
			ev0100mapper.doDeleteSTOCEVTM(grid);
		}

		return msg.getMessage("0017");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] doCopy(Map<String, String> param, List<Map<String, Object>> gridDatas) throws Exception {
		String [] args = new String[2];
		String newEvTplNo = docNumService.getDocNumber("EVT");
		param.put("EV_TPL_NUM", newEvTplNo);
		ev0100mapper.doInsertSTOCEVTM(param);

		for(Map<String, Object> data : gridDatas){
			data.put("EV_TPL_NUM", newEvTplNo);
			ev0100mapper.doInsertSTOCEVTD(data);
		}
		args[0] = newEvTplNo;
		args[1] = msg.getMessage("0001");
		return args;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] doSave(Map<String, String> param, List<Map<String, Object>> gridDatas) throws Exception {
		String [] args = new String[2];



		int existEVTM = ev0100mapper.checkExistEVTM(param);

		String evTplNo = param.get("EV_TPL_NUM").toString();
		if(existEVTM != 0){
			ev0100mapper.doUpdateSTOCEVTM(param);
			for(Map<String, Object> data : gridDatas){
				data.put("EV_TPL_NUM", evTplNo);


				if (data.get("STATUS")== null) {
					data.put("STATUS", "");
				}

				if(data.get("STATUS").toString().equals("D")){
					ev0100mapper.doDeleteSTOCEVTD(data);
				}else{
					int existEVTD = ev0100mapper.checkExistEVTD(data);
					if(existEVTD != 0){
						ev0100mapper.doUpdateSTOCEVTD(data);
					}else{
						ev0100mapper.doInsertSTOCEVTD(data);
					}
				}
			}
		}else{
			evTplNo = docNumService.getDocNumber("EVT");
			param.put("EV_TPL_NUM", evTplNo);
			ev0100mapper.doInsertSTOCEVTM(param);
			for(Map<String, Object> data : gridDatas){

				if (data.get("STATUS")== null) {
					data.put("STATUS", "");
				}

				if(!data.get("STATUS").toString().equals("D")){
					data.put("EV_TPL_NUM", evTplNo);
					ev0100mapper.doInsertSTOCEVTD(data);
				}
			}
		}
		args[0] = evTplNo;
		args[1] = msg.getMessage("0001");
		return args;
	}

	// SRM_101
	public List<Map<String, Object>> doSearchAppendItem(Map<String, String> param) throws Exception {
		return ev0100mapper.doSearchAppendItem(param);
	}



	public List<Map<String, String>> getEvimType(Map<String, String> param) throws Exception {
		return ev0100mapper.getEvimType(param);
	}



}
