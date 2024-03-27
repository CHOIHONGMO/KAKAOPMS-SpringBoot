package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0220Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import java.math.BigDecimal;
import java.util.*;

@Service(value="EV0220Service")
public class EV0220Service extends BaseService {

	/**********************************************************/
	public static final String EV_TEMP          = "TEMP";


	@Autowired
	private MessageService msg;
	@Autowired
	EV0220Mapper ev0220Mapper;

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
		return ev0220Mapper.doSearch(paramObj);
	}

	/**
	 * doExecute
	 *
	 * @param param the form data
	 * @return the List
	 * @throws Exception the exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] doExecute(Map<String, String> form, List<Map<String, Object>> gridData) throws Exception{

		String[] args				= new String[2];
		String evType 				= "";
		String purchaseType 		= "";
		String evNum				= "";
		String evTplNum				= "";
		String startDate 			= "";
		String closeDate 			= "";

		StringBuffer sbMsg 			= new StringBuffer();
		StringBuffer sbMsgVd 		= new StringBuffer();
		StringBuffer sbMsgCont 		= new StringBuffer();

		BigDecimal h_score 			= new BigDecimal("0");  	//100점환산 점수
		BigDecimal fifty 			= new BigDecimal("50");		//100점환산계산용
		BigDecimal hundred 			= new BigDecimal("100");	//100점환산계산용

		List<Map<String, Object>> retData;

		for (Map<String, Object> gridRow : gridData) {




			retData = ev0220Mapper.doEvCheck(gridRow);  // 정량평가 존재 여부 체크

			if( retData == null || retData.size() == 0 ) {
				//throw new NoResultException(msg.getMessageByScreenId("EV0220","MSG_02")); //정량평가 항목이 존재하지 않습니다.
			} else {
				int cnt = 0;
				for( Map<String, Object> chkData : retData ) {
					if( cnt == 0 ) {
						evNum					= chkData.get("EV_NUM").toString();
						evType 					= chkData.get("EV_TYPE").toString();
						purchaseType 			= chkData.get("PURCHASE_TYPE").toString();
						evTplNum				= chkData.get("EXEC_EV_TPL_NUM").toString();
						startDate 				= chkData.get("START_DATE").toString();
						closeDate 				= chkData.get("CLOSE_DATE").toString();
					}
				}

				/** Item Subject Grouping */
				List<Map<String,Object>> evItemSubject = makeEvItemSubject(retData);


				Map<String,String> param = new HashMap<String,String>();
				List<Map<String,Object>> vendorList = ev0220Mapper.getVendorList(gridRow); // 정량평가 대상 업체가져오기


				for( Map<String,Object> vendor : vendorList ) {
					String vendorCd = vendor.get("VENDOR_CD").toString();
					String vendorNm = vendor.get("VENDOR_NM").toString();
					String vendorSq = vendor.get("VENDOR_SQ").toString();
					getLog().error(vendorCd+" ################ "+ vendorNm);

					//기존 정량평가 데이타 삭제..(STOCEVET)
					param.put("EV_NUM" , evNum);
					param.put("EV_TPL_NUM" , evTplNum);
					param.put("VENDOR_CD" , vendorCd);
					param.put("VENDOR_SQ" , vendorSq);

					ev0220Mapper.deleteEvet(param);

					/* ---------------------------------------------- */
					/* 누락항목 표시용                            */
					sbMsgVd.append("* ");
					sbMsgVd.append(vendorNm);
					sbMsgVd.append("(").append(vendorCd).append(")");
					/* ---------------------------------------------- */

					String siljuk = "";
					String siltae = "";
					String groupCd = "";

					/** 업체그룹별 가산점 조회 */
					param.put("VENDOR_CD", vendorCd);

					siltae = "0";
					siljuk = "0";
					groupCd = "";

					for( Map<String,Object> subject : evItemSubject ) {
						String qtyItemCd = subject.get("QTY_ITEM_CD").toString();

						String evItemNum = subject.get("EV_ITEM_NUM").toString();

						String[] result = doEvItemCheckScore(evType, evNum, vendorCd, qtyItemCd, retData, siltae, siljuk,evItemNum,startDate,closeDate);

						getLog().error(qtyItemCd+" >>>>>>>>>>>>>>> "+result[2]+" >>>>>>>>>>>>> "+result[7]);

						if( result[2] == null  || "".equals(result[0]) ) {
							result[0] = subject.get("EV_ITEM_NUM").toString();
							result[2] = "0";
							result[5] = "0";
						}

						Map<String,String> data = new HashMap<String,String>();
						data.put("EV_NUM"			, evNum);
						data.put("EV_TPL_NUM"		, evTplNum);
						data.put("EV_ITEM_NUM"		, result[0]);
						data.put("EV_NUM"			, evNum);
						data.put("VENDOR_CD"		, vendorCd);
						data.put("EV_ID_SQ", result[1]);

						String evScore 					= "";
						if( EV_TEMP.equals(qtyItemCd)) {			 //측정치+가산점 = 총점인 경우 사용
							evScore 					= result[10];
						} else {
							evScore 					= result[2];
						}

						String resultValue 				= result[6];
						String resultValueExist 		= "Y";
						String wt 						= result[5];

						/*--------------------------------------------------------*/
						getLog().error("evType      :: "+evType);
						getLog().error("resultValue :: "+resultValue);
						getLog().error("evScore     :: "+evScore);
						getLog().error("wt          :: "+wt);
						/*--------------------------------------------------------*/

						BigDecimal ev_score 	= new BigDecimal(evScore);  //펑가점수
						BigDecimal weight 		= new BigDecimal(wt); 		//가중치
						BigDecimal final_score 	= new BigDecimal("0");  	//FINAL_SCORE



						//항목별집계처리
						if( "ROUTINE".equals(evType)  || "REGISTRATION".equals(evType)  ) { //정기평가 or 등록평가

							if( "0".equals(evScore) ) {
								final_score      = new BigDecimal("0");
								resultValue      = null;
								resultValueExist = "N";
							} else {
								//final_score = ev_score.multiply(weight, MathContext.DECIMAL32).divide(hundred); // (점수 * 가중치) / 100
//								final_score = ev_score.multiply(weight, MathContext.DECIMAL32); // (점수 * 가중치)
								BigDecimal highScore 	= new BigDecimal(String.valueOf(subject.get("HIGH_SCORE")));

								final_score = ev_score.divide(highScore, 5, BigDecimal.ROUND_DOWN).multiply(weight);

								resultValueExist = "Y";
							}

							//STOCEVET 정량평가
							data.put("EV_SCORE"				, String.valueOf(ev_score.floatValue())  );
							data.put("ADDITION_SCORE"		, null);
							data.put("FINAL_SCORE"			, String.valueOf(final_score.floatValue())   );
							data.put("RESULT_VALUE"			, resultValue);
							data.put("RESULT_VALUE_EXIST"	, resultValueExist);
							data.put("GROUP_CD"				, groupCd);
						}

						if(  !"".equals(result[7]) ) {
							sbMsgCont.append("\t");
							sbMsgCont.append("- ");
							sbMsgCont.append(result[7]);
							sbMsgCont.append("\n");
						}

						/*--------------------------------------------------------*/
						getLog().error("groupCd          :: "+groupCd);
						getLog().error("resultValueExist :: "+resultValueExist);
						getLog().error("final_score      :: "+final_score.toString());
						getLog().error("!!!! "+data);
						/*--------------------------------------------------------*/

						//STOCEVET 등록
						ev0220Mapper.regEvetItem(data);

					} //end for - evItemsubject

					BigDecimal final_score 		= new BigDecimal("0");
					//정량평가점수 - STOCEVET
					BigDecimal evet_score		= new BigDecimal( ev0220Mapper.getEvetScore(param) );
					//정성평가점수 - EV_SCORE
					BigDecimal eves_score		= new BigDecimal( ev0220Mapper.getEveuScore(param));

					final_score = evet_score.add(eves_score);

					String grade = "";
					if( "CLASS".equals(evType) ) {
						/*
						String weightSum = srm_220_mapper.getWeightSum(param);
						getLog().error("weight sum ::: "+weightSum);
						fifty = new BigDecimal(weightSum);

						// 100점환산 = 합계 * 100 / 50(가중치합)
						h_score = final_score.multiply(hundred, MathContext.DECIMAL32).divide(fifty);
						*/
					} else {
						h_score = final_score;
					}


					//param.put("EV_SCORE"					, final_score.toString());
					param.put("EV_SCORE"					, h_score.toString());
					param.put("EV_GRADE_CLS"				, grade);

					//평가결과 테이블 등록
					if("EV0045".equals(form.get("MENU_ID"))) {
						param.put("VENDOR_SQ", "1");
					}
					ev0220Mapper.regEves(param);

					if( sbMsgCont.length() > 0 ) {
						sbMsg.append( sbMsgVd.toString());
						sbMsg.append( "\n");
						sbMsg.append( sbMsgCont.toString());

						sbMsgVd.delete(0, sbMsgVd.length());
						sbMsgCont.delete(0, sbMsgCont.length());
					}

				} //end for - vendorList


			}


		}

		args[0] = msg.getMessage("0001");
		args[1] = sbMsg.toString();

		return args;
	}

	/**
	 * 항목 점수계산 (정량평가)
	 * @param evType
	 * @param evNum
	 * @param vendorCd
	 * @param subj
	 * @param startDate
	 * @param closeDate
	 * @param list
	 * @return
	 * @throws Exception
	 */
	public String[] doEvItemCheckScore(String evType, String evNum, String vendorCd, String qtyItemCd, List<Map<String,Object>> list, String siltae, String siljuk,String evItemNums
			,String startDate ,String closeDate
			) throws Exception {

		String[] result 		= new String[11];
		String orgScore 		= "";
		String message			= "";

		BigDecimal hap_score   = new BigDecimal("0");
		BigDecimal org_score   = new BigDecimal("0");

		Map<String,String> param = new HashMap<String,String>();
		param.put("VENDOR_CD",  vendorCd);
		param.put("QT_ITEM_CD", qtyItemCd);


		param.put("STARTDATE",  startDate);
		param.put("CLOSEDATE",  closeDate);



		/** 항목 유형별 Value 조회 */
/*
		if( EV_E1001.equals(qtyItemCd) ) { //정기평가

			// 파트너사 신용도 조회
			orgScore 	= srm_220_mapper.getVendorInfoScore(param);
			//message 	= EV_E1001;
			getLog().error("정기 ::: "+orgScore);
			message 	= msg.getMessageByScreenId("EV0220","MSG_03");

		} if( EV_S1001.equals(qtyItemCd) || EV_S1002.equals(qtyItemCd) || EV_S1003.equals(qtyItemCd) || EV_S1004.equals(qtyItemCd) || EV_S1005.equals(qtyItemCd)) { //등록평가

			// 파트너사 등록평가 각 항목 조회(신용도, IT인력규모, IT인력, 사업수행실적, 솔루션보유)
			orgScore 	= srm_220_mapper.getVendorInfoScore(param);
			//message 	= EV_ESxxx;
			getLog().error("등록 ::: "+orgScore);
			message 	= msg.getMessageByScreenId("EV0220","MSG_04");

		} else {
			message = msg.getMessageByScreenId("EV0220","MSG_08");
		}
*/
		if( "ESG".equals(qtyItemCd) ) { // ESG 평가
			orgScore 	= ev0220Mapper.getEsgScore(param);
		} else if( "WONGA1.0".equals(qtyItemCd)
				|| "WONGA2.0".equals(qtyItemCd)
				|| "WONGA2.2".equals(qtyItemCd)

				|| "25WONGA1.2".equals(qtyItemCd)
				|| "25WONGA2.0".equals(qtyItemCd)
				|| "25WONGA2.2".equals(qtyItemCd)
		) { // 원가 절감율
			orgScore 	= ev0220Mapper.getWongaScore(param);
		} else if( "GRFOLLOW".equals(qtyItemCd) ) { // 납기준수율
			orgScore 	= ev0220Mapper.getGrFollowScore(param);
		}


		//임시(?)
		if( orgScore == null || "".equals(orgScore) || "null".equals(orgScore) ) {
			orgScore = "0";
			//throw new NoResultException(message);
		} else {
			message = "";
		}
		if( "CLASS".equals(evType)) {

		}


		hap_score = new BigDecimal(orgScore);
//		if( "ROUTINE".equals(evType) || "REGISTRATION".equals(evType)) {
//			hap_score = new BigDecimal(orgScore);
//		} else { //가산점 처리를 할 경우
//			BigDecimal bd_siltae 		= new BigDecimal(siltae);  //실태가산점
//			BigDecimal bd_siljuk 		= new BigDecimal(siljuk);  //실적가산점
//			org_score					= new BigDecimal(orgScore);
//			getLog().error("org_score :: "+org_score.toString());
//
//			if( EV_TEMP.equals(qtyItemCd) ) {      //실태
//				hap_score = org_score.add(bd_siltae); //FINAL_SOCRE = EV_SCORE + 실태가산점
//			} else if(EV_TEMP.equals(qtyItemCd)) { //실적
//				hap_score = org_score.add(bd_siljuk); //FINAL_SOCRE = EV_SCORE + 실적가산점
//			} else {
//				hap_score = org_score;
//			}
//		}
//		getLog().error("hap_score :: "+hap_score.toString());

		/** Subject별 항목을 list 반환한다. */
		List<Map<String,Object>> evIdList = makeEvIdList(qtyItemCd, list);

		String evItemNum	= "";
		String evItemCont	= "";
		String evIdCont		= "";
		String weight		= "";
		String evIdSq		= "";
		String evIdScore	= "";
		String fromValue	= "";
		String fromCond		= "";
		String toValue		= "";
		String toCond		= "";
		String chkRst		= "";

		if( "0".equals(orgScore) ) { //평가 결과가 없을 경우

			result[0] = "";
			result[1] = "0";
			result[2] = "0";
			result[3] = "";
			result[4] = "";
			result[5] = "0";
			result[6] = "";
			result[8] = null;
			result[9] = null;
			result[10] = "0";

		} else {

			int chkCnt = 0;
			for( Map<String,Object> evItem : evIdList ) {

				evItemNum		= evItem.get("EV_ITEM_NUM"			).toString();
				evItemCont		= evItem.get("EV_ITEM_CONTENTS"		).toString();
				evIdCont		= evItem.get("EV_ID_CONTENTS"		).toString();
				weight			= evItem.get("WEIGHT"				).toString();
				evIdSq			= evItem.get("EV_ID_SQ"				).toString();
				evIdScore		= evItem.get("EV_ID_SCORE"			).toString();
				fromValue		= evItem.get("FROM_VALUE"			).toString();
				fromCond		= evItem.get("FROM_CONDITION_CD"	).toString();
				fromCond		= convertOperandStr(fromCond		);
				toValue			= evItem.get("TO_VALUE"				).toString();
				toCond			= evItem.get("TO_CONDITION_CD"		).toString();
				toCond			= convertOperandStr(toCond			);

				result[0] = evItemNum;
				result[3] = evItemCont;
				result[4] = evIdCont;
				result[6] = orgScore;
				result[8] = siltae;
				result[9] = siljuk;
				result[10] = hap_score.toString();

				chkRst = eval(hap_score.toString(), fromValue, fromCond, toValue, toCond, "&&");

				if( "true".equals(chkRst) ) {  //만족하는 조건일 경우의 점수를 반환한다.
					result[1] = evIdSq;
					result[2] = evIdScore;
					result[5] = weight;
					chkCnt++;
				}

				getLog().error("%%%%%%%%%%%%%%%%%%%%%%%%");
				getLog().error("evItemNum :: "+evItemNum);
				getLog().error("chkRst    :: "+chkRst);
				getLog().error("orgScore  :: "+orgScore);
				getLog().error("hap_score :: "+hap_score.toString());
				getLog().error("evIdScore :: "+evIdScore);
				getLog().error("siltae    :: "+siltae);
				getLog().error("siljuk    :: "+siljuk);
				getLog().error("weight    :: "+weight);
				getLog().error("%%%%%%%%%%%%%%%%%%%%%%%%");
			}

			if( chkCnt == 0) {
				result[2] = "0";
				result[5] = "0";
			}

		}

		result[7] = message;

		return result;
	}

	/**
	 * EV_ITEM_SUBJECT Grouping
	 * @param list
	 * @return
	 */
	public List<Map<String,Object>> makeEvItemSubject(List<Map<String,Object>> list) {

		List<Map<String,Object>> result = new ArrayList<Map<String,Object>>();

		String subject 		= "";
		String itemNum 		= "";
		String qtyItemCd	= "";
		String oldSubject 	= "";
		String highScore	= "";
		for(Map<String,Object> item:list) {

			subject 	= item.get("EV_ITEM_SUBJECT").toString();
			itemNum 	= item.get("EV_ITEM_NUM").toString();
			qtyItemCd 	= item.get("QTY_ITEM_CD").toString();


			highScore = item.get("HIGH_SCORE").toString();

			if( !oldSubject.equals(subject) ) {
				Map<String,Object> data = new HashMap<String,Object>();
				data.put("EV_ITEM_SUBJECT"	, subject);
				data.put("EV_ITEM_NUM"		, itemNum);
				data.put("QTY_ITEM_CD"		, qtyItemCd);
				data.put("HIGH_SCORE"		, highScore);
				result.add(data);
				oldSubject = subject;
			}

		}

		return result;
	}

	/**
	 * 평가항번 List 생성
	 * @param list
	 * @return
	 */
	public List<Map<String,Object>> makeEvIdList(String qtyItemCd, List<Map<String,Object>> list) {

		List<Map<String,Object>> result = new ArrayList<Map<String,Object>>();

		for( Map<String,Object> evItem : list ) {
//			if(  subject.equals(  evItem.get("EV_ITEM_SUBJECT").toString() )  ) {
			if(  qtyItemCd.equals(  evItem.get("QTY_ITEM_CD").toString() )  ) {
				result.add(evItem);
			}
		}

		return result;
	}

	/**
	 * 조건문 전각문자 변황
	 * @param org
	 * @return
	 */
	public String convertOperandStr(String org) {
		String convert = "";

		convert = EverString.replaceAll(org, "＜", "<");
		convert = EverString.replaceAll(convert, "＞", ">");
		convert = EverString.replaceAll(convert, "＝", "=");

		return convert;
	}

	/**
	 * 문자열을 수식으로 변환후 실행
	 * @param val
	 * @param fromVal
	 * @param fromCondition
	 * @param toVal
	 * @param toCondition
	 * @param andOr    - & or && or | or ||
	 * @return
	 * @throws Exception
	 */
	public String eval(String val, String fromVal, String fromCondition, String toVal, String toCondition, String operand) throws Exception {

		String result = "";

		ScriptEngineManager mgr = new ScriptEngineManager();
		ScriptEngine engine = mgr.getEngineByName("JavaScript");

		StringBuffer sb = new StringBuffer();

		     sb.append("if(")
		       .append(" parseFloat(")
		       .append(val)
		       .append(") ")
		       .append(fromCondition)
		       .append(" parseFloat(")
		       .append(fromVal)
		       .append(") ")
		       .append(operand)
		       .append(" parseFloat(")
		       .append(val)
		       .append(") ")
		       .append(toCondition)
		       .append(" parseFloat(")
		       .append(toVal)
		       .append(") ")
		       .append("  )")
		       .append("{")
		       .append(" true ")
		       .append("}")
		       .append("else")
		       .append("{")
		       .append(" false ")
		       .append("}")
		     ;

		  getLog().error(sb.toString());
		  result = engine.eval(sb.toString()).toString();

		  return result;
	}
























	public List<Map<String, Object>> doSearchEsgGubun(Map<String, String> param) throws Exception{
		return ev0220Mapper.doSearchEsgGubun(param);
	}



	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] doEsgGuganSave(Map<String, String> form, List<Map<String, Object>> gridData) throws Exception{
		String[] args				= new String[2];


		ev0220Mapper.delEsgGubun(form);
		for(Map<String,Object> grid : gridData) {
			ev0220Mapper.saveEsgGubun(grid);
		}
		args[0] = msg.getMessage("0001");
		args[1] = "";
		return args;
	}









}
