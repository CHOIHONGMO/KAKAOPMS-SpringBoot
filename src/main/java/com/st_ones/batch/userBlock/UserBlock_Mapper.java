package com.st_ones.batch.userBlock;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface UserBlock_Mapper {

    List<Map<String, Object>> doSelectBlockList(Map<String, String> param);
    void setUserBlockU(Map<String, Object> data);
    void setUserBlockC(Map<String, Object> data);
}
