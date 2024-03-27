package com.st_ones.evermp.BOD1;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BOD101_Mapper {


	Map<String,String> getBackMaster(Map<String, String> formData);

	String bod1010_getMgInfo(Map<String, String> formData);

	List<Map<String,Object>> bod1010_doSearch_MysiteNo(Map<String, Object> itemList);

	List<Map<String,Object>> bod1111Dosearch(Map<String, String> itemList);

	List<Map<String,Object>> bod1010_doSearch_MySiteYes(Map<String, Object> itemList);
	List<Map<String,Object>> bod1110Dosearch(Map<String, String> itemList);

	List<Map<String,Object>> bod1120Dosearch(Map<String, String> itemList);



	void doInsertUPOHD(Map<String, String> param);
	void doInsertUPODT(Map<String, Object> param);




	void doInsertYPOHD(Map<String, Object> param);
	void doInsertYPODT(Map<String, Object> param);


	void doGrSaveGRDT(Map<String, Object> param);











	void delupodt(Map<String, Object> param);
	void delypodt(Map<String, Object> param);



	void delupohd(Map<String, Object> param);
	void delypohd(Map<String, Object> param);

	// 고객사 주문상세 수정
	public void siv1020_doUpdateUPODT(Map<String, Object> map);

	// 공급사 발주상세 수정
	public void siv1020_doUpdateYPODT(Map<String, Object> map);


}