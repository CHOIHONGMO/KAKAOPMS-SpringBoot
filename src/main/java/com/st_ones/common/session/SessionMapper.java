package com.st_ones.common.session;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface SessionMapper {

    List<Map<String, String>> getQtdtData(Map<String, String> formData);
    Map<String, String> getQthdData(Map<String, String> formData);

    int doUpdateQtdt(Map<String, String> datum);

    int doUpdateQthd(Map<String, String> formData);

    List<Map<String, Object>> getColComments();

}
