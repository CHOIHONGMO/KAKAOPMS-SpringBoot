package com.st_ones.eversrm.system.management;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface EXECSQL_Mapper {

    List<Map<String, Object>> search(Map<String, String> param);

    int transaction(Map<String, String> param);
}
