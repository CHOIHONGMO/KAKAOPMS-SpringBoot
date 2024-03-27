package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0220Mapper;
import com.st_ones.evermp.buyer.eval.EV0240Mapper;
import com.st_ones.evermp.buyer.eval.EV0260Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Service(value="EV0260Service")
public class EV0260Service extends BaseService {
	@Autowired EV0260Mapper srm_260_mapper;

	@Autowired EV0220Mapper srm_220_mapper;
	@Autowired EV0220Service srm_220_service;

	@Autowired EV0240Service srm_240_service;
	@Autowired EV0240Mapper srm_240_mapper;

	@Autowired MessageService msg;

	/**
	 * doSearch
	 *
	 * @param param the form data
	 * @return the List
	 * @throws Exception the exception
     */
	public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception{
		Map<String, Object> paramObj = (Map) param;
		if(EverString.isNotEmpty(param.get("BUYER_CD"))){
			paramObj.put("BUYER_CD_LIST", Arrays.asList(param.get("BUYER_CD").split(",")));
		}
		return srm_260_mapper.doSearch(paramObj);
	}

	/**
	 * dosave
	 *
	 * @param param the gridDatas
	 * @return the msg
	 * @throws Exception the exception
     */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSave(List<Map<String, Object>> gridDatas) throws Exception{
		for(Map<String, Object> gridData : gridDatas){
			srm_260_mapper.doSave(gridData);
			//EVES update

			//ES용 ET EE 점수합산
			gridData.put("VENDOR_SQ", "1");
			String euScore = srm_240_mapper.getEuScore(gridData);
			String etScore = srm_240_mapper.getEtScore(gridData);
			if(euScore == null){euScore = "0";}
			if(etScore == null){etScore = "0";}
			BigDecimal sum = new BigDecimal(euScore).add(new BigDecimal(etScore));

			if("CLASS".equals(gridData.get("EV_TYPE_CD").toString())){//등급평가일때
				/*
				java.math.BigDecimal h_score = new java.math.BigDecimal("0");  //100점환산 점수
				java.math.BigDecimal fifty 	 = new java.math.BigDecimal("50"			);	//100점환산계산용
				java.math.BigDecimal hundred = new java.math.BigDecimal("100");	//100점환산계산용
				Map<String, String> tpl = new HashMap<String, String>();
				tpl.put("EV_TPL_NUM", gridData.get("EV_TPL_NUM").toString());
				String weightSum = srm_220_mapper.getWeightSum(tpl);
				getLog().error("weight sum ::: "+weightSum);
				fifty = new BigDecimal(weightSum);

				// if(h_score.compareTo(hundred) == 1){ h_score = hundred;  }
				//등급표 죠회
				Map<String, String> param = new java.util.HashMap<String, String>();
				param.put("YEAR", EverDate.getYear());
				param.put("PURCHASE_TYPE", gridData.get("PURCHASE_TYPE_CD").toString());
				List<Map<String,Object>> evalGrade = srm_220_mapper.getEvalCls(param);

				// 100점환산 = 합계 * 100 / 50
				h_score = sum.multiply(hundred).divide(fifty);
				String grade = srm_220_service.doGradeCheck(h_score.toString(), evalGrade);
				gridData.put("EV_GRADE_CLS", grade);
				gridData.put("EV_SCORE", h_score.toString());
				*/
			} else {//정기평가일때
				gridData.put("EV_SCORE", sum.toString());
			}

			srm_240_mapper.updateEsScore(gridData);
		}

		return msg.getMessage("0001");
	}
}














