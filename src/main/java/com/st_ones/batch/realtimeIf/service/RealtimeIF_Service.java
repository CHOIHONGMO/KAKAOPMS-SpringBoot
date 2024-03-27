package com.st_ones.batch.realtimeIf.service;

import com.st_ones.batch.batchLogCom.service.BatchLogCommon_Service;
import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import org.apache.commons.lang3.StringUtils;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

@Service(value = "RealtimeIF_Service")
public class RealtimeIF_Service {

	protected Logger logger = LoggerFactory.getLogger(getClass());

	@Autowired private BatchLogCommon_Service batchLogCommon_Service;
	@Autowired private RealtimeIF_Mapper realtimeif_mapper;

    @Autowired private MessageService msg;
    @Autowired private DocNumService docNumService;

    // IM0301_Service.java : 품목 등록 후 DGNS 품목 등록하기
    // 품목기본정보 : BOFADM.PUA_MTRL_CD@DL_DGNS_SLIP
    // 품목상세정보 : BOFADM.PUA_MTRL_STND@DL_DGNS_SLIP
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String insPuaMtrlCd(Map<String, String> param) throws Exception {

    	String jobRlt = "E";
        String startDate = EverDate.getTimeStampString();

    	String msgStr = "";
        try {
        	// 1. 품목기본정보 등록
            realtimeif_mapper.insPuaMtrlCd(param);

        	// 2. 품목상세정보 등록
            String itemSpec = EverString.nullToEmptyString(param.get("ITEM_SPEC"));
            itemSpec = itemSpec.replaceAll("；", ";").replaceAll(" ", "");

            // 품목 기타정보 (I/F 용)
            String modelName = "", size = "", material = "", capacity = "", color = "", addInfo = "";

            String[] spValue = itemSpec.split(";");
    		for (int x = 0; x < spValue.length; x++){
    			//System.out.println("spValue["+x+"] ====> " + spValue[x]);
    			String[] sArray2 = spValue[x].split(":");
	    		for(int k = 0; k < sArray2.length; k++){
		    		if( spValue[x].startsWith("모델명") ) {
		    			modelName = sArray2[k];
		    		} else if( spValue[x].startsWith("사이즈") || spValue[x].startsWith("규격") ) {
		    			size = sArray2[k];
		    		} else if( spValue[x].startsWith("재질")) {
		    			material = sArray2[k];
		    		} else if( spValue[x].startsWith("용량") || spValue[x].startsWith("중량") ) {
		    			capacity = sArray2[k];
		    		} else if( spValue[x].startsWith("색상") ) {
		    			color = sArray2[k];
		    		} else if( spValue[x].startsWith("추가정보") ) {
		    			addInfo = sArray2[k];
		    		}
	    		}
	    		if("".equals(modelName) && "".equals(addInfo) && "".equals(material) && "".equals(capacity) && "".equals(color)){
	    			if( "".equals(size) ){
	    				size = spValue[x];
	    			}else{
	    				size = size + ";" + spValue[x];
	    			}
	    		}
    		}

    		if( EverString.isEmpty(param.get("MAKER_PART_NO")) ) {
        		param.put("MAKER_PART_NO", modelName);	// 모델명
    		}
    		param.put("MTRL_CAPACITY", capacity);		// 용량(중량)
    		param.put("MTRL_SIZE", size);				// 사이즈(규격)
    		param.put("MTRL_COLOR", color);				// 색상
    		param.put("MTRL_QUALITY", material);		// 재질
    		param.put("MTRL_ETC", addInfo);				// 추가정보

            realtimeif_mapper.insPuaMtrlSpec(param);

            msgStr = msg.getMessage("0001");
            jobRlt = "S";
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            msgStr = getMessageAsString(e);
            throw new JobExecutionException();
        } finally {
            try {
                Map<String, Object> logData = new HashMap<String, Object>();
                logData.put("JOB_DATE", startDate.substring(0, 19));
                logData.put("JOB_TYPE", "RealTime");
                logData.put("JOB_ID", "ITEM_REG");
                logData.put("JOB_NM", "[신규상품등록] " + param.get("DGNS_ITEM_CD"));
                logData.put("JOB_KEY", "");
                logData.put("JOB_RLT", jobRlt);
                logData.put("JOB_RLT_CD", "");
                logData.put("JOB_RLT_MSG", (jobRlt == "S")? msgStr + " => [" + param.get("DGNS_ITEM_CD") + "] " + param.get("ITEM_DESC") : msgStr);
                logData.put("JOB_END_DATE", EverDate.getTimeStampString().substring(0, 19));
                batchLogCommon_Service.doSaveBatchLog(logData);
            } catch (Exception e2) {
                logger.error(e2.getMessage(), e2);
            }
        }
        return msg.getMessage("0001");
    }

    // 고객사 상품정보 변경
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String updatePuaMtrlCd(Map<String, String> param) throws Exception {

    	String jobRlt = "E";
        String startDate = EverDate.getTimeStampString();

    	String msgStr = "";
        try {
        	// 1. 품목기본정보 수정
            realtimeif_mapper.updatePuaMtrlCd(param);

            // 2. 품목상세정보 수정
            String itemSpec = EverString.nullToEmptyString(param.get("ITEM_SPEC"));
            itemSpec = itemSpec.replaceAll("；", ";").replaceAll(" ", "");

            // 품목 기타정보 (I/F 용)
            String modelName = "", size = "", material = "", capacity = "", color = "", addInfo = "";

            String[] spValue = itemSpec.split(";");
    		for (int x = 0; x < spValue.length; x++){
    			//System.out.println("spValue["+x+"] ====> " + spValue[x]);
    			String[] sArray2 = spValue[x].split(":");
	    		for(int k = 0; k < sArray2.length; k++){
		    		if( spValue[x].startsWith("모델명") ) {
		    			modelName = sArray2[k];
		    		} else if( spValue[x].startsWith("사이즈") || spValue[x].startsWith("규격") ) {
		    			size = sArray2[k];
		    		} else if( spValue[x].startsWith("재질")) {
		    			material = sArray2[k];
		    		} else if( spValue[x].startsWith("용량") || spValue[x].startsWith("중량") ) {
		    			capacity = sArray2[k];
		    		} else if( spValue[x].startsWith("색상") ) {
		    			color = sArray2[k];
		    		} else if( spValue[x].startsWith("추가정보") ) {
		    			addInfo = sArray2[k];
		    		}
	    		}
	    		if("".equals(modelName) && "".equals(addInfo) && "".equals(material) && "".equals(capacity) && "".equals(color)){
	    			if( "".equals(size) ){
	    				size = spValue[x];
	    			}else{
	    				size = size + ";" + spValue[x];
	    			}
	    		}
    		}

    		if( EverString.isEmpty(param.get("MAKER_PART_NO")) ) {
        		param.put("MAKER_PART_NO", modelName);	// 모델명
    		}
    		param.put("MTRL_CAPACITY", capacity);		// 용량(중량)
    		param.put("MTRL_SIZE", size);				// 사이즈(규격)
    		param.put("MTRL_COLOR", color);				// 색상
    		param.put("MTRL_QUALITY", material);		// 재질
    		param.put("MTRL_ETC", addInfo);				// 추가정보

            realtimeif_mapper.updatePuaMtrlSpec(param);




            realtimeif_mapper.updateItemUseFlag(param);

            msgStr = msg.getMessage("0001");
            jobRlt = "S";
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            msgStr = getMessageAsString(e);
            throw new JobExecutionException();
        } finally {
            try {
                Map<String, Object> logData = new HashMap<String, Object>();
                logData.put("JOB_DATE", startDate.substring(0, 19));
                logData.put("JOB_TYPE", "RealTime");
                logData.put("JOB_ID", "ITEM_CHANGE");
                logData.put("JOB_NM", "[상품정보변경] " + param.get("ITEM_NO"));
                logData.put("JOB_KEY", "");
                logData.put("JOB_RLT", jobRlt);
                logData.put("JOB_RLT_CD", "");
                logData.put("JOB_RLT_MSG", (jobRlt == "S")? msgStr + " => [" + param.get("ITEM_NO") + "] " + param.get("ITEM_DESC") : msgStr);
                logData.put("JOB_END_DATE", EverDate.getTimeStampString().substring(0, 19));
                batchLogCommon_Service.doSaveBatchLog(logData);
            } catch (Exception e2) {
                logger.error(e2.getMessage(), e2);
            }
        }
        return msg.getMessage("0001");
    }

    // 고객사 품목코드의 판매단가 생성 및 변경 후 I/F 데이터 등록
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String insCustUinfo(Map<String, String> param) throws Exception {

    	String jobRlt = "E";
        String startDate = EverDate.getTimeStampString();

    	String msgStr = "";
        try {
            realtimeif_mapper.insCustUinfo(param);
            msgStr = msg.getMessage("0001");
            jobRlt = "S";
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            msgStr = getMessageAsString(e);
            throw new JobExecutionException();
        } finally {
            try {
                Map<String, Object> logData = new HashMap<String, Object>();
                logData.put("JOB_DATE", startDate.substring(0, 19));
                logData.put("JOB_TYPE", "RealTime");
                logData.put("JOB_ID", "UINFO_CHANGE");
                logData.put("JOB_NM", "[고객판가등록] " + param.get("ITEM_NO"));
                logData.put("JOB_KEY", "");
                logData.put("JOB_RLT", jobRlt);
                logData.put("JOB_RLT_CD", "");
                logData.put("JOB_RLT_MSG", (jobRlt == "S")? msgStr + " => [" + param.get("COMPANY_CODE") + "] " + param.get("ITEM_NO") + " : "+ param.get("UNIT_PRICE") : msgStr);
                logData.put("JOB_END_DATE", EverDate.getTimeStampString().substring(0, 19));
                batchLogCommon_Service.doSaveBatchLog(logData);
            } catch (Exception e2) {
                logger.error(e2.getMessage(), e2);
            }
        }
        return msg.getMessage("0001");
    }

    /**
     * 납품명세서 DGNS IF
     * @param param
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String regDgnsInvoice(Map<String, String> ifMap) throws Exception {
    	String jobRlt = "E";
        String startDate = EverDate.getTimeStampString();

    	String msgStr = "";
    	String invList = "";
        try {
        	Set set = ifMap.keySet();
        	Iterator iter = set.iterator();
        	while(iter.hasNext()) {
            	Map<String, String> param = new HashMap<String, String>();
            	param.put("INV_NO", String.valueOf(iter.next()));

            	realtimeif_mapper.regDgnsInvoiceHD(param);
            	realtimeif_mapper.regDgnsInvoiceDT(param);
            	invList+=","+param.get("INV_NO");
        	}
        	msgStr = msg.getMessage("0001");
            jobRlt = "S";
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            msgStr = getMessageAsString(e);
            throw new JobExecutionException();
        } finally {
            try {
                Map<String, Object> logData = new HashMap<String, Object>();
                logData.put("JOB_DATE", startDate.substring(0, 19));
                logData.put("JOB_TYPE", "RealTime");
                logData.put("JOB_ID", "UIVHD_REG");
                logData.put("JOB_NM", "[납품명세서 등록] " + invList.substring(1,invList.length() ) );
                logData.put("JOB_KEY", "");
                logData.put("JOB_RLT", jobRlt);
                logData.put("JOB_RLT_CD", "");
                logData.put("JOB_RLT_MSG", (jobRlt == "S")? msgStr + " => [" + invList.substring(1,invList.length()) + "]" : msgStr);
                logData.put("JOB_END_DATE", EverDate.getTimeStampString().substring(0, 19));
                batchLogCommon_Service.doSaveBatchLog(logData);
            } catch (Exception e2) {
                logger.error(e2.getMessage(), e2);
            }
        }
        return msg.getMessage("0001");
    }

    // Message를 String으로 변환
    protected String getMessageAsString(Throwable e) {

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw, true);
        e.printStackTrace(pw);
        pw.flush();
        return StringUtils.abbreviate(sw.toString(), 3000);
    }

}
