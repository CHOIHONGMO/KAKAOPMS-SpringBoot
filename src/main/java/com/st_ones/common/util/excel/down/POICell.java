package com.st_ones.common.util.excel.down;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Workbook;


public class POICell extends AbsCell{
	private Row row;
	private Workbook workbook;
	
	public void setWorkBook(Workbook workbook) {
		this.workbook = workbook;
	}
	
	public void setRow(Row row) {
		this.row = row;
	}
	
	public void writeLabelCell() {
		row.createCell(columnIdx).setCellValue(cellStr);
	}
}
