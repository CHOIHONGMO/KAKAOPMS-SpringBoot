package com.st_ones.nosession.supplier;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface SupplierMapper {

    List<Map<String, Object>> getUserBACP(Map<String, String> param);
    
    // 공급사 유효성 체크
    Map<String, String> doIrsNumCheck(Map<String, String> param);
    
    // 고객사 유효성 체크
    Map<String, String> doIrsNumCheckCust(Map<String, String> param);

    Map<String, String> vendorIdSearch(Map<String, String> param);

    Map<String, String> doPwInfo(Map<String, String> param);

    void doUpdateCVUR(Map<String, String> param);

    void doUpdateUSER(Map<String, String> param);

    Map<String, String> operIdSearch(Map<String, String> param);

    Map<String, String> custIdSearch(Map<String, String> param);
}
