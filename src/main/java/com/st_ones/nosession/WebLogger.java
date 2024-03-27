package com.st_ones.nosession;

import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.sql.DataSource;
import java.io.File;
import java.io.RandomAccessFile;

@Controller
@RequestMapping("/")
public class WebLogger extends BaseController {
    @Autowired
    private DataSource dataSource;

    @RequestMapping("WebLogger/view")
    public String watcher(EverHttpRequest req) throws Exception {

//        String path = PropertiesManager.getString("eversrm.system.log");

        String path = "E:/wls12c/user_projects/domains/base_domain/logs/nohup/KAKAOPMS_stdout.log";

        File file = new File(path);
        System.err.println(path+"=========================================="+file.exists());
        if (file.exists()) {
            RandomAccessFile randomAccessFile = new RandomAccessFile(path, "r");
            long totalLength = randomAccessFile.length();
            long startPoint = totalLength - 300000 > 0 ? totalLength - 300000 : 0;
            randomAccessFile.seek(startPoint);

            long endPoint;
            String str;
            StringBuilder sb = new StringBuilder();
            while ((str = randomAccessFile.readLine()) != null) {
                sb.append("").append(new String(str.getBytes("iso-8859-1"), "euc-kr").replaceAll("<", "&lt;")).append("\n");
                endPoint = randomAccessFile.getFilePointer();
                randomAccessFile.seek(endPoint);
            }

            randomAccessFile.close();

            String resultString = sb.toString();
            resultString = resultString.replaceAll(" ", "&nbsp;");
            resultString = resultString.replaceAll("\t", "&nbsp;&nbsp;&nbsp;");
            resultString = resultString.replaceAll("INFO", "<span style='color:#0a8eeb;'>INFO</span>");
            resultString = resultString.replaceAll("WARN", "<span style='color:orange;'>WARN</span>");
            resultString = resultString.replaceAll("ERROR", "<span style='color:red;'>ERROR</span>");

            System.err.println("================================resultString="+resultString);

            req.setAttribute("logString", resultString);
        }

        req.setAttribute("path", path+"=========================================="+file.exists());

        return "/eversrm/system/log/WebLogger";
    }
}
