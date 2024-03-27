package com.st_ones.common.util.excel.upload;

import jxl.read.biff.BiffException;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public abstract class AbstExcelImportProc {
    InputStream inputStream;
    protected List<String> headerValues = new ArrayList<String>();
    protected List<List<String>> contentsRows = new ArrayList<List<String>>();
    protected Map<String, String> colInfoMap;
    protected Map<String, String> paramOptions;

    public void setParamOptions(Map<String, String> paramOptions) {
        this.paramOptions = paramOptions;
    }

    public void setInputStream(InputStream inputStream) {
        this.inputStream = inputStream;
    }

    public abstract List<Map<String, String>> read() throws InvalidFormatException, IOException, BiffException;

    public abstract String read2() throws Exception;

    public Map<String, String> getParamOptions(){
        return this.paramOptions;
    }

    public void setColInfo(Map<String, String> colInfo) {
        this.colInfoMap = colInfo;
    }

    public List<String> getIdList() {
        List<String> idList = new ArrayList<String>();
        return idList;
    }
}