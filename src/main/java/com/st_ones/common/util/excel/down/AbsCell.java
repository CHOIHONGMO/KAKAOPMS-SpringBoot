package com.st_ones.common.util.excel.down;

public abstract class AbsCell {

	protected int columnIdx;
	protected int excelRowIdx;
	protected String cellStr;
	protected Double cellNum;
	protected String format;
	protected String columnId;
	
	public int getColumnIdx() {
		return columnIdx;
	}
	public void setColumnIdx(int columnIdx) {
		this.columnIdx = columnIdx;
	}
	public int getExcelRowIdx() {
		return excelRowIdx;
	}
	public void setExcelRowIdx(int excelRowIdx) {
		this.excelRowIdx = excelRowIdx;
	}
	public String getCellStr() {
		return cellStr;
	}
	public void setCellStr(String cellStr) {
		this.cellStr = cellStr;
	}
	public String getFormat() {
		return format;
	}
	public void setFormat(String format) { this.format = format; }
	public String getColumnId() {
		return columnId;
	}
	public void setColumnId(String columnId) {
		this.columnId = columnId;
	}
	public void setCellNum(String cellNum) { this.cellNum = Double.parseDouble(cellNum); }
}
