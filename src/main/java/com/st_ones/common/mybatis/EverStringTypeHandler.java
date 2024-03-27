package com.st_ones.common.mybatis;

import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import org.apache.ibatis.type.StringTypeHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * myBatis의 resultType이 Bean 타입 등으로 되어 있고, String인 것이 명확하게 정해져 있을 때 호출되는 핸들러이다.
 */
@MappedTypes(value = {String.class})
@MappedJdbcTypes(value = {JdbcType.CHAR, JdbcType.NCHAR, JdbcType.VARCHAR, JdbcType.NVARCHAR})
public class EverStringTypeHandler extends StringTypeHandler {

    Logger logger = LoggerFactory.getLogger(this.getClass());

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, String parameter, JdbcType jdbcType) throws SQLException {
        logger.debug("setNonNullParameter: {}", parameter);
        //super.setNonNullParameter(ps, i, EverString.changeCharacterSetApp2DbString(parameter), jdbcType);
        super.setNonNullParameter(ps, i, parameter, jdbcType);
    }

    @Override
    public String getResult(ResultSet rs, String columnName) throws SQLException {
        //return EverString.changeCharacterSetDb2AppString(rs.getString(columnName));
        return rs.getString(columnName);
    }
}