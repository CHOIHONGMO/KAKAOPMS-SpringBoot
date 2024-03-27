package com.st_ones.common.serverpush.reverseajax;

import org.directwebremoting.Browser;
import org.directwebremoting.annotations.RemoteProxy;
import org.directwebremoting.impl.DaemonThreadFactory;
import org.directwebremoting.ui.dwr.Util;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

@Service
@RemoteProxy
public class LoginMonitor implements Runnable {
	
	protected List<String> loginInfos = new ArrayList<String>();
	public static long givenTime;

	public void startThread(){
		ScheduledThreadPoolExecutor executor = new ScheduledThreadPoolExecutor(1, new DaemonThreadFactory());
		executor.scheduleAtFixedRate(this, 1, 1000, TimeUnit.MILLISECONDS);
//		Util.setValue("clockDisplay", getRemainTime(givenTime));
	}
	public void add5Min() {
		givenTime += 1000 * 60 * 5;
	}

	public void setGivenTimeToCurrent() {
		givenTime = System.currentTimeMillis();
	}

	public String getRemainTime(long _givenTime) {
		long remainTime = _givenTime - System.currentTimeMillis();
		long remainTimeSec = remainTime / 1000;
		long remainTimeMin = remainTimeSec / 60;
		long remainTimeHour = remainTimeMin / 60;
		long remainTimeDay = remainTimeHour / 24;

		long sec = remainTimeSec % 60;
		long min = remainTimeMin % 60;
		long hour = remainTimeHour % 24;
		long day = remainTimeDay;
		return String.format("%d일 %2d시간 %2d분 %2d초", day, hour, min, sec);
	}
	
	public void run() {
		Browser.withAllSessions(new Runnable() {
			public void run() {
				Util.setValue("clockDisplay", getRemainTime(givenTime));
			}
		});
	}
	
}
