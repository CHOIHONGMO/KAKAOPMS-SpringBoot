package com.st_ones.common.file.service;

import com.st_ones.common.file.FileAttachMapper;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : FileAttachService.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 09. 11.
 * @version 1.0
 * @see
 */

@Service(value = "fileAttachService")
public class FileAttachService extends BaseService {

    @Autowired
    private FileAttachMapper fileAttachMapper;

    public synchronized String getUUID() throws InterruptedException {
        Thread.sleep(2);
        return UUIDGenerator.getUUID("UUID");
    }

    public void insertFileInfo(HashMap<String, String> fileSaveInfo) throws Exception {
        fileSaveInfo.put("TABLE_NM", "STOCATCH");
        fileAttachMapper.insertFileInfo(fileSaveInfo);
    }

    public List<Map<String, Object>> getFilesInfo(String bizType, String uuid) throws Exception {
        HashMap<String, String> hashMap = new HashMap<String, String>();
        hashMap.put("BIZ_TYPE", bizType);
        hashMap.put("UUID", uuid);
        return fileAttachMapper.getFileInfos(hashMap);
    }

    public Map<String, String> getFileInfo(String uuid, String uuid_sq) {
        HashMap<String, String> hashMap = new HashMap<String, String>();
        hashMap.put("UUID", uuid);
        hashMap.put("UUID_SQ", uuid_sq);
        return fileAttachMapper.getFileInfo(hashMap);
    }

    /**
     * 결재 시 결재정보 폼에 보여줄 첨부파일 목록을 HTML로 변환하여 보여주는 메소드입니다.
     * @param bizType
     * @param uuid
     * @return
     * @throws Exception
     */
    public String getFileInfosForSingleApprovalForm(String bizType, String uuid) throws Exception {

        if(bizType == null || uuid == null) {
            return "";
        }

        StringBuffer attachFileListHtml = new StringBuffer();
        HashMap<String, String> hashMap = new HashMap<String, String>();
        hashMap.put("BIZ_TYPE", bizType);
        hashMap.put("UUID", uuid);
        
        String domainName = PropertiesManager.getString("eversrm.system.domainName");
        String portNumber = PropertiesManager.getString("eversrm.system.domainPort");
        
        List<Map<String, Object>> fileInfos = fileAttachMapper.getFileInfos(hashMap);
        for (Map<String, Object> fileInfo : fileInfos) {

            String uuidSeq = EverString.nullToEmptyString(fileInfo.get("UUID_SQ"));
            String fileName = EverString.nullToEmptyString(fileInfo.get("REAL_FILE_NM"));
            attachFileListHtml.append("<a class=\"e-attachfile\" href=\"")
                    .append(domainName).append(":").append(portNumber)
                    .append("/common/file/fileAttach/download.so?")
                    .append("BIZ_TYPE=").append(bizType)
                    .append("&UUID=").append(uuid).append("&UUID_SQ=").append(uuidSeq)
                    .append("\">").append(fileName).append("</a><br>");
        }

        return attachFileListHtml.toString();
    }

    /**
     * UUID와 UUID_SQ로 파일을 지정해 삭제합니다.
     * @param fileObjMap
     * @throws Exception
     */
    public void deleteFile(Map<String, String> fileObjMap) throws Exception {

        Map<String, String> fileInfo = fileAttachMapper.getFileInfo(fileObjMap);
        String filePath = fileInfo.get("FILE_PATH");
        String fileName = fileInfo.get("FILE_NM");
        String fileExtension = fileInfo.get("FILE_EXTENSION");

        File file = new File(filePath + "/" + fileName + "." + fileExtension);

        boolean deleteStatus = file.delete();
        if(deleteStatus) {
            getLog().info("[{}] 파일이 삭제되었습니다.", filePath + "/" + fileName + "." + fileExtension);
        } else {
            getLog().info("[{}] 파일이 삭제되지 않았습니다.", filePath + "/" + fileName + "." + fileExtension);
        }

		/* This parameter is use for sync of each database server. */
        fileObjMap.put("TABLE_NM", "STOCATCH");
        fileAttachMapper.deleteFile(fileObjMap);
    }

    /**
     * UUID가 같은 모든 파일을 한번에 삭제합니다.
     * @param fileObjMap
     * @throws Exception
     */
    public void deleteFiles(Map<String, String> fileObjMap) throws Exception {

        List<Map<String, Object>> fileInfo = fileAttachMapper.getFileInfos(fileObjMap);

        for(Map<String, Object> param : fileInfo) {

            String filePath = EverString.nullToEmptyString(param.get("FILE_PATH"));
            String fileName = EverString.nullToEmptyString(param.get("FILE_NM"));
            String fileExtension = EverString.nullToEmptyString(param.get("FILE_EXTENSION"));

            File file = new File(filePath + "/" + fileName + "." + fileExtension);
            file.delete();

            Map<String, String> delParam = new HashMap<String, String>();
            delParam.put("UUID", EverString.nullToEmptyString(param.get("UUID")));
            delParam.put("UUID_SQ", EverString.nullToEmptyString(param.get("UUID_SQ")));
            delParam.put("TABLE_NM", "STOCATCH");
            fileAttachMapper.deleteFile(delParam);
        }
    }

    public int getFileCount(String uuid) {
        Map<String, String> map = new HashMap<String, String>();
        map.put("UUID", uuid);
        return fileAttachMapper.getFileCount(map);
    }

    public void setBinaryFileInfo(String uuid, String uuid_seq, byte[] binaryData){

        Map<String, Object> map = new HashMap<String, Object>();
        map.put("UUID", uuid);
        map.put("UUID_SQ", uuid_seq);
        map.put("BINARY_FILE_INFO", binaryData);
        fileAttachMapper.setBinaryFileInfo(map);
    }

    public Map<String, Object> getBinaryFileInfo(String uuid, String uuid_seq){
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("UUID", uuid);
        map.put("UUID_SQ", uuid_seq);
        return fileAttachMapper.getBinaryFileInfo(map);
    }
}