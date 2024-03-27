package com.st_ones.common.util.service;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.EverDateMapper;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@Service(value = "wiseDateService")
public class EverDateService extends BaseService {

	Logger logger = LoggerFactory.getLogger(this.getClass());

	@Autowired private EverDateMapper everDateMapper;

	public int diffWithServerDate(String requestDateString, Date currentTimeWithUserGmt, boolean isGrid) throws ParseException {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		String dateFormat = userInfo.getDateFormat().replaceAll("/", "");
		if (isGrid) {
			dateFormat = "yyyyMMdd";
		}
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(dateFormat, Locale.getDefault());
		Date requestDate = simpleDateFormat.parse(requestDateString.replaceAll("/", ""));
		int requestDateInt = getDateAsInt(requestDate);
		int serverDateAsCliendLocaleInt = getDateAsInt(currentTimeWithUserGmt);

		logger.info(String.format("serverDateAsCliendLocaleInt: %s, requestDateInt: %s", serverDateAsCliendLocaleInt, requestDateInt));

		int gap = serverDateAsCliendLocaleInt - requestDateInt;
		if (gap > 0) {
			return -1;
		} else if (gap < 0) {
			return 1;
		}
		return 0;
	}

	public int diffWithServerTime(String requestTimeString, Date currentTimeWithUserGmt) throws ParseException {
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("HHmmss", Locale.getDefault());
		Date requestTime = simpleDateFormat.parse(requestTimeString);
		int serverTimeInt = getTimeAsInt(currentTimeWithUserGmt);
		int requestTimeInt = getTimeAsInt(requestTime);

		logger.info(String.format("serverTimeInt: %s, requestTimeInt: %s", serverTimeInt, requestTimeInt));

		int gap = serverTimeInt - requestTimeInt;
		if (gap > 0) {
			return -1;
		} else if (gap < 0) {
			return 1;
		}
		return 0;
	}

	private int getDateAsInt(Date requestDate) {
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd", Locale.getDefault());
		return Integer.parseInt(simpleDateFormat.format(requestDate));
	}

	private int getTimeAsInt(Date requestDate) {
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("HHmmss", Locale.getDefault());
		return Integer.parseInt(simpleDateFormat.format(requestDate));
	}

	public String getWorkingDay(int paramDay) {
		Map<String, Object> param = new HashMap<String, Object>();
		param.put("PARAM_DAY", paramDay);
		return everDateMapper.getWorkingDay(param);
	}

}