package com.st_ones.common.mybatis;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : BooleanTypeHandler.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@MappedJdbcTypes(JdbcType.VARCHAR)
public class BooleanTypeHandler extends BaseTypeHandler<Boolean> {
	private static final String TRUE = "1";
	private static final String FALSE = "0";

	private Boolean stringToBoolean(String value) {
        return TRUE.equals(value);
    }

	private String booleanToString(Boolean bool) {
		if (bool) {
			return TRUE;
		}
		return FALSE;
	}

	@Override
	public void setNonNullParameter(PreparedStatement ps, int i, Boolean parameter, JdbcType JdbcType) throws SQLException {
		ps.setString(i, booleanToString(parameter));

	}

	@Override
	public Boolean getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
		return stringToBoolean(rs.getString(columnIndex));
	}

	@Override
	public Boolean getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
		return stringToBoolean(cs.getString(columnIndex));
	}

	@Override
	public Boolean getNullableResult(ResultSet rs, String columnName) throws SQLException {
		return stringToBoolean(rs.getString(columnName));
	}
}