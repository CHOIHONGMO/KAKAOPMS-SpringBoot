package com.st_ones.common.util.clazz;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 8 오전 9:32
 */

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import org.apache.commons.lang3.time.DateFormatUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class EverDate {

    private static Logger logger = LoggerFactory.getLogger(EverDate.class);
    static UserInfo baseInfo = null;

    public static void isDate(String paramString1, String paramString2)
            throws ParseException {
        if (paramString1 == null)
            throw new NullPointerException("date string to check is null");
        if (paramString2 == null) {
            throw new NullPointerException(
                    "format string to check date is null");
        }
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                paramString2, Locale.KOREA);
        Date localDate = null;
        try {
            localDate = localSimpleDateFormat.parse(paramString1);
        } catch (ParseException localParseException) {
            throw new ParseException(localParseException.getMessage()
                    + " with format \"" + paramString2 + "\"",
                    localParseException.getErrorOffset());
        }

        if (!(localSimpleDateFormat.format(localDate).equals(paramString1)))
            throw new ParseException("Out of bound date:\"" + paramString1
                    + "\" with format \"" + paramString2 + "\"", 0);
    }

    public static String getDateString() {
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                "yyyy-MM-dd", Locale.KOREA);
        return localSimpleDateFormat.format(new Date());
    }

    public static String getFormatString(String paramString) {
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                paramString, Locale.KOREA);
        String str = localSimpleDateFormat.format(new Date());
        return str;
    }

    public static String getFormatString(String paramString1,
                                         String paramString2) {
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                paramString2, Locale.KOREA);
        String str = localSimpleDateFormat.format(paramString1);
        return str;
    }

    private static int getNumberByPattern(String paramString) {
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                paramString, Locale.KOREA);
        String str = localSimpleDateFormat.format(new Date());
        return Integer.parseInt(str);
    }

    public static String getShortDateString() {
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                "yyyyMMdd", Locale.KOREA);
        return localSimpleDateFormat.format(new Date());
    }

    public static String getShortTimeString() {
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat("HHmmss",
                Locale.KOREA);
        return localSimpleDateFormat.format(new Date());
    }

    public static String getTimeStampString() {
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                "yyyy-MM-dd-HH:mm:ss:SSS", Locale.KOREA);
        return localSimpleDateFormat.format(new Date());
    }

    public static String getTimeString() {
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                "HH:mm:ss", Locale.KOREA);
        return localSimpleDateFormat.format(new Date());
    }

    public static int getFirstMonth(int paramInt1, int paramInt2, int paramInt3) {
        Calendar localCalendar1 = Calendar.getInstance();
        Calendar localCalendar2 = Calendar.getInstance();

        localCalendar1 = Calendar.getInstance();
        localCalendar1.set(1, paramInt1);
        localCalendar1.set(2, paramInt2 - 1);
        localCalendar1.set(5, 1);

        localCalendar2 = localCalendar1;
//		int i = localCalendar2.get(1);
//		int j = localCalendar2.get(2) + 1;
//		int k = localCalendar2.get(5);
        return (localCalendar2.get(7) - 1);
    }

    public static int getDaysInMonth(int paramInt1, int paramInt2) {
        Calendar localCalendar1 = Calendar.getInstance();
        Calendar localCalendar2 = Calendar.getInstance();

        localCalendar1 = Calendar.getInstance();
        localCalendar1.set(1, paramInt1);
        localCalendar1.set(2, paramInt2);
        localCalendar1.set(5, 0);

        localCalendar2 = localCalendar1;
//		int i = localCalendar2.get(1);
//		int j = localCalendar2.get(2);
        int k = localCalendar2.get(5);

        return k;
    }

    public static String addDateYear(String paramString, int paramInt) {
        String str = null;

        Calendar localCalendar = Calendar.getInstance();
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                "yyyyMMdd");
        try {
            Date localDate = localSimpleDateFormat.parse(paramString);
            localCalendar.setTime(localDate);

            localCalendar.add(1, paramInt);
            localDate = localCalendar.getTime();
            str = localSimpleDateFormat.format(localDate);
        } catch (ParseException localParseException) {
            str = paramString;
        }

        return str;
    }

    public static String addDateMonth(String paramString, int paramInt) {

        String format = "";
        SimpleDateFormat localSimpleDateFormat;
        if (paramString != null) {
            if (paramString.length() == 6) {
                format = "yyyyMM";
            } else if (paramString.length() == 8) {
                format = "yyyyMMdd";
            }
        }

        String str = null;

        Calendar localCalendar = Calendar.getInstance();
        localSimpleDateFormat = new SimpleDateFormat(format);
        try {
            Date localDate = localSimpleDateFormat.parse(paramString);
            localCalendar.setTime(localDate);

            localCalendar.add(2, paramInt);
            localDate = localCalendar.getTime();
            str = localSimpleDateFormat.format(localDate);
        } catch (ParseException localParseException) {
            str = paramString;
        }

        return str;
    }

    public static String addDateDay(String paramString, int paramInt) {
        String str = null;

        Calendar localCalendar = Calendar.getInstance();
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                "yyyyMMdd");
        try {
            Date localDate = localSimpleDateFormat.parse(paramString);
            localCalendar.setTime(localDate);

            localCalendar.add(5, paramInt);
            localDate = localCalendar.getTime();
            str = localSimpleDateFormat.format(localDate);
        } catch (ParseException localParseException) {
            str = paramString;
        }

        return str;
    }

    public static String addDateTimeHour(String paramString, int paramInt) {
        String str = null;

        Calendar localCalendar = Calendar.getInstance();
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                "yyyyMMddHHmmss");
        try {
            Date localDate = localSimpleDateFormat.parse(paramString);
            localCalendar.setTime(localDate);

            localCalendar.add(10, paramInt);
            localDate = localCalendar.getTime();
            str = localSimpleDateFormat.format(localDate);
        } catch (ParseException localParseException) {
            str = paramString;
        }

        return str;
    }

    public static String addDateTimeMinute(String paramString, int paramInt) {
        String str = null;

        Calendar localCalendar = Calendar.getInstance();
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                "yyyyMMddHHmmss");
        try {
            Date localDate = localSimpleDateFormat.parse(paramString);
            localCalendar.setTime(localDate);

            localCalendar.add(12, paramInt);
            localDate = localCalendar.getTime();
            str = localSimpleDateFormat.format(localDate);
        } catch (ParseException localParseException) {
            str = paramString;
        }

        return str;
    }

    public static String addDateTimeSecond(String paramString, int paramInt) {
        String str = null;

        Calendar localCalendar = Calendar.getInstance();
        SimpleDateFormat localSimpleDateFormat = new SimpleDateFormat(
                "yyyyMMddHHmmss");
        try {
            Date localDate = localSimpleDateFormat.parse(paramString);
            localCalendar.setTime(localDate);

            localCalendar.add(13, paramInt);
            localDate = localCalendar.getTime();
            str = localSimpleDateFormat.format(localDate);
        } catch (ParseException localParseException) {
            str = paramString;
        }

        return str;
    }

    /**
     * 현재날짜 반환 ex) 20110120 return currentDate: yyyyMMdd
     *
     * @return String
     * @throws UserInfoNotFoundException
     */
    public static String getDate() {
        baseInfo = UserInfoManager.getUserInfoImpl();
        String format = baseInfo.getDateFormat().replaceAll("[^yYmMdD]", "").replaceAll("ymmd", "yMMd");
        return DateFormatUtils.format(new Date(), format);
    }

    /**
     * 현재날짜 반환 ex) 20110120 return currentDate: yyyyMMdd
     *
     * @return String
     * @throws UserInfoNotFoundException
     */
    public static String getDate2() throws UserInfoNotFoundException {
        String format = "yyyyMMdd";
        return DateFormatUtils.format(new Date(), format);
    }

    /**
     * 현재년도 반환 ex) 2011 return current year: yyyy
     *
     * @return String
     */
    public static String getYear() {
        String format = "yyyy";
        return DateFormatUtils.format(new Date(), format);
    }

    /**
     * 현재달 반환 ex) 01 or 02 or 03... return currentMonth: MM
     *
     * @return String
     */
    public static String getMonth() {
        String format = "MM";
        return DateFormatUtils.format(new Date(), format);
    }

    /**
     * 현재일 반환 ex) 01 or 02 or 03... or 31 return current day: dd
     *
     * @return String
     */
    public static String getDay() {
        String format = "dd";
        return DateFormatUtils.format(new Date(), format);
    }

    /**
     * 현재시간 반환 ex)103025 return current time: HHmmss
     *
     * @return String
     */
    public static String getTime() {
        SimpleDateFormat simpledateformat = new SimpleDateFormat("HHmmss",
                Locale.KOREA);
        return simpledateformat.format(new Date());
    }

    /**
     * 현재시간 반환
     * 시간포맷 (HHmmss, HH.mm.ss)
     *
     * @return String
     */
    public static String getFormattedTime() {
        SimpleDateFormat simpledateformat = new SimpleDateFormat("HH:mm:ss",
                Locale.KOREA);
        return simpledateformat.format(new Date());
    }

    /**
     * 현재 날짜 [ + or - ] Years add year from current date
     *
     * @param paramInt
     * @return String
     * @throws UserInfoNotFoundException
     */
    public static String addYears(int paramInt) {
        baseInfo = UserInfoManager.getUserInfoImpl();
        String format = baseInfo.getDateFormat().replaceAll("/", "");
        return DateFormatUtils.format(DateUtils.addYears(new Date(), paramInt),
                format);

    }

    /**
     * 현재 날짜 [ + or - ] Months add month from current date
     *
     * @param paramInt
     * @return String
     * @throws UserInfoNotFoundException
     */
    public static String addMonths(int paramInt) {
        baseInfo = UserInfoManager.getUserInfoImpl();
        String format = baseInfo.getDateFormat().replaceAll("[^yYmMdD]", "").replaceAll("ymmd", "yMMd");
        return DateFormatUtils.format(DateUtils.addMonths(new Date(), paramInt), format);
    }

    /**
     * 현재 날짜 [ + or - ] Weeks add week from current date
     *
     * @param paramInt
     * @return String
     * @throws UserInfoNotFoundException
     */
    public static String addWeeks(int paramInt) {
        baseInfo = UserInfoManager.getUserInfoImpl();
        String format = baseInfo.getDateFormat().replaceAll("/", "");
        return DateFormatUtils.format(DateUtils.addWeeks(new Date(), paramInt),
                format);
    }

    /**
     * 현재 날짜의 마지막 일을 구하는 함수
     *
     * @param yearMonth
     * @return String yearMonthDay
     * @throws Exception
     */
    public static String getLastDayofMonth(String yearMonth) throws Exception {
        String yearMonthDay = "";

        if (yearMonth.trim().length() != 6) {
            throw new EverException("Invalid format of year month.!! <" + yearMonth + ">");
        }

        String year = yearMonth.substring(0, 4);
        String month = yearMonth.substring(4);

        org.joda.time.DateTime dateTime = new org.joda.time.DateTime(Integer.parseInt(year), Integer.parseInt(month), 14, 12, 0, 0, 000);
        int day = dateTime.dayOfMonth().getMaximumValue();

        yearMonthDay = yearMonth + String.valueOf(day);

        return yearMonthDay;
    }


    /**
     * 현재 날짜 [ + or - ] Days add day from current date
     *
     * @param paramInt
     * @return String
     */
    public static String addDays(int paramInt) {
        baseInfo = UserInfoManager.getUserInfoImpl();
        String format = baseInfo.getDateFormat().replaceAll("[^yYmMdD]", "").replaceAll("ymmd", "yMMd");
        return DateFormatUtils.format(DateUtils.addDays(new Date(), paramInt), format);
    }

    /**
     * 날짜 문자열을 sourceFormat 형태로 받아서 targetFormat 형태로 변환 ex)
     * formatDate("2012:12:12", "yyyy:MM:dd", "yyyy년 MM월 dd일 입니다."); 출력 2012년
     * 12월 12일 입니다. ex) formatDate("2012:12:12", "yyyy:MM:dd",
     * "YEAR: yyyy MONTH: MM DAY: dd"); "YEAR: 2012 MONTH: 12 DAY: 12"
     * <p>
     * return string with date format
     *
     * @param dateString
     * @param sourceFormat
     * @param targetDateFormat
     * @return String
     */
    public static String formatDate(String dateString, String sourceFormat,
                                    String targetDateFormat) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(sourceFormat,
                Locale.getDefault());
        Date date;
        try {
            date = simpleDateFormat.parse(dateString);
        } catch (ParseException e) {
            logger.error(e.getMessage(), e);
            return "";
        }
        simpleDateFormat = new SimpleDateFormat(targetDateFormat,
                Locale.getDefault());
        return simpleDateFormat.format(date);
    }

    /**
     * yyyyMMdd 형식의 날짜 문자열을 yyyy/MM/DD로 변환 convert yyyyMMdd to yyyy/MM/dd
     *
     * @param dateString
     * @return String
     */
    public static String formatDate(String dateString) {
        baseInfo = UserInfoManager.getUserInfoImpl();
        return formatDate(dateString, "yyyyMMdd", baseInfo.getDateFormat());
    }

    /**
     * User GMT를 기준으로 System GMT에 대한 조회조건에서 사용되는 From Date를 반환.
     *
     * @param gmtDate
     * @param sysGmt
     * @param userGmt
     * @return
     */
    public static String getGmtFromDate(Object gmtDate, String sysGmt, String userGmt) {

        String rtnDate = gmtDate.toString();

        if (rtnDate == null || rtnDate.trim().length() <= 0) {
            return "";
        }

        int diff_hour = 0;
        int diff_minute = 0;
        Calendar diffGmtCal = null;

        String dateValueFormat = UserInfoManager.getUserInfo()
                .getDateValueFormat().replaceAll("[^yYmMdD]", "").replaceAll("m", "M");

        diffGmtCal = Calendar.getInstance();
        if (dateValueFormat.equals("yyyyMMdd")) {
            diffGmtCal.set(Integer.parseInt(rtnDate.substring(0, 4)),
                    Integer.parseInt(rtnDate.substring(4, 6)) - 1,
                    Integer.parseInt(rtnDate.substring(6, 8)), 0, 0, 0);
        } else if (dateValueFormat.equals("ddMMyyyy")) {
            diffGmtCal.set(Integer.parseInt(rtnDate.substring(4, 8)),
                    Integer.parseInt(rtnDate.substring(2, 4)) - 1,
                    Integer.parseInt(rtnDate.substring(0, 2)), 0, 0, 0);
        }
        rtnDate = String.valueOf(diffGmtCal.get(Calendar.YEAR))
                + (diffGmtCal.get(Calendar.MONTH) + 1 < 10 ? "0"
                + String.valueOf(diffGmtCal.get(Calendar.MONTH) + 1)
                : String.valueOf(diffGmtCal.get(Calendar.MONTH) + 1))
                + (diffGmtCal.get(Calendar.DAY_OF_MONTH) < 10 ? "0"
                + String.valueOf(diffGmtCal.get(Calendar.DAY_OF_MONTH))
                : String.valueOf(diffGmtCal.get(Calendar.DAY_OF_MONTH)));

        if (sysGmt.equals(userGmt)) {
            rtnDate += " 00:00:00";
        } else {
            if (sysGmt.length() == 9 && userGmt.length() == 9) {
                diff_hour = Integer.parseInt(sysGmt.substring(4, 6))
                        - Integer.parseInt(userGmt.substring(4, 6));
                diff_minute = Integer.parseInt(sysGmt.substring(7, 9))
                        - Integer.parseInt(userGmt.substring(7, 9));
                diffGmtCal.set(Calendar.HOUR, diffGmtCal.get(Calendar.HOUR)
                        + diff_hour);

                if (diff_hour > 0 && diff_minute != 0) {
                    diffGmtCal.set(Calendar.MINUTE,
                            diffGmtCal.get(Calendar.MINUTE) + diff_minute);
                } else if (diff_hour <= 0 && diff_minute != 0) {
                    diffGmtCal.set(Calendar.MINUTE,
                            diffGmtCal.get(Calendar.MINUTE) - diff_minute);
                }

                rtnDate = String.valueOf(diffGmtCal.get(Calendar.YEAR))
                        + (diffGmtCal.get(Calendar.MONTH) + 1 < 10 ? "0"
                        + String.valueOf(diffGmtCal.get(Calendar.MONTH) + 1)
                        : String.valueOf(diffGmtCal.get(Calendar.MONTH) + 1))
                        + (diffGmtCal.get(Calendar.DAY_OF_MONTH) < 10 ? "0"
                        + String.valueOf(diffGmtCal
                        .get(Calendar.DAY_OF_MONTH)) : String
                        .valueOf(diffGmtCal.get(Calendar.DAY_OF_MONTH)));

                rtnDate += " "
                        + (diffGmtCal.get(Calendar.HOUR_OF_DAY) < 10 ? "0"
                        + String.valueOf(diffGmtCal
                        .get(Calendar.HOUR_OF_DAY)) : String
                        .valueOf(diffGmtCal.get(Calendar.HOUR_OF_DAY)))
                        + ":"
                        + (diffGmtCal.get(Calendar.MINUTE) < 10 ? "0"
                        + String.valueOf(diffGmtCal
                        .get(Calendar.MINUTE)) : String
                        .valueOf(diffGmtCal.get(Calendar.MINUTE)))
                        + ":"
                        + (diffGmtCal.get(Calendar.SECOND) < 10 ? "0"
                        + String.valueOf(diffGmtCal
                        .get(Calendar.SECOND)) : String
                        .valueOf(diffGmtCal.get(Calendar.SECOND)));
            }
        }

        return rtnDate;
    }

    /**
     * User GMT를 기준으로 System GMT에 대한 조회조건에서 사용되는 To Date를 반환.
     *
     * @param gmtDate
     * @param sysGmt
     * @param userGmt
     * @return String
     */
    public static String getGmtToDate(Object gmtDate, String sysGmt,
                                      String userGmt) {

        String rtnDate = gmtDate.toString();

        if (rtnDate == null || rtnDate.trim().length() <= 0) {
            return "";
        }

        int diff_hour = 0;
        int diff_minute = 0;
        Calendar diffGmtCal = null;

        String dateValueFormat = UserInfoManager.getUserInfo()
                .getDateValueFormat().replaceAll("[^yYmMdD]", "").replaceAll("m", "M");
        diffGmtCal = Calendar.getInstance();
        if (dateValueFormat.equals("yyyyMMdd")) {
            diffGmtCal.set(Integer.parseInt(rtnDate.substring(0, 4)),
                    Integer.parseInt(rtnDate.substring(4, 6)) - 1,
                    Integer.parseInt(rtnDate.substring(6, 8)), 23, 59, 59);
        } else if (dateValueFormat.equals("ddMMyyyy")) {
            diffGmtCal.set(Integer.parseInt(rtnDate.substring(4, 8)),
                    Integer.parseInt(rtnDate.substring(2, 4)) - 1,
                    Integer.parseInt(rtnDate.substring(0, 2)), 23, 59, 59);
        }

        rtnDate = String.valueOf(diffGmtCal.get(Calendar.YEAR))
                + (diffGmtCal.get(Calendar.MONTH) + 1 < 10 ? "0"
                + String.valueOf(diffGmtCal.get(Calendar.MONTH) + 1)
                : String.valueOf(diffGmtCal.get(Calendar.MONTH) + 1))
                + (diffGmtCal.get(Calendar.DAY_OF_MONTH) < 10 ? "0"
                + String.valueOf(diffGmtCal.get(Calendar.DAY_OF_MONTH))
                : String.valueOf(diffGmtCal.get(Calendar.DAY_OF_MONTH)));

        if (sysGmt.equals(userGmt)) {
            rtnDate += " 23:59:59";
        } else {
            if (sysGmt.length() == 9 && userGmt.length() == 9) {
                diff_hour = Integer.parseInt(sysGmt.substring(4, 6))
                        - Integer.parseInt(userGmt.substring(4, 6));
                diff_minute = Integer.parseInt(sysGmt.substring(7, 9))
                        - Integer.parseInt(userGmt.substring(7, 9));
                diffGmtCal.set(Calendar.HOUR, diffGmtCal.get(Calendar.HOUR)
                        + diff_hour);

                if (diff_hour > 0 && diff_minute != 0) {
                    diffGmtCal.set(Calendar.MINUTE,
                            diffGmtCal.get(Calendar.MINUTE) + diff_minute);
                } else if (diff_hour <= 0 && diff_minute != 0) {
                    diffGmtCal.set(Calendar.MINUTE,
                            diffGmtCal.get(Calendar.MINUTE) - diff_minute);
                }

                rtnDate = String.valueOf(diffGmtCal.get(Calendar.YEAR))
                        + (diffGmtCal.get(Calendar.MONTH) + 1 < 10 ? "0"
                        + String.valueOf(diffGmtCal.get(Calendar.MONTH) + 1)
                        : String.valueOf(diffGmtCal.get(Calendar.MONTH) + 1))
                        + (diffGmtCal.get(Calendar.DAY_OF_MONTH) < 10 ? "0"
                        + String.valueOf(diffGmtCal
                        .get(Calendar.DAY_OF_MONTH)) : String
                        .valueOf(diffGmtCal.get(Calendar.DAY_OF_MONTH)));

                rtnDate += " "
                        + (diffGmtCal.get(Calendar.HOUR_OF_DAY) < 10 ? "0"
                        + String.valueOf(diffGmtCal
                        .get(Calendar.HOUR_OF_DAY)) : String
                        .valueOf(diffGmtCal.get(Calendar.HOUR_OF_DAY)))
                        + ":"
                        + (diffGmtCal.get(Calendar.MINUTE) < 10 ? "0"
                        + String.valueOf(diffGmtCal
                        .get(Calendar.MINUTE)) : String
                        .valueOf(diffGmtCal.get(Calendar.MINUTE)))
                        + ":"
                        + (diffGmtCal.get(Calendar.SECOND) < 10 ? "0"
                        + String.valueOf(diffGmtCal
                        .get(Calendar.SECOND)) : String
                        .valueOf(diffGmtCal.get(Calendar.SECOND)));

            }
        }
        return rtnDate;
    }


    /**
     * 현재 날짜를 기준으로 반환받을 데이터의 앞, 뒤를 지정
     */
    public static String getYearCombo(int from, int to) throws Exception {
        List<Map<String, Object>> dateCombo = new ArrayList<Map<String, Object>>();
        Map<String, Object> dataMap;

        if (from == 0) {
            from = Integer.parseInt(EverDate.getYear());
        } else {
            from = Integer.parseInt(EverDate.getYear()) - from;
        }

        if (to == 0) {
            to = Integer.parseInt(EverDate.getYear());
        } else {
            to = Integer.parseInt(EverDate.getYear()) + to;
        }

        for (int i = from; i <= to; i++) {
            dataMap = new HashMap<String, Object>();

            dataMap.put("text", i);
            dataMap.put("value", i);

            dateCombo.add(dataMap);
        }

        // String dateString = new ObjectMapper().writeValueAsString(dateCombo);

        return EverConverter.getJsonString(dateCombo);
    }

}