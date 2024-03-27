package com.st_ones.eversrm.system.auth;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * <pre>
 * *****************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 * *****************************************************************************
 * </pre>
 *
 * @author 김경지
 * @version 1.0
 * @File Name : BSYA01_Mapper.java
 * @date 2017. 08. 29.
 * @see
 */
@Repository
public interface BSYA01_Mapper {

    List<Map<String, Object>> doSearch_UserList(Map<String, String> param);

    List<Map<String, Object>> doSearch_CtrlList(Map<String, String> param);

    List<Map<String, Object>> doSearch_ButtonList(Map<String, String> param);

    List<Map<String, Object>> doSearch_menuTree(Map<String, String> param);

    List<Map<String, Object>> doSearch_Menu_UserList(Map<String, String> parm);

    List<Map<String, Object>> doSearch_Menu_CtrlList(Map<String, String> parm);

    List<Map<String, Object>> doSearch_Button_UserList(Map<String, String> parm);

    List<Map<String, Object>> doSearch_Button_CtrlList(Map<String, String> parm);

    int doSave_Button_Auth(Map<String, Object> gridData);

    int doDelete_Button_Auth(Map<String, Object> gridData);

    int doDelete_Menu_Auth(Map<String, String> param);

    int doSave_Menu_Auth(Map<String, Object> gridData);

    int doSaveHistory_Menu_Auth(Map<String, Object> gridData);

    int doSaveHistory_Button_Auth(Map<String, Object> gridData);

    List<Map<String, Object>> doSearch_MenuHistory(Map<String, String> param);
    List<Map<String, Object>> doSearch_ButtonHistory(Map<String, String> param);


}
