package com.st_ones.common.cache;

import com.st_ones.common.generator.domain.GridMeta;
import org.apache.ibatis.annotations.Param;
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
 * @author Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @version 1.0
 * @File Name : CacheMapper.java
 * @date 2013. 07. 22.
 * @see
 */
@Repository
public interface CacheMapper {

    List<Map<String, String>> getScrnData();

    List<Map<String, String>> getMessagesByScreenId(@Param("screenId") String screenId, @Param("langCd") String langCd);

    List<Map<String, String>> getAuthorizedButtonCd(@Param("screenId") String screenId, @Param("actionAuthCd") String actionAuthCd);

    List<String> getBreadCrumbInfo(@Param("screenId") String screenId, @Param("moduleType") String moduleType, @Param("grantedAuthCd") String grantedAuthCd, @Param("langCd") String langCd);

    List<String> getBreadCrumbInfoLike(@Param("screenId") String screenId, @Param("moduleType") String moduleType, @Param("grantedAuthCd") String grantedAuthCd, @Param("langCd") String langCd);

    List<Map<String, String>> getButtonInfo(Map<String, String> param);

    List<Map<String, String>> getComCodes(Map<String, String> param);

    List<String> getAllCodeType();

    List<Map<String, String>> getFormInfo(@Param("screenId") String screenId, @Param("langCd") String langCd);

    List<GridMeta> getColumnInfos(@Param("screenId") String screenId, @Param("gridId") String gridId, @Param("langCd") String langCd);

    List<GridMeta> getBottomBarInfos(@Param("langCd") String langCd);

    String getUserCodes(@Param("commonId") String commonId, @Param("databaseCd") String databaseCd);

    Map<String, String> getCommonPopupDetailInfo(@Param("commonId") String commonId, @Param("databaseCd") String databaseCd);

    List<Map<String, String>> getMULGCommonPopupInfo(@Param("commonId") String commonId, @Param("langCd") String langCd, @Param("multiCd") String multiCd);

    List<Map<String, String>> getMULGSa(@Param("screenId") String screenId, @Param("langCd") String langCd, @Param("multiCd") String multiCd);

    String getMulgPopupName(@Param("screenId") String screenId, @Param("multiCd") String multiCd, @Param("langCd") String langCd);

    String getMulgMt(@Param("tmplMenuCd") String tmplMenuCd, @Param("langCd") String langCd, @Param("multiCd") String multiCd);

    List<Map<String, String>> getMulgMtAll(@Param("langCd") String langCd, @Param("multiCd") String multiCd);

    String getExcelDownMode(@Param("screenId") String screenId);

    Map<String, Object> getToolbarInfo(@Param("screenId") String screenId, @Param("tmplMenuCd") String tmplMenuCd);

    Map<String, String> getFullMenuNm(@Param("tmpl_menu_cd") String screenId);
}