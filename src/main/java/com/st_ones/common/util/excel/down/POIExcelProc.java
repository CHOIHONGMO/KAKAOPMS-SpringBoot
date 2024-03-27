package com.st_ones.common.util.excel.down;

import jxl.write.WriteException;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.WorkbookUtil;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.text.ParseException;
import java.util.Iterator;

public class POIExcelProc extends AbsExcelExportProcessor {

    private Workbook workbook;
    private Sheet sheet;
    private Row row;

    @Override
    protected void beforeWrite() throws IOException {
        workbook = new XSSFWorkbook();
        sheet = workbook.createSheet(WorkbookUtil.createSafeSheetName("GridData"));
    }

    @Override
    protected void writeHeaders() throws WriteException {
        int i = 0;
        row = sheet.createRow(0);

        Iterator<String> iter = data.get(0).keySet().iterator();
        while (iter.hasNext()) {
            row.createCell(i++).setCellValue(iter.next());
        }
    }

    @Override
    protected void writeRows() throws WriteException, ParseException, IOException {
        for (int rowIndex = 0; rowIndex < data.size(); rowIndex++) {
            row = sheet.createRow(rowIndex + 1);
            for (int columnIndex = 0; columnIndex < data.get(rowIndex).size(); columnIndex++) {
                writeCell(columnIndex, rowIndex, data.get(rowIndex).get(columnIndex));
            }
        }
    }

    @Override
    protected void afterWrite() throws IOException, WriteException {
        autoWidth();
        workbook.write(outputStream);
    }

    private void autoWidth() {
        for (int i = 0; i < data.size(); i++) {
            sheet.autoSizeColumn(i);
        }
    }

    private void writeCell(int columnIndex, int rowIndex, Object column) throws ParseException {

        POICell cell = new POICell();
        cell.setColumnIdx(columnIndex);
        cell.setCellStr((String) column);
        cell.setRow(row);
        cell.setWorkBook(workbook);

        cell.writeLabelCell();
    }
}
