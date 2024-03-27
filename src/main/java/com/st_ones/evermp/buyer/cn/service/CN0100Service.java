package com.st_ones.evermp.buyer.cn.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.EverString;
import com.st_ones.evermp.IM03.IM0301_Mapper;
import com.st_ones.evermp.buyer.bd.service.BD0300Service;
import com.st_ones.evermp.buyer.cn.CN0100Mapper;
import com.st_ones.evermp.buyer.rq.service.RQ0300Service;
import com.st_ones.evermp.vendor.bq.service.BQ0300Service;
import com.st_ones.evermp.vendor.qt.service.QT0300Service;
import com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;




@Service(value = "CN0100Service")
public class CN0100Service  extends BaseService {

	@Autowired private CN0100Mapper cn0100mapper;
    @Autowired private BAPM_Service approvalService;
    @Autowired private QT0300Service qT0300Service;
    @Autowired private BQ0300Service bQ0300Service;

    @Autowired private IM0301_Mapper im0301Mapper;

    @Autowired MessageService msg;
	@Autowired private DocNumService docNumService;
	@Autowired private BD0300Service  bd300Service;
	@Autowired private RQ0300Service  rq300Service;

    // 실시간 I/F는 공통에서 관리함
    @Autowired private RealtimeIF_Service realtimeif_service;
    @Autowired private RealtimeIF_Mapper realtimeif_mapper;

    public List<Map<String, Object>> doSearchTargetExec(Map<String, String> param) {

        return cn0100mapper.doSearchTargetExec(param);
    }

    public Map<String, String> getCnhd(Map<String, String> param) {
        return cn0100mapper.getCnhd(param);
    }

    public List<Map<String, Object>> doSearchCnvd(Map<String, String> param) throws Exception {
    	List<Map<String, Object>> resultList = null;
    	Map<String,Object> cnvdDataCust = new HashMap<String,Object>();
    	List<Map<String, Object>> tempList = new ArrayList<Map<String,Object>>();
    	String cnpyJson="";
        Map<String, Object> paramObj = (Map) param;

        if(!EverString.isEmpty(param.get("QTA_NUM_LIST"))) {
            paramObj.put("OQTA_NUM_LIST", Arrays.asList(param.get("QTA_NUM_LIST").split(",")));
            resultList = cn0100mapper.getBaseRfqVendor(paramObj);
        } else {
        	resultList = cn0100mapper.doSearchCnvd(paramObj);
        	if(EverString.isEmpty(param.get("GUBN"))) {
                 for(Map<String,Object> cnvdData : resultList) {
                 	List<Map<String, Object>> cnPyList = cn0100mapper.getCnpyList(cnvdData);

                 	 cnpyJson = new ObjectMapper().writeValueAsString(cnPyList);

                 	cnvdData.put("PAY_INFO",cnpyJson);
                 	tempList.add(cnvdData);
                 }
        	}else {
        		//고객사 지급조건 시작
                resultList.get(0).put("VENDOR_CD", resultList.get(0).get("PR_BUYER_CD"));
                List<Map<String, Object>> cnPyListCust = cn0100mapper.getCnpyList(resultList.get(0));
                cnpyJson = new ObjectMapper().writeValueAsString(cnPyListCust);
                cnvdDataCust.put("PAY_INFO_FORM",cnpyJson);
                tempList.add(cnvdDataCust);
                resultList = tempList;
        	}
        }
        return resultList;

    }

    public List<Map<String, Object>> doSearchCndt(Map<String, String> param) {
    	List<Map<String, Object>> resultList = null;

        Map<String, Object> paramObj = (Map) param;

        if(!EverString.isEmpty(param.get("QTA_NUM_LIST")) && EverString.isEmpty(param.get("CN0120P03_GUBN"))) {
            paramObj.put("OQTA_NUM_LIST", Arrays.asList(param.get("QTA_NUM_LIST").split(",")));
            resultList = cn0100mapper.getBaseRfqItem(paramObj);
        } else {
            resultList = cn0100mapper.doSearchCndt(paramObj);
        }
        return resultList;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> deleteExec (Map<String, String> param) throws Exception {
    	cn0100mapper.deleteCnhd(param);
    	cn0100mapper.deleteCndt(param);
    	cn0100mapper.deleteCnpy(param);
    	cn0100mapper.deleteCnvd(param);
    	param.put("message",msg.getMessage("0001"));
    	return param;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> saveExec(Map<String, String> param ,
    		                            List<Map<String, Object>> gridV,
    		                            List<Map<String, Object>> gridItem) throws Exception{

    	Map<String,Object> chkMap = new HashMap<String,Object>();
    	List<Map<String, String>> itemCdList = new ArrayList<>();

    	for(Map<String, Object> grid : gridItem){
    		 Map<String, String> itemMap = new HashMap<>();
    		 itemMap.put("QTA_NUM", String.valueOf(grid.get("QTA_NUM")));
    		 itemMap.put("QTA_SQ",  String.valueOf(grid.get("QTA_SQ")));
             itemCdList.add(itemMap);
        }
    	chkMap.put("ITEM_LIST", itemCdList);
    	String cou = cn0100mapper.checkCn(chkMap);
    	String execCnt = "";
    	if(!"0".equals(cou)) {
    		throw new Exception("현재 상품 건으로 작성된 품의가 있습니다.");
    	}

    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	if(EverString.isEmpty(param.get("EXEC_NUM"))) {
            String execNum = docNumService.getDocNumber(userInfo.getCompanyCd(),"EXEP");
            param.put("EXEC_NUM",execNum);
    	}

    	if(param.get("EXEC_TYPE_D").equals("EXEC_CHAGE")) {
    		execCnt =cn0100mapper.checEexeckCnt(param);
    	}else {
    		execCnt = EverString.nullToEmptyString(param.get("EXEC_CNT")).equals("") ? "1" : param.get("EXEC_CNT");
    	};

    	param.put("EXEC_CNT", execCnt);

        Map<String, String> sParam = new HashMap<String, String>();
        sParam.put("APP_DOC_NUM", param.get("APP_DOC_NUM"));
        sParam.put("APP_DOC_CNT", param.get("APP_DOC_CNT"));
        String oldSignStatus = EverString.nullToEmptyString(cn0100mapper.getOldSignStatus(sParam));

        Map<String, String> nDataForm = new HashMap<String, String>();
        nDataForm.putAll(param);

        String signStatus = nDataForm.get("SIGN_STATUS");
        String appDocCnt  = nDataForm.get("APP_DOC_CNT");
        if(signStatus.equals("P")) {
        	//그룹웨어 연동떄문 결재신청 STOCSTM 테이블 임시저장 무결성 조건 위반으로 인해 비교 두개함.
            if (EverString.isEmpty(param.get("APP_DOC_NUM")) || oldSignStatus.equals("T")) {
                String nAppDocNum = docNumService.getDocNumber("AP");
                nDataForm.put("APP_DOC_NUM", nAppDocNum);
            } else {
                nDataForm.put("APP_DOC_NUM", param.get("APP_DOC_NUM"));
            }
            if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0") || appDocCnt.equals("null")) {
                appDocCnt = "1";
            } else {
                // 이전의 SIGN_STATUS가 반려(R), 결재취소(C)이면 결재차수 = 결재차수 + 1
                if (oldSignStatus.equals("E") || oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                    appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                }
            }

            nDataForm.put("APP_DOC_CNT", appDocCnt);
            nDataForm.put("SIGN_STATUS", "P");
            nDataForm.put("DOC_TYPE", "EXEP");
            approvalService.doApprovalProcess(nDataForm, param.get("approvalFormData"), param.get("approvalGridData"));

            param.put("APP_DOC_NUM",nDataForm.get("APP_DOC_NUM"));
            param.put("APP_DOC_CNT",appDocCnt);
            param.put("PROGRESS_CD","3200"); // 품의중
        } else {
            param.put("PROGRESS_CD","3100"); // 품의대기
        }
        cn0100mapper.saveCnhd(param);
        cn0100mapper.delCndt(param);
        cn0100mapper.delCnvd(param);
        cn0100mapper.delCnpy(param);

        for(Map<String,Object> data : gridItem) {
        	data.put("EXEC_NUM",param.get("EXEC_NUM"));
        	data.put("EXEC_CNT",param.get("EXEC_CNT"));
        	data.put("PR_PLANT_CD",param.get("PR_PLANT_CD"));
        	cn0100mapper.saveCndt(data);
        }

        for(Map<String,Object> data : gridV) {
        	data.put("EXEC_NUM",param.get("EXEC_NUM"));
        	data.put("EXEC_CNT",param.get("EXEC_CNT"));
        	if("O".equals(param.get("SHIPPER_TYPE"))) { // 외자일 경우 무조건 계약대기목록으로
            	data.put("CT_PO_TYPE","CT");
        	}
        	cn0100mapper.saveCnvd(data);

        	if(data.get("PAY_INFO")!=null && !EverString.isEmpty(String.valueOf(data.get("PAY_INFO")))) {
            	List<Map<String, Object>> payInfoList = new ObjectMapper().readValue(String.valueOf(data.get("PAY_INFO")), List.class);
                for(Map<String,Object> payData : payInfoList) {
                	payData.put("EXEC_NUM",param.get("EXEC_NUM"));
                	payData.put("EXEC_CNT",param.get("EXEC_CNT"));
                	payData.put("PAY_DUE_DATE",param.get("PAY_DUE_DATE"));
                	payData.put("VENDOR_CD",data.get("VENDOR_CD"));
                	payData.put("APAR_TYPE",data.get("APAR_TYPE"));
                	payData.put("PAY_METHOD_NM",data.get("PAY_METHOD_NM"));
                	payData.put("PAY_DUE_DATE",data.get("BUDGET_EXE_DATE"));

                	cn0100mapper.saveCnpy(payData);
                }
        	}
        }


        param.put("message",msg.getMessage("0001"));
    	return param;
    }

    // 협력업체 선정취소
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String settleCancel(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> rowData : gridData) {

            int ecdtCnt = cn0100mapper.getChkExec(rowData);
            if(ecdtCnt == 0){
            	cn0100mapper.doRQExcept(rowData);
            	cn0100mapper.doRQExceptRqdt(rowData);
            	cn0100mapper.doRQExceptDt(rowData);

            	cn0100mapper.doBDExcept(rowData);
            	cn0100mapper.doBDExceptRqdt(rowData);
            	cn0100mapper.doBDExceptDt(rowData);
            }else{
                throw new Exception(msg.getMessageByScreenId("CN0110","010"));
            }
        }
        return msg.getMessage("0001");
    }

    public List<Map<String, Object>> getExecList(Map<String, String> param) {
        Map<String, Object> paramObj = (Map) param;
        if(EverString.isNotEmpty(param.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));
        }

        return cn0100mapper.getExecList(paramObj);
    }

    /**
     * 구매품의 결재 승인 이후 프로세스
     * @param docNum
     * @param docCnt
     * @param signStatus
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApproval( String docNum, String docCnt, String signStatus) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);

        map = cn0100mapper.getCnhd(map);
        map.put("SIGN_STATUS", signStatus);

        if(signStatus.equals("E")){ //승인

            map.put("PROGRESS_CD", "3300"); // 품의완료(3300)
            cn0100mapper.upsSignResult(map);

            // 1. 단가생성 (임시 품목에 대한 ITEM_CD 채번)
            List<Map<String, Object>> infoTargetList = cn0100mapper.getInfoTargetCnvd(map);
            if (infoTargetList.size() > 0) {
            	for(Map<String, Object> data : infoTargetList) {
            		// 임시품목코드 채번
            		if (data.get("ITEM_CD") == null || "".equals(data.get("ITEM_CD"))) {
                        data.put("ITEM_CLS1", PropertiesManager.getString("eversrm.item.imsi.item_cls1")); // 임시 대분류
                        data.put("ITEM_CLS2", PropertiesManager.getString("eversrm.item.imsi.item_cls2")); // 임시 중분류
                        data.put("ITEM_CLS3", PropertiesManager.getString("eversrm.item.imsi.item_cls3")); // 임시 소분류
                        data.put("ITEM_CLS4", PropertiesManager.getString("eversrm.item.imsi.item_cls4")); // 임시 세분류

                        // 임시품목코드 채번(Prefix : IM)
                        String itemCd = docNumService.getDocNumber("IM");
                        data.put("ITEM_CD", itemCd);
                        data.put("IMSI_ITEM_CD", itemCd);
                        cn0100mapper.createMtgl(data);     // 상품 마스터
                    	cn0100mapper.createMtgc(data);     // 상품 - 분류체계 맵핑
                	}

            		// DGNS I/F 단가생성 (APPLY_PLANT=*)
                    String custListStr = EverString.nullToEmptyString(String.valueOf(data.get("APPLY_TARGET_CD")));
                    if (!"null".equals(custListStr) && custListStr.length() > 0) {
                        // 단가생성 고객사코드
                    	String[] custListArgs = custListStr.split(",");
                        for (int i = 0; i < custListArgs.length; i++) {

                        	// 단가적용 고객사코드(공통인 경우 7개 ELSE 1개)
                        	data.put("APPLY_COM", custListArgs[i]);

                        	// 기존 유효한 단가 만료처리로직 추가 (임시품목 제외)
			            	if( (data.get("ITEM_CD") != null && !"".equals(data.get("ITEM_CD"))) && (data.get("IMSI_ITEM_CD") == null || "".equals(data.get("IMSI_ITEM_CD"))) ) {
			            		cn0100mapper.updateValidTodateYInfo(data);
			            	}

		                	// 단가 생성
		                	String contNum = docNumService.getDocNumber("CT");
		                	data.put("CONT_NO", contNum);
		                	data.put("CONT_SEQ", "1");
		                	data.put("SIGN_STATUS", signStatus);

		                	// 매입단가 생성
		                	cn0100mapper.createYINFH(data);
		                	cn0100mapper.createStoYInfo(data);

		                	// 매출단가 생성
		                	cn0100mapper.createUINFH(data);
		                	cn0100mapper.createStoUInfo(data);

		                	// 품의상세(STOPCNDT)의 계약정보 UPDATE
		                	cn0100mapper.doUpdateContInfoCNDT(data);

		    				// 유효 지난거 일괄 삭제
		    				im0301Mapper.deleteYInfoValid(data);

			            	// T : I/F 대상, S : 성공, E : 실패
		    	            // (DGNS I/F) : 고객사 판매단가 등록
		    	            //=======================================================================================
			            	String erpIfFlag = cn0100mapper.getCustErpIfFlag(data);
			            	if( data.get("CUST_ITEM_CD") != null && !"".equals(data.get("CUST_ITEM_CD")) && "1".equals(erpIfFlag) ) {
		            			Map<String, String> ifData = new HashMap<>();
			    	            ifData.put("CUST_ITEM_CD", String.valueOf(data.get("CUST_ITEM_CD")));		// 고객사 상품코드
		            			ifData.put("USE_FLAG", "1");
		            			realtimeif_mapper.updateItemUseFlag(ifData);	// DGNS 품목마스터(PUA_MTRL_CD)의 USE_YN=1 처리함

		            			// 매입단가가 유효한 경우에만 단가 i/f
		            			if( data.get("UNIT_IF_FLAG") != null && "1".equals(data.get("UNIT_IF_FLAG")) ) {
		            				//BigDecimal SALES_UNIT_PRC =(BigDecimal) data.get("SALES_UNIT_PRC");
		            				//SALES_UNIT_PRC = SALES_UNIT_PRC ==null ? BigDecimal.ZERO : SALES_UNIT_PRC;
		            				ifData.put("COMPANY_CODE", String.valueOf(data.get("APPLY_COM")));		// 단가적용 고객사
				    	            ifData.put("DIVISION_CODE", String.valueOf(data.get("APPLY_PLANT")));	// 단가적용 사업장
				    	            //ifData.put("UNIT_PRICE", String.valueOf(SALES_UNIT_PRC));	// 고객사 판매단가
				    	            ifData.put("UNIT_PRICE", String.valueOf(data.get("UNIT_IF_FLAG").toString()));	// 고객사 판매단가
				    	            realtimeif_service.insCustUinfo(ifData);		// 품목정보 i/f 테이블 등록(ICOYITEM_IF)

				    	            //판매단가 DGNS I/F 여부 세팅(ERP_IF_SEND_FLAG)
			                		im0301Mapper.updateDgnsIfFlag(data);
		            			}
			                }
		    	            //=======================================================================================
                        }
                    }
                }
            }
            
            //2. 발주 생성 (임시품목은 임시품목코드 채번 후 발주 생성)
            // 주문(STOUPOHD, STOUPODT)이 없으면 발주생성 안됨......
            List<Map<String, Object>> poTargetList = cn0100mapper.getPoTargetCnvd(map);
            if(poTargetList.size()>0) {
            	for(Map<String, Object> data : poTargetList) {
            		
                    String poNum = docNumService.getDocNumber("PO");
                    data.put("PO_NO", poNum);
                    cn0100mapper.createPohd(data);
                    cn0100mapper.createPodt(data);
                    
                    //STOUPDT 진행상태업데이트
                    data.put("PROGRESS_CD_M", "5100");
                    cn0100mapper.doReqConfirmUpo(data);
                }
            }
        } else if(signStatus.equals("R")){ 	//반려
            map.put("PROGRESS_CD","3100");
            cn0100mapper.upsSignResult(map);
        } else if(signStatus.equals("C")){	//취소
            map.put("PROGRESS_CD","3100");
            cn0100mapper.upsSignResult(map);
        }

//if(1==1) throw new Exception("================================================");
        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }

    public List<Map<String,Object>> CN0140_doSearch(Map<String, String> formData){
        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("BUYER_CD"))) {
            paramObj.put("BUYER_CD_LIST", Arrays.asList(formData.get("BUYER_CD").split(",")));
        }
        return cn0100mapper.CN0140_doSearch(paramObj);
    }

	public List<Map<String, Object>> getSettleItemList(Map<String, String> param) throws Exception {
		List<Map<String, Object>> reList = new ArrayList<Map<String, Object>>();
		if(EverString.nullToEmptyString(param.get("GUBUN")).equals("RQ")) {
			Map<String, String> reData=qT0300Service.getQtHdSubmitData(param);
			reList=qT0300Service.getQtdtSubmitData(reData);
		}else {
			Map<String, String> reData=bQ0300Service.getBqHdSubmitData(param);
			reList=bQ0300Service.getBqdtSubmitData(reData);
		}
		return reList;
	}

	public List<Map<String, Object>> getHtmlCnpyList(Map<String, String> formData) {
		// TODO Auto-generated method stub
		return cn0100mapper.getHtmlCnpyList(formData);
	}

	public List<Map<String, Object>> doHtmlhCnvd(Map<String, String> formData) {
		// TODO Auto-generated method stub
		 Map<String, Object> paramObj = (Map) formData;
		return cn0100mapper.doHtmlSearchCnvd(paramObj);
	}

	//구매품의/본사품의/변경품의 결재 로직
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> gwSign(Map<String, String> formData) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		Map<String, String> reData     = new HashMap<String, String>();
		Map<String, String> signData   = new HashMap<String, String>();
		Map<String, Object> updateData = this.getTmHtml(formData);
		System.out.println("aaa");
		String APP_NUM = "";
        if(updateData !=null) {
        	Map<String, String> rd = new HashMap<String, String>();
        	rd.put("APP_DOC_NUM",String.valueOf(updateData.get("APP_DOC_NUM")));
        	rd.put("APP_DOC_CNT",String.valueOf(updateData.get("APP_DOC_CNT")));
        	rd.put("xmlParam"	,String.valueOf(formData.get("xmlParam")));
        	approvalService.updateBeforGwSTOCSCTM(rd);
        	if(formData.get("IF_SIGN_FLAG").equals("P") || formData.get("IF_SIGN_FLAG").equals("CP")) {
        		APP_NUM=formData.get("APP_DOC_NUM")+formData.get("APP_DOC_CNT");
        	}else {
        		APP_NUM=formData.get("APP_DOC_NUM2")+formData.get("APP_DOC_CNT2");

        	}
        }else {
        	String appDocNum = docNumService.getDocNumber(userInfo.getCompanyCd(),"AP");
        	if(formData.get("IF_SIGN_FLAG").equals("P") || formData.get("IF_SIGN_FLAG").equals("CP")) {
            	signData.put("APP_DOC_NUM" 	, appDocNum);
            	signData.put("APP_DOC_CNT" 	, "1");

            }else {
            	signData.put("APP_DOC_NUM2" 	, appDocNum);
            	signData.put("APP_DOC_CNT2" 	, "1");
            }

            signData.put("EXEC_NUM" 	, formData.get("EXEC_NUM"));
            signData.put("EXEC_CNT" 	, formData.get("EXEC_CNT"));
            signData.put("IF_SIGN_FLAG" , formData.get("IF_SIGN_FLAG"));
            signData.put("SIGN_STATUS" 	, "T");
            signData.put("PROGRESS_CD" 	, "3100");

            cn0100mapper.gwSignResult(signData);

            signData.put("APP_DOC_NUM" 		, appDocNum);
        	signData.put("APP_DOC_CNT" 		, "1");
            signData.put("DOC_TYPE" 		, "AP");
            signData.put("SUBJECT" 			, formData.get("SUBJECT"));
            signData.put("BLSM_HTML" 		, formData.get("xmlParam"));
            signData.put("BLSM_USE_FALG"	, "1");
            signData.put("BLSM_STATUS"		, "1"); // 품의신청(01)
            signData.put("BLSM_APPLY_FLAG"	, "0");
            approvalService.insertSTOCSCTM(signData);
            APP_NUM=appDocNum+"1";
        }
        reData.put("APP_DON_NUM2" , APP_NUM);
        reData.put("REMSG"		  , "'확인' Click 시 그룹웨어(G/W) 결재 상신창이 열립니다. 결재상신을 완료해 주세요.");
        //그룹웨어 결재 신청 된건 밸리데이션 체크
        int checkelctRequied = approvalService.elctRequiedCheck(reData);
        if (checkelctRequied > 0) {
            throw new Exception(msg.getMessageByScreenId("CN0130P01", "0002"));
        }

		return reData;
	}

	public boolean gbunFlag(Map<String, String> formData) {
		//품의
		boolean flag =false;
		if(formData.get("pageName").equals("CN")) {
			int a=cn0100mapper.gbunFlag(formData);
			if(a>0) {flag=true;}
		}else {
			formData.put("RFX_NUM",formData.get("EXEC_NUM"));
			formData.put("RFX_CNT",formData.get("EXEC_CNT"));
			int a=bd300Service.gbunFlag(formData);
			if(a>0) {flag=true;}
		}
		return flag;
	}

	public Map<String, Object> getTmHtml(Map<String, String> formData) {
		Map<String, Object> reData = new HashMap<String, Object>();
		if(formData.get("pageName").equals("CN")){
			reData=cn0100mapper.getBlsmHtml(formData);

		}else {
			reData=bd300Service.getBlsmHtml(formData);

		}
		return reData;
	}

	public Map<String, Object> getLocalItemInfo(Map<String, Object> data) {
		// TODO Auto-generated method stub
		return cn0100mapper.getLocalItemInfo(data);
	}

	public List<Map<String, Object>> getPuVendorList(Map<String, String> formData) {
		// TODO Auto-generated method stub
		return cn0100mapper.getPuVendorList(formData);
	}

	public List<Map<String, Object>> getPuBdItemList(Map<String, Object> puVendor) {
		// TODO Auto-generated method stub
		return cn0100mapper.getPuBdItemList(puVendor);
	}

	public List<Map<String, Object>> getPuRqItemList(Map<String, Object> puVendor) {
		// TODO Auto-generated method stub
		return cn0100mapper.getPuRqItemList(puVendor);
	}

	public List<Map<String, Object>> getAdditionalColumnInfos(Map<String, String> param) {
		List<Map<String, Object>> reg = new ArrayList<Map<String, Object>>();
		if(param.get("RFX_NUM").substring(0,2).equals("BD")) {
			reg=bd300Service.getAdditionalColumnInfos(param);
		}else {
			reg=rq300Service.getAdditionalColumnInfos(param);
		}

		return reg;
	}

	public Map<String, Object> getHdDetail(Map<String, String> param) throws Exception {
		Map<String, Object> reg = new HashMap<String, Object>();
		if(param.get("RFX_NUM").substring(0,2).equals("BD")) {
			reg=bd300Service.getBdHdDetail(param);
		}else {
			reg=rq300Service.getRfqHd(param);
		}
		return reg;
	}

	public List<Map<String, Object>> getDtList(Map<String, String> param) {
		List<Map<String, Object>> reg = new ArrayList<Map<String, Object>>();
		if(param.get("RFX_NUM").substring(0,2).equals("BD")) {
			reg=bd300Service.doSearchComparisonTable(param);
		}else {
			reg=rq300Service.doSearchComparisonTable(param);
		}
		return reg;
	}

	public List<Map<String, Object>> doHtmlChCndt(Map<String, String> formData) {
		// TODO Auto-generated method stub
		return cn0100mapper.doHtmlChCndt(formData);
	}

	public List<Map<String, Object>> getHtmlCnpyListSum(Map<String, String> formData) {
		// TODO Auto-generated method stub
		return cn0100mapper.getHtmlCnpyListSum(formData);
	}


}
