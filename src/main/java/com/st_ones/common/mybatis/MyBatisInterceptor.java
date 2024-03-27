package com.st_ones.common.mybatis;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import org.apache.commons.lang3.StringUtils;
import org.apache.ibatis.executor.Executor;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.plugin.*;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.RowBounds;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StopWatch;

import java.util.*;

/**
 * <pre>
 * *****************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 * *****************************************************************************
 * </pre>
 *
 * @author Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @version 1.0
 * @File Name : MyBatisInterceptor.java
 * @date 2013. 07. 22.
 * @see
 */
@Intercepts({
        @Signature(type = Executor.class, method = "query",
                args = {MappedStatement.class, Object.class, RowBounds.class, ResultHandler.class}),
        @Signature(type = Executor.class, method = "update",
                args = {MappedStatement.class, Object.class})})
public class MyBatisInterceptor implements Interceptor {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    public Object intercept(final Invocation invoca) throws Exception {

        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        if (isDuplicated(stackTrace)) {
            return invoca.proceed();
        }
        Object[] arguments = invoca.getArgs();
        MappedStatement mappedStatement = (MappedStatement) arguments[0];

        try {
            if (arguments[1] == null) {
                Map<String, String> map = new HashMap<String, String>();
                arguments[1] = map;
            }
            if (arguments[1] instanceof String) {

                Map<String, String> map = new HashMap<String, String>();
                map.put("value", (String) arguments[1]);
                arguments[1] = map;
            }
            if (arguments[1] instanceof Map) {
                Iterator<String> mapItor = ((Map<String, Object>) arguments[1]).keySet().iterator();
                while (mapItor.hasNext()) {

                    String keyVal = mapItor.next();
                    if (((Map<String, Object>) arguments[1]).get(keyVal) instanceof String) {

                        String tmpVal = (String) ((Map<String, Object>) arguments[1]).get(keyVal);
                        if (keyVal.trim().indexOf("DATE") > -1) {
                            tmpVal = EverString.nullToEmptyString(tmpVal).replaceAll("/", "");
                        }
                    }
                }
                addSessionInfo((Map<String, Object>) arguments[1]);
            }
        } catch (UserInfoNotFoundException e) {
            logger.error(e.getMessage(), e);
        }

        int resultCount = -1;
        Object obj;

        StopWatch stopWatch = new StopWatch("myBatis Load Time");
        try {
            stopWatch.start("Query Execution start");
            obj = invoca.proceed();
            stopWatch.stop();

            if (obj != null) {
                if (obj instanceof Integer) {
                    resultCount = (Integer) obj;
                } else if (obj instanceof List) {
                    List dataList = (List) obj;
                    resultCount = dataList.size();
                }
            }

        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            stopWatch.stop();
            throw e;
        } finally {

//            try {
//                sqlLogging(mappedStatement, arguments[1], stopWatch, resultCount);
//            } catch (Exception e) {
//                logger.error(e.getMessage(), e);
//            }

            if (arguments[1] instanceof Map) {
                ((Map<String, Object>) arguments[1]).remove("ses");
                ((Map<String, Object>) arguments[1]).remove("eversrm");
            }
        }

        return obj;
    }

    private boolean isDuplicated(StackTraceElement[] stackTrace) {
        int intercepCount = 0;
        String interceptorClassName = this.getClass().getName();
        for (StackTraceElement e : stackTrace) {
            if (e.getClassName().equals(interceptorClassName)) {
                intercepCount++;
            }
        }
        return intercepCount != 1;
    }

    private void addSessionInfo(final Map<String, Object> map) throws Exception {

        String exclusion = null;
        if (map.containsKey("exclusion")) {
            exclusion = EverString.isEmpty((String) map.get("exclusion")) ? "false" : (String) map.get("exclusion");
        }
        if (exclusion == null || !exclusion.equals("true")) {
            map.putAll(EverConverter.forDynamicQuery(map));
        }

        if (StringUtils.isEmpty(UserInfoManager.getUserInfo().getUserId())) {

            UserInfo baseInfo = new UserInfo();
            baseInfo.setGateCd(PropertiesManager.getString("eversrm.gateCd.default"));
            baseInfo.setLangCd(PropertiesManager.getString("eversrm.langCd.default"));
            baseInfo.setDatabaseCd(PropertiesManager.getString("eversrm.system.database"));
            baseInfo.setUserGmt(PropertiesManager.getString("eversrm.gmt.default"));
            baseInfo.setSystemGmt(PropertiesManager.getString("eversrm.gmt.default"));

            map.put("ses", baseInfo);
        } else {
            map.put("ses", UserInfoManager.getUserInfo());
        }

        Map<String, String> systemPropMap = new HashMap<String, String>();
        Map<String, String> props = PropertiesManager.getPropertiesAsMap();
        Iterator<String> it = props.keySet().iterator();
        while (it.hasNext()) {
            String key = it.next();
            systemPropMap.put(StringUtils.replace(key, "eversrm.system.", ""), props.get(key));
        }
        map.put("eversrm", systemPropMap);

//        logger.info("addSessionInfo: {}", map.get("ses"));
    }

    private void sqlLogging(MappedStatement mappedStatement, Object parameters, StopWatch stopWatch, int resultCount) throws Exception {

        if (!isSqlLogging(mappedStatement)) {
            return;
        }

        BoundSql boundSql = mappedStatement.getBoundSql(parameters);
        EverSqlLogger everSqlLogger = new EverSqlLogger(mappedStatement.getId(), boundSql.getSql(), parameters);
        everSqlLogger.logging(boundSql, stopWatch, resultCount);
    }

    /**
     * 메뉴 쿼리, 공통팝업 sql 로그등 공통 sql에 대한 로그를 출력할 것인지
     * false : 미출력, true : 출력
     *
     * @param mappedStatement
     * @return
     */
    private boolean isSqlLogging(MappedStatement mappedStatement) {

        try {
            boolean commonSqlLogging = PropertiesManager.getBoolean("eversrm.system.common.sql.logging");
            if (!commonSqlLogging && mappedStatement.getId().indexOf("com.st_ones.common") != -1) {
                return false;
            }
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
        return true;
    }

    public Object plugin(final Object target) {
        return Plugin.wrap(target, this);
    }

    public void setProperties(final Properties properties) {
//        logger.info("Calling setProperties():"+properties.propertyNames().toString());
    }
}