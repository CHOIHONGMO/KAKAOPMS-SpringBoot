package com.st_ones.batch.comPartIf.web;

import com.st_ones.batch.EverJob;
import com.st_ones.batch.batchLogCom.service.BatchLogCommon_Service;
import com.st_ones.batch.comPartIf.service.ComPartIf_Service;
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

@Service
public class ComPartJob extends EverJob {

	@Autowired private BatchLogCommon_Service batchLogCommon_Service;
    @Autowired private ComPartIf_Service comPartIf_service;

    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {

        if (super.isAllowedToRunBatch(context)) {

            printJobStartLog(context);

            String jobRlt = "E";
            String startDate = EverDate.getTimeStampString();

            UserInfo baseinfo = new UserInfo();
            baseinfo.setGateCd(PropertiesManager.getString("eversrm.gateCd.default"));
            baseinfo.setUserId(PropertiesManager.getString("eversrm.userId.default"));
            baseinfo.setLangCd(PropertiesManager.getString("eversrm.langCd.default"));
            baseinfo.setManageCd(PropertiesManager.getString("eversrm.default.company.code"));

            baseinfo.setIpAddress("127.0.0.1");
            UserInfoManager.createUserInfo(baseinfo);
            
            batchLogCommon_Service = SpringContextUtil.getBean(BatchLogCommon_Service.class);
            comPartIf_service = SpringContextUtil.getBean(ComPartIf_Service.class);
            
            String msg = "";
            int totalCount = 0;
            try {
                msg = comPartIf_service.ComPlantIf(new HashMap<String, String>());
                jobRlt = "S";
            } catch (Exception e) {
                logger.error(e.getMessage(), e);
                msg = getMessageAsString(e);
                jobRlt = "E";
                throw new JobExecutionException();
            } finally {
                try {
                    Map<String, Object> logData = new HashMap<String, Object>();
                    logData.put("JOB_DATE", startDate.substring(0, 19));
                    logData.put("JOB_TYPE", "Batch");
                    logData.put("JOB_ID", "ComPartIf");
                    logData.put("JOB_NM", "고객사 파트(영업장) I/F");
                    logData.put("JOB_KEY", "");
                    logData.put("JOB_RLT", jobRlt);
                    logData.put("JOB_RLT_CD", "");
                    logData.put("JOB_RLT_MSG", msg);
                    logData.put("JOB_END_DATE", EverDate.getTimeStampString().substring(0, 19));
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
