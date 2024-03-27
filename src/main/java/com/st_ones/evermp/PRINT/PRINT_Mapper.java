package com.st_ones.evermp.PRINT;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface PRINT_Mapper {
	// 거래명세서 정보
	List<Map<String, Object>> selectLANG(Map<String, Object> param);
	List<Map<String, Object>> selectIVHD(Map<String, Object> param);
	List<Map<String, Object>> selectIVDT(Map<String, Object> param);

	// 견적서 정보
	List<Map<String, Object>> selectCPOHD(Map<String, Object> param);
	List<Map<String, Object>> selectCPODT(Map<String, Object> param);

	// 발주서 정보
	List<Map<String, Object>> selectPOHD(Map<String, Object> param);
	List<Map<String, Object>> selectPODT(Map<String, Object> param);

	// 견적서(공급사용)
    List<Map<String, Object>> selectVRQHD(Map<String, Object> param);
	List<Map<String, Object>> selectVRQDT(Map<String, Object> paramMap);

	// 견적서(운영사용)
	List<Map<String, Object>> selectORQHD(Map<String, Object> param);
	List<Map<String, Object>> selectORQDT(Map<String, Object> paramMap);

	// 견적의뢰서
	List<Map<String, Object>> selectNWRQHD(Map<String, Object> reqMap);
	List<Map<String, Object>> selectNWRQDT(Map<String, Object> paramMap);

	//header정보

	List<Map<String, Object>> selectHD(Map<String, Object> param);

	// 지표관리
	List<Map<String, Object>> selectUPOHD(Map<String, Object> param);
	List<Map<String, Object>> selectUPODT(Map<String, Object> paramMap);

    List<Map<String, Object>> selectTTIH(Map<String, Object> param);














	// 견적서(운영사용)
	List<Map<String, Object>> selectOCNHD(Map<String, Object> param);
	List<Map<String, Object>> selectOCNDT(Map<String, Object> paramMap);



	List<Map<String, Object>> selectUIVDT(Map<String, Object> paramMap);
	List<Map<String, Object>> selectUIVHD(Map<String, Object> param);

	List<Map<String, Object>> selectIVDT_DGNS(Map<String, Object> paramMap);
	List<Map<String, Object>> selectIVHD_DGNS(Map<String, Object> param);





	List<Map<String, Object>> getTTIH(Map<String, Object> param);
	List<Map<String, Object>> getTTID(Map<String, Object> param);



}