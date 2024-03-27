package com.st_ones.common.cache.data;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : CacheUtil.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Service(value = "cacheUtil")
public class CacheUtil {

	@Autowired CodeCache codeCache;
	@Autowired MessageCache messageCache;
	@Autowired ScrnCache scrnCache;
	@Autowired FormInfoCache formInfoCache;
	@Autowired SystCache systCache;
	@Autowired CmpcComboCache cmpcComboCache;
	@Autowired CmpcPopupCache cmpcPopupCache;
	@Autowired MulgPopupInfoCache mulgPopupInfoCache;
	@Autowired MulgPopupNameCache mulgPopupNameCache;
	@Autowired MulgMtCache mulgMtCache;
	@Autowired MulgSaCache mulgButtonCaptionCache;
	//	@Autowired BreadCrumbCache breadCrumbCache;
	//	@Autowired AuthorizedButtonCache authorizedButtonCache;
	@Autowired ColumnInfoCache columnInfoCache;
	@Autowired ButtonInfoCache buttonInfoCache;

	public void initCacheCode() {

		DataCacheCommon[] cacheList = {codeCache, messageCache, systCache,
				mulgButtonCaptionCache, cmpcPopupCache, mulgMtCache, scrnCache,
				cmpcComboCache, mulgPopupInfoCache, mulgPopupNameCache};

		for (DataCacheCommon cache : cacheList) {
			cache.initData();
		}

		columnInfoCache.removeAllCaches();
		buttonInfoCache.removeAllCaches();
		formInfoCache.removeAllCaches();
	}

	public void loadCacheData() throws IOException {
		UserInfo baseInfo = new UserInfo();
		baseInfo.setGateCd("100");
		UserInfoManager.createUserInfo(baseInfo);

		codeCache.loadAllData();
		codeCache.saveData();
	}
}
