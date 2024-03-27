package com.st_ones.common.excel;

import net.sf.jxls.parser.Cell;
import net.sf.jxls.processor.RowProcessor;
import net.sf.jxls.transformer.Row;
import org.apache.poi.ss.usermodel.CellStyle;

import java.util.List;
import java.util.Map;

/**
 *
 */
public class AutoFitRowProcessor implements RowProcessor {

    @Override
    public void processRow(Row row, Map namedCell) {

        List cells = row.getCells();

        for (int i = 0; i < cells.size(); i++) {
            Cell cell = (Cell) cells.get(i);
            if(!cell.isNull()) {
                CellStyle cellStyle = cell.getPoiCell().getCellStyle();
//                cellStyle.setWrapText(true);
                cell.getPoiCell().setCellStyle(cellStyle);
//                cell.getPoiCell().setCellValue("huhu!");
            }
        }
    }
}
