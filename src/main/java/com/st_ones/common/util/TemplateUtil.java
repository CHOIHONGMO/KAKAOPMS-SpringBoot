package com.st_ones.common.util;

import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class TemplateUtil {

    @Autowired
    FileAttachService fileAttachService;

    /**
     * 블라썸 기본 HTML 을 만들어 줍니다. 템플릿 파일을 로드한 후, 기본적인 폼 정보를 치환하고 결과 HTML을 리턴합니다.
     * @param approvalType 결재유형(PR, SE, PO, 등등을 지정합니다.)
     * @param formData 폼데이터 객체
     * @return
     * @throws Exception
     */
    public String getTemplate(String approvalType, Map<String, String> formData) throws Exception {

        String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.approval" + approvalType + "_TemplateFileName");

        String resultContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
        if (StringUtils.isEmpty(resultContents)) {
            throw new Exception("블라썸 템플릿 파일이 존재하지 않습니다.");
        }

        String domain = PropertiesManager.getString("eversrm.urls.maintain.dev");
        resultContents = StringUtils.replace(resultContents, "$domainName$", domain);

        String vendorUrl = PropertiesManager.getString("eversrm.urls.vendor.dev");
        resultContents = StringUtils.replace(resultContents, "$vendorUrl$", vendorUrl);

        Iterator<String> iterator = formData.keySet().iterator();
        while(iterator.hasNext()) {
            String key = iterator.next();
            String value = String.valueOf(formData.get(key)).equals("null") ? "" : String.valueOf(formData.get(key));
            resultContents = StringUtils.replace(resultContents,"$"+key+"$", value);
        }

        resultContents = EverString.rePreventSqlInjection(resultContents);

        return resultContents;
    }

    /**
     * 상세정보의 HTML 을 만들어 줍니다.
     * @param resultContents 결과 HTML
     * @param items 상세아이템
     * @param sortKey 순서
     * @return
     */
    public String getItemAsHtml(String resultContents, List<Map<String, Object>> items, String[] sortKey) {

        StringBuilder sb = new StringBuilder();
        for (Map<String, Object> datum : items) {

            sb.append("<tr>");
            for (String key : sortKey) {

                String align = null;
                if(key.contains(":")) {
                    align = StringUtils.substringAfter(key, ":");
                    key = StringUtils.substringBefore(key, ":");
                }

                String value = String.valueOf(datum.get(key)).equals("null") ? "" : String.valueOf(datum.get(key));
                sb.append("<td");
                if(StringUtils.isNotEmpty(align)) {
                    if(align.equals("L")) {
                        align = "left";
                    } else if(align.equals("R")) {
                        align = "right";
                    } else {
                        align = "center";
                    }
                    sb.append(" style='text-align:").append(align).append("'");
                }
                sb.append(">");
                sb.append(StringUtils.defaultIfEmpty(value, "")).append("</td>");
            }
            sb.append("</tr>");
        }

        return StringUtils.replace(resultContents,"$ITEM_DETAIL$", sb.toString());
    }

    /**
     * 첨부파일 HTML 을 만들어 줍니다.
     * @param title 컬럼 타이틀(첨부, 참고자료 등)
     * @param resultContents 결과 HTML
     * @param bizType 파일첨부 업무유형
     * @param uuid 파일첨부 UUID
     * @return
     * @throws Exception
     */
    public String getAttachFileHtml(String title, String resultContents, String bizType, String uuid) throws Exception {

        List<Map<String, Object>> attachFileList;
        if(fileAttachService == null) {
            attachFileList = new ArrayList<Map<String, Object>>();
            Map<String, Object> file = new HashMap<String, Object>();
            file.put("UUID_SQ", "1");
            file.put("REAL_FILE_NM", "fileAttachService_is_null.zip");
            attachFileList.add(file);

            Map<String, Object> file2 = new HashMap<String, Object>();
            file2.put("UUID_SQ", "1");
            file2.put("REAL_FILE_NM", "fileAttachService_is_null2.zip");
            attachFileList.add(file2);

        } else {
            attachFileList = fileAttachService.getFilesInfo(bizType, uuid);
        }

        StringBuilder sb = new StringBuilder();
        if(attachFileList != null && attachFileList.size() > 0) {
            sb.append("<div class='file_box'>                           \n");
            sb.append("    <dl>                                         \n");
            sb.append("        <dt>").append(title).append("</dt>       \n");
            sb.append("        <dd>                                     \n");
            sb.append("            <ul>                                 \n");

            String domainNm = PropertiesManager.getString("eversrm.system.domainName");
			String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
			
            String domain   = "";
    		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
    		if (sslFlag) { domain = "https://"; }
    		else { domain = "http://"; }
    		if ("80".equals(domainPort)) {
    			domain += domainNm;
    		} else {
    			domain += domainNm + ":" + domainPort;
    		}
    		
            for (Map<String, Object> attFile : attachFileList) {

                String fileDownloadUrl = domain+"/common/file/fileAttach/download.so?";
                String queryString = "EVER_REQUEST_DATA_TYPE=FILE_DOWNLOAD&UUID=" + uuid + "&UUID_SQ=" + attFile.get("UUID_SQ");
                fileDownloadUrl = fileDownloadUrl + queryString;

                sb.append("\t\t\t\t<li>")
                        .append("<a href='").append(fileDownloadUrl).append("'>")
                        .append(attFile.get("REAL_FILE_NM"))
                        .append("</a></li>\n");
            }

            sb.append("            </ul>                                \n");
            sb.append("        </dd>                                    \n");
            sb.append("    </dl>                                        \n");
            sb.append("</div>                                           \n");
        }

        return StringUtils.replace(resultContents, "$FILE_DOWNLOAD$", sb.toString());
    }
    
    /** ******************************************************************************************
	 * 결재상신을 위해 블라썸 첨부파일 HTML을 만드는 Method
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public String getAttachFileHtml2(String title, String bizType, String uuid, String vendorUrl) throws Exception {
			StringBuilder sb = new StringBuilder();
			sb.append("<div style='width:740px;margin:10px 0;overflow:hidden;border-right:1px solid #d8d7d7;'>\n");
			sb.append("	<dl style='overflow:hidden;width:100%;border:1px solid #d8d7d7;background:#eeeeee'>\n");
			sb.append("		<dt style='float:left;width:112px;padding:0 0 0 29px;color:#252525;font-size:11px;line-height:22px;font-weight:bold;background:#eeeeee url(").append(vendorUrl+"/images/siis/blossom/ico_file.gif) 7px 5px no-repeat'>").append(title).append("</dt>\n");
			sb.append("		<dd style='float:left;padding:0;width:598px;border-left:1px solid #d8d7d7;color:#222;font-size:11px;background:#fff'>\n");
			sb.append("			<ul style='list-style:none;padding:0;margin:0;width:100%;background:#fff'>\n");
			
			String domainNm = PropertiesManager.getString("eversrm.system.domainName");
			String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
			
            String domain   = "";
    		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
    		if (sslFlag) { domain = "https://"; }
    		else { domain = "http://"; }
    		if ("80".equals(domainPort)) {
    			domain += domainNm;
    		} else {
    			domain += domainNm + ":" + domainPort;
    		}
    		
			if(fileAttachService == null) {
				fileAttachService = SpringContextUtil.getBean(FileAttachService.class);
			}
			List<Map<String, Object>> fileInfo = fileAttachService.getFilesInfo(bizType, uuid);
			int i=0;
			for (Map<String, Object> attFile : fileInfo) {
				String fileDownloadUrl = domain+"/common/file/fileAttach/download.so?";
				String queryString = "EVER_REQUEST_DATA_TYPE=FILE_DOWNLOAD&UUID=" + uuid + "&UUID_SQ=" + attFile.get("UUID_SQ");
				fileDownloadUrl = fileDownloadUrl + queryString;
				sb.append("<li style='padding:0 0 0 6px;height:25px;line-height:25px'>")
						.append("<a href='").append(fileDownloadUrl).append("'>")
						.append(attFile.get("REAL_FILE_NM"))
						.append("</a></li>");
				i++;
			}
			if(i == 0) {
				sb.append("<li style='padding:0 0 0 6px;height:25px;line-height:25px'>")
				.append("<a href='").append("#").append("'>")
				.append("")
				.append("</a></li>");
			}
			sb.append("			</ul>								\n");
			sb.append("		</dd>									\n");
			sb.append("	</dl>										\n");
			sb.append("</div>										\n");
			return sb.toString();
		
	}

    /** ******************************************************************************************
     * 결재상신을 위해 블라썸 첨부파일 HTML을 만드는 Method (여러개의 첨부파일 있는 경우)
     * @param req
     * @return
     * @throws Exception
     */
    public String getAttachFileHtml3(String title, String bizType, String uuid, String vendorUrl) throws Exception {
        StringBuilder sb = new StringBuilder();

        sb.append("		<dt style='float:left;width:112px;padding:0 0 0 29px;color:#252525;font-size:11px;line-height:22px;font-weight:bold;background:#eeeeee url(").append(vendorUrl+"/images/siis/blossom/ico_file.gif) 7px 5px no-repeat'>").append(title).append("</dt>\n");
        sb.append("		<dt style='float:left;width:400px;padding:0 0 0 20px;font-size:11px;line-height:22px;font-weight:bold;'>\n");
        
        String domainNm = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
		
        String domain   = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { domain = "https://"; }
		else { domain = "http://"; }
		if ("80".equals(domainPort)) {
			domain += domainNm;
		} else {
			domain += domainNm + ":" + domainPort;
		}
		
        if(fileAttachService == null) {
			fileAttachService = SpringContextUtil.getBean(FileAttachService.class);
		}
        List<Map<String, Object>> fileInfo = fileAttachService.getFilesInfo(bizType, uuid);
        int i=0;
        for (Map<String, Object> attFile : fileInfo) {
            String fileDownloadUrl = domain+"/common/file/fileAttach/download.so?";
            String queryString = "EVER_REQUEST_DATA_TYPE=FILE_DOWNLOAD&UUID=" + uuid + "&UUID_SQ=" + attFile.get("UUID_SQ");
            fileDownloadUrl = fileDownloadUrl + queryString;
            sb.append("<a href='").append(fileDownloadUrl).append("'>")
                    .append(attFile.get("REAL_FILE_NM"))
                    .append("</a>")
                    .append("&nbsp;");
            i++;
        }
        if(i == 0) {
            sb.append("<a href='").append("#").append("'>")
                    .append("")
                    .append("</a>");
        }
        sb.append("			</dt>								\n");

        return sb.toString();

    }
}
