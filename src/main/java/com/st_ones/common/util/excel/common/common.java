package com.st_ones.common.util.excel.common;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.util.excel.down.AbsExcelExportProcessor;
import com.st_ones.common.util.excel.down.JXLExcelProc;
import com.st_ones.common.util.excel.down.POIExcelProc;
import org.apache.commons.lang3.StringEscapeUtils;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public class common {
	public static String[] getArray(String data) throws IOException {
        return (new ObjectMapper()).readValue(StringEscapeUtils.unescapeXml(data), new TypeReference<String[]>() {});
	}
	
	public static List<Map<String, Object>> getListMap(String rows) throws IOException {
        return (new ObjectMapper()).readValue(rows, new TypeReference<List<Map<String, Object>>>() {});
	}
	
	public static Map<String, String> getMap(String data) throws IOException {
		return (new ObjectMapper()).readValue(data, new TypeReference<Map<String, String>>() {});
	}
	
	public static Map<String, Object> getObjMap(String data) throws IOException {
		return (new ObjectMapper()).readValue(data, new TypeReference<Map<String, Object>>() {});
	}
	
	public static AbsExcelExportProcessor getExcelExportProcInst(String excelType) {
		if("xlsx".equals(excelType)) { return new POIExcelProc(); }
		else if ("xls".equals(excelType)) { return new JXLExcelProc(); }
		else { return null; }
	}
}