package com.st_ones.common.file.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletRequest;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.StringUtils;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.*;
import java.net.URLEncoder;
import java.util.*;

/**
 * <pre>
 * *****************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 * *****************************************************************************
 * </pre>
 *
 * @author Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @version 1.0
 * @File Name : FileAttachController.java
 * @date 2013. 09. 11.
 * @see
 */
@Controller
@RequestMapping(value = "/common/file")
public class FileAttachController extends BaseController {

    Logger logger = LoggerFactory.getLogger(FileAttachController.class);
    final static String DOWNLOAD_URL = "/common/file/fileAttach/download.so";

    final
    DocNumService docNumService;

    final
    FileAttachService fileAttachService;

    private final MessageService messageService;

    private final CommonComboService commonComboService;

    String imageFlag = "N";

    public FileAttachController(DocNumService docNumService, FileAttachService fileAttachService, MessageService messageService, CommonComboService commonComboService, ServletContext servletContext) {
        this.docNumService = docNumService;
        this.fileAttachService = fileAttachService;
        this.messageService = messageService;
        this.commonComboService = commonComboService;
        this.servletContext = servletContext;
    }

    private boolean isValidExtension(String fileExtension) {
        String[] extensions = getExtensionTypesProperty().split(";");
        String uploadPolicy = getUploadPolicyTypeProperty();

        if ("restrict".equals(uploadPolicy)) {
            for (String extension : extensions) if (extension.equalsIgnoreCase(fileExtension)) return false;
            return true;
        }
        for (String extension : extensions) if (extension.equalsIgnoreCase(fileExtension)) return true;
        return false;
    }

    private boolean isValidExtensionImage(String fileExtension) {
        String[] extensions = "jpg;jpe;jpeg;tif;gif;png".split(";");
        String uploadPolicy = getUploadPolicyTypeProperty();
        if ("restrict".equals(uploadPolicy)) {
            for (String extension : extensions) {
                if ((extension.equalsIgnoreCase(fileExtension))) {
                    return true;
                }
            }

            return false;
        }
        for (String extension : extensions) if (extension.equalsIgnoreCase(fileExtension)) return true;
        return false;

    }

    @ResponseBody
    @SuppressWarnings("unchecked")
    @RequestMapping(value = "/fileAttach/upload")
    public void fileAttachUpload(HttpServletRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> mRequest = new HashMap<String, String>();
        Enumeration en = req.getParameterNames();

        while (en.hasMoreElements()) {
            String paramName = en.nextElement().toString();
            String paramValue = req.getParameter(paramName);
            if (paramName == null || paramValue == null) continue;
            paramName = paramName.toUpperCase();

            mRequest.put(paramName, paramValue);
        }

        FileResult fileResult = new FileResult();

        req.setCharacterEncoding("utf-8"); // 주의:한글 파일명의 경우 flex에서 utf-8로 올려보냄 , euc-kr 일경우 선언 필요

        String bizType = req.getParameter("bizType");
        final String returnType = req.getParameter("returnType");
        if (EverString.isEmpty(bizType)) {
            bizType = "-";
        }
        final File tempDirectory = new File(getTempFilePath()); // 파일 임시 저장소
        final String targetDirectory = getFileUploadPath(bizType) + EverDate.getYear() + "/" + EverDate.getYear() + EverDate.getMonth(); // 파일 저장소

        checkDirectoryExist(targetDirectory, getTempFilePath());

        FileItemFactory factory = new DiskFileItemFactory(4096, tempDirectory);
        ServletFileUpload fileUpload = new ServletFileUpload(factory);
        List items = fileUpload.parseRequest((javax.servlet.http.HttpServletRequest) req);

        Iterator it = items.iterator();

        String uuid = req.getParameter("fileId");
        if (EverString.isEmpty(uuid)) {
            uuid = fileAttachService.getUUID();
        }

        while (it.hasNext()) {
            FileItem item = (FileItem) it.next();
            if (!item.isFormField()) {
                File clientFile = new File(item.getName());
                String fileName = clientFile.getName();
                if (req.getHeader("User-Agent").indexOf("MSIE 8.0") > -1) {
                    fileName = new String(fileName.getBytes("utf-8"), "utf-8");
                } else {
                    fileName = clientFile.getName();
                }

                String fileExtension = fileName.substring(fileName.lastIndexOf('.') + 1);

                if ("IMG".equals(bizType)) {
                    if (isValidExtensionImage(fileExtension) == false) {
                        String message = String.format("%s를 제외한 파일은 업로드 할 수 없습니다.", "jpe, jpg, jpeg, tif, gif, png");
                        String msg = URLEncoder.encode(message, "UTF-8");
                        resp.setResponseMessage(msg);
                        resp.setParameter("message", msg);
                        resp.setResponseCode("false");

                        resp.setStatus(601);
                        return;
                    }
                } else {
                    if (isValidExtension(fileExtension) == false) {
                        String message = String.format("%s를 제외한 파일은 업로드 할 수 없습니다.", PropertiesManager.getString("everf.fileUpload.extension.type"));
                        String msg = URLEncoder.encode(message, "UTF-8");
                        resp.setResponseMessage(msg);
                        resp.setParameter("message", msg);
                        resp.setResponseCode("false");

                        resp.setStatus(601);
                        return;
                    }

                }


                String uuidSeq = null;
                synchronized (this) {
                    Thread.sleep(2);
                    uuidSeq = String.valueOf(System.currentTimeMillis());
                }

                File tempFile;
                boolean isEncryptFile = false;
                boolean useFileDecryptionModule = PropertiesManager.getBoolean("everf.file.use.security.module");
                logger.info("첨부파일 암호화 여부가 [{}]로 설정되어 있습니다. ", useFileDecryptionModule);

                tempFile = new File(tempDirectory + "/" + uuid + "_" + uuidSeq + "." + fileExtension);
                item.write(tempFile);

                File targetFile = new File(targetDirectory + "/" + uuid + "_" + uuidSeq + "." + fileExtension);
                logger.info("[{}] 파일을 [{}] 경로로 이동시킵니다.", tempFile.getName(), targetFile.getPath());
                FileUtils.moveFile(tempFile, targetFile);

                if (targetFile.exists()) {
                    logger.info("[{}] 파일이 생성되었습니다.", targetFile.getParent());
                }

                String fileSize = String.valueOf(item.getSize());

                try {
                    String[] fileName1 = clientFile.getName().split("\\\\");
                    int length = fileName1.length;
                    String fileName2 = fileName1[length - 1];
                    fileName = fileName2;

                } catch (Exception e) {
                    logger.error(e.getMessage(), e);
                }

                HashMap<String, String> fileSaveInfo = getFileSaveInfo(bizType, targetDirectory, fileName, fileExtension, uuid, uuidSeq, fileSize, isEncryptFile);
                // 파일 해시 값을 저장한다.
                fileSaveInfo.put("HASH_NUM", EverFile.fileToHash(targetFile));
                fileAttachService.insertFileInfo(fileSaveInfo);

                if (StringUtils.equals(returnType, "json")) {
                    String userAgent = req.getHeader("User-Agent");
                    if (userAgent != null && userAgent.indexOf("MSIE") > -1) {
                        resp.setContentType("text/html");
                    } else {
                        resp.setContentType("application/json");
                    }

                    resp.setCharacterEncoding("utf-8");

                    fileSaveInfo.put("downloadUrl", getDownloadUrl(uuid, uuidSeq));
                    fileResult.setNewUuid(uuid + "_" + uuidSeq);
                    fileResult.setSuccess(true);
                    resp.getWriter().write(new ObjectMapper().writeValueAsString(fileResult));
                } else {
                    Map<String, Object> fileItemModel = getFileItemModel(uuid, uuidSeq, fileSize);

                    fileResult.setSuccess(true);
                    resp.getWriter().write(new ObjectMapper().writeValueAsString(fileResult));
                }
            }
        }
    }

    private String stringToHex(String str) {
        StringBuffer sbuf = new StringBuffer();
        for (int i = 0; i < str.length(); i++) {
            sbuf.append(" 0x" + Integer.toHexString(str.charAt(i)).toUpperCase());

        }
        return sbuf.toString();
    }

    private Map<String, Object> getFileItemModel(String uuid, String uuidSeq, String fileSize) {
        Map<String, Object> fileItemModel = new HashMap<String, Object>();
        fileItemModel.put("fileId", uuid + uuidSeq);
        fileItemModel.put("fileName", uuid + uuidSeq);
        fileItemModel.put("fileSize", fileSize);
        fileItemModel.put("fileValue", getDownloadUrl(uuid, uuidSeq));
        return fileItemModel;
    }

    private final ServletContext servletContext;

    @RequestMapping(value = "/fileAttach/getUploadedFileInfo")
    public void getUploadedFileInfo(HttpServletRequest req,
                                    EverHttpResponse resp,
                                    @RequestParam(value = "bizType", required = false, defaultValue = "-") String bizType,
                                    @RequestParam("fileId") String uuid,
                                    @RequestParam(value = "caller", required = false, defaultValue = "-") String caller) throws Exception {

        List<Map<String, Object>> fileInfo = fileAttachService.getFilesInfo(bizType, uuid);
        if (bizType.equals("IMG")) {
            for (Map<String, Object> file : fileInfo) {

                try {
                    File imageFile = new File(file.get("FILE_PATH") + "/" + file.get("FILE_NM") + "." + file.get("FILE_EXTENSION"));
                    String encode = new String(Base64.getEncoder().encode(FileUtils.readFileToByteArray(imageFile)));
                    file.put("BYTE_ARRAY", encode);
                } catch (FileNotFoundException e) {
                    File imageFile = new File(servletContext.getRealPath("/images/noimage.jpg"));
                    String encode = new String(Base64.getEncoder().encode(FileUtils.readFileToByteArray(imageFile)));
                    file.put("BYTE_ARRAY", encode);
                }
            }
        }

        ObjectMapper om = new ObjectMapper();

        if (StringUtils.equals(caller, "fileManager")) {

            for (Map<String, Object> file : fileInfo) {
                file.put("uuid", file.get("fileId"));   // fine-uploader에서 uuid로 받음
            }

            resp.getWriter().println(om.writeValueAsString(fileInfo));
        } else {
            for (Map<String, Object> file : fileInfo) {
                file.put("uuid", file.get("fileId"));   // fine-uploader에서 uuid로 받음
            }

            resp.setParameter("fileInfo", om.writeValueAsString(fileInfo));
            resp.setResponseMessage("success");
            resp.setResponseCode("true");
        }
    }

    /**
     * 서버에 업로드된 파일정보를 리턴합니다.
     *
     * @param bizType
     * @param uuid
     * @return
     */
    public List<Map<String, Object>> getUploadedFileInfo(String bizType, String uuid) throws Exception {
        return fileAttachService.getFilesInfo(bizType, uuid);
    }

    private HashMap<String, String> getFileSaveInfo(final String bizType, final String filePath, String fileName, String fileExtension, String uuid, String uuidSeq, String fileSize, boolean isEncryptFile) throws UnsupportedEncodingException {

        HashMap<String, String> fileSaveInfo = new HashMap<String, String>();
        fileSaveInfo.put("UUID", uuid);
        fileSaveInfo.put("UUID_SQ", uuidSeq);
        fileSaveInfo.put("fileSeq", String.valueOf(fileAttachService.getFileCount(uuid)));
        fileSaveInfo.put("fileName", uuid + "_" + uuidSeq);
        fileSaveInfo.put("FILE_PATH", filePath);
        fileSaveInfo.put("FILE_SIZE", fileSize);
        fileSaveInfo.put("EXTENSION", fileExtension);
        fileSaveInfo.put("REAL_FILE_NM", fileName);
        fileSaveInfo.put("BIZ_TYPE", bizType);
        fileSaveInfo.put("ENC_FLAG", isEncryptFile == true ? "1" : "0");

        return fileSaveInfo;
    }

    private String getDownloadUrl(String uuid, String uuidSeq) {
        return String.format("%s?UUID=%s&UUID_SQ=%s", DOWNLOAD_URL, uuid, uuidSeq);
    }

    private void checkDirectoryExist(String filePathParam, String tempPathParam) {

        File realPath = new File(filePathParam);
        File tempPath = new File(tempPathParam);
        if (!tempPath.isDirectory()) {
            tempPath.mkdirs();
        }
        if (!realPath.isDirectory()) {
            realPath.mkdirs();
        }
    }

    @RequestMapping(value = "/fileAttach/delete")
    public void deleteFile(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> paramDataMap = req.getParamDataMap();
        String[] fileUUID = req.getParameter("file_uuid").split("_");
        paramDataMap.put("UUID", fileUUID[0]);
        paramDataMap.put("UUID_SQ", fileUUID[1]);
        fileAttachService.deleteFile(paramDataMap);
        File tempDirectory = new File(getTempFilePath());
        if (tempDirectory.isDirectory()) {
            File[] listFiles = tempDirectory.listFiles();
            for (File file : listFiles) {
                if (file.canWrite()) {
                    file.delete();
                }
            }
        }

        resp.setResponseMessage("success");
        resp.setResponseCode("true");
    }

    @RequestMapping(value = "/fileAttach/deleteFile")
    public void fileAttachDeleteFile(EverHttpRequest req, EverHttpResponse resp) throws Exception {
//		String fileURL = req.getParameter("fileURL");
//		logger.error(fileURL);
//		if (fileURL == null) {
//			throw new NoResultException("fileURL is null!!!");
//		}

//		String paramString = fileURL.substring(fileURL.indexOf('?') + 1, fileURL.length());
//		String[] params = paramString.split("&");
        Map<String, String> paramMap = new HashMap<String, String>();
        paramMap.put("UUID", req.getParameter("UUID"));
        paramMap.put("UUID_SQ", req.getParameter("UUID_SQ"));
        fileAttachService.deleteFile(paramMap);
        File tempDirectory = new File(getTempFilePath());
        if (tempDirectory.isDirectory()) {
            File[] listFiles = tempDirectory.listFiles();
            for (File file : listFiles) {
                if (file.canWrite()) {
                    file.delete();
                }
            }
        }
        resp.setParameter("UUID", paramMap.get("UUID"));
        resp.setParameter("UUID_SQ", paramMap.get("UUID_SQ"));
        resp.setParameter("FILE_COUNT", String.valueOf(fileAttachService.getFileCount(paramMap.get("UUID"))));
        resp.setResponseMessage("success");
        resp.setResponseCode("true");
    }

    @RequestMapping(value = "/fileAttach/download")
    public void fileAttachDownload(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        File finalFile = null;
        boolean shouldDecryptFile = false;

        DataInputStream in = null;
        ServletOutputStream op = null;

        try {

            String userAgent = req.getHeader("User-Agent");
            if (org.apache.commons.lang.StringUtils.containsIgnoreCase(userAgent, "android")
                    || org.apache.commons.lang.StringUtils.containsIgnoreCase(userAgent, "iphone")) {

                if (req.getSession().getAttribute("ses") == null) {

                    resp.setContentType("text/html; charset=UTF-8");
                    resp.setCharacterEncoding("utf-8");
                    String domainUrl = PropertiesManager.getString("eversrm.system.domainUrl");
                    resp.getWriter().write("<script type='text/javascript'>location.href='/welcome?returnUrl=" + URLEncoder.encode(domainUrl + req.getRequestURI() + "?" + req.getQueryString(), "UTF-8") + "';</script>");
                    resp.getWriter().flush();
                    resp.getWriter().close();
                    return;
                }

            }

            if (req.getSession().getAttribute("ses") == null) {
                resp.getWriter().write("<script type='text/javascript'>alert('로그인하셔야 합니다.');</script>");
                resp.getWriter().flush();
                resp.getWriter().close();
                return;
            }

            String uuid = req.getParameter("UUID");
            String uuid_seq = req.getParameter("UUID_SQ");

            Map<String, String> fileInfo = fileAttachService.getFileInfo(uuid, uuid_seq);
            if (fileInfo == null || fileInfo.size() == 0) {
                throw new FileNotFoundException();
            }

            String sourceFile = fileInfo.get("FILE_PATH") + "/" + fileInfo.get("FILE_NM") + "." + fileInfo.get("FILE_EXTENSION");
            String originalFileName = fileInfo.get("REAL_FILE_NM");
            int length = 0;
            ServletContext context = req.getSession().getServletContext();
            String mimeType = context.getMimeType(sourceFile);

            finalFile = new File(sourceFile);
            if (!finalFile.isFile()) {
                logger.error("파일이 존재하지 않습니다: [{}]", sourceFile);
                finalFile = new File(servletContext.getRealPath("/images/noimage.jpg"));
                throw new FileNotFoundException("FILE NOT FOUND");
            }

            resp.setContentLength((int) finalFile.length());
            resp.setContentType((mimeType != null) ? mimeType : "application/octet-stream;");

            boolean ie = (userAgent.indexOf("MSIE") > -1) || (userAgent.indexOf("Trident") > -1);

            logger.info("userAgent: {}", userAgent);

            String fileName;
            if (ie) {
                fileName = URLEncoder.encode(originalFileName, "UTF-8").replaceAll("\\+", "%20");
            } else {

                StringBuffer sb = new StringBuffer();
                for (int i = 0; i < originalFileName.length(); i++) {
                    char c = originalFileName.charAt(i);
                    if (c > '~') {
                        sb.append(URLEncoder.encode("" + c, "UTF-8"));
                    } else {
                        sb.append(c);
                    }
                }
                fileName = sb.toString();
            }

            resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

//            if (userAgent != null && userAgent.indexOf("MSIE 5.5") > -1) { // MS IE 5.5 이하
//                resp.setHeader("Content-Disposition", "filename=" + URLEncoder.encode(original_filename, "UTF-8").replaceAll("\\+", "%20") + ";");
//            } else if (userAgent != null && userAgent.indexOf("MSIE") > -1) { // MS IE (보통은 6.x 이상 가정)
//                resp.setHeader("Content-Disposition", "attachment; filename=" + java.net.URLEncoder.encode(original_filename, "UTF-8").replaceAll("\\+", "%20") + ";");
//            } else { // 모질라나 오페라
//                resp.setHeader("Content-Disposition", "attachment; filename=" + new String(original_filename.getBytes("UTF-8"), "latin1").replaceAll("\\+", "%20") + ";");
//            }


            try {
                op = resp.getOutputStream();
                byte[] bbuf = new byte[4096];

                // 협력업체용 참부파일 (BID (입찰), BOARD(공지사항), CONT(계약) )
//            in = new DataInputStream(new ByteArrayInputStream(binaryfile));
//            if (PropertiesManager.getString("everf.file.binary.bizTypes").indexOf(fileInfo.get("BIZ_TYPE")) >= 0) {
//
//            } else {
                in = new DataInputStream(new FileInputStream(finalFile));
//            }
                while ((length = in.read(bbuf)) != -1) {
                    op.write(bbuf, 0, length);
                }
            } catch (Exception e) {

            } finally {
                if (in != null) {
                    in.close();
                }
                if (op != null) {
                    op.close();
                }
            }

        } catch (FileNotFoundException fne) {
            logger.error(fne.getMessage(), fne);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('첨부파일이 존재하지 않습니다.');</script>");
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('잘못된 접근을 시도했거나 서버에서 오류가 발생했습니다.\\n관리자에게 문의바랍니다.');</script>");
        } finally {

            if (shouldDecryptFile) {
                boolean deleteStatus = finalFile.delete();
                if (deleteStatus) {
                    logger.info("[{}] 복호화된 파일을 삭제처리했습니다.", finalFile.getPath());
                } else {
                    logger.info("[{}] 복호화된 파일을 삭제하지 못했습니다.", finalFile.getPath());
                }
            }

            if (op != null) {
                op.flush();
            }
            if (in != null) {
                in.close();
            }
            if (op != null) {
                op.close();
            }
        }
    }

    private String getUploadPolicyTypeProperty() {
        return PropertiesManager.getString("everf.fileUpload.policy.type");
    }

    private String getExtensionTypesProperty() {
        return PropertiesManager.getString("everf.fileUpload.extension.type");
    }

    private String getFileUploadPath(String bizType) {
        return EverString.nullToEmptyString(bizType).equals("IMG") ? PropertiesManager.getString("everf.imageUpload.path") : PropertiesManager.getString("everf.fileUpload.path") + bizType + "/";
    }

    /**
     * 업무타입이 IMG일 때 파일다운로드 경로를 가져옵니다.
     * 이 경로는 업로드할 때와 똑같기 때문에 그냥 업로드 프라퍼티를 그대로 사용합니다.
     *
     * @param bizType
     * @return
     */
    private String getFileDownloadPath(String bizType) {
        return EverString.nullToEmptyString(bizType).equals("IMG") ? PropertiesManager.getString("everf.imageUpload.path") : PropertiesManager.getString("everf.fileUpload.path") + bizType + "/";
    }

    private String getTempFilePath() {
        return PropertiesManager.getString("everf.fileUpload.tempPath");
    }

    @RequestMapping(value = "/fileAttach/show")
    public String fileAttachView(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String bizType = req.getParameter("bizType");
        String uuid = req.getParameter("uuid");
        String callback = req.getParameter("callback");
        String nRow = req.getParameter("nRow");
        String detailView = req.getParameter("detailView");

        if (EverString.isEmpty(bizType)) throw new NoResultException("biz Type must Set!.");

        resp.setParameter("bizType", bizType);
        resp.setParameter("uuid", uuid);
        resp.setParameter("callback", callback);
        resp.setParameter("nRow", nRow);
        resp.setParameter("detailView", detailView);

        return "/common/file/fileAttach";
    }

    @Test
    public void uploadFile() throws Exception {

        String uuidPrefix = EverDate.getDate2();
        String uuidPostfix = RandomStringUtils.randomAlphanumeric(11);
        logger.info(uuidPrefix + "_" + uuidPostfix);

        String uuidSeq = RandomStringUtils.randomAlphanumeric(30);
        logger.info(uuidSeq);

        String path = getFileUploadPath("S2");
        logger.info(path + "S2/" + uuidPrefix);

        File f = new File(path + "S2/" + uuidPrefix);
        if (!f.exists()) {
            f.mkdirs();
        }

        File f2 = new File("C:/AA/BB/CC.txt");
        logger.info(f2.getPath());
        logger.info(f2.getAbsolutePath());
        logger.info(f2.getCanonicalPath());

    }

    @RequestMapping(value = "/dirFiles")
    public void dirFiles(EverHttpRequest req, EverHttpResponse resp) throws IOException {

        String fileList = "";
        String dir = req.getParameter("dir");
        if (StringUtils.isNotEmpty(dir)) {
            Iterator<File> fileIterator = FileUtils.iterateFiles(new File(dir), null, false);
            while (fileIterator.hasNext()) {
                fileList += fileIterator.next().getName() + "<br/>";
            }
        }

        resp.getWriter().write(fileList);
        resp.setContentType("text/html");
    }

    // /common/file/getTmplAttFileNum
    @RequestMapping(value = "/getTmplAttFileNum")
    public void getTmplAttFileNum(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String attFileNum = "";
        String tmplNum = req.getParameter("tmplNum");

        List<Map<String, String>> codeCombo = commonComboService.getCodeCombo("CB0063");
        for (Map<String, String> code : codeCombo) {
            if (code.get("value").equals(tmplNum)) {
                attFileNum = code.get("ATT_FILE_NUM");
                break;
            }
        }
        resp.setParameter("attFileNum", attFileNum);
    }

    @Test
    public void testDir() {

        String fileList = "";
        Iterator<File> fileIterator = FileUtils.iterateFiles(new File("C:/Temp"), null, false);
        while (fileIterator.hasNext()) {
            fileList += fileIterator.next().getName() + "\n";
        }

        logger.info(fileList);
    }


    @RequestMapping(value = "/fileAttach/downloadPoPdf")
    public void fileAttachDownloadPoPdf(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        File finalFile = null;
        boolean shouldDecryptFile = false;

        DataInputStream in = null;
        ServletOutputStream op = null;

        try {

            String userAgent = req.getHeader("User-Agent");

            String poNum = req.getParameter("poNum");

            String poPdfpath = PropertiesManager.getString("html.output.path.po");


            String sourceFile = poPdfpath + poNum + ".pdf";
            String originalFileName = poNum + ".pdf";
            int length = 0;
            ServletContext context = req.getSession().getServletContext();
            String mimeType = context.getMimeType(sourceFile);

            finalFile = new File(sourceFile);
            if (!finalFile.isFile()) {
                logger.error("파일이 존재하지 않습니다: [{}]", sourceFile);
                finalFile = new File(servletContext.getRealPath("/images/noimage.jpg"));
                throw new FileNotFoundException("FILE NOT FOUND");
            }

            resp.setContentLength((int) finalFile.length());
            resp.setContentType((mimeType != null) ? mimeType : "application/octet-stream;");

            boolean ie = (userAgent.indexOf("MSIE") > -1) || (userAgent.indexOf("Trident") > -1);

            logger.info("userAgent: {}", userAgent);

            String fileName;
            if (ie) {
                fileName = URLEncoder.encode(originalFileName, "UTF-8").replaceAll("\\+", "%20");
            } else {

                StringBuffer sb = new StringBuffer();
                for (int i = 0; i < originalFileName.length(); i++) {
                    char c = originalFileName.charAt(i);
                    if (c > '~') {
                        sb.append(URLEncoder.encode("" + c, "UTF-8"));
                    } else {
                        sb.append(c);
                    }
                }
                fileName = sb.toString();
            }

            resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

            try {
                op = resp.getOutputStream();
                byte[] bbuf = new byte[4096];

                in = new DataInputStream(new FileInputStream(finalFile));
                while ((length = in.read(bbuf)) != -1) {
                    op.write(bbuf, 0, length);
                }
            } catch (Exception e) {

            } finally {
                if (in != null) {
                    in.close();
                }
                if (op != null) {
                    op.close();
                }
            }

        } catch (FileNotFoundException fne) {
            logger.error(fne.getMessage(), fne);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('첨부파일이 존재하지 않습니다.');</script>");
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('잘못된 접근을 시도했거나 서버에서 오류가 발생했습니다.\\n관리자에게 문의바랍니다.');</script>");
        } finally {

            if (shouldDecryptFile) {
                boolean deleteStatus = finalFile.delete();
                if (deleteStatus) {
                    logger.info("[{}] 복호화된 파일을 삭제처리했습니다.", finalFile.getPath());
                } else {
                    logger.info("[{}] 복호화된 파일을 삭제하지 못했습니다.", finalFile.getPath());
                }
            }

            if (op != null) {
                op.flush();
            }
            if (in != null) {
                in.close();
            }
            if (op != null) {
                op.close();
            }
        }
    }


    @RequestMapping(value = "/fileAttach/downloadInvPdf")
    public void fileAttachDownloadInvPdf(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        File finalFile = null;
        boolean shouldDecryptFile = false;

        DataInputStream in = null;
        ServletOutputStream op = null;

        try {

            String userAgent = req.getHeader("User-Agent");

            String invNum = req.getParameter("invNum");
            String type = req.getParameter("type");

            String invPdfpath = PropertiesManager.getString("html.output.path.iv");


            String sourceFile = invPdfpath + invNum + "_" + type + ".pdf";
            String originalFileName = invNum + "_" + type + ".pdf";
            int length = 0;
            ServletContext context = req.getSession().getServletContext();
            String mimeType = context.getMimeType(sourceFile);

            finalFile = new File(sourceFile);
            if (!finalFile.isFile()) {
                logger.error("파일이 존재하지 않습니다: [{}]", sourceFile);
                finalFile = new File(servletContext.getRealPath("/images/noimage.jpg"));
                throw new FileNotFoundException("FILE NOT FOUND");
            }

            resp.setContentLength((int) finalFile.length());
            resp.setContentType((mimeType != null) ? mimeType : "application/octet-stream;");

            boolean ie = (userAgent.indexOf("MSIE") > -1) || (userAgent.indexOf("Trident") > -1);

            logger.info("userAgent: {}", userAgent);

            String fileName;
            if (ie) {
                fileName = URLEncoder.encode(originalFileName, "UTF-8").replaceAll("\\+", "%20");
            } else {

                StringBuffer sb = new StringBuffer();
                for (int i = 0; i < originalFileName.length(); i++) {
                    char c = originalFileName.charAt(i);
                    if (c > '~') {
                        sb.append(URLEncoder.encode("" + c, "UTF-8"));
                    } else {
                        sb.append(c);
                    }
                }
                fileName = sb.toString();
            }

            resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

            try {
                op = resp.getOutputStream();
                byte[] bbuf = new byte[4096];

                in = new DataInputStream(new FileInputStream(finalFile));
                while ((length = in.read(bbuf)) != -1) {
                    op.write(bbuf, 0, length);
                }
            } catch (Exception e) {

            } finally {
                if (in != null) {
                    in.close();
                }
                if (op != null) {
                    op.close();
                }
            }

        } catch (FileNotFoundException fne) {
            logger.error(fne.getMessage(), fne);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('첨부파일이 존재하지 않습니다.');</script>");
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('잘못된 접근을 시도했거나 서버에서 오류가 발생했습니다.\\n관리자에게 문의바랍니다.');</script>");
        } finally {

            if (shouldDecryptFile) {
                boolean deleteStatus = finalFile.delete();
                if (deleteStatus) {
                    logger.info("[{}] 복호화된 파일을 삭제처리했습니다.", finalFile.getPath());
                } else {
                    logger.info("[{}] 복호화된 파일을 삭제하지 못했습니다.", finalFile.getPath());
                }
            }

            if (op != null) {
                op.flush();
            }
            if (in != null) {
                in.close();
            }
            if (op != null) {
                op.close();
            }
        }
    }


    @RequestMapping(value = "/fileAttach/downloadContPdf")
    public void fileAttachDownloadContPdf(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        File finalFile = null;
        boolean shouldDecryptFile = false;

        DataInputStream in = null;
        ServletOutputStream op = null;

        try {

            String userAgent = req.getHeader("User-Agent");

            String contNum = req.getParameter("contNum");
            String contCnt = req.getParameter("contCnt");

            String poPdfpath = PropertiesManager.getString("html.output.path");
            String contFile = contNum + "@" + contCnt + ".pdf";

            String sourceFile = poPdfpath + contFile;
            String originalFileName = contFile;
            int length = 0;
            ServletContext context = req.getSession().getServletContext();
            String mimeType = context.getMimeType(sourceFile);

            finalFile = new File(sourceFile);
            if (!finalFile.isFile()) {
                logger.error("파일이 존재하지 않습니다: [{}]", sourceFile);
                finalFile = new File(servletContext.getRealPath("/images/noimage.jpg"));
                throw new FileNotFoundException("FILE NOT FOUND");
            }

            resp.setContentLength((int) finalFile.length());
            resp.setContentType((mimeType != null) ? mimeType : "application/octet-stream;");

            boolean ie = (userAgent.indexOf("MSIE") > -1) || (userAgent.indexOf("Trident") > -1);

            logger.info("userAgent: {}", userAgent);

            String fileName;
            if (ie) {
                fileName = URLEncoder.encode(originalFileName, "UTF-8").replaceAll("\\+", "%20");
            } else {

                StringBuffer sb = new StringBuffer();
                for (int i = 0; i < originalFileName.length(); i++) {
                    char c = originalFileName.charAt(i);
                    if (c > '~') {
                        sb.append(URLEncoder.encode("" + c, "UTF-8"));
                    } else {
                        sb.append(c);
                    }
                }
                fileName = sb.toString();
            }

            resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

            try {
                op = resp.getOutputStream();
                byte[] bbuf = new byte[4096];

                in = new DataInputStream(new FileInputStream(finalFile));
                while ((length = in.read(bbuf)) != -1) {
                    op.write(bbuf, 0, length);
                }
            } catch (Exception e) {

            } finally {
                if (in != null) {
                    in.close();
                }
                if (op != null) {
                    op.close();
                }
            }

        } catch (FileNotFoundException fne) {
            logger.error(fne.getMessage(), fne);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('첨부파일이 존재하지 않습니다.');</script>");
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('잘못된 접근을 시도했거나 서버에서 오류가 발생했습니다.\\n관리자에게 문의바랍니다.');</script>");
        } finally {

            if (shouldDecryptFile) {
                boolean deleteStatus = finalFile.delete();
                if (deleteStatus) {
                    logger.info("[{}] 복호화된 파일을 삭제처리했습니다.", finalFile.getPath());
                } else {
                    logger.info("[{}] 복호화된 파일을 삭제하지 못했습니다.", finalFile.getPath());
                }
            }

            if (op != null) {
                op.flush();
            }
            if (in != null) {
                in.close();
            }
            if (op != null) {
                op.close();
            }
        }
    }


    @RequestMapping(value = "/fileAttach/downloadAsIsFile")
    public void downloadAsIsFile(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        File finalFile = null;
        boolean shouldDecryptFile = false;

        DataInputStream in = null;
        ServletOutputStream op = null;

        try {

            String userAgent = req.getHeader("User-Agent");

            String fileNm = req.getParameter("fileNm");

            String poPdfpath = PropertiesManager.getString("asis.file.path");
            String contFile = fileNm + ".pdf";

            String sourceFile = poPdfpath + contFile;
            String originalFileName = contFile;
            int length = 0;
            ServletContext context = req.getSession().getServletContext();
            String mimeType = context.getMimeType(sourceFile);

            finalFile = new File(sourceFile);
            if (!finalFile.isFile()) {
                logger.error("파일이 존재하지 않습니다: [{}]", sourceFile);
                finalFile = new File(servletContext.getRealPath("/images/noimage.jpg"));
                throw new FileNotFoundException("FILE NOT FOUND");
            }

            resp.setContentLength((int) finalFile.length());
            resp.setContentType((mimeType != null) ? mimeType : "application/octet-stream;");

            boolean ie = (userAgent.indexOf("MSIE") > -1) || (userAgent.indexOf("Trident") > -1);

            logger.info("userAgent: {}", userAgent);

            String fileName;
            if (ie) {
                fileName = URLEncoder.encode(originalFileName, "UTF-8").replaceAll("\\+", "%20");
            } else {

                StringBuffer sb = new StringBuffer();
                for (int i = 0; i < originalFileName.length(); i++) {
                    char c = originalFileName.charAt(i);
                    if (c > '~') {
                        sb.append(URLEncoder.encode("" + c, "UTF-8"));
                    } else {
                        sb.append(c);
                    }
                }
                fileName = sb.toString();
            }

            resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

            try {
                op = resp.getOutputStream();
                byte[] bbuf = new byte[4096];

                in = new DataInputStream(new FileInputStream(finalFile));
                while ((length = in.read(bbuf)) != -1) {
                    op.write(bbuf, 0, length);
                }
            } catch (Exception e) {

            } finally {
                if (in != null) {
                    in.close();
                }
                if (op != null) {
                    op.close();
                }
            }

        } catch (FileNotFoundException fne) {
            logger.error(fne.getMessage(), fne);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('첨부파일이 존재하지 않습니다.');</script>");
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("utf-8");
            resp.getWriter().write("<script type='text/javascript'>alert('잘못된 접근을 시도했거나 서버에서 오류가 발생했습니다.\\n관리자에게 문의바랍니다.');</script>");
        } finally {

            if (shouldDecryptFile) {
                boolean deleteStatus = finalFile.delete();
                if (deleteStatus) {
                    logger.info("[{}] 복호화된 파일을 삭제처리했습니다.", finalFile.getPath());
                } else {
                    logger.info("[{}] 복호화된 파일을 삭제하지 못했습니다.", finalFile.getPath());
                }
            }

            if (op != null) {
                op.flush();
            }
            if (in != null) {
                in.close();
            }
            if (op != null) {
                op.close();
            }
        }
    }
}