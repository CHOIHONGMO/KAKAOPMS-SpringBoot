package com.st_ones.eversrm.scheduler;

import com.st_ones.batch.bdOpen.web.BdOpen;
import com.st_ones.batch.comDeptIf.web.ComDeptJob;
import com.st_ones.batch.comDivisionIf.web.ComDivisionJob;
import com.st_ones.batch.comPartIf.web.ComPartJob;
import com.st_ones.batch.comPlantIf.web.ComPlantJob;
import com.st_ones.batch.comUserIf.web.ComUserJob;
import com.st_ones.batch.cpoIF.web.CPOIF;
import com.st_ones.batch.custUnitPrcIF.web.CustUnitPrcIF;
import com.st_ones.batch.grIF.web.GRIF;
import com.st_ones.batch.gwApprovalIf.web.GwApprovalIF;
import com.st_ones.batch.itemIF.web.ITEMIF;
import com.st_ones.batch.rfqNoticeMail.web.RfqNoticeMail;
import com.st_ones.batch.userBlock.web.UserBlockJob;
import com.st_ones.everf.serverside.config.PropertiesManager;
import jakarta.servlet.http.HttpServlet;
import org.quartz.CronTrigger;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.impl.StdSchedulerFactory;

import java.net.UnknownHostException;
import java.text.ParseException;

import static org.quartz.CronScheduleBuilder.cronSchedule;
import static org.quartz.JobBuilder.newJob;
import static org.quartz.TriggerBuilder.newTrigger;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 7. 25 오전 11:12
 */
public class SchedulerInitializer extends HttpServlet {

	private static final long serialVersionUID = 1L;

	public SchedulerInitializer() throws SchedulerException, ParseException, UnknownHostException {

		java.net.InetAddress address = java.net.InetAddress.getLocalHost();
		String server_ip = address.getHostAddress();

		Scheduler scheduler = StdSchedulerFactory.getDefaultScheduler();
		String scheduleName01 = "eversrm.scheduling01"; // 고객 사업장 I/F (STOCCUPL)
		String scheduleName02 = "eversrm.scheduling02"; // 고객 사업부 I/F (STOCOGDP, DEPT_TYPE=100)
		String scheduleName03 = "eversrm.scheduling03"; // 고객 부서 I/F (STOCOGDP, DEPT_TYPE=200)
		String scheduleName04 = "eversrm.scheduling04"; // 고객 파트(영업장) I/F (STOCOGDP, DEPT_TYPE=300)
		String scheduleName05 = "eversrm.scheduling05"; // 고객 사용자 I/F (STOCCVUR, STOCUSAP=PF0131)

		String scheduleName10 = "eversrm.scheduling10"; // 고객사 신규품목 등록요청 I/F (STOUNWRQ)
		String scheduleName11 = "eversrm.scheduling11"; // 고객사 주문정보 I/F (STOUPOHD, STOUPODT)
		String scheduleName12 = "eversrm.scheduling12"; // 고객사 입고정보 I/F (STOCGRDT)
		String scheduleName13 = "eversrm.scheduling13"; // 고객사 판가정보 I/F (ICOYITEM_IF)

		String scheduleName20 = "eversrm.scheduling20"; // 1년간 로그인 안한 사용자 Block처리 배치작업

		//String scheduleName21 = "eversrm.scheduling21"; // 납품지연 알림(시스템 => 고객사별 운영사 품목담당자)
		//String scheduleName22 = "eversrm.scheduling22"; // 납품예정 알림(운영사 품목담당자 => 공급사 납품담당자)
		//String scheduleName23 = "eversrm.scheduling23"; // 납품알림(운영사 품목담당자 => 공급사 납품담당자)
		//String scheduleName24 = "eversrm.scheduling24"; // 입고완료처리 요청(고객사, 입고담당자)

		String scheduleName30 = "eversrm.scheduling30"; // 견적지연 안내 E-mail 발송(운영사 시스템 => 공급사담당자)
		String scheduleName31 = "eversrm.scheduling31"; // 대명소노 GW 결재승인 이후 업무처리 프로세스(EndApproval) : 입찰시행품의, 구매품의, 본사품의

		String scheduleName32 = "eversrm.scheduling32"; // 입찰 개찰요청 SMS

		/** ******************************************************************************************
		 * 고객 사업장 I/F (STOCCUPL)
		 * 1일 1회 24시 30분
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail01 = newJob(ComPlantJob.class).withIdentity(scheduleName01, "DEFAULT01").withDescription("고객사 사업장 수신").build();
		CronTrigger trigger01 = newTrigger().withIdentity(scheduleName01, "DEFAULT01").withSchedule(cronSchedule("0 30 0 * * ?")).build();
		scheduler.deleteJob(jobDetail01.getKey());

		/** ******************************************************************************************
		 * 고객 사업부 I/F (STOCOGDP, DEPT_TYPE=100)
		 * 1일 1회 01시 00분
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail02 = newJob(ComDivisionJob.class).withIdentity(scheduleName02, "DEFAULT02").withDescription("고객사 사업부 수신").build();
		CronTrigger trigger02 = newTrigger().withIdentity(scheduleName02, "DEFAULT02").withSchedule(cronSchedule("0 0 1 * * ?")).build();
		scheduler.deleteJob(jobDetail02.getKey());

		/** ******************************************************************************************
		 * 고객 부서 I/F (STOCOGDP, DEPT_TYPE=200)
		 * 1일 1회 01시 05분
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail03 = newJob(ComDeptJob.class).withIdentity(scheduleName03, "DEFAULT03").withDescription("고객사 부서 수신").build();
		CronTrigger trigger03 = newTrigger().withIdentity(scheduleName03, "DEFAULT03").withSchedule(cronSchedule("0 5 1 * * ?")).build();
		scheduler.deleteJob(jobDetail03.getKey());

		/** ******************************************************************************************
		 * 고객 파트(영업장) I/F (STOCOGDP, DEPT_TYPE=300)
		 * 1일 1회 01시 10분
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail04 = newJob(ComPartJob.class).withIdentity(scheduleName04, "DEFAULT04").withDescription("고객사 파트(영업장) 수신").build();
		CronTrigger trigger04 = newTrigger().withIdentity(scheduleName04, "DEFAULT04").withSchedule(cronSchedule("0 10 1 * * ?")).build();
		scheduler.deleteJob(jobDetail04.getKey());

		/** ******************************************************************************************
		 * 고객 사용자 I/F (STOCCVUR, STOCUSAP=PF0131)
		 * 1일 1회 01시 20분
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail05 = newJob(ComUserJob.class).withIdentity(scheduleName05, "DEFAULT05").withDescription("고객사 사용자 수신").build();
		CronTrigger trigger05 = newTrigger().withIdentity(scheduleName05, "DEFAULT05").withSchedule(cronSchedule("0 20 1 * * ?")).build();
		scheduler.deleteJob(jobDetail05.getKey());

		/** ******************************************************************************************
		 * 신규품목 등록요청 I/F
		 * 시간 : 0분 시작, 매 5분, 월 ~ 금
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail10 = newJob(ITEMIF.class).withIdentity(scheduleName10, "DEFAULT10").withDescription("신규품목 등록요청 I/F").build();
		CronTrigger trigger10 = newTrigger().withIdentity(scheduleName10, "DEFAULT10").withSchedule(cronSchedule("0 0/5 * ? * MON-SAT")).build();
		scheduler.deleteJob(jobDetail10.getKey());

		/** ******************************************************************************************
		 * 주문 I/F
		 * 시간 : 1분 시작, 매 5분, 월 ~ 금
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail11 = newJob(CPOIF.class).withIdentity(scheduleName11, "DEFAULT11").withDescription("I/F 발주").build();
		CronTrigger trigger11 = newTrigger().withIdentity(scheduleName11, "DEFAULT11").withSchedule(cronSchedule("0 1/5 * ? * MON-SAT")).build();
		scheduler.deleteJob(jobDetail11.getKey());

		/** ******************************************************************************************
		 * 입고 I/F
		 * 시간 : 3분 시작, 매 5분, 월 ~ 금
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail12 = newJob(GRIF.class).withIdentity(scheduleName12, "DEFAULT12").withDescription("I/F 입고").build();
		CronTrigger trigger12 = newTrigger().withIdentity(scheduleName12, "DEFAULT12").withSchedule(cronSchedule("0 3/5 * ? * MON-SAT")).build();
		scheduler.deleteJob(jobDetail12.getKey());

		/** ******************************************************************************************
		 * 고객사 판가정보 I/F (ICOYITEM_IF)
		 * 1일 1회 00시 05분
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail13 = newJob(CustUnitPrcIF.class).withIdentity(scheduleName13, "DEFAULT13").withDescription("고객사 판가정보 I/F").build();
		CronTrigger trigger13 = newTrigger().withIdentity(scheduleName13, "DEFAULT13").withSchedule(cronSchedule("0 5 0 * * ?")).build();
		scheduler.deleteJob(jobDetail13.getKey());

		/** ******************************************************************************************
		 * 1년동안 로그인 안 한 사용자 Block 처리
		 * 1일 1회 01시 30분
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail20 = newJob(UserBlockJob.class).withIdentity(scheduleName20, "DEFAULT20").withDescription("사용자 Block처리").build();
		CronTrigger trigger20 = newTrigger().withIdentity(scheduleName20, "DEFAULT20").withSchedule(cronSchedule("0 30 1 * * ?")).build();
		scheduler.deleteJob(jobDetail20.getKey());

		/** ******************************************************************************************
		 * 견적지연 안내 E-mail 발송(운영사 시스템 => 공급사 담당자)
		 * 발송시간 : 매일 09:00 : 견적마감일
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail30 = newJob(RfqNoticeMail.class).withIdentity(scheduleName30, "DEFAULT30").withDescription("견적지연알림").build();
		CronTrigger trigger30 = newTrigger().withIdentity(scheduleName30, "DEFAULT30").withSchedule(cronSchedule("0 0 9 * * ?")).build();
		scheduler.deleteJob(jobDetail30.getKey());

		/** ******************************************************************************************
		 * 대명소노 GW 결재승인 이후 업무처리 프로세스(EndApproval) : 입찰시행품의, 구매품의, 본사품의
		 * 시간 : 4분 시작, 매 5분
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail31 = newJob(GwApprovalIF.class).withIdentity(scheduleName31, "DEFAULT31").withDescription("GW 결재승인 (EndApproval)").build();
		CronTrigger trigger31 = newTrigger().withIdentity(scheduleName31, "DEFAULT31").withSchedule(cronSchedule("0 4/5 * * * ?")).build();
		scheduler.deleteJob(jobDetail31.getKey());


		/** ******************************************************************************************
		 * 입찰 개찰 요청 SMS
		 * 시간 : 매시 2분
		 * @param req
		 * @return
		 * @throws Exception
		 */
		JobDetail jobDetail32 = newJob(BdOpen.class).withIdentity(scheduleName32, "DEFAULT32").withDescription("입찰 개찰 요청 SMS").build();
		CronTrigger trigger32 = newTrigger().withIdentity(scheduleName32, "DEFAULT32").withSchedule(cronSchedule("0 2 * * * ?")).build();
		scheduler.deleteJob(jobDetail32.getKey());





		// ============================================== 사용하지 않음 ==============================================================================//
		/** ******************************************************************************************
		 * [미사용] 납품지연 알림(시스템 => 고객사별 운영사 품목담당자)
		 * 발송시간 : 08:50 : 희망납기일 D+1 시점에서 1회 발송
		 * @param req
		 * @return
		 * @throws Exception
		 */
		/*JobDetail jobDetail21 = newJob(InvoiceDelayIf.class).withIdentity(scheduleName21, "DEFAULT21").withDescription("납품지연알림").build();
		CronTrigger trigger21 = newTrigger().withIdentity(scheduleName21, "DEFAULT21").withSchedule(cronSchedule("0 50 8 * * ?")).build();
		scheduler.deleteJob(jobDetail21.getKey());*/

		/** ******************************************************************************************
		 * [미사용] 납품예정 알림(운영사 품목담당자 => 공급사 납품담당자)
		 * 발송시간 : 09:10 : 희망납기일 D-1 시점에서 1회 발송
		 * @param req
		 * @return
		 * @throws Exception
		 */
		/*JobDetail jobDetail22 = newJob(DelyAlarmIf.class).withIdentity(scheduleName22, "DEFAULT22").withDescription("납품예정알림").build();
		CronTrigger trigger22 = newTrigger().withIdentity(scheduleName22, "DEFAULT22").withSchedule(cronSchedule("0 10 9 * * ?")).build();
		scheduler.deleteJob(jobDetail22.getKey());*/

		/** ******************************************************************************************
		 * 납품알림(운영사 품목담당자 => 공급사 납품담당자)
		 * 발송시간 : 09:00 : 희망납기일 시점에서 1회 발송
		 * @param req
		 * @return
		 * @throws Exception
		 */
		/*JobDetail jobDetail23 = newJob(CurDelyAlarmIf.class).withIdentity(scheduleName23, "DEFAULT23").withDescription("금일납품알림").build();
		CronTrigger trigger23 = newTrigger().withIdentity(scheduleName23, "DEFAULT23").withSchedule(cronSchedule("0 0 9 * * ?")).build();
		scheduler.deleteJob(jobDetail23.getKey());*/

		/** ******************************************************************************************
		 * [미사용] 입고완료처리 요청(고객사, 입고담당자)
		 * 납품완료 후 D + 3 시점에 14시 SMS 1회 발송
		 * @param req
		 * @return
		 * @throws Exception
		 */
		/*JobDetail jobDetail24 = newJob(GrRequestDelaySms.class).withIdentity(scheduleName24, "DEFAULT24").withDescription("입고완료처리요청").build();
		CronTrigger trigger24 = newTrigger().withIdentity(scheduleName24, "DEFAULT24").withSchedule(cronSchedule("0 0 14 * * ?")).build();
		scheduler.deleteJob(jobDetail24.getKey());*/

		/** ******************************************************************************************
		 * [미사용] 마감확정요청(고객) : 매입, 매출 마감확정 기능 제외
		 * 마감확정 후 D + 2 부터 매일 08시 메일 발송(미확정 고객사)
		 * @param req
		 * @return
		 * @throws Exception
		 */
		//JobDetail jobDetail25 = newJob(CustCfmReqMail.class).withIdentity(scheduleName25, "DEFAULT25").withDescription("마감확정요청(고객)").build();
		//CronTrigger trigger25 = newTrigger().withIdentity(scheduleName25, "DEFAULT25").withSchedule(cronSchedule("0 0 8 * * ?")).build();
		//scheduler.deleteJob(jobDetail25.getKey());
		//scheduler.scheduleJob(jobDetail25, trigger25);
		// ============================================== 사용하지 않음 ==============================================================================//








		/*
		 * Cron Expression cron expression의 각각의 필드는 다음을 나타낸다.(왼쪽 -> 오른쪽 순) 필드 이름
		 * 허용 값 허용된 특수 문자 Seconds 0 ~ 59 , - * / Minutes 0 ~ 59 , - * / Hours 0
		 * ~ 23 , - * / Day-of-month 1 ~ 31 , - * ? / L W Month 1 ~12 or JAN ~
		 * DEC , - * / Day-Of-Week 1 ~ 7 or SUN-SAT , - * ? / L # Year
		 * (optional) empty, 1970 ~ 2099 , - * /
		 *
		 * Cron Expression 의 특수문자 '*' : 모든 수를 나타냄. 분의 위치에 * 설정하면 "매 분 마다" 라는 뜻.
		 * '?' : day-of-month 와 day-of-week 필드에서만 사용가능. 특별한 값이 없음을 나타낸다. '-' :
		 * "10-12" 과 같이 기간을 설정한다. 시간 필드에 "10-12" 이라 입력하면 "10, 11, 12시에 동작하도록 설정"
		 * 이란 뜻. ',' : "MON,WED,FRI"와 같이 특정 시간을 설정할 때 사용한다. "MON,WED,FRI" 이면
		 * " '월,수,금' 에만 동작" 이란 뜻. '/' : 증가를 표현합니다. 예를 들어 초 단위에 "0/15"로 세팅 되어 있다면
		 * "0초 부터 시작하여 15초 이후에 동작" 이란 뜻. 'L' : day-of-month 와 day-of-week 필드에만
		 * 사용하며 마지막날을 나타냅. 만약 day-of-month 에 "L" 로 되어 있다면 이번 달의 마지막에 실행하겠다는 것을
		 * 나타냄. 'W' : day-of-month 필드에만 사용되며, 주어진 기간에 가장 가까운 평일(월~금)을 나타낸다. 만약
		 * "15W" 이고 이번 달의 15일이 토요일이라면 가장가까운 14일 금요일날 실행된다. 또 15일이 일요일이라면 가장 가까운
		 * 평일인 16일 월요일에 실행되게 된다. 만약 15일이 화요일이라면 화요일인 15일에 수행된다. "LW" : L과 W를
		 * 결합하여 사용할 수 있으며 "LW"는 "이번달 마지막 평일"을 나타냄 "#" : day-of-week에 사용된다. "6#3"
		 * 이면 3(3)번째 주 금요일(6) 이란 뜻이된다.1은 일요일 ~ 7은 토요일
		 *
		 * Expression Meaning "0 0 12 * * ?" 매일 12시에 실행 "0 15 10 ? * *" 매일 10시
		 * 15분에 실행 "0 15 10 * * ?" 매일 10시 15분에 실행 "0 15 10 * * ? *" 매일 10시 15분에
		 * 실행 "0 15 10 * * ?  2010" 2010년 동안 매일 10시 15분에 실행 "0 * 14 * * ?" 매일
		 * 14시에서 시작해서 14:59분 에 끝남 "0 0/5 14 * * ?" 매일 14시에 시작하여 5분 간격으로 실행되며
		 * 14:55분에 끝남 "0 0/5 14,18 * * ?" 매일 14시에 시작하여 5분 간격으로 실행되며 14:55분에 끝나고,
		 * 매일 18시에 시작하여 5분간격으로 실행되며 18:55분에 끝난다. "0 0-5 14 * * ?" 매일 14시에 시작하여
		 * 14:05 분에 끝난다.
		 *
		 * Ex) 매일 7시 20분에 한번 수행 [cronSchedule("0 20 7 * * ?")]
		 *     매일 5시에 한번 수행 [cronSchedule("0 0 5 * * ?")]
		 *     10분마다 수행 [cronSchedule("0 0/10 * * * ?")]
		 */

		// 특정 IP에서만 실행한다.
		if(PropertiesManager.getString("quartz.batch.running.ips").indexOf(server_ip) >= 0) {
			scheduler.scheduleJob(jobDetail01, trigger01);	// 고객 사업장 I/F (STOCCUPL)
			scheduler.scheduleJob(jobDetail02, trigger02);	// 고객 사업부 I/F (STOCOGDP, DEPT_TYPE=100)
			scheduler.scheduleJob(jobDetail03, trigger03);	// 고객 부서 I/F (STOCOGDP, DEPT_TYPE=200)
			scheduler.scheduleJob(jobDetail04, trigger04);	// 고객 파트(영업장) I/F (STOCOGDP, DEPT_TYPE=300)
			scheduler.scheduleJob(jobDetail05, trigger05);	// 고객 사용자 I/F (STOCCVUR, STOCUSAP=PF0131)

			scheduler.scheduleJob(jobDetail10, trigger10);	// 고객사 신규품목 등록요청 I/F (STOUNWRQ)
			scheduler.scheduleJob(jobDetail11, trigger11);	// 고객사 주문정보 I/F (STOUPOHD, STOUPODT)
			scheduler.scheduleJob(jobDetail12, trigger12);	// 고객사 입고정보 I/F (STOCGRDT)
			scheduler.scheduleJob(jobDetail13, trigger13);	// 고객사 판가정보 I/F (ICOYITEM_IF)

			scheduler.scheduleJob(jobDetail20, trigger20);	// 1년간 로그인 안한 사용자 Block처리 배치작업

			scheduler.scheduleJob(jobDetail30, trigger30);	// 견적지연 안내 E-mail 발송(운영사 시스템 => 공급사담당자)
			scheduler.scheduleJob(jobDetail31, trigger31);	// 대명소노 GW 결재승인 이후 업무처리 프로세스(EndApproval) : 입찰시행품의, 구매품의, 본사품의
			scheduler.scheduleJob(jobDetail32, trigger32);	// 입찰 개찰 요청 SMS
		} else {
			System.err.println("Batch 가 실행되지 않았습니다. 특정 IP 에서만 실행됩니다. 허용된 IP 주소는 "  + PropertiesManager.getString("quartz.batch.running.ips") + " 입니다.");
		}
	}
}
