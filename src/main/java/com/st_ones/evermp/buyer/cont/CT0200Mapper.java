package com.st_ones.evermp.buyer.cont;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
@Repository
public interface CT0200Mapper {
    Map<String, String> ecob0040_getBundleContractInfo(Map<String, String> param);

    List<Map<String, Object>> ecob0040_doSearchAdditionalForm(Map<String, String> param);

    List<Map<String, Object>> becm080_getVendorListForBundleContract(Map<String, Object> formData);

    String becm080_getDeptCodeByDeptName(@Param("belongDeptNm") String belongDeptNm);

    List<Map<String, Object>> ecob0040_getSavedVendorListForBundleContract(Map<String, String> param);

    List<Map<String, String>> ecob0040_getBundleContInfo(Map<String, String> param);

    List<Map<String, Object>> basicContSearch(Map<String, Object> param);

    public void syncFileAttach(Map<String, String> param);
}
