package com.st_ones.common.popup.service;

import com.st_ones.common.cache.data.CmpcPopupCache;
import com.st_ones.common.cache.data.MulgPopupInfoCache;
import com.st_ones.common.generator.domain.GridMeta;
import com.st_ones.common.popup.CommonPopupMapper;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.service.BaseService;
import org.apache.commons.lang.math.NumberUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.ibatis.session.SqlSessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : BSYT_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Service(value = "commonPopupService")
public class CommonPopupService extends BaseService {

	@Autowired private SqlSessionFactory sqlSessionFactory;
	@Autowired private MulgPopupInfoCache mulgPopupInfoCache;
	@Autowired private CmpcPopupCache cmpcPopupCache;
	@Autowired private CommonPopupMapper commonPopupMapper;

	public Map<String, String> seachComboDetailInfo(String commonId) throws UserInfoNotFoundException {

		String langCd = UserInfoManager.getUserInfo().getLangCd();
		
		Map<String, String> commonPopupDetailInfo = cmpcPopupCache.getData(commonId);
		List<Map<String, String>> commonPopupInfo = mulgPopupInfoCache.getData(commonId, langCd);

		for (Map<String, String> map : commonPopupInfo) {
			commonPopupDetailInfo.put(map.get("MULTI_CD"), map.get("MULTI_NM"));
		}
		return commonPopupDetailInfo;
	}

	public List<GridMeta> getGridHeader(String commonId) throws UserInfoNotFoundException {
		
		List<GridMeta> gridMetaList = new ArrayList<GridMeta>();
		List<GridMeta> maskHiddenMetaList = new ArrayList<GridMeta>();

		Map<String, String> param = new HashMap<String, String>();
		param.put("COMMON_ID", commonId);
		param.put("DATABASE_CD", PropertiesManager.getString("eversrm.system.database"));
		List<Map<String, String>> list = commonPopupMapper.getCommonPopupGridHeader(param);
		
		if(list.size() > 0) {

			Map<String, String> tmp = list.get(0);
			String[] argCd = tmp.get("LIST_ITEM_CD").split("###");
			String[] argNm = tmp.get("MULTI_NM").split("###");

			int widthSpecifiedColCnt = 0;
			int widthSpecifiedColSum = 0;

			for(int i = 0; i < argCd.length; i++) {

				GridMeta tmpMeta = new GridMeta();

				String columnId = argCd[i];
				if(StringUtils.contains(columnId, "(") && StringUtils.contains(columnId, ")")) {
					String aw = StringUtils.substringBetween(columnId, "(", ")");
					columnId = StringUtils.substringBefore(columnId, "(");
					if(StringUtils.contains(aw, ":")) {
						String[] alignAndWidth = StringUtils.split(aw, ":");
						String align = alignAndWidth[0];
						String width = alignAndWidth[1];

						align = align.equals("C") ? "center" : (align.equals("R") ? "right" : "left");
						tmpMeta.setAlign(align);
						tmpMeta.setWidth(width);
						widthSpecifiedColCnt++;
						widthSpecifiedColSum += Integer.parseInt(width);

					} else {

						if(NumberUtils.isNumber(aw)) {
							tmpMeta.setWidth(aw);
							tmpMeta.setAlign("left");
							widthSpecifiedColCnt++;
							widthSpecifiedColSum += Integer.parseInt(aw);

						} else {
							tmpMeta.setAlign(aw.equals("C") ? "center" : (aw.equals("R") ? "right" : "left"));
						}
					}

					tmpMeta.setColumnId(columnId);
				} else {
					tmpMeta.setColumnId(columnId);
					tmpMeta.setAlign("left");
				}

				gridMetaList.add(tmpMeta);
			}

			Double colWidth = 0.0;
			if((100 - widthSpecifiedColSum) != 0
				&& (argCd.length - widthSpecifiedColCnt) != 0) {
				colWidth = (double) Math.round((100 - widthSpecifiedColSum) / (argCd.length - widthSpecifiedColCnt));
			}

			for(int i = 0; i < argCd.length; i++) {

				GridMeta maskMeta;
				GridMeta gridMeta = gridMetaList.get(i);
				String columnId = argCd[i];

				if(StringUtils.contains(argCd[i],"_$")) {

					String maskType;
					if(columnId.contains("(")) {
						maskType = StringUtils.substringBetween(columnId, "_$", "(");
					} else {
						maskType = StringUtils.substringAfterLast(columnId, "_$");
					}
					columnId = StringUtils.substringBefore(columnId, "_$");

					maskMeta = new GridMeta();
					maskMeta.setColumnId(columnId+"_$TP");
					maskMeta.setColumnType(i == 0 ? "text" : "text");
					maskMeta.setText(argNm[i]+"$$");
					maskMeta.setWidth("0");
					maskMeta.setMaxLength("10000");
					maskMeta.setEditable("false");
					maskMeta.setAlign("center");
					maskMeta.setFontColor("'0|0|255'");
					maskMeta.setBackgroundColor("");
					maskMeta.setEssential("D");
					maskMeta.setDataType("D");
					maskMeta.setLangCode(UserInfoManager.getUserInfo().getLangCd());
					maskMeta.setDataFormat("D");
					maskMeta.setImageName("");
					maskMeta.setMultiType("G");
					maskMeta.setDynamicColumn(false);
					maskHiddenMetaList.add(maskMeta);

					gridMeta.setMaskType(maskType);
				}

				if(StringUtils.contains(argCd[i],"_HIDDEN")) {

					String maskType = StringUtils.substringAfterLast(columnId, "_HIDDEN");

					columnId = StringUtils.substringBefore(columnId, "(");

					gridMeta.setColumnId(columnId);
					gridMeta.setColumnType(i == 0 ? "text" : "text");
					gridMeta.setText(argNm[i]+"$$");
					gridMeta.setWidth("0");
					gridMeta.setMaxLength("10000");
					gridMeta.setEditable("false");
					gridMeta.setAlign("center");
					gridMeta.setFontColor("'0|0|255'");
					gridMeta.setBackgroundColor("");
					gridMeta.setEssential("D");
					gridMeta.setDataType("D");
					gridMeta.setLangCode(UserInfoManager.getUserInfo().getLangCd());
					gridMeta.setDataFormat("D");
					gridMeta.setImageName("");
					gridMeta.setMultiType("G");
					gridMeta.setDynamicColumn(false);
					gridMeta.setMaskType(maskType);
					gridMetaList.set(i, gridMeta);

				} else {

					columnId = StringUtils.substringBefore(columnId, "(");
					columnId = StringUtils.substringBefore(columnId, "_$");
					gridMeta.setColumnId(columnId);
					gridMeta.setColumnType(i == 0 ? "text" : "text");
					gridMeta.setText(argNm[i]);
					if(StringUtils.isEmpty(gridMeta.getWidth())) {
						if((100 - widthSpecifiedColSum) != 0
								&& (argCd.length - widthSpecifiedColCnt) != 0) {
							gridMeta.setWidth(String.valueOf((int) Math.floor(colWidth)));
						}
					}

					gridMeta.setMaxLength("10000");
					gridMeta.setEditable("false");
//					gridMeta.setAlign(i == 0 ? "center" : "center");
					gridMeta.setFontColor(i == 0 ? "'0|0|255'" : "");
					gridMeta.setBackgroundColor("");
					gridMeta.setEssential("D");
					gridMeta.setDataType("D");
					gridMeta.setLangCode(UserInfoManager.getUserInfo().getLangCd());
					gridMeta.setDataFormat("D");
					gridMeta.setImageName("");
					gridMeta.setMultiType("G");
					gridMeta.setDynamicColumn(false);
					gridMetaList.set(i, gridMeta);
				}
			}
		}

		gridMetaList.addAll(maskHiddenMetaList);

		return gridMetaList;
	}

	public List<Map<String, Object>> getGridData(String query, Map<String, String> parametersMap) {

		Map<String, Object> param = new HashMap<String, Object>();
		param.put("sqlSessionFactory", sqlSessionFactory);
		param.put("param", parametersMap);
		param.put("_sqlQuery_", query);

        return commonPopupMapper.getCommonPopupGridData(param);
	}

	public List<LinkedHashMap<String, Object>> getGridDataAsHashMap(Map<String, String> sql) {
		return commonPopupMapper.getCommonPopupGridDataAsHashMap(sql);
	}

}