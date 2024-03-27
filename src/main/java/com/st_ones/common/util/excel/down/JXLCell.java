package com.st_ones.common.util.excel.down;

import jxl.write.Label;
import jxl.write.Number;
import jxl.write.WritableCell;

public class JXLCell extends AbsCell{

	public WritableCell getLabelCell() {
		return new Label(columnIdx, excelRowIdx, cellStr);
	}

	public WritableCell getNumberCell() {
		return new Number(columnIdx, excelRowIdx, cellNum);
	}


}
