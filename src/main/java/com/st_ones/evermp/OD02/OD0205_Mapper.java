package com.st_ones.evermp.OD02;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface OD0205_Mapper {

/*---조회-------------------------------------------------------------------------------------------*/

	List<Map<String, Object>> od0205_doSearch(Map<String, String> param);

/*---납품완료------------------------------------------------------------------------------------------*/

	void OD0205_doCompleteUIVDT(Map<String, Object> gridData);

/*---납품취소----------------------------------------------------------------------------------------*/


	void OD0205_doCancelUIVDT(Map<String, Object> gridData);


/*---납품수정----------------------------------------------------------------------------------------*/

	void od0205_doUpdateUIVHD(Map<String, Object> gridData);

	void od0205_doUpdateUIVDT(Map<String, Object> gridData);

	void od0205_doUpdateUPODT(Map<String, Object> gridData);

	void od0205_doUpdateYPODT(Map<String, Object> gridData);

	void od0205_doUpdateMMRS(Map<String, Object> gridData);

	int chkGidt(Map<String, Object> gridData);

	int chkUivdt(Map<String, Object> gridData);

/*---납품삭제----------------------------------------------------------------------------------------*/

	void od0205_doDeleteUIVDT(Map<String, Object> gridData);

	void od0205_doDeleteUPODT(Map<String, Object> gridData);

	void od0205_doDeleteYPODT(Map<String, Object> gridData);

	void od0205_doDeleteIMMRS(Map<String, Object> gridData);

/*---메일발송----------------------------------------------------------------------------------------*/

	Map<String, Object> getInvChangeHeaderInfo(Map<String, Object> param);

	List<Map<String, Object>> getInvChangeDetailInfo(Map<String, Object> param);









	String chkIV(Map<String, Object> gridData);





}
