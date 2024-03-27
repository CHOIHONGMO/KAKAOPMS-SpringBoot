package com.st_ones.common.file.web;

import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import jakarta.servlet.ServletException;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Map;

@Controller
public class ImageDispatcher  {

    private Logger logger = LoggerFactory.getLogger(ImageDispatcher.class);

    @Autowired
    FileAttachService fileAttachService;

    @RequestMapping(value = {"/common/images/*.jpeg", "/common/images/*.jpg",
                             "/common/images/*.png", "/common/images/*.gif",
                             "/common/images/*.tif"})
    protected void processImage(EverHttpRequest req, EverHttpResponse resp) throws ServletException, IOException {

        String uuid = req.getParameter("uuid");
        String uuid_seq = req.getParameter("uuid_sq");

        Map<String, String> fileInfo = fileAttachService.getFileInfo(uuid, uuid_seq);

        try {

            String bizType = fileInfo.get("BIZ_TYPE");
            String fileUploadPath = PropertiesManager.getString("everf.fileUpload.path");

            if(StringUtils.equals(bizType, "IMG")) {
                fileUploadPath = PropertiesManager.getString("everf.imageUpload.path");
            }
            String filename = fileUploadPath + bizType + "/" + fileInfo.get("FILE_NM") + "." + fileInfo.get("FILE_EXTENSION");

            BufferedInputStream bis = new BufferedInputStream(new FileInputStream(filename));
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream(512);

            int imageByte;
            while((imageByte = bis.read()) != -1) {
                byteArrayOutputStream.write(imageByte);
            }

            bis.close();

            byteArrayOutputStream.writeTo(resp.getOutputStream());

//            resp.setContentType("image/" + StringUtils.lowerCase(fileInfo.get("FILE_EXTENSION")));
            resp.setContentType("image/*");
            resp.setContentLength(imageByte);
            resp.setHeader("Content-Disposition", "inline; filename=\"" + fileInfo.get("REAL_FILE_NM")+"\"");

        } catch(Exception e) {
            logger.error(e.getMessage(), e);
        }
    }
}
