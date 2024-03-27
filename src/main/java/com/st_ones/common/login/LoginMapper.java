package com.st_ones.common.login;

import com.st_ones.common.login.domain.LoginSearch;
import com.st_ones.common.login.domain.UserInfo;
import org.springframework.stereotype.Repository;

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
 * @File Name : LoginMapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Repository
public interface LoginMapper {

	String findUserId(LoginSearch loginSearch);

	String findUserIdPW(LoginSearch loginSearch);

	UserInfo getUserInfoC(LoginSearch loginSearch);

	UserInfo getUserInfoC_SSO(LoginSearch loginSearch);

	UserInfo getUserInfoB(LoginSearch loginSearch);

	UserInfo getUserInfoB_SSO(LoginSearch loginSearch);

	UserInfo getUserInfoS(LoginSearch loginSearch);

	String findUserType(Map<String, String> param);

	String checkAgree(Map<String, String> param);

	void ConfirmAgree(Map<String, String> param)throws Exception;

	void ConfirmAgree_BS(Map<String, String> param)throws Exception;

	List<Map<String, String>> getVendorUserList();
	
	void updateWrongPasswordCount(Map<String, String> userInfo);
	
	int getPasswordWrongCount(Map<String, String> userInfo);
	
	void resetPasswordWrongCount(Map<String, String> userInfo);
	
	void setLastLoginDate(Map<String, String> userInfo);

    String getUserType(Map<String, String> userInfo);

    List<Map<String,String>> getNoticeListPopup(Map<String, String> noticeInfo);

	String getSignStatus(Map<String, String> param);

	List<Map<String, String>> getmUserInfo();

	Map<String, String> getLogos();
}