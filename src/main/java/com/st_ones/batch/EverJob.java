package com.st_ones.batch;

import com.st_ones.everf.serverside.config.PropertiesManager;
import org.apache.commons.lang3.StringUtils;
import org.quartz.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.annotation.Nullable;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.UnknownHostException;
import java.text.DateFormat;
import java.util.Locale;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 7. 25 오전 11:12
 */
public abstract class EverJob implements Job {

    protected Logger logger = LoggerFactory.getLogger(getClass());
    protected DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.MEDIUM, Locale.KOREAN);

    protected boolean isAllowedToRunBatch(JobExecutionContext context) throws JobExecutionException {

        boolean webCall = (context == null);
        // 배치를 실행할 IP 체크 (운영WAS가 2대라서 1대에서만 배치가 돌아가도록 하기 위함)
        boolean isIpAllowedToRunQuartz = false;
        // 개발, 운영서버에서만 배치가 돌아가도록 eversrm.properties 에 수정되어 있음
        boolean useQuartz = PropertiesManager.getString("quartz.use.yn", "N").equals("Y");
        // 개발서버 여부
        boolean isDevServer = PropertiesManager.getBoolean("eversrm.system.developmentFlag");

        try {
            java.net.InetAddress address = java.net.InetAddress.getLocalHost();
    		String server_ip = address.getHostAddress();

            if(PropertiesManager.getString("quartz.batch.running.ips").indexOf(server_ip) >= 0) {
                isIpAllowedToRunQuartz = true;
                // 아래의 패키지 하위에 있는 배치 프로그램은 운영서버에서만 돌아가게끔 수정
                /*if(context != null) {
                    String packageName = context.getJobDetail().getJobClass().getPackage().getName();
                    if(packageName.indexOf("ecVanIf") > -1 || packageName.indexOf("emartIf") > -1 || packageName.indexOf("handexIf") > -1 || packageName.indexOf("shopLinkerIf") > -1) {
                        if(isDevServer) {
                            isIpAllowedToRunQuartz = false;
                        }
                    }
                }*/
            }
        } catch (UnknownHostException e) {
            logger.error(e.getMessage(), e);
        }

        return (webCall || (useQuartz && isIpAllowedToRunQuartz));
    }

    /**
     * 배치 실행 로그를 출력합니다.
     * @param context
     */
    protected void printJobStartLog(JobExecutionContext context) {
        if (context == null) {
            logger.info("Starting Schedule Job manually.");
        } else {
            try {
                SchedulerMetaData metaData = context.getScheduler().getMetaData();
                String description = context.getJobDetail().getDescription();
                String runningSince = dateFormat.format(metaData.getRunningSince());
                logger.info("STARTING SCHEDULE JOB ({}) (Detail: Executed {} time(s) since {})", description, metaData.getNumberOfJobsExecuted(), runningSince);
            } catch (SchedulerException e) {
                logger.error(e.getMessage(), e);
            }
        }
    }

    /**
     * 배치 종료 로그를 출력합니다.
     * @param context
     * @param resultMessage
     * @param totalCount
     */
    protected void printJobEndLog(JobExecutionContext context, String resultMessage, @Nullable Object totalCount) {

        if(context != null) {
            Trigger trigger = context.getTrigger();
            String description = context.getJobDetail().getDescription();
            String nextFireTime = dateFormat.format(trigger.getNextFireTime());
            logger.info("SCHEDULE JOB IS FINISHED ({}) Result: Total({}):{} (Detail: Next fire time: {})", description, totalCount, resultMessage, nextFireTime);
        }
    }

    /**
     * 배치가 실행되도록 설정되지 않았을 때의 상태 로그를 출력합니다.
     * @param context
     */
    protected void printJobNotRunningLog(JobExecutionContext context) {

        if(context != null) {
            String description = context.getJobDetail().getDescription();
            String nextFireTime = dateFormat.format(context.getTrigger().getNextFireTime());
            logger.warn("[BATCH NOT SET TO RUN] {} :-> Next FireTime: {}", description, nextFireTime);
        } else {
            logger.warn("[BATCH NOT SET TO RUN]");
        }
    }

    /**
     * Return converted printStaceTrace buffer to String
     * @param e
     * @return
     */
    protected String getMessageAsString(Throwable e) {

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw, true);
        e.printStackTrace(pw);
        pw.flush();
        return StringUtils.abbreviate(sw.toString(), 3000);
    }
}
