package com.st_ones.common.util.excel.upload;

import jxl.read.biff.BiffException;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by azure on 2016-03-07.
 */
public class POIExcelImportProcessor extends AbstExcelImportProc {

    Logger logger = LoggerFactory.getLogger(this.getClass());

    private Workbook workbook = null;
    private ArrayList<ArrayList<String>> csvData = null;
    private int maxRowWidth = 0;
    private int formattingConvention = 0;
    private DataFormatter formatter = null;
    private FormulaEvaluator evaluator = null;
    private String separator = ",";

    private static final String CSV_FILE_EXTENSION = ".csv";
    private static final String DEFAULT_SEPARATOR = ",";

    /**
     * Identifies that the CSV file should obey Excel's formatting conventions
     * with regard to escaping certain embedded characters - the field separator,
     * speech mark and end of line (EOL) character
     */
    public static final int EXCEL_STYLE_ESCAPING = 0;

    @Override
    public List<Map<String, String>> read() throws InvalidFormatException, IOException, BiffException {
        return null;
    }

    @Override
    public String read2() throws Exception {

        boolean isColumn = true;
        StringBuilder data = new StringBuilder();
        XSSFWorkbook workbook = new XSSFWorkbook(inputStream);
        XSSFSheet sheet = workbook.getSheetAt(0);

        if (sheet.getPhysicalNumberOfRows() > 0) {

            int lastRowNum = sheet.getLastRowNum();
            int totalColumnCount = sheet.getRow(0).getLastCellNum();

            for (int j = 1; j <= lastRowNum; j++) {

                XSSFRow row = sheet.getRow(j);

                for(int i=0; i < totalColumnCount; i++) {

                    XSSFCell cell = row.getCell(i);

                    if(cell != null) {

                        XSSFCellStyle cellStyle = cell.getCellStyle();
                        XSSFColor color = cellStyle.getBottomBorderXSSFColor();
                        if(color != null) {

                            // if column
                            if(cellStyle.getFont().getBold() && cellStyle.getBottomBorderXSSFColor().getARGBHex().equals("FFCCCCCC")) {
                                isColumn = true;
                                continue;
                            } else {
                                isColumn = false;
                            }
                        } else {
                            isColumn = false;
                        }

                        switch (cell.getCellType()) {

	                        case BOOLEAN:
	                            data.append("\""+cell.getBooleanCellValue() + "\",");
	                            break;
	
	                        case NUMERIC:
	
	                            if(DateUtil.isCellDateFormatted(cell)) {
	
	                                data.append("\""+new SimpleDateFormat("yyyyMMdd").format(cell.getDateCellValue())+"\",");
	
	                            } else {
	                                cell.setCellType(CellType.STRING);    /* 엑셀에 입력된 숫자값을 그대로 받기 위해 강제변환 */
	                                data.append("\""+cell.getStringCellValue().replaceAll("\"", "\"\"") + "\",");
	                            }
	
	                            break;
	
	                        case STRING:
	                            String cellValue = cell.getStringCellValue().replaceAll("\"", "\"\"");
	                            cellValue = cellValue.replaceAll("\n", "#n");
	                            data.append("\""+ cellValue + "\",");
	                            break;
	
	                        case BLANK:
	                            data.append("" + ",");
	                            break;
	
	                        default:
	                            data.append("\""+cell+"\",");

                        }

                    } else {
                        data.append("\"\"" + ",");
                    }

                    if(i == totalColumnCount-1) {
                        data.deleteCharAt(data.length()-1);
                    }
                }

                if(!isColumn && j != lastRowNum) {
                    data.append("\n");
                }
            }

        }

        return data.toString();
    }

    /**
     * Open an Excel workbook ready for conversion.
     *
     * @param fis An instance of the File class that encapsulates a handle
     *             to a valid Excel workbook. Note that the workbook can be in
     *             either binary (.xls) or SpreadsheetML (.xlsx) format.
     * @throws java.io.FileNotFoundException                              Thrown if the file cannot be located.
     * @throws IOException                                        Thrown if a problem occurs in the file system.
     * @throws InvalidFormatException Thrown
     *                                                                    if invalid xml is found whilst parsing an input SpreadsheetML
     *                                                                    file.
     */
    private void openWorkbook(InputStream fis) throws
            IOException, InvalidFormatException {

        try {

            // Open the workbook and then create the FormulaEvaluator and
            // DataFormatter instances that will be needed to, respectively,
            // force evaluation of forumlae found in cells and create a
            // formatted String encapsulating the cells contents.
            this.workbook = WorkbookFactory.create(fis);
            this.evaluator = this.workbook.getCreationHelper().createFormulaEvaluator();
            this.formatter = new DataFormatter(true);
        } finally {
            if (fis != null) {
                fis.close();
            }
        }
    }

    private void convertToCSV() {

        Sheet sheet = null;
        Row row = null;
        int lastRowNum = 0;
        this.csvData = new ArrayList<ArrayList<String>>();

        // Discover how many sheets there are in the workbook....
        int numSheets = this.workbook.getNumberOfSheets();

        // and then iterate through them.
        for (int i = 0; i < numSheets; i++) {

            // Get a reference to a sheet and check to see if it contains
            // any rows.
            sheet = this.workbook.getSheetAt(i);
            if (sheet.getPhysicalNumberOfRows() > 0) {

                // Note down the index number of the bottom-most row and
                // then iterate through all of the rows on the sheet starting
                // from the very first row - number 1 - even if it is missing.
                // Recover a reference to the row and then call another method
                // which will strip the data from the cells and build lines
                // for inclusion in the resylting CSV file.
                lastRowNum = sheet.getLastRowNum();
                for (int j = 0; j <= lastRowNum; j++) {
                    row = sheet.getRow(j);
                    this.rowToCSV(row);
                }
            }
        }
    }

    /**
     * Called to convert a row of cells into a line of data that can later be
     * output to the CSV file.
     *
     * @param row An instance of either the HSSFRow or XSSFRow classes that
     *            encapsulates information about a row of cells recovered from
     *            an Excel workbook.
     */
    private void rowToCSV(Row row) {

        Cell cell = null;
        int lastCellNum = 0;
        ArrayList<String> csvLine = new ArrayList<String>();

        // Check to ensure that a row was recovered from the sheet as it is
        // possible that one or more rows between other populated rows could be
        // missing - blank. If the row does contain cells then...
        if (row != null) {

            // Get the index for the right most cell on the row and then
            // step along the row from left to right recovering the contents
            // of each cell, converting that into a formatted String and
            // then storing the String into the csvLine ArrayList.
            lastCellNum = row.getLastCellNum();
            for (int i = 0; i <= lastCellNum; i++) {
                cell = row.getCell(i);
                if (cell == null) {
                    csvLine.add("");
                } else {
                	if (cell.getCellType() != CellType.FORMULA) {
                        csvLine.add(this.formatter.formatCellValue(cell));
                    } else {
                        csvLine.add(this.formatter.formatCellValue(cell, this.evaluator));
                    }
                }
            }
            // Make a note of the index number of the right most cell. This value
            // will later be used to ensure that the matrix of data in the CSV file
            // is square.
            if (lastCellNum > this.maxRowWidth) {
                this.maxRowWidth = lastCellNum;
            }
        }
        this.csvData.add(csvLine);
    }

    /**
     * Checks to see whether the field - which consists of the formatted
     * contents of an Excel worksheet cell encapsulated within a String - contains
     * any embedded characters that must be escaped. The method is able to
     * comply with either Excel's or UNIX formatting conventions in the
     * following manner;
     * <p/>
     * With regard to UNIX conventions, if the field contains any embedded
     * field separator or EOL characters they will each be escaped by prefixing
     * a leading backspace character. These are the only changes that have yet
     * emerged following some research as being required.
     * <p/>
     * Excel has other embedded character escaping requirements, some that emerged
     * from empirical testing, other through research. Firstly, with regards to
     * any embedded speech marks ("), each occurrence should be escaped with
     * another speech mark and the whole field then surrounded with speech marks.
     * Thus if a field holds <em>"Hello" he said</em> then it should be modified
     * to appear as <em>"""Hello"" he said"</em>. Furthermore, if the field
     * contains either embedded separator or EOL characters, it should also
     * be surrounded with speech marks. As a result <em>1,400</em> would become
     * <em>"1,400"</em> assuming that the comma is the required field separator.
     * This has one consequence in, if a field contains embedded speech marks
     * and embedded separator characters, checks for both are not required as the
     * additional set of speech marks that should be placed around ay field
     * containing embedded speech marks will also account for the embedded
     * separator.
     * <p/>
     * It is worth making one further note with regard to embedded EOL
     * characters. If the data in a worksheet is exported as a CSV file using
     * Excel itself, then the field will be surounded with speech marks. If the
     * resulting CSV file is then re-imports into another worksheet, the EOL
     * character will result in the original simgle field occupying more than
     * one cell. This same 'feature' is replicated in this classes behaviour.
     *
     * @param field An instance of the String class encapsulating the formatted
     *              contents of a cell on an Excel worksheet.
     * @return A String that encapsulates the formatted contents of that
     * Excel worksheet cell but with any embedded separator, EOL or
     * speech mark characters correctly escaped.
     */
    private String escapeEmbeddedCharacters(String field) {
        StringBuffer buffer = null;

        // If the fields contents should be formatted to confrom with Excel's
        // convention....
        if (this.formattingConvention == EXCEL_STYLE_ESCAPING) {

            // Firstly, check if there are any speech marks (") in the field;
            // each occurrence must be escaped with another set of spech marks
            // and then the entire field should be enclosed within another
            // set of speech marks. Thus, "Yes" he said would become
            // """Yes"" he said"
            if (field.contains("\"")) {
                buffer = new StringBuffer(field.replaceAll("\"", "\\\"\\\""));
                buffer.insert(0, "\"");
                buffer.append("\"");
            } else {
                // If the field contains either embedded separator or EOL
                // characters, then escape the whole field by surrounding it
                // with speech marks.
                buffer = new StringBuffer(field);
                if ((buffer.indexOf(this.separator)) > -1 ||
                        (buffer.indexOf("\n")) > -1) {
                    buffer.insert(0, "\"");
                    buffer.append("\"");
                }
            }
            return (buffer.toString().trim());
        }
        // The only other formatting convention this class obeys is the UNIX one
        // where any occurrence of the field separator or EOL character will
        // be escaped by preceding it with a backslash.
        else {
            if (field.contains(this.separator)) {
                field = field.replaceAll(this.separator, ("\\\\" + this.separator));
            }
            if (field.contains("\n")) {
                field = field.replaceAll("\n", "\\\\\n");
            }
            return (field);
        }
    }
}
