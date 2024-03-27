package com.st_ones.eversrm;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface DashboardMapper {

	// Buyer
    String summary01(Map<String, String> param);
    String summary02(Map<String, String> param);
    String summary03(Map<String, String> param);
    String summary04(Map<String, String> param);
    String summary05(Map<String, String> param);
    String summary06(Map<String, String> param);
    String summary07(Map<String, String> param);
    String summary08(Map<String, String> param);
    String summary09(Map<String, String> param);
    String summary10(Map<String, String> param);
    String summary11(Map<String, String> param);
    String summary12(Map<String, String> param);
    String summary13(Map<String, String> param);
    String summary14(Map<String, String> param);
    String summary15(Map<String, String> param);
    String summary16(Map<String, String> param);

    // Vendor
    String summary17(Map<String, String> param);
    String summary18(Map<String, String> param);
    String summary19(Map<String, String> param);
    String summary20(Map<String, String> param);
    String summary21(Map<String, String> param);
    String summary22(Map<String, String> param);
    String summary23(Map<String, String> param);
    String summary24(Map<String, String> param);
    String summary25(Map<String, String> param);
    String summary26(Map<String, String> param);
    String summary27(Map<String, String> param);
    String summary31(Map<String, String> param);
    String summary32(Map<String, String> param);
    String summary33(Map<String, String> param);
    String summary34(Map<String, String> param);
    String summary35(Map<String, String> param);

    List<Map<String, Object>> doNotice(Map<String, String> param);
    List<Map<String, Object>> doFaq(Map<String, String> param);
    List<Map<String, Object>> doQna(Map<String, String> param);
    List<Map<String, Object>> doNewgrid(Map<String, String> param);
    List<Map<String, Object>> doBggrid(Map<String, String> param);
    List<Map<String, Object>> doMygrid(Map<String, String> param);

    String getVendorType(Map<String, String> param);

    Map<String, String> mypageTypeB(Map<String, String> param);

    Map<String, String> mypageTypeS(Map<String, String> param);

    Map<String, String> getSalesDataS(Map<String, String> param);

    Map<String, String> mypageTypeC(Map<String, String> param);

    List<Map<String, String>> getItemClsList(Map<String, String> param);
    List<Map<String, String>> getNoitceListMain(Map<String, String> param);
    List<Map<String, String>> getVoiceListMain(Map<String, String> param);

    String getMyScreenId(Map<String, Object> param);

    List<Map<String, Object>> doOpGrid1(Map<String, String> param);
    List<Map<String, Object>> doOpGrid2(Map<String, String> param);
    List<Map<String, Object>> doOpGrid3(Map<String, String> param);
    List<Map<String, Object>> doOpGrid3_1(Map<String, String> param);
    List<Map<String, Object>> doOpGrid3_2(Map<String, String> param);
    List<Map<String, Object>> doOpGrid4(Map<String, String> param);
    List<Map<String, Object>> doOpGrid5(Map<String, String> param);
    List<Map<String, Object>> doOpGrid6(Map<String, String> param);
    List<Map<String, Object>> doOpGrid7(Map<String, String> param);
}
