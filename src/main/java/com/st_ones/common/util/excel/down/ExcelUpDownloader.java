package com.st_ones.common.util.excel.down;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.excel.upload.ExcelImportHandler;
import com.st_ones.common.util.service.UtilService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FileUtils;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.xssf.usermodel.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.io.*;
import java.net.URLEncoder;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@Controller
@RequestMapping(value = "/grid", method = RequestMethod.POST)
public class ExcelUpDownloader {

    Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private UtilService utilService;

    @RequestMapping(value = "/uploadExcel", method = RequestMethod.POST)
    public void uploadExcel(HttpServletRequest req, HttpServletResponse res) throws IOException {

        String tempFileName = "excelUploadTempFile_"+System.currentTimeMillis()+".xlsx";
        String sourceFilePath = PropertiesManager.getString("everf.fileUpload.tempPath") + "excelUpload/" + tempFileName;
        String targetFilePath = PropertiesManager.getString("everf.fileUpload.tempPath") + "excelUpload/dec_" + tempFileName;

        res.setCharacterEncoding("UTF-8");
        res.setContentType("text/html; charset=UTF-8");

        List<FileItem> fileItems;

        PrintWriter writer = res.getWriter();
        Map<String, Object> resultMap = new HashMap<String, Object>();
        ServletFileUpload fileUpload = new ServletFileUpload(new DiskFileItemFactory());

        try {
            fileItems = fileUpload.parseRequest((javax.servlet.http.HttpServletRequest) req);
        } catch (FileUploadException fue) {
            resultMap.put("errorMessage", fue.getMessage());
            writer.println(new ObjectMapper().writeValueAsString(resultMap));
            logger.error(fue.getMessage(), fue);
            return;
        }

        FileItem excelFileItem = null;
        for(FileItem fileItem : fileItems) {

            if(fileItem.getFieldName().equals("file-0")) {
                excelFileItem = fileItem;
            }
        }

        String gridData = null;
        try {

            File tempDirectory = new File(PropertiesManager.getString("everf.fileUpload.tempPath") + "excelUpload/");
            if(!tempDirectory.isDirectory()) {
                tempDirectory.mkdirs();
            }

            /*File excelTempFile = new File(sourceFilePath);
            excelFileItem.write(excelTempFile);*/

            gridData = new ExcelImportHandler(excelFileItem.getName()).read2(excelFileItem.getInputStream());

        } catch(Exception e) {

            resultMap.put("errorMessage", e.getMessage());
            writer.println(new ObjectMapper().writeValueAsString(resultMap));
            logger.error(e.getMessage(), e);

        } finally {

            File tFile = new File(sourceFilePath);
            if(tFile.exists()) {
                FileUtils.forceDelete(tFile);
                logger.info("[{}] 임시파일을 삭제합니다.", tFile.getPath());
            }

            File t2File = new File(targetFilePath);
            if(t2File.exists()) {
                FileUtils.forceDelete(t2File);
                logger.info("[{}] 임시파일을 삭제합니다.", t2File.getPath());
            }
        }

        resultMap.put("gridData", gridData);
        writer.println(new ObjectMapper().writeValueAsString(resultMap));

    }

    @RequestMapping(value ="downloadExcel")
    public void downloadExcel(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String screenId = req.getParameter("screenId");
        String fileName = req.getParameter("fileName");
        String finalPath = PropertiesManager.getString("everf.fileUpload.tempPath") + "excelDownload/" + fileName;

        try {
            String data = req.getParameter("data");
            if (data.length() > 0) {

                byte[] fileData = Base64.getDecoder().decode(data);

                File file = new File(finalPath);
                FileUtils.writeByteArrayToFile(file, fileData);

                FileInputStream fis = null;
                XSSFWorkbook workbook = null;

                try {

                    fis= new FileInputStream(file);

                    // HSSFWorkbook은 엑셀파일 전체 내용을 담고 있는 객체
                    workbook = new XSSFWorkbook(fis);
                    // 탐색에 사용할 Sheet, Row, Cell 객체
                    XSSFSheet curSheet;
                    XSSFRow curRow;
                    XSSFCell curCell;
                    XSSFDataFormat format = workbook.createDataFormat();

                    // Sheet 탐색 for문
                    for(int sheetIndex = 0 ; sheetIndex < workbook.getNumberOfSheets(); sheetIndex++) {
                        // 현재 Sheet 반환
                        curSheet = workbook.getSheetAt(sheetIndex);
                        // row 탐색 for문
                        for(int rowIndex=0; rowIndex < curSheet.getPhysicalNumberOfRows(); rowIndex++) {
                            // row 0은 헤더정보이기 때문에 무시
                            if(rowIndex != 0) {
                                // 현재 row 반환
                                curRow = curSheet.getRow(rowIndex);
                                String value;
                                // row의 첫번째 cell값이 비어있지 않은 경우 만 cell탐색
                                // if(!"".equals(curRow.getCell(0).getStringCellValue())) {

                                    // cell 탐색 for 문
                                    for(int cellIndex=0;cellIndex<curRow.getPhysicalNumberOfCells(); cellIndex++) {
                                        curCell = curRow.getCell(cellIndex);
                                        CellStyle cellStyle = curCell.getCellStyle();
                                        String styleString = cellStyle.getDataFormatString();
                                        if(true) {
                                            value = "";
                                         // cell 스타일이 다르더라도 String으로 반환 받음
                                            switch (curCell.getCellType()) {
                                                case FORMULA:
                                                    value = curCell.getCellFormula();
                                                    break;
                                                case NUMERIC:
                                                    if(!"".equals(value)) {
                                                        value = curCell.getNumericCellValue() + "";
                                                    } else {
                                                        value = "0";
                                                    }
                                                    break;
                                                case STRING:
                                                    value = curCell.getStringCellValue() + "";
                                                    break;
                                                case BLANK:
                                                    value = curCell.getBooleanCellValue() + "";
                                                    break;
                                                case ERROR:
                                                    value = curCell.getErrorCellValue() + "";
                                                    break;
                                                default:
                                                    value = new String();
                                                    break;
                                            }
                                        }

                                        // 소숫점 포맷 수정
                                        if( styleString.indexOf(".0#") > -1 && value.contains(".0")) {
                                            cellStyle.setDataFormat(format.getFormat("#,##0"));
                                        }

                                        // 16진수 형식으로 받아 오는지 체크
                                        Boolean reg = Pattern.matches("^[A-Z]*$", value);
                                        if( styleString.indexOf(".0#") > -1 && !reg) {
                                            cellStyle.setDataFormat(format.getFormat("#,##0"));
                                        }
                                    }
                                // }
                            }
                        }
                    }

                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();

                } finally {
                    try {
                        FileOutputStream fileOut = new FileOutputStream(file);
                        workbook.write(fileOut);
                        fileOut.close();

                        // 사용한 자원은 finally에서 해제
                        if( fis!= null) fis.close();

                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }

                UserInfo userInfo = UserInfoManager.getUserInfo();

                utilService.logForJob("ExcelDownload", "com.st_ones.common.util.excel.down.ExcelUpDownloader.downloadExcel", screenId, "ExcelDownload", "엑셀 다운로드", "G", userInfo.getUserId(), userInfo.getIpAddress(), "", "");

                String userAgent = req.getHeader("User-Agent");
                boolean ie = (userAgent.indexOf("MSIE") > -1) || (userAgent.indexOf("Trident") > -1);

                if (ie) {

                    fileName = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
                } else if(userAgent.indexOf("Chrome") > -1) {

                    StringBuffer sb = new StringBuffer();
                    for (int i = 0; i < fileName.length(); i++) {
                        char c = fileName.charAt(i);
                        if (c > '~') {
                            sb.append(URLEncoder.encode("" + c, "UTF-8"));
                        } else {
                            sb.append(c);
                        }
                    }
                    fileName = sb.toString();
                } else {
                    fileName = new String(fileName.getBytes("UTF-8"), "iso-8859-1");
                }

                resp.addHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                resp.addHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                resp.addHeader("Pragma", "no-cache");

                ServletOutputStream outputStream = resp.getOutputStream();
                outputStream.write(FileUtils.readFileToByteArray(file));
                outputStream.flush();
            }
        } catch(Exception e) {
            logger.error(e.getMessage(), e);
            throw e;
        } finally {
            FileUtils.forceDeleteOnExit(new File(finalPath));
        }
    }
}
