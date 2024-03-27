package com.st_ones.common.util.excel.upload;

import com.st_ones.common.util.excel.common.common;
import jxl.read.biff.BiffException;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;

public class ExcelImportHandler {

    private AbstExcelImportProc excelImportProcessor;

    public ExcelImportHandler(String fileName) throws IOException {
        excelImportProcessor = getExcelImportInstance(fileName);
    }

    public ExcelImportHandler(String fileName, String colInfo) throws IOException {

        excelImportProcessor = getExcelImportInstance(fileName);
        excelImportProcessor.setColInfo(common.getMap(colInfo));
    }

    private AbstExcelImportProc getExcelImportInstance(String fileName) {

        String extension = fileName.replaceAll(".*\\.", "");
        if (extension.equalsIgnoreCase("xlsx")) {
            return new POIExcelImportProcessor();
        } else if (extension.equalsIgnoreCase("xls")) {
            return new JXLExcelImportProc();
        } else {
            throw new IllegalArgumentException("unknown file extension. file name: " + fileName);
        }
    }

    public List<Map<String, String>> read(InputStream inputStream) throws InvalidFormatException, IOException, BiffException {
        excelImportProcessor.setInputStream(inputStream);
        return excelImportProcessor.read();
    }

    public String read2(InputStream inputStream) throws Exception {
        excelImportProcessor.setInputStream(inputStream);
        return excelImportProcessor.read2();
    }
}
