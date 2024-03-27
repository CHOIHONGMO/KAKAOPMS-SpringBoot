package com.st_ones.common.combo;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 11. 20 오후 3:28
 */

import com.st_ones.common.util.clazz.EverString;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.ParameterMapping;
import org.apache.ibatis.mapping.SqlSource;
import org.apache.ibatis.scripting.xmltags.XMLLanguageDriver;
import org.apache.ibatis.session.Configuration;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service(value = "sqlBuilder")
public class SqlBuilder {

    public String getSql(Map<String, Object> param) {

        BoundSql boundSql;
        Configuration configuration = (Configuration)param.get("configuration");
        SqlSource sqlQuery_ = new XMLLanguageDriver().createSqlSource(configuration, "<script>"+param.get("_sqlQuery_")+"</script>", Map.class);

        Map<String, String> param1 = (Map<String, String>)param.get("param");
        boundSql = sqlQuery_.getBoundSql(param1);

        StringBuilder sql = new StringBuilder(boundSql.getSql());
        for (ParameterMapping pm : boundSql.getParameterMappings()) {
            String property = pm.getProperty();
            int index = sql.indexOf("?");
            sql.replace(index, index + 1, "'" + EverString.CheckInjection(param1.get(property)) + "'");
        }

        return sql.toString();
    }
}
