package com.st_ones.common.generator.service;

import com.st_ones.common.cache.data.ColumnInfoCache;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.generator.GridGenMapper;
import com.st_ones.common.generator.domain.GridMeta;
import com.st_ones.common.popup.service.CommonPopupService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.web.BaseController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.CacheManager;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service(value = "gridGenService")
@Scope("prototype")
public class GridGenService extends BaseController {

    @Autowired
    private CommonPopupService commonPopupService;
    @Autowired
    private CommonComboService commonComboService;
    @Autowired
    private ColumnInfoCache columnInfoCache;
    @Autowired
    private GridGenMapper gridGenMapper;
    @Autowired
    CacheManager cacheManager;

    private String screenID;
    private String gridID;
    private String langCode;
    private String numberFormat;
    private String dateFormat;
    private List<GridMeta> columnInfos = new ArrayList<GridMeta>();

    public void init(String _screenID, String _gridID, String _langCode, String dateFormat, String numberFormat) throws Exception {

        this.screenID = _screenID;
        this.gridID = _gridID;
        this.langCode = _langCode;
        this.numberFormat = numberFormat;
        this.dateFormat = dateFormat;

        setGridMetas();
    }

    private void setGridMetas() throws Exception {

        if (screenID.equals("commonPopup")) {
            columnInfos = commonPopupService.getGridHeader(gridID);
        } else {
            columnInfos = columnInfoCache.getData(screenID, gridID, langCode);
        }

        for (GridMeta columnInfo : columnInfos) {

            if ("combo".equals(columnInfo.getColumnType())) {

                if (EverString.isNotEmpty(columnInfo.getCommonId())) {

                    List<Map<String, String>> list = commonComboService.getCodeCombo(columnInfo.getCommonId());
                    if (list.size() == 0) {
                        list = new ArrayList<Map<String, String>>();
                        Map<String, String> map = new LinkedHashMap<String, String>();
                        map.put("value", "mm");
                        map.put("text", "공통코드 오입력");
                        list.add(map);
                        columnInfo.setCombos(list);
                    } else {
                        columnInfo.setCombos(list);
                    }

                } else {
                    List<Map<String, String>> list = new ArrayList<Map<String, String>>();
                    Map<String, String> map = new LinkedHashMap<String, String>();
                    map.put("value", "mm");
                    map.put("text", "콤보공통코드 오입력");
                    list.add(map);
                    columnInfo.setCombos(list);
                }
            }
        }
    }

    public String getEssential() {
        String essential = "";

        for (GridMeta columnInfo : columnInfos) {
            if (EverString.defaultIfEmpty(columnInfo.getEssential(), "").equals("E")) {
                essential = essential + "," + columnInfo.getColumnId();
            }

            String dataType = columnInfo.getDataType();
            String dataFormat = getDataFormat(dataType);
            columnInfo.setDataFormat(dataFormat);
        }

        essential = essential.replaceFirst(",", "");
        return essential;
    }

    private String getDataFormat(String dataType) {
        if (dataType == null) {
            return "";
        }

        if (dataType.equals("NUM") || dataType.equals("SEQ") || dataType.equals("CNT")) {    // 숫자, 항번, 순번
            return "0";
        } else if (dataType.equals("MAX") || dataType.equals("AMT")) { // 금액
            return "0";
        } else if (dataType.equals("DEC1")) {    // 소수점 1자리
            return "1";
        } else if (dataType.equals("DEC2")) {    // 소수점 2자리
            return "2";
        } else if (dataType.equals("DEC3")) {    // 소수점 3자리
            return "3";
        } else if (dataType.equals("DEC4")) {    // 소수점 4자리
            return "4";
        } else if (dataType.equals("PER")) {    // 퍼센트 : 소수점 2자리
            return "2";
        } else if (dataType.equals("QTY")) {    // 수량 : 소수점 3자리
            return "3";
        } else if (dataType.equals("RAT")) {    // 비율 : 소수점 2자리
            return "2";
        } else if (dataType.equals("SCO")) {    // 점수 : 소수점 1자리
            return "1";
        } else if (dataType.equals("PRI")) {    // 단가 : 소수점 없음
            return "0";
        } else {
            return "";
        }
    }

    public List<GridMeta> getColumnInfos() {
        return columnInfos;
    }

    public List<Map<String, Object>> getBtnImageInfos(String screenId) {
        return gridGenMapper.getBtnImageInfos(screenId);
    }
}
