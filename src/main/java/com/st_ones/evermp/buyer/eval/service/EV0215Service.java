package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0210Mapper;
import com.st_ones.evermp.buyer.eval.EV0215Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service(value="EV0215Service")
public class EV0215Service extends BaseService {
	@Autowired EV0215Mapper srm_215_mapper;
	@Autowired MessageService msg;
	@Autowired private DocNumService docNumService;
	@Autowired EV0210Mapper srm_210_mapper;

	/**
	 * 평가대상가져오기
     */
	public List<Map<String, Object>> doImportSrm(Map<String, String> param) throws Exception{
		return srm_215_mapper.doImportSrm(param);
	}

	// 일괄평가생성
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> srm215_doEvalAll(Map<String, String> param, List<Map<String, Object>> grid) throws Exception{
		Map<String, String> map = new HashMap<>();

		int i = 0;
		String evType = "";
		String SI_EV_NUM = "";
		String SM_EV_NUM = "";
		String CO_EV_NUM = "";

		for(Map<String, Object> data : grid) {
			int VENDOR_SQ = 0;

			if("".equals(data.get("VENDOR_SQ")) || data.get("VENDOR_SQ") == null) {
				for (Map<String, Object> temp : grid) {
					String temp_periodic_ev_type = String.valueOf(temp.get("PERIODIC_EV_TYPE"));
					String temp_vendor_cd = String.valueOf(temp.get("VENDOR_CD"));

					if(temp_periodic_ev_type.equals(data.get("PERIODIC_EV_TYPE"))) {
						if(temp_vendor_cd.equals(data.get("VENDOR_CD"))) {
							if("".equals(temp.get("VENDOR_SQ")) || temp.get("VENDOR_SQ") == null) {
								temp.put("VENDOR_SQ", ++VENDOR_SQ);
							} else {
								VENDOR_SQ = Integer.valueOf(String.valueOf(temp.get("VENDOR_SQ")));
							}
						}
					}
				}
			}

			if(evType.indexOf(String.valueOf(data.get("PERIODIC_EV_TYPE"))) == -1) {
				evType += "," + String.valueOf(data.get("PERIODIC_EV_TYPE"));

				String docNo = docNumService.getDocNumber("EV");

				if("SI".equals(String.valueOf(data.get("PERIODIC_EV_TYPE")))) {
					SI_EV_NUM = docNo;
				} else if("SM".equals(String.valueOf(data.get("PERIODIC_EV_TYPE")))) {
					SM_EV_NUM = docNo;
				} else if("CO".equals(String.valueOf(data.get("PERIODIC_EV_TYPE")))) {
					CO_EV_NUM = docNo;
				}

				param.put("EV_NUM", docNo);
				param.put("PROGRESS_CD", "100");
				param.put("EV_TPL_NUM", EverString.nullToEmptyString(data.get("EXEC_EV_TPL_NM")));
				param.put("PERIODIC_EV_TYPE", EverString.nullToEmptyString(data.get("PERIODIC_EV_TYPE")));

				Map<String, Object> EVTM = srm_215_mapper.doSearchEVTM(param);

				if(EVTM == null || EVTM.size() == 0) {
					throw new NoResultException("[" + param.get("EV_TPL_NUM") + "] " + msg.getMessageByScreenId("SRM_215","001"));
				}

				param.put("EV_NM", EverString.nullToEmptyString(EVTM.get("EV_TPL_SUBJECT")));
				param.put("EV_CTRL_USER_ID", param.get("EV_CTRL_USER_ID"));
				param.put("EXEC_EV_TPL_NUM", EverString.nullToEmptyString(data.get("EXEC_EV_TPL_NM")));
				param.put("PURCHASE_TYPE", "NPUR");

				srm_210_mapper.doInsertEVEM(param);
			} else {
				if("SI".equals(String.valueOf(data.get("PERIODIC_EV_TYPE")))) {
					param.put("EV_NUM", SI_EV_NUM);
				} else if("SM".equals(String.valueOf(data.get("PERIODIC_EV_TYPE")))) {
					param.put("EV_NUM", SM_EV_NUM);
				} else if("CO".equals(String.valueOf(data.get("PERIODIC_EV_TYPE")))) {
					param.put("EV_NUM", CO_EV_NUM);
				}
			}

			param.put("VENDOR_CD", EverString.nullToEmptyString(data.get("VENDOR_CD")));

			Map<String, Object> EVES = srm_215_mapper.doSearchVNGL(param);

			if(EVES == null || EVES.size() == 0) {
				throw new NoResultException("[" + param.get("VENDOR_CD") + "] " + msg.getMessageByScreenId("SRM_215","006"));
			}

			EVES.put("EV_NUM", param.get("EV_NUM"));
			EVES.put("VENDOR_SQ", data.get("VENDOR_SQ"));
			EVES.put("CONT_NUM", data.get("CONT_NUM"));
			EVES.put("CONT_DESC", data.get("CONT_DESC"));

			if("".equals(data.get("INPUT_MM")) || data.get("INPUT_MM") == null) {
				EVES.put("INPUT_MM", "0");
			} else {
				EVES.put("INPUT_MM", data.get("INPUT_MM"));
			}

			srm_210_mapper.doInsertEVES(EVES);

			String REP_EV_USER_ID = EverString.nullToEmptyString(data.get("REP_EV_USER_ID"));

			Set<String> keySet = data.keySet();
			for(String key : keySet) {
				Object value = data.get(key);

				if(key.indexOf("USER") >= 0 && !key.equals("REP_EV_USER_ID")) {
					if(!"".equals(value) && value != null) {
						param.put("USER_ID", EverString.nullToEmptyString(value));

						Map<String, Object> EVEU = srm_215_mapper.doSearchUSER(param);

						if(EVEU == null || EVEU.size() == 0) {
							throw new NoResultException("[" + value + "] " + msg.getMessageByScreenId("SRM_215","007"));
						}

						EVEU.put("EV_NUM", param.get("EV_NUM"));
						EVEU.put("VENDOR_CD", param.get("VENDOR_CD"));
						EVEU.put("VENDOR_SQ", data.get("VENDOR_SQ"));

						if(value.equals(REP_EV_USER_ID)) {
							EVEU.put("REP_FLAG", "1");
						} else {
							EVEU.put("REP_FLAG", "0");
						}

						EVEU.put("EV_USER_ID", value);

						srm_210_mapper.doInsertEVEU(EVEU);
					}
				}
			}

		}

		map.put("MSG", msg.getMessage("0001"));

		return map;
	}
}














