package com.st_ones.evermp.buyer.cont;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
@Repository
public interface CT0100Mapper {
	List<Map<String, Object>> formManagementDoSearch(Map<String, String> param);

	void formManagementDoCopyCF(Map<String, Object> gridRow);

	void formManagementDoCopyCR(Map<String, Object> gridRow);

	int getCheckCnt(Map<String, Object> gridRow);

	void formManagementDoDeleteEccf(Map<String, Object> gridRow);

	void formManagementDoDeleteEccr(Map<String, Object> gridRow);

    List<Map<String, Object>> doSearchAllForms();

	void doUpdateForm(Map<String, Object> data);

    Map<String, String> getConsultationInformation(Map<String, String> formData);

	List<Map<String, Object>> doSearchMainForm(Map<String, String> param);

	List<Map<String, Object>> doSearchAdditionalForm(Map<String, String> param);

	List<Map<String, Object>> doSearchSupAttachFileInfo(Map<String, String> param);

	List<Map<String, Object>> doSearchPayInfo(Map<String, String> param);

	List<Map<String, Object>> doSearchPayInfoForERP(Map<String, String> param);

    Map<String, String> becf040_doSearch(@Param("formNum") String formNum);

    List<Map<String, Object>> becf040_doSearchECCR(Map<String, String> param);

    int becf040_doInsertForm(Map<String, String> formData);

    int becf040_doUpdateForm(Map<String, String> formData);

	void newFormRegistrationDoInsertFormData(Map<String, String> formData);

	void newFormRegistrationDoUpdateFormData(Map<String, String> formData);
	
	void newFormRegistrationDoUpdateGridData(Map<String, Object> gridRow);
	
	void newFormRegistrationDoDeleteGridData(Map<String, Object> gridRow);
	
	int newFormRegistrationGetExistCount(Map<String, Object> gridRow);
	
	void newFormRegistrationDoInsertGridData(Map<String, Object> gridRow);
	
	Map<String, String> newFormRegistrationGetFormData(Map<String, String> formData);
	
	List<Map<String, Object>> newFormRegistrationGetGridData(Map<String, String> param);

}
