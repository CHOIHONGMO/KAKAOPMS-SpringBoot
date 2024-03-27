package com.st_ones.evermp.IM04.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.IM04.IM0401_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;


@Service(value = "im04_Service")
public class IM0401_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private IM0401_Mapper im0401Mapper;

    @Autowired
    LargeTextService largeTextService;

    /** ****************************************************************************************************************
     * 품목분류 현황
     * @param param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> selectItemClass(Map<String, String> param) throws Exception {
        List<Map<String, Object>> rtn;

        if (EverString.isEmpty(param.get("ITEM_CLS"))) {
            rtn = im0401Mapper.selectItemClassSearchNm(param);
        } else {
            rtn = im0401Mapper.selectItemClass(param);
        }

        return rtn;
    }

    public List<Map<String, Object>> selectChildClass(Map<String, String> param) throws Exception {
        return im0401Mapper.selectChildClass(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String saveItemClass(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> gridDatum : gridData) {

            if ("I".equals(gridDatum.get("INSERT_FLAG"))) {
                gridDatum.put("DEL_FLAG", "0");
                if ("C1".equals(gridDatum.get("ITEM_CLS_TYPE"))) {
                    if (im0401Mapper.existsItemClass(gridDatum) > 0) {
                        throw new NoResultException(msg.getMessage("0034"));
                    }
                } else {
                    String ruleKey = PropertiesManager.getString("eversrm.item.type.management.rule");
                    if (ruleKey.equals("auto")) {
                        if ("C2".equals(gridDatum.get("ITEM_CLS_TYPE"))) {
                            gridDatum.put("ITEM_CLS2", im0401Mapper.newItemClassKey(gridDatum));
                        } else if ("C3".equals(gridDatum.get("ITEM_CLS_TYPE"))) {
                            gridDatum.put("ITEM_CLS3", im0401Mapper.newItemClassKey(gridDatum));
                        } else if ("C4".equals(gridDatum.get("ITEM_CLS_TYPE"))) {
                            gridDatum.put("ITEM_CLS4", im0401Mapper.newItemClassKey(gridDatum));
                        }
                    } else if (ruleKey.equals("manual")) {
                        if (im0401Mapper.existsItemClass(gridDatum) > 0) {
                            throw new NoResultException(msg.getMessage("0034"));
                        }
                    }
                }

                gridDatum.put("DEL_FLAG", "1");
                int chk = im0401Mapper.existsItemClass(gridDatum);

                gridDatum.put("TABLE_NM", "STOCMTCA");

                if (chk > 0) {
                    im0401Mapper.updateItemClass(gridDatum);
                } else {
                    //gridDatum.put("SORT_SQ", im0401Mapper.newSortSeq(gridDatum));
                    im0401Mapper.insertItemClass(gridDatum);
                }

            } else {

                String itemClass = gridDatum.get("ITEM_CLS" + gridDatum.get("ITEM_CLS_TYPE").toString().substring(1)).toString();
                if (!itemClass.equals(gridDatum.get("ITEM_CLS_ORI").toString())) { // Key is changed
                    gridDatum.put("DEL_FLAG", "0");
                    if (im0401Mapper.existsItemClass(gridDatum) > 0) {
                        throw new NoResultException(msg.getMessage("0034"));
                    }

                    gridDatum.put("DEL_FLAG", "1");
                    int chk = im0401Mapper.existsItemClass(gridDatum);

                    gridDatum.put("TABLE_NM", "STOCMTCA");

                    if (chk > 0) {
                        im0401Mapper.updateItemClass(gridDatum);
                    } else {
                        //gridDatum.put("SORT_SQ", im0401Mapper.newSortSeq(gridDatum));
                        im0401Mapper.insertItemClass(gridDatum);
                    }

                } else {
                    gridDatum.put("TABLE_NM", "STOCMTCA");
                    im0401Mapper.updateItemClass(gridDatum);
                }
            }
        }

        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String deleteItemClass(List<Map<String, Object>> gridData) throws Exception {

        String rtnmsg = "";
        for (Map<String, Object> gridDatum : gridData) {
            if (!"I".equals(gridDatum.get("INSERT_FLAG"))) {
                gridDatum.put("TABLE_NM", "STOCMTCA");

                if (im0401Mapper.notDeleteItemClass(gridDatum) > 1) {
                    rtnmsg = "X";
                } else {
                    im0401Mapper.deleteItemClass_r(gridDatum);
                    rtnmsg = "Y";
                }
            }
        }
        return rtnmsg;
    }
}
