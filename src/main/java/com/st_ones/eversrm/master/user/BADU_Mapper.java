package com.st_ones.eversrm.master.user;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BADU_Mapper {

	List<Map<String, Object>> doSearchUserSup(Map<String, String> param);

	List<Map<String, Object>> doSearchUser(Map<String, String> param);

	Map<String, String> doGetUser(@Param("USER_ID") String userId);

	Map<String, Object> doGetUser(Map<String, String> param);

	Map<String, Object> doGetUser_VNGL(Map<String, String> param);

	Map<String, Object> doGetEncPassword(Map<String, String> param);

	List<Map<String, Object>> doGetAcProfile(Map<String, String> param);

	List<Map<String, Object>> doGetAuProfile(Map<String, String> param);

	int existsUserInformation(Map<String, String> param);

	int createUserInformation(Map<String, String> generalForm);

	int existsUserInformation_VNGL(Map<String, String> param);

	int existsMYNUser_VNGL(Map<String, String> param);
	int existsMYNUser_CUST(Map<String, String> param);

	int createUserInformation_VNGL(Map<String, String> generalForm);

	void updateUserInformation(Map<String, String> generalForm);

	int CheckUserInfoPassWordSame(Map<String, String> generalForm);

	void updateUserInformation_VNGL(Map<String, String> generalForm);

	int CheckUserInfoPassWordSame_VNGL(Map<String, String> generalForm);

	void doResetUserInfo(Map<String, String> generalForm);

	void doSaveIssue(Map<String, String> generalForm);

	void doSaveIssue_CVUR(Map<String, String> generalForm);

	int existsUSAP(Map<String, Object> auGridData);

	void RealdeleteUSAP(Map<String, Object> auGridData);

	void createUSAP(Map<String, Object> auGridData);

	void updateUSAP(Map<String, Object> auGridData);

	void doDeleteUSAP(Map<String, String> generalForm);

	int existsUSAC(Map<String, Object> acGridData);

	void createUSAC(Map<String, Object> acGridData);

	void updateUSAC(Map<String, Object> acGridData);

	void doDeleteUSAC(Map<String, String> generalForm);

	void doDeleteUserInfo(Map<String, String> generalForm);

	void createBACP(Map<String, String> generalForm);

	List<Map<String, Object>> selectUserSearch(Map<String, String> param);

	List<Map<String, Object>> doSearchUserWorkHistory(Map<String, String> param);

	Map<String,String> getUserInfo(Map<String, String> formData);


	List<Map<String, Object>> getTmsList(Map<String, String> param);


	List<Map<String, Object>> doSearchUserCust(Map<String, String> param);

	void doResetUserInfoCVUR(Map<String, String> generalForm);

	void saveTms(Map<String, Object> generalForm);


	String chkTms(Map<String, Object> param);




}