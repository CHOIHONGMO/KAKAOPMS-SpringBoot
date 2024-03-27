package com.st_ones.eversrm.system.popup.service;

import com.st_ones.common.cache.data.CmpcComboCache;
import com.st_ones.common.cache.data.CmpcPopupCache;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.eversrm.system.popup.BSYP_Mapper;
import jakarta.transaction.TransactionRolledbackException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 * @File Name : BSYP_Service.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Service(value = "bsyp_Service")
public class BSYP_Service extends BaseService {

	@Autowired private MessageService msg;
	@Autowired private BSYP_Mapper bsyp_mapper;
	@Autowired private CmpcPopupCache cmpcPopupCache;
	@Autowired private CmpcComboCache cmpcComboCache;

	@AuthorityIgnore
	public Map<String, String> getComboDetailInfo(Map<String, String> param) {
		return bsyp_mapper.getComboDetailInfo(param);
	}

	@AuthorityIgnore
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveCommonCodeSql(Map<String, String> param) throws Exception {

        param.put("SQL_TEXT", EverString.rePreventSqlInjection(param.get("SQL_TEXT")));

		int chk = bsyp_mapper.checkCommonCodeSql(param);
		/* This parameter is use for sync of each database server. */
		param.put("TABLE_NM", "STOCCMPC");

		if (chk > 0) {
			bsyp_mapper.updateCommonCodeSql(param);
			removeCache(param.get("COMMON_ID"));
		} else {
			bsyp_mapper.insertCommonCodeSql(param);
		}

//		cmpcPopupCache.removeData(param.get("COMMON_ID"));
//		cmpcComboCache.removeData(param.get("COMMON_ID"));

		return msg.getMessage("0001");
	}

	private void removeCache(String commonId) {
		getLog().info("Removing Cache: " + commonId);

//		STOCCMPCComboCache.removeData(commonId);
//		STOCCMPCPopupCache.removeData(commonId);
	}

	@AuthorityIgnore
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String  doDeleteCommonCodeSql(Map<String, String> param) throws Exception {
		/* This parameter is use for sync of each database server. */
		param.put("TABLE_NM", "STOCCMPC");
		//param.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));
		bsyp_mapper.deleteCommonCodeSql(param);
		removeCache(param.get("COMMON_ID"));

		return msg.getMessage("0017");
	}

	@AuthorityIgnore
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = TransactionRolledbackException.class)
	public void doVerifyCommonCodeSql(Map<String, String> param) throws Exception {
		bsyp_mapper.verifyCommonCodeSql(param);
		throw new TransactionRolledbackException("it should be rollback!");
	}

	@AuthorityIgnore
	public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception {
		return bsyp_mapper.getComboList(param);
	}
}