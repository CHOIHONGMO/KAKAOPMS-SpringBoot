package com.st_ones.evermp.STO.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.STO.STO0201_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "sto0201_service")
public class STO0201_Service extends BaseService {

    @Autowired private STO0201_Mapper sto0201_mapper;
    @Autowired DocNumService  docNumService;  // 문서번호채번
    @Autowired MessageService msg;

    /**
     * 재고이동
     */
    //저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void sto0201_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList){
            String TRANNO = docNumService.getDocNumber("SM");
            gridData.put("TRAN_NO",  TRANNO);
            sto0201_mapper.sto0201_InsertTRANFROM(gridData);
            sto0201_mapper.sto0201_InsertTRANTO(gridData);
            sto0201_mapper.sto0201_InsertMMRSFROM(gridData);
            sto0201_mapper.sto0201_insertMMRSTO(gridData);
        }
    }

    /**
     * 재고조정
     */
    // 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void sto0202_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList){
            String IANO = docNumService.getDocNumber("SA");
            gridData.put("IA_NO",  IANO);
            sto0201_mapper.sto0202_InsertGIAD(gridData);
            sto0201_mapper.sto0202_insertMMRS(gridData);
        }
    }

    /**
     * 재고팝업
     */
    //창고 조회
    public List<Map<String, Object>> sto02p01_doSearch(Map<String, String> param) throws Exception {
        return sto0201_mapper.sto02p01_doSearch(param);
    }


}