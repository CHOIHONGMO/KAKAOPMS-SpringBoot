package com.st_ones.batch.custCfmReqMail.web;

import com.st_ones.batch.EverJob;
import com.st_ones.batch.batchLogCom.service.BatchLogCommon_Service;
import com.st_ones.batch.custCfmReqMail.service.CustCfmReqMailService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.SpringContextUtil;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 마감확정요청(고객)
 */
@Service
public class CustCfmReqMail extends EverJob {
	
	@Autowired private BatchLogCommon_Service batchLogCommon_Service;
    @Autowired private CustCfmReqMailService custCfmReqMailService;

    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {

        if(super.isAllowedToRunBatch(context)) {
            printJobStartLog(context);

            String jobRlt = "E";
            String startDate = EverDate.getTimeStampString();

            UserInfo baseinfo = new UserInfo();
            baseinfo.setGateCd(PropertiesManager.getString("eversrm.gateCd.default"));
            baseinfo.setUserId(PropertiesManager.getString("eversrm.userId.default"));
            baseinfo.setLangCd(PropertiesManager.getString("eversrm.langCd.default"));
            baseinfo.setIpAddress("127.0.0.1");
            UserInfoManager.createUserInfo(baseinfo);
            
            batchLogCommon_Service = SpringContextUtil.getBean(BatchLogCommon_Service.class);
            custCfmReqMailService = SpringContextUtil.getBean(CustCfmReqMailService.class);

            String msg = "";
            int totalCount = 0;

            try {
                msg = custCfmReqMailService.doCustCfmReqMail(new HashMap<String, String>());
                jobRlt = "S";

            } catch (Exception e) {
                logger.error(e.getMessage(), e);
                msg = getMessageAsString(e);
                throw new JobExecutionException();
            } finally {
                try {
                    Map<String, Object> logData = new HashMap<String, Object>();
                    logData.put("JOB_DATE", startDate.substring(0, 19));
                    logData.put("JOB_TYPE", "Batch");
                    logData.put("JOB_ID", "CUST_CFM_REQ_MAIL");
                    logData.put("JOB_NM", "마감확정요청(고객)");
                    logData.put("JOB_KEY", "");
                    logData.put("JOB_RLT", jobRlt);
                    logData.put("JOB_RLT_CD", "");
                    logData.put("JOB_RLT_MSG", msg);
                    logData.put("JOB_END_DATE", EverDate.getTimeStampString().substring(0, 19));
                    //배치로그에 해당메세지 저장.
                    batchLogCommon_Service.doSaveBatchLog(logData);

                } catch (Exception e2) {
                    logger.error(e2.getMessage(), e2);
                }
            }
            printJobEndLog(context, msg, totalCount);

        } else {
            printJobNotRunningLog(context);
        }
    }
}
