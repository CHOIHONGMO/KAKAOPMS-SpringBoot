package com.st_ones.evermp.OD02;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface OD0204_Mapper {

	List<Map<String, Object>> od0204_doSearch(Map<String, String> param);

	public void od0204_doCreateUIVHD(Map<String, Object> map);

	public void od0204_doCreateUIVDT(Map<String, Object> map);

	public Map<String, Object> getPoQtySumInvQty(Map<String, Object> map);

	public void od0204_doUpdateUPODT(Map<String, Object> map);

	public void od0204_doUpdateYPODT(Map<String, Object> map);

	public void od0204_doinsertMMRS(Map<String, Object> reqMap);

	String checkProgressCd(Map<String, Object> gridData);

	void doConfirmRejectUpo(Map<String, Object> gridData);

	void doConfirmRejectYpo(Map<String, Object> gridData);

	int chkInvPo(Map<String, Object> map);

	void setUPoClose(Map<String, Object> gridData);

	void setYPoClose(Map<String, Object> gridData);

}
