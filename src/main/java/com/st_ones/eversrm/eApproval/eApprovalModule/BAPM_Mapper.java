package com.st_ones.eversrm.eApproval.eApprovalModule;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : BAPM_Mapper.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Repository
public interface BAPM_Mapper {

    List<Map<String, Object>> selectPath(Map<String, String> param);

    String getPathNo(Map<String, String> param);

    void insertPath(Map<String, String> gridData);

    void updatePath(Map<String, String> gridData);

    void deletePath(Map<String, Object> gridData);

    List<Map<String, Object>> selectPathDetail(Map<String, String> param);

    void insertPathDetail(Map<String, Object> gridData);

    void deletePathDetail(Map<String, Object> gridData);

    void deleteLULP(Map<String, String> gridData);

    List<Map<String, Object>> selectPathPopup(Map<String, String> param);

    Map<String, String> getUserInfoByName(HashMap<String, String> hashMap);

    int matchUserCountByName(HashMap<String, String> hashMap);

    List<String> selectSTOCSCTPSignStatusHistory(Map<String, String> docInfo);

    void insertSTOCSCTM(Map<String, String> approvalHeader);

    void insertSTOCSCTP(Map<String, String> approvalDetail);

    void executeBlossom(Map<String, Object> blsmMap);

    void doUpdateApprovalRequest(Map<String, Object> blsmMap);

    List<Map<String, String>> getCCuserList(Map<String, String> param);

    Map<String, String> selectSTOCSCTM(Map<String, String> approvalInfoKey);

    Map<String, String> selectSTOCSCTM(@Param("APP_DOC_NUM") String appDocNo, @Param("APP_DOC_CNT") String appDocCnt);

    List<Map<String, Object>> selectSTOCSCTP(Map<String, String> formData);

    int getAuthorizedCount(Map<String, String> approvalInfoKey);

    String selectMySignStatus(Map<String, String> formDataParam);

    void updateSTOCSCTP(Map<String, String> formData);

    int getNextSignUserCnt(Map<String, String> formData);

    List<Map<String, Object>> getNextSignUserId(Map<String, String> formData);

    void setNextUser(Map<String, String> formData);

    void updateSTOCSCTM(Map<String, String> formData);

    String getNextSignPathSeq(Map<String, String> formData);

    String getUpdateFlag(Map<String, String> param);

    void updateReadDate(Map<String, String> formData);

    List<Map<String, Object>> getMyPath(HashMap<String, String> hashMap);

    List<Map<String, String>> selectLULP(HashMap<String, String> approvalPathKey);

    int isCancellable(Map<String, String> map);

    String getCurrentDocCount(Map<String, String> approvalInfoKey);

    void deleteSCTM(Map<String, String> appDocNo);

    void deleteSCTP(Map<String, String> appDocNo);

    Map<String, String> selectPathDetail1(Map<String, String> param);

    void updateInterfaceFlag(Map<String, String> map);

    void bapp053_deleteSCTP(Map<String, String> map);
    void bapp053_insertSCTP(Map<String, Object> map);

	void updateBeforGwSTOCSCTM(Map<String, String> param);

	int elctRequiedCheck(Map<String, String> param);
}