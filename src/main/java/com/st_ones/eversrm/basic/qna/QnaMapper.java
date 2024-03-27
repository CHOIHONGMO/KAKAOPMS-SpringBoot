package com.st_ones.eversrm.basic.qna;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface QnaMapper {

	List<Map<String, Object>> doSearchQnaList(Map<String, String> param);

	void doInsertQna(Map<String, String> formData);

	void doUpdateQna(Map<String, String> formData);

	void doUpdateHITQna(Map<String, String> formData);

	void doDeleteQna(Map<String, String> formData);

	Map<String, String> doReviewQna(Map<String, String> param);

}