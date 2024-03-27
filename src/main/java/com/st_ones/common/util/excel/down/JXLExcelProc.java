package com.st_ones.common.util.excel.down;

import com.fasterxml.jackson.databind.ObjectMapper;
import jxl.Workbook;
import jxl.format.Alignment;
import jxl.format.Border;
import jxl.format.BorderLineStyle;
import jxl.format.Colour;
import jxl.format.VerticalAlignment;
import jxl.write.*;
import jxl.write.biff.RowsExceededException;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.lang.Boolean;
import java.math.BigDecimal;
import java.net.URL;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.util.List;
import java.util.Map;

public class JXLExcelProc extends AbsExcelExportProcessor {

    private WritableSheet sheet;
    private WritableWorkbook workbook;

    @Override
    protected void beforeWrite() throws IOException {
        workbook = Workbook.createWorkbook(outputStream);
        sheet = workbook.createSheet("GridDatas", 0);
    }

    @Override
    protected void writeHeaders() throws WriteException, IOException {

    }

    @Override
    protected void writeRows() throws WriteException, ParseException, IOException {

        Object paramData = null;
        String imgPath = "";
        double imgWidth = Double.parseDouble(excelOptions.get("imgWidth").toString());
        double imgHeight = Double.parseDouble(excelOptions.get("imgHeight").toString());
        int colWidth = Integer.parseInt(excelOptions.get("colWidth").toString());
        boolean attachImgFlag = Boolean.parseBoolean(excelOptions.get("attachImgFlag").toString());

        int startRowIdx = 0;

        WritableCellFormat writableCellFormat = null;

        if (groupColDef != null) {

            List<Map<String, Object>> groupColDefList = new ObjectMapper().readValue(groupColDef, List.class);
            for (int i = 0, colIndex = 0; i < groupColDefList.size(); i++, colIndex++) {

                writableCellFormat = new WritableCellFormat();
                writableCellFormat.setAlignment(Alignment.CENTRE);
                writableCellFormat.setBackground(Colour.ICE_BLUE);
                writableCellFormat.setVerticalAlignment(VerticalAlignment.CENTRE);
                writableCellFormat.setShrinkToFit(true);
                writableCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN, Colour.GRAY_50);

                Map<String, Object> colDef = groupColDefList.get(i);

                String colName = (String) colDef.get("colName");
                int colSpan = NumberUtils.toInt((String) colDef.get("colSpan"));

                sheet.addCell(new Label(colIndex, 0, StringUtils.trim(colName), writableCellFormat));

                if (colSpan > 0) {
                    sheet.mergeCells(colIndex, 0, (colIndex + colSpan) - 1, 0);
                    sheet.addCell(new Label(colIndex, 0, StringUtils.trim(colName), writableCellFormat));
                    colIndex += colSpan - 1;
                }
            }

            if (StringUtils.isNotEmpty(frozenColIndex)) {
                sheet.getSettings().setHorizontalFreeze(Integer.parseInt(frozenColIndex));
                sheet.getSettings().setVerticalFreeze(2);
            }

            startRowIdx = 2;
        }

        for (int colIdx = 0, colLen = colNames.size(); colIdx < colLen; colIdx++) {

            writableCellFormat = new WritableCellFormat();
            writableCellFormat.setBackground(Colour.ICE_BLUE);
            writableCellFormat.setVerticalAlignment(VerticalAlignment.CENTRE);
            String align = colAlign.get(colIdx);
            if(align.equals("left")) {
                writableCellFormat.setAlignment(Alignment.LEFT);
            } else if(align.equals("center")) {
                writableCellFormat.setAlignment(Alignment.CENTRE);
            } else {
                writableCellFormat.setAlignment(Alignment.RIGHT);
            }

            writableCellFormat.setShrinkToFit(true);
            writableCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN, Colour.GRAY_50);

            sheet.addCell(new Label(colIdx, startRowIdx, colNames.get(colIdx), writableCellFormat));
            sheet.setColumnView(colIdx, colWidth); // width

            for (int rowIdx = startRowIdx, rowLen = data.size(); rowIdx < rowLen; rowIdx++) {

                paramData = data.get(rowIdx).get(colIndex.get(colIdx));
                sheet.addCell(getCell(colIdx, rowIdx, paramData));

                if (paramData instanceof Map && attachImgFlag) {
                    imgPath = (String) ((Map) paramData).get("src");

                    if (imgPath == null || "".equals(imgPath)) {
                        continue;
                    }

                    BufferedImage buffImage = ImageIO.read(new URL(url + imgPath));

                    File output = new File(System.currentTimeMillis() + "temp.png");
                    ImageIO.write(buffImage, "png", output);

                    WritableImage image = new WritableImage(
                            colIdx, rowIdx + 1,   //column, row
                            imgWidth, imgHeight,   //width, height in terms of number of cells
                            output); //Supports only 'png' images

                    sheet.addImage(image);
                    sheet.setRowView(rowIdx + 1, Integer.parseInt(excelOptions.get("rowSize").toString())); // height
                }
            }
        }
    }

    @Override
    protected void afterWrite() throws IOException, WriteException {
        autoWidth();
        workbook.write();
        workbook.close();
    }

    private void autoWidth() throws RowsExceededException {
/*        for (int i = 0; i < colNames.length; i++) {
            CellView autoSizeCellView = new CellView();
            autoSizeCellView.setAutosize(true);
            sheet.setColumnView(i, autoSizeCellView);
        }*/
    }

    private String dataValid(Object data) {
        if (data instanceof String) {
            return (String) data;
        } else if (data instanceof Map) {

            Object tmp = ((Map) data).get("text");

            if (tmp instanceof Double || tmp instanceof Integer || data instanceof Long) {
                return new DecimalFormat("#.#").format(new BigDecimal(tmp.toString()));
            } else if (data instanceof Boolean) {
                return tmp.toString();
            } else {
                if (tmp == null) return "";
                else return tmp.toString();
            }
        } else if (data instanceof Boolean) {
            return data.toString();
        } else if (data instanceof Double || data instanceof Integer || data instanceof Long) {
            return new DecimalFormat("#.#").format(new BigDecimal(data.toString()));
        } else {
            return (String) data;
        }
    }

    private WritableCell getCell(int columnIndex, int rowIndex, Object data) throws ParseException {

        JXLCell cell = new JXLCell();
        cell.setColumnIdx(columnIndex);
        cell.setColumnId(colIndex.get(columnIndex));
        cell.setCellStr(dataValid(data));
        cell.setExcelRowIdx(rowIndex + 1);

        if (colTypes.get(columnIndex) == "number") {
            cell.setCellNum((String) data);
            return cell.getNumberCell();
        } else {
            return cell.getLabelCell();
        }
    }
}
