package com.st_ones.evermp.IM04.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * 2018. 08. 07 kkj
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.IM04.IM0403_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;


@Service(value = "im0403_Service")
public class IM0403_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private IM0403_Mapper im0403Mapper;


    /** ****************************************************************************************************************
     * 품목분류(판촉)
     * @param param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> selectItemClass(Map<String, String> param) throws Exception {
        List<Map<String, Object>> rtn;

        if (EverString.isEmpty(param.get("ITEM_CLS"))) {
            rtn = im0403Mapper.selectItemClassSearchNm(param);
        } else {
            rtn = im0403Mapper.selectItemClass(param);
        }

        return rtn;
    }

    //하위 판촉품목조회
    public List<Map<String, Object>> selectChildClass(Map<String, String> param) throws Exception {
        return im0403Mapper.selectChildClass(param);
    }

    //품목분류 판촉 저장

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String saveItemClass(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> gridDatum : gridData) {

            if ("I".equals(gridDatum.get("INSERT_FLAG"))) {
                gridDatum.put("DEL_FLAG", "0");
                if ("C1".equals(gridDatum.get("PT_ITEM_CLS_TYPE"))) {
                    gridDatum.put("PT_ITEM_CLS1","P"+gridDatum.get("PT_ITEM_CLS1"));
                    if (im0403Mapper.existsItemClass(gridDatum) > 0) {
                        throw new NoResultException(msg.getMessage("0034"));
                    }
                } else {
                    String ruleKey = PropertiesManager.getString("eversrm.item.type.management.rule");
                    if (ruleKey.equals("auto")) {
                        if ("C2".equals(gridDatum.get("PT_ITEM_CLS_TYPE"))) {
                            gridDatum.put("PT_ITEM_CLS2", im0403Mapper.newItemClassKey(gridDatum));
                        } else if ("C3".equals(gridDatum.get("PT_ITEM_CLS_TYPE"))) {
                            gridDatum.put("PT_ITEM_CLS3", im0403Mapper.newItemClassKey(gridDatum));
                        }
                    } else if (ruleKey.equals("manual")) {
                        if (im0403Mapper.existsItemClass(gridDatum) > 0) {
                            throw new NoResultException(msg.getMessage("0034"));
                        }
                    }
                }

                gridDatum.put("DEL_FLAG", "1");
                int chk = im0403Mapper.existsItemClass(gridDatum);

                gridDatum.put("TABLE_NM", "STOCPTCA");
                gridDatum.put("ITEM_TYPE", "G");

                if (chk > 0) {
                    im0403Mapper.updateItemClass(gridDatum);
                } else {
                    gridDatum.put("SORT_SQ", im0403Mapper.newSortSeq(gridDatum));
                    im0403Mapper.insertItemClass(gridDatum);
                }

            } else {

                String itemClass = gridDatum.get("PT_ITEM_CLS" + gridDatum.get("PT_ITEM_CLS_TYPE").toString().substring(1)).toString();
                if (!itemClass.equals(gridDatum.get("PT_ITEM_CLS_ORI").toString())) { // Key is changed
                    gridDatum.put("DEL_FLAG", "0");
                    if (im0403Mapper.existsItemClass(gridDatum) > 0) {
                        throw new NoResultException(msg.getMessage("0034"));
                    }

                    gridDatum.put("DEL_FLAG", "1");
                    int chk = im0403Mapper.existsItemClass(gridDatum);

                    gridDatum.put("TABLE_NM", "STOCPTCA");
                    gridDatum.put("ITEM_TYPE", "G");

                    if (chk > 0) {
                        im0403Mapper.updateItemClass(gridDatum);
                    } else {
                        gridDatum.put("SORT_SQ", im0403Mapper.newSortSeq(gridDatum));
                        im0403Mapper.insertItemClass(gridDatum);
                    }

                } else {
                    gridDatum.put("TABLE_NM", "STOCPTCA");
                    im0403Mapper.updateItemClass(gridDatum);
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
                gridDatum.put("TABLE_NM", "STOCPTCA");

                if (im0403Mapper.notDeleteItemClass(gridDatum) > 1) {
                    rtnmsg = "X";
                } else {
                    im0403Mapper.deleteItemClass_r(gridDatum);
                    rtnmsg = "Y";
                }
            }
        }
        return rtnmsg;
    }


    /** ****************************************************************************************************************
     * 품목분류 판촉(팝업)
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> doSearchPTItemClassPopup_TREE(Map<String, String> param) throws Exception {
        return im0403Mapper.doSearchPTItemClassPopup_TREE(param);
    }

}
