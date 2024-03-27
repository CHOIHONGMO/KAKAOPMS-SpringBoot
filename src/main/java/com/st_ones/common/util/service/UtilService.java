package com.st_ones.common.util.service;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.UtilMapper;
import com.st_ones.everf.serverside.exception.SystemPropertyNotFoundException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.code.service.BSYC_Service;
import org.apache.ibatis.mapping.VendorDatabaseIdProvider;
import org.mybatis.spring.MyBatisSystemException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : UtilService.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Service
public class UtilService extends BaseService {

	@Autowired
	public UtilMapper utilMapper;

	@Autowired
	public BSYC_Service bsyc_Service;

	@Autowired
	VendorDatabaseIdProvider databaseIdProvider;

	@Autowired
	DataSource dataSource;

	private String databaseId = null;

	public List<Map<String, Object>> getItemSearchByCode(Map<String, String> param) throws Exception {
		return utilMapper.getItemSearchByCode(param);
	}

	public List<Map<String, Object>> getVendorSearchByCode(Map<String, String> param) throws Exception {
		return utilMapper.getVendorSearchByCode(param);
	}

	public String getUserDateFormat(String codeType) throws Exception {
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		return bsyc_Service.getCodeValue(codeType, baseInfo.getDateFormat());
	}

	@Transactional(propagation = Propagation.NESTED, rollbackFor = Exception.class)
	public void logForJob(String methodName, String moduleName, String screenId, String actionCode, String jobDesc, String jobType, String userId, String ipAddress, String failType, String userType) {
		try {
			utilMapper.setLogForJob(methodName, moduleName, screenId, actionCode, jobDesc, jobType, userId, ipAddress, failType, userType);
		} catch(MyBatisSystemException e) {
			getLog().error(e.getMessage());
		}
	}

	public List<Map<String, String>> getCheckCnt(String packageName) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		param.put("PACKAGE_NM", packageName);
		return utilMapper.getCheckCnt(param);
	}

	public String getDatabaseId(){
		if(databaseId == null) databaseId = databaseIdProvider.getDatabaseId(dataSource);
        return databaseId;
	}

	public String getDatabaseCode() {

//		getLog().info("{}", getDatabaseId());

		if("oracle".equals(getDatabaseId())) return "OR";
		if("mssql".equals(getDatabaseId()))  return "MS";
		if("mysql".equals(getDatabaseId()))  return "MY";
		if("postgresql".equals(getDatabaseId())) return "PS";
		throw new SystemPropertyNotFoundException("illegal database id. this value has been set by context persistence VendorDatabaseIdProvider bean. databaseId: " + databaseId);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String menuClickSave(Map<String, String> data) throws Exception {
		utilMapper.menuClickSave(data);
		return "";
	}

	public void logForPJob(Map formData) throws Exception{
		utilMapper.setLogForPJob(formData);
	}
}