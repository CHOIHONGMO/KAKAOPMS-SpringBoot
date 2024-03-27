package com.st_ones.common.util.excel.down;

import com.st_ones.common.util.excel.common.common;
import jxl.write.WriteException;

import java.io.IOException;
import java.io.OutputStream;
import java.text.ParseException;
import java.util.List;
import java.util.Map;

public class ExcelExportHandler {

	private AbsExcelExportProcessor excelExportProc;

	public ExcelExportHandler(String rows, Map<String, List<String>> columnDef, String fileType, String url, String excelOptions, String groupColDef, String frozenColIndex) throws IOException {

		excelExportProc = common.getExcelExportProcInst(fileType);
		excelExportProc.setData(common.getListMap(rows));
		excelExportProc.setColIndex(columnDef.get("colIndex"));
		excelExportProc.setColNames(columnDef.get("colNames"));
		excelExportProc.setColTypes(columnDef.get("colTypes"));
		excelExportProc.setColAlign(columnDef.get("colAlign"));
		excelExportProc.setExcelOptions(common.getObjMap(excelOptions));
		excelExportProc.setUrl(url);
		excelExportProc.setGroupColDef(groupColDef);
		excelExportProc.setFrozenColIndex(frozenColIndex);
	}

	public void write(OutputStream outputStream) throws IOException, WriteException, ParseException {
		excelExportProc.setOutputStream(outputStream);
		excelExportProc.write();
	}
}
