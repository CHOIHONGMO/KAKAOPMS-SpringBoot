package com.st_ones.common.util.excel.upload;

import jxl.Cell;
import jxl.Sheet;
import jxl.Workbook;
import jxl.read.biff.BiffException;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;

import java.io.IOException;
import java.util.*;

public class JXLExcelImportProc extends AbstExcelImportProc {

    @Override
    public List<Map<String, String>> read() throws BiffException, IOException {

        Workbook workbook = Workbook.getWorkbook(inputStream);
        Sheet sheet = workbook.getSheet(0);
        Cell[] colNames = sheet.getRow(0);


        String[] arryColName = checkColIndex(colNames, super.colInfoMap);
        for (int i = 0; i < arryColName.length; i++) {
            // ?
        }

        List<Map<String, String>> excelData = new ArrayList<Map<String, String>>();
        for (int i = 1, rowCnt = sheet.getRows(); i < rowCnt; i++) {

            Cell[] cells = sheet.getRow(i);
            Map<String, String> rowData = new HashMap<String, String>();

            try {
                for (int j = 0, cellsLen = cells.length; j < cellsLen; j++) {
                    rowData.put(arryColName[j], cells[j].getContents());
                }
            } catch (ArrayIndexOutOfBoundsException e) {

            }

            excelData.add(rowData);
        }

        return excelData;
    }

    @Override
    public String read2() throws InvalidFormatException, IOException, BiffException {
        return null;
    }

    public String[] checkColIndex(Cell[] cells, Map<String, String> colInfo) {
        List<String> rtnData = new ArrayList<String>();
        // {BD_100: "800", BD_200: "900", ... 컬럼키:"컬럼명"
        Iterator<String> ite = colInfo.keySet().iterator();
        while (ite.hasNext()) {
            String columnId = ite.next();
            for (int i = 0, cellsLen = cells.length; i < cellsLen; i++) {
                if (colInfo.get(columnId).equals(cells[i].getContents())) {
                    rtnData.add(columnId);
                }
            }
        }

        return rtnData.toArray(new String[rtnData.size()]);
    }
}
