package com.st_ones.common.code.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 12. 22 오전 9:42
 */

import com.st_ones.common.cache.data.CodeCache;
import com.st_ones.common.code.CodeMapper;
import com.st_ones.common.config.service.EverConfigService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "codeService")
public class CodeService extends BaseService {

	private static final String EVER_DBLINK = "ever.remote.database.link.name";

	/* @formatter:off */
	@Autowired private MessageService msg;
	@Autowired private CodeMapper codeMapper;
	@Autowired private CodeCache codeCache;
	/* @formatter:on */

	Logger logger = LoggerFactory.getLogger(this.getClass());

	@Autowired
	private EverConfigService everConfigService;

	public List<Map<String, Object>> doSearchHD(Map<String, String> param) throws Exception {
		return codeMapper.doSearchHD(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveHD(List<Map<String, Object>> gridDatas) throws Exception {

		Map<String, Object> param = new HashMap<String, Object>();
		String newKey = codeMapper.getNewKey(param);

		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("CODE_TYPE", EverString.isEmpty(gridData.get("CODE_TYPE").toString()) ? newKey : gridData.get("CODE_TYPE"));

			int checkCnt = codeMapper.checkHDData(gridData);
			// checkCnt = 0 : new Insert, checkCnt = 1 : Update, checkCnt = 2 : Select Insert

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCCODH");
			//gridData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

			if (checkCnt == 0) {
				codeMapper.doInsertHD(gridData);
			} else if (checkCnt == 1) {
				codeMapper.doUpdateHD(gridData);
				codeCache.refreshData((String)gridData.get("CODE_TYPE"), (String)gridData.get("LANG_CD"));
			} else if (checkCnt == 2) {
				int transCnt = codeMapper.doSelectInsertHD(gridData);
				if (transCnt < 1) {
					throw new NoResultException(msg.getMessageForService(this, "exception_msg"));
				}
			}
		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteHD(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCCODH");
			//gridData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));
			codeMapper.doDeleteHD(gridData);

			gridData.put("TABLE_NM", "STOCCODD");
			//gridData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));
			codeMapper.doDeleteDT(gridData);

			codeCache.refreshData((String)gridData.get("CODE_TYPE"), (String)gridData.get("LANG_CD"));

		}

		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> doSearchDT(Map<String, String> param) throws Exception {
		return codeMapper.doSearchDT(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveDT(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			if (codeMapper.checkConstraintR31(gridData) == 0) {
				throw new NoResultException(msg.getMessageForService(this, "exception_msg"));
			}

			int checkCnt = codeMapper.checkDTData(gridData);

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCCODD");
			//gridData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

			// checkCnt = 0 : new Insert, checkCnt = 1 : Update, checkCnt = 2 : Select Insert
			if (checkCnt == 0) {
				codeMapper.doInsertDT(gridData);
				codeCache.refreshData((String)gridData.get("CODE_TYPE"), (String)gridData.get("LANG_CD"));
			} else if (checkCnt == 1) {
				codeMapper.doUpdateDT(gridData);
				codeCache.refreshData((String)gridData.get("CODE_TYPE"), (String)gridData.get("LANG_CD"));
			} else if (checkCnt == 2) {
				int transCnt = codeMapper.doSelectInsertDT(gridData);
				codeCache.refreshData((String)gridData.get("CODE_TYPE"), (String)gridData.get("LANG_CD"));
				if (transCnt < 1) {
					throw new NoResultException(msg.getMessageForService(this, "exception_msg"));
				}
			}
		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteDT(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCCODD");
			//gridData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

			codeMapper.doDeleteDT(gridData);
			codeCache.refreshData((String)gridData.get("CODE_TYPE"), (String)gridData.get("LANG_CD"));

		}

		return msg.getMessage("0017");
	}

	@AuthorityIgnore
	public List<Map<String, String>> getCODEByCodeType(String codeType, String langCode) {
		return codeCache.getData(codeType, langCode);
	}

	@AuthorityIgnore
	public List<Map<String, String>> getCODEByCodeType(String codeType, String[] columnIds) throws UserInfoNotFoundException {

		String langCd = UserInfoManager.getUserInfo().getLangCd();
		List<Map<String, String>> codeByCodeType = getCODEByCodeType(codeType, langCd);
		List<Map<String, String>> list = new ArrayList<Map<String, String>>();
		for (Map<String, String> icomCode : codeByCodeType) {
			Map<String, String> map = new HashMap<String, String>();
			for (String columnId : columnIds) {
				map.put(columnId, icomCode.get(columnId));
			}
			list.add(map);
		}
		return list;
	}

	@AuthorityIgnore
	public String getCodeValue(String codeType, String code) throws Exception {

		String langCd = UserInfoManager.getUserInfo().getLangCd();
		List<Map<String, String>> codes = getCODEByCodeType(codeType, langCd);
		for (Map<String, String> map : codes) {
			if (map.get("CODE").equals(code)) {
				return map.get("CODE_DESC");
			}
		}
		logger.error(String.format("code value is not exist. codeType: %s, cd: %s", codeType, code));
		return null;
	}

	public List<Map<String, Object>> doSearchByStreet1(Map<String, String> param) throws Exception {
		return codeMapper.doSearchByStreet1(param);
	}

	public List<Map<String, Object>> doSearchByStreet2(Map<String, String> param) throws Exception {
		return codeMapper.doSearchByStreet2(param);
	}

	public List<Map<String, Object>> doSearchByStreet3(Map<String, String> param) throws Exception {
		return codeMapper.doSearchByStreet3(param);
	}

	public List<Map<String, Object>> doSearchByDistrict(Map<String, String> param) throws Exception {
		return codeMapper.doSearchByDistrict(param);
	}

}