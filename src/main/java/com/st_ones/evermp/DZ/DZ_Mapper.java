package com.st_ones.evermp.DZ;
/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public interface DZ_Mapper {

	String tx01020_search_TR_CD(Map<String, Object> param);

	void tx01020_doAutoDocExe_S(Map<String, Object> grid);

    int tx01020_maxInSq(Map<String, String> formData);
}