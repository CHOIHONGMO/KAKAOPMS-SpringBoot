package com.st_ones.common.login.domain;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : LoginSearch.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

public class LoginSearch {

	private String gateCd;
	private String userId;
	private String password;
	private String userType;
	private String ssoUserId;
	private String ssoFlag;
	private String userR; // 공인인증서 Login을 위한 Key
	private String irsNum;
	private String residentNo;
	private String companyType;
	private String langCd;
	private String isDev;
	private String ipAddress;
	private String sessionChange;
	private String databaseCd;
	private String gmtDefault;
	private boolean isCertLogin;    // 공인인증서 로그인 여부
	private String checkUserMonth;  //공인인증서 인증완료 여부
	private String mUserId;

	public String getGateCd() {
		return gateCd;
	}

	public void setGateCd(String gateCd) {
		this.gateCd = gateCd;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String _userId) {
		this.userId = _userId;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String _password) {
		this.password = _password;
	}

	public String getUserType() {
		return userType;
	}
	
	public void setUserType(String _userType) {
		this.userType = _userType;
	}

	public String getSsoUserId() {
		return ssoUserId;
	}

	public void setSsoUserId(String _ssoUserId) {
		this.ssoUserId = _ssoUserId;
	}

	public String getSsoFlag() {
		return ssoFlag;
	}

	public void setSsoFlag(String _ssoFlag) {
		this.ssoFlag = _ssoFlag;
	}

	public String getUserR() {
		return userR;
	}

	public void setUserR(String _userR) {
		this.userR = _userR;
	}

	public String getIrsNum() {
		return irsNum;
	}

	public void setIrsNum(String _irsNum) {
		this.irsNum = _irsNum;
	}

	public String getResidentNo() {
		return residentNo;
	}

	public void setResidentNo(String _residentNo) {
		this.residentNo = _residentNo;
	}

	public String getCompanyType() {
		return companyType;
	}

	public void setCompanyType(String _companyType) {
		this.companyType = _companyType;
	}

	public String getLangCd() {
		return langCd;
	}
	
	public void setLangCd(String langCd) {
		this.langCd = langCd;
	}

	public String getIsDev() {
		return isDev;
	}
	
	public void setIsDev(String isDev) {
		this.isDev = isDev;
	}

	public String getIpAddress() {
		return ipAddress;
	}

	public void setIpAddress(String ipAddress) {
		this.ipAddress = ipAddress;
	}

	public String getSessionChange() {
		return sessionChange;
	}

	public void setSessionChange(String sessionChange) {
		this.sessionChange = sessionChange;
	}
	
	public String getDatabaseCd() {
		return databaseCd;
	}

	public void setDatabaseCd(String databaseCd) {
		this.databaseCd = databaseCd;
	}

	public String getGmtDefault() {
		return gmtDefault;
	}
	
	public void setGmtDefault(String gmtDefault) {
		this.gmtDefault = gmtDefault;
	}

    public boolean isCertLogin() { return isCertLogin; }

    public void setCertLogin(boolean isCertLogin) { this.isCertLogin = isCertLogin; }

	public String getCheckUserMonth() {
		return checkUserMonth;
	}

	public void setCheckUserMonth(String checkUserMonth) {
		this.checkUserMonth = checkUserMonth;
	}

	public String getmUserId() { return mUserId; }

	public void setmUserId(String mUserId) { this.mUserId = mUserId; }
}