package com.st_ones.common.generator.service;

import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.multiLang.service.BSYL_Service;
import com.st_ones.eversrm.system.screen.service.BSYS_Service;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.WordUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service("sourceGenService")
public class SourceGenService extends BaseService {

    private static Logger logger = LoggerFactory.getLogger(SourceGenService.class);

    @Autowired
    BSYL_Service bsylService;

    @Autowired
    BSYS_Service bsysService;

    public void getMultilanguageData(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String screenId = req.getParameter("paramScreenId");
        String gridId = "";

        Map<String, String> param = new HashMap<String, String>();
        param.put("st_SCREEN_ID", "L");
        param.put("SCREEN_ID", screenId);
        param.put("IP_ADDRESS", "127.0.0.1");
        List<Map<String, Object>> screenAttributeList = bsylService.doSearch(param);

        List<Map<String, Object>> formData = new ArrayList<Map<String, Object>>();

        String tagGuide = "";
        for (Map<String, Object> gridData : screenAttributeList) {

            final String columnType = (String)gridData.get("COLUMN_TYPE");

            if (!gridData.get("MULTI_TYPE").equals("F") || EverString.isEmpty(columnType)) {
                if(gridData.get("MULTI_TYPE").equals("G") && StringUtils.isEmpty(gridId)) {
                    gridId = (String)gridData.get("FORM_GRID_ID");
                }
                continue;
            }

            final String searchConditionFlag = (String)gridData.get("SEARCH_CONDITION_FLAG");
            final String columnId = (String)gridData.get("COLUMN_ID");
            final String formGridId = (String)gridData.get("FORM_GRID_ID");
            final String disableFlag = (String)gridData.get("DISABLE_FLAG");
            final String formId = formGridId+"_"+columnId;
            boolean koreanIme = false;

            if (columnId.indexOf("_NM")   >= 0 ||
                columnId.indexOf("_ADDR") >= 0 ||
                columnId.indexOf("_DESC") >= 0 ||
                columnId.indexOf("_SPEC") >= 0 ||
                columnId.indexOf("_TEXT") >= 0 ||
                columnId.indexOf("_CONTENT") >= 0 ||
                columnId.indexOf("_RMK")  >= 0 )
            {
                koreanIme = true;
            }

            if (columnType.equals("text") && searchConditionFlag.equals("1")) {
                tagGuide = String.format("\t&lt;e:label for=\"%s\" title=\"${%s_N}\" /&gt;\n"
                        +"\t&lt;e:field&gt;\n"
                        +"\t\t&lt;e:select id=\"st_%s\" name=\"st_%s\" value=\"${st_default}\" width=\"${%s_W}\" options=\"${searchTerms}\" visible=\"${everMultiVisible}\" disabled=\"\" readOnly=\"\" required=\"\" /&gt;\n"
                        +"\t\t&lt;e:inputText id=\"%s\""
                        +(koreanIme ? " style=\"${imeMode}\"" : " style=\"ime-mode:inactive\"")
                        + " name=\"%s\" value=\"${form.%s}\" width=\"${%s_W}\" maxLength=\"${%s_M}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\"/&gt;\n"
                        +"\t&lt;/e:field&gt;"
                        ,columnId, formId
                        ,columnId, columnId, formId
                        ,columnId, columnId, columnId, formId, formId, formId, formId, formId);
            }
            else if (columnType.equals("text") && searchConditionFlag.equals("0")) {
                tagGuide =	String.format("\t&lt;e:label for=\"%s\" title=\"${%s_N}\"/&gt;\n"
                        +"\t&lt;e:field&gt;\n"
                        +"\t\t&lt;e:select id=\"st_%s\" name=\"st_%s\" value=\"${st_default}\" width=\"${%s_W}\" options=\"${searchTerms}\" visible=\"${everMultiVisible}\" required=\"\" readOnly=\"\" disabled=\"\" /&gt;\n"
                        +"\t\t&lt;e:inputText id=\"%s\""
                        +(koreanIme ? " style=\"${imeMode}\"" : " style=\"ime-mode:inactive\"")
                        +" name=\"%s\" value=\"${form.%s}\" width=\"${%s_W}\" maxLength=\"${%s_M}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\"/&gt;\n"
                        +"\t&lt;/e:field&gt;\n"
                        ,columnId, formId
                        ,columnId, columnId, formId
                        ,columnId, columnId, columnId, formId, formId, formId, formId, formId);
            }
            else if (columnType.equals("textarea")) {
                tagGuide =	String.format("\t&lt;e:label for=\"%s\" title=\"${%s_N}\"/&gt;\n"
                        +"\t&lt;e:field&gt;\n"
                        +"\t\t&lt;e:select id=\"st_%s\" name=\"st_%s\" value=\"${st_default}\" width=\"${%s_W}\" options=\"${searchTerms}\" visible=\"${everMultiVisible}\" required=\"\" readOnly=\"\" disabled=\"\" /&gt;\n"
                        +"\t\t&lt;e:textArea id=\"%s\""
                        +(koreanIme ? " style=\"${imeMode}\"" : " style=\"ime-mode:inactive\"")
                        +" name=\"%s\" height=\"100px\" value=\"${form.%s}\" width=\"${%s_W}\" maxLength=\"${%s_M}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" /&gt;\n"
                        +"\t&lt;/e:field&gt;\n"
                        ,columnId, formId
                        ,columnId, columnId, formId
                        ,columnId, columnId, columnId, formId, formId, formId, formId, formId);
            }
            else if (columnType.equals("search")) {
                tagGuide = String.format("\t&lt;e:label for=\"%s\" title=\"${%s_N}\"/&gt;\n"
                        +"\t&lt;e:field&gt;\n"
                        +"\t\t&lt;e:select id=\"st_%s\" name=\"st_%s\" value=\"${st_default}\" width=\"${%s_W}\" options=\"${searchTerms}\" visible=\"${everMultiVisible}\" required=\"\" readOnly=\"\" disabled=\"\" /&gt;\n"
                        +"\t\t&lt;e:search id=\"%s\""
                        +(koreanIme ? " style=\"${imeMode}\"" : " style=\"ime-mode:inactive\"")
                        +" name=\"%s\" value=\"\" width=\"${%s_W}\" maxLength=\"${%s_M}\" onIconClick=\"${%s_RO ? \"everCommon.blank\" : \"\"}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" /&gt;\n"
                        +"\t&lt;/e:field&gt;\n"
                        ,columnId, formId
                        ,columnId, columnId, formId
                        ,columnId, columnId, formId, formId, formId, formId, formId, formId);
            }
            else if (columnType.equals("search") && searchConditionFlag.equals("0")) {
                tagGuide = String.format("\t&lt;e:select id=\"st_%s\" name=\"st_%s\" readOnly=\"\" disabled=\"\" required=\"\" options=\"${searchTerms}\" value=\"${st_default}\" width=\"${%s_W}\" visible=\"${everMultiVisible}\" /&gt;\n"
                        +"\t\t&lt;e:search id=\"%s\""
                        +(koreanIme ? " style=\"${imeMode}\"" : " style=\"ime-mode:inactive\"")
                        +" name=\"%s\" value=\"\" width=\"${%s_W}\" maxLength=\"${%s_M}\" onIconClick=\"${%s_RO ? \"everCommon.blank\" : \"\"}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" /&gt;\n"
                        ,columnId, columnId, formId
                        ,columnId, columnId, formId, formId, formId, formId, formId, formId);
            }
            else if (columnType.equals("date")) {
                tagGuide = String.format("\t&lt;e:label for=\"%s\" title=\"${%s_N}\"/&gt;\n"
                        +"\t&lt;e:field&gt;\n"
                        +"\t\t&lt;e:inputDate id=\"%s\" name=\"%s\" value=\"${form.%s}\" width=\"${%s_W}\" datePicker=\"true\" required=\"${%s_R}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" /&gt;\n"
                        +"\t&lt;/e:field&gt;\n"
                        ,columnId, formId
                        ,columnId, columnId, columnId, formId, formId, formId, formId);
            }
            else if (columnType.equals("date") && disableFlag.equals("0")) {
                tagGuide = String.format("\t&lt;e:inputDate id=\"%s\" name=\"%s\" value=\"${form.%s}\" width=\"${%s_W}\" datePicker=\"true\" required=\"${%s_R}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" /&gt;\n"
                        ,columnId, columnId, columnId, formId, formId, formId, formId);
            }
            else if (columnType.equals("number")) {
                tagGuide = String.format("\t&lt;e:label for=\"%s\" title=\"${%s_N}\"/&gt;\n"
                        +"\t&lt;e:field&gt;\n"
                        +"\t\t&lt;e:select id=\"st_%s\" name=\"st_%s\" value=\"${st_default}\" width=\"${%s_W}\" options=\"${searchTerms}\" disabled=\"\" readOnly=\"\" required=\"\" visible=\"${everMultiVisible}\" /&gt;\n"
                        +"\t\t&lt;e:inputNumber id=\"%s\" name=\"%s\" value=\"${form.%s}\" maxValue=\"${%s_M}\" decimalPlace=\"${%s_NF}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" /&gt;\n"
                        +"\t&lt;/e:field&gt;\n"
                        ,columnId, formId
                        ,columnId, columnId, formId
                        ,columnId, columnId, columnId, formId, formId, formId, formId, formId);
            }
            else if (columnType.equals("number") && searchConditionFlag.equals("0")) {
                tagGuide = String.format("&lt;e:inputNumber id=\"%s\" name=\"%s\" value=\"${form.%s}\" width=\"${%s_W}\" maxValue=\"${%s_M}\" decimalPlace=\"${%s_NF}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" /&gt;\n"
                        ,columnId, columnId, columnId, formId, formId, formId, formId, formId, formId);
            }
            else if (columnType.equals("combo")) {
                String tempColId = WordUtils.capitalizeFully(columnId.replaceAll("_", " ")).replaceAll(" ", "");
                String colOptions = tempColId.substring(0, 1).toLowerCase() + tempColId.substring(1, tempColId.length())+"Options";
                tagGuide = String.format("\t&lt;e:label for=\"%s\" title=\"${%s_N}\"/&gt;\n"
                        +"\t&lt;e:field&gt;\n"
                        +"\t\t&lt;e:select id=\"st_%s\" name=\"st_%s\" value=\"${st_default}\" width=\"${%s_W}\" options=\"${searchTerms}\" disabled=\"\" readOnly=\"\" required=\"\" visible=\"${everMultiVisible}\" /&gt;\n"
                        +"\t\t&lt;e:select id=\"%s\" name=\"%s\" value=\"${form.%s}\" options=\"${"+colOptions+"}\" width=\"${%s_W}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" placeHolder=\"\" /&gt;\n"
                        +"\t&lt;/e:field&gt;"
                        ,columnId, formId
                        ,columnId, columnId, formId
                        ,columnId, columnId, columnId, formId, formId, formId, formId);
            }
            else if (columnType.equals("checkbox")) {
                tagGuide = String.format("\t&lt;e:label for=\"%s\" title=\"${%s_N}\"/&gt;\n"
                        +"\t&lt;e:field&gt;\n"
                        +"\t\t&lt;e:check id=\"%s\" name=\"%s\" value=\"1\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" /&gt;\n"
                        +"\t&lt;/e:field&gt;\n"
                        ,columnId, formId, columnId, columnId, formId, formId, formId);
            }

            if (EverString.isNotEmpty(tagGuide)) {
                gridData.put("TAG_GUIDE", tagGuide);
            } else {
                gridData.put("TAG_GUIDE", "NONE");
            }

            formData.add(gridData);
        }

        req.setAttribute("formData", formData);
        if(StringUtils.isNotEmpty(gridId)) {
            req.setAttribute("gridId", gridId);
        }
    }

    public void getActionData(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String tagGuide = "";
        String screenId = req.getParameter("paramScreenId");

        Map<String, String> param = new HashMap<String, String>();
        param.put("st_SCREEN_ID", "L");
        param.put("SCREEN_ID", screenId);
        param.put("IP_ADDRESS", "127.0.0.1");
        List<Map<String, Object>> buttonList = bsysService.doSearchScreenActionManagement(param);

        for (Map<String, Object> buttonData : buttonList) {
            tagGuide = "\t&lt;e:button id=\"" + buttonData.get("ACTION_CD") + "\" name=\"" + buttonData.get("ACTION_CD") + "\" label=\"${" + buttonData.get("ACTION_CD") + "_N}\""  + " onClick=\"" + buttonData.get("ACTION_CD") + "\" disabled=\"${" + buttonData.get("ACTION_CD") + "_D}\" visible=\"${"
                    + buttonData.get("ACTION_CD") + "_V}\"/>\n";
            buttonData.put("BUTTON_TAG", tagGuide);
        }

        req.setAttribute("buttonData", buttonList);
    }

    public void createController(Map<String, String> conInfo) throws Exception{
        // 폴더 생성
        makeDir(conInfo.get("createFolder"));

        // 파일 생성
        makeFile(conInfo);
    }

    private static boolean makeFile(Map<String, String> conInfo) {
        String fileNm = conInfo.get("fileName");
        String createFolder = conInfo.get("createFolder");

        int packageCnt = createFolder.indexOf("com");
        String pNm = createFolder.substring(packageCnt, createFolder.length()).replace("\\", ".");
        String pPath = pNm.substring(0, pNm.length() - 1);

        String[] arr = pPath.split("\\.");
        int sourceCnt = createFolder.indexOf(arr[2]);
        String sNm = createFolder.substring(sourceCnt, createFolder.length()).replace("\\", "/");
        String sPath = sNm.substring(0, sNm.length() - 1);

        List<File> fileList = new ArrayList<File>();

        fileList.add(0, new File(createFolder + "\\web\\" + fileNm + "_Controller.java"));
        fileList.add(1, new File(createFolder + "\\service\\"+ fileNm + "_Service.java"));
        fileList.add(2, new File(createFolder + fileNm + "_Mapper.java"));
        fileList.add(3, new File(createFolder.replace("java", "resources\\mappers") + fileNm + "_Mapper.xml"));
        fileList.add(4, new File(createFolder.replace("java\\com\\st_ones", "webapp\\WEB-INF\\views") + fileNm + ".jsp"));

        boolean isMakeFile = false;

        try {
            for(int i = 0; i < fileList.size(); i++) {
                fileList.get(i).createNewFile();
                isMakeFile = true;

                BufferedWriter out = new BufferedWriter(new FileWriter(fileList.get(i)));
                StringBuffer sb = new StringBuffer();
                String c = "";
                if(i == 0) {
                    c = String.format("package "+pPath+".web;\n" +
                            "\n" +
                            "import "+pPath+".service."+fileNm+"_Service;\n" +
                            "import com.st_ones.common.combo.service.CommonComboService;\n" +
                            "import com.st_ones.common.message.service.MessageService;\n" +
                            "import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;\n" +
                            "import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;\n" +
                            "import org.springframework.beans.factory.annotation.Autowired;\n" +
                            "import org.springframework.stereotype.Controller;\n" +
                            "import org.springframework.web.bind.annotation.RequestMapping;\n" +
                            "\n" +
                            "import java.util.List;\n" +
                            "import java.util.Map;\n" +
                            "\n" +
                            "\n" +
                            "/**\n" +
                            " * The type "+fileNm+" _ controller.\n" +
                            " */\n" +
                            "@Controller\n" +
                            "@RequestMapping(value = \"/"+sPath+"\")\n" +
                            "public class "+fileNm+"_Controller {\n" +
                            "    @Autowired\n" +
                            "    private MessageService msg;\n" +
                            "    @Autowired\n" +
                            "    private "+fileNm+"_Service "+fileNm.toLowerCase()+"_service;\n" +
                            "    @Autowired\n" +
                            "    private CommonComboService commonComboService;\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" string.\n" +
                            "     *\n" +
                            "     * @param req the req\n" +
                            "     * @return the string\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @RequestMapping(value=\"/"+fileNm+"/view\")\n" +
                            "    public String "+fileNm+"(EverHttpRequest req) throws Exception {\n" +
                            "        //req.setAttribute(\"defaultFromDate\", EverDate.addMonths(-1));\n" +
                            "        //req.setAttribute(\"defaultToDate\", EverDate.getDate());\n" +
                            "\n" +
                            "        return \"/"+sPath+"/"+fileNm+"\";\n" +
                            "    }\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do search.\n" +
                            "     *\n" +
                            "     * @param req the req\n" +
                            "     * @param resp the resp\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @RequestMapping(value=\"/"+fileNm+"/doSearch\")\n" +
                            "    public void "+fileNm+"_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {\n" +
                            "        Map<String, String> param = req.getFormData();\n" +
                            "\n" +
                            "        //resp.setLinkStyle(\"grid\", \"COLUMN\");\n" +
                            "\n" +
                            "        resp.setGridObject(\"grid\", "+fileNm.toLowerCase()+"_service."+fileNm+"_doSearch(param));\n" +
                            "        resp.setResponseCode(\"true\");\n" +
                            "    }\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do delete.\n" +
                            "     *\n" +
                            "     * @param req the req\n" +
                            "     * @param resp the resp\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @RequestMapping(value=\"/"+fileNm+"/doDelete\")\n" +
                            "    public void "+fileNm+"_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {\n" +
                            "        List<Map<String, Object>> gridData = req.getGridData(\"grid\");\n" +
                            "\n" +
                            "        "+fileNm.toLowerCase()+"_service."+fileNm+"_doDelete(gridData);\n" +
                            "        resp.setResponseMessage(msg.getMessage(\"0017\"));\n" +
                            "        resp.setResponseCode(\"true\");\n" +
                            "    }\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do save.\n" +
                            "     *\n" +
                            "     * @param req the req\n" +
                            "     * @param resp the resp\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @RequestMapping(value=\"/"+fileNm+"/doSave\")\n" +
                            "    public void "+fileNm+"_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {\n" +
                            "        List<Map<String, Object>> gridData = req.getGridData(\"grid\");\n" +
                            "\n" +
                            "        "+fileNm.toLowerCase()+"_service."+fileNm+"_doSave(gridData);\n" +
                            "        resp.setResponseMessage(msg.getMessage(\"0031\"));\n" +
                            "        resp.setResponseCode(\"true\");\n" +
                            "    }\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do insert.\n" +
                            "     *\n" +
                            "     * @param req the req\n" +
                            "     * @param resp the resp\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @RequestMapping(value=\"/"+fileNm+"/doInsert\")\n" +
                            "    public void "+fileNm+"_doInsert(EverHttpRequest req, EverHttpResponse resp) throws Exception {\n" +
                            "        List<Map<String, Object>> gridData = req.getGridData(\"grid\");\n" +
                            "\n" +
                            "        "+fileNm.toLowerCase()+"_service."+fileNm+"_doInsert(gridData);\n" +
                            "        resp.setResponseMessage(msg.getMessage(\"0015\"));\n" +
                            "        resp.setResponseCode(\"true\");\n" +
                            "    }\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do update.\n" +
                            "     *\n" +
                            "     * @param req the req\n" +
                            "     * @param resp the resp\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @RequestMapping(value=\"/"+fileNm+"/doUpdate\")\n" +
                            "    public void "+fileNm+"_doUpdate(EverHttpRequest req, EverHttpResponse resp) throws Exception {\n" +
                            "        List<Map<String, Object>> gridData = req.getGridData(\"grid\");\n" +
                            "\n" +
                            "        "+fileNm.toLowerCase()+"_service."+fileNm+"_doUpdate(gridData);\n" +
                            "        resp.setResponseMessage(msg.getMessage(\"0016\"));\n" +
                            "        resp.setResponseCode(\"true\");\n" +
                            "    }\n" +
                            "}\n");
                } else if(i == 1) {
                    c = String.format("package "+pPath+".service;\n" +
                            "\n" +
                            "import "+pPath+"."+fileNm+"_Mapper;\n" +
                            "import com.st_ones.common.docNum.service.DocNumService;\n" +
                            "import com.st_ones.common.message.service.MessageService;\n" +
                            "import org.springframework.beans.factory.annotation.Autowired;\n" +
                            "import org.springframework.stereotype.Service;\n" +
                            "import org.springframework.transaction.annotation.Propagation;\n" +
                            "import org.springframework.transaction.annotation.Transactional;\n" +
                            "\n" +
                            "import java.util.List;\n" +
                            "import java.util.Map;\n" +
                            "\n" +
                            "/**\n" +
                            " * The type "+fileNm+" _ service.\n" +
                            " */\n" +
                            "@Service(value = \""+fileNm+"_Service\")\n" +
                            "public class "+fileNm+"_Service {\n" +
                            "    /**\n" +
                            "     * The "+fileNm+" _ mapper.\n" +
                            "     */\n" +
                            "    @Autowired\n" +
                            "    "+fileNm+"_Mapper "+fileNm.toLowerCase()+"_mapper;\n" +
                            "    /**\n" +
                            "     * The Msg.\n" +
                            "     */\n" +
                            "    @Autowired MessageService msg;\n" +
                            "    /**\n" +
                            "     * The Doc num service.\n" +
                            "     */\n" +
                            "    @Autowired DocNumService docNumService;\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do search.\n" +
                            "     *\n" +
                            "     * @param param the param\n" +
                            "     * @return the list\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    public List<Map<String,Object>> "+fileNm+"_doSearch(Map<String, String> param) throws Exception{\n" +
                            "        return "+fileNm.toLowerCase()+"_mapper."+fileNm+"_doSearch(param);\n" +
                            "    }\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do delete.\n" +
                            "     *\n" +
                            "     * @param gridData the grid data\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)\n" +
                            "    public void "+fileNm+"_doDelete(List<Map<String, Object>> gridData) throws Exception {\n" +
                            "        for (Map<String, Object> rowData : gridData) {\n" +
                            "            "+fileNm.toLowerCase()+"_mapper."+fileNm+"_doDelete(rowData);\n" +
                            "        }\n" +
                            "    }\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do save.\n" +
                            "     *\n" +
                            "     * @param gridData the grid data\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)\n" +
                            "    public void "+fileNm+"_doSave(List<Map<String, Object>> gridData) throws Exception {\n" +
                            "        for (Map<String, Object> rowData : gridData) {\n" +
                            "            "+fileNm.toLowerCase()+"_mapper."+fileNm+"_doSave(rowData);\n" +
                            "        }\n" +
                            "    }\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do insert.\n" +
                            "     *\n" +
                            "     * @param gridData the grid data\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)\n" +
                            "    public void "+fileNm+"_doInsert(List<Map<String, Object>> gridData) throws Exception {\n" +
                            "        for (Map<String, Object> rowData : gridData) {\n" +
                            "            "+fileNm.toLowerCase()+"_mapper."+fileNm+"_doInsert(rowData);\n" +
                            "        }\n" +
                            "    }\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do update.\n" +
                            "     *\n" +
                            "     * @param gridData the grid data\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)\n" +
                            "    public void "+fileNm+"_doUpdate(List<Map<String, Object>> gridData) throws Exception {\n" +
                            "        for (Map<String, Object> rowData : gridData) {\n" +
                            "            "+fileNm.toLowerCase()+"_mapper."+fileNm+"_doUpdate(rowData);\n" +
                            "        }\n" +
                            "    }\n" +
                            "}");
                } else if(i == 2) {
                    c = String.format("package "+pPath+";\n" +
                            "\n" +
                            "import java.util.List;\n" +
                            "import java.util.Map;\n" +
                            "\n" +
                            "\n" +
                            "/**\n" +
                            " * The interface "+fileNm+" _ mapper.\n" +
                            " */\n" +
                            "public interface "+fileNm+"_Mapper {\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do search.\n" +
                            "     *\n" +
                            "     * @param param the param\n" +
                            "     * @return the list\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    public List<Map<String,Object>> "+fileNm+"_doSearch(Map<String, String> param) throws Exception;\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do delete.\n" +
                            "     *\n" +
                            "     * @param rowData the row data\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    public void "+fileNm+"_doDelete(Map<String, Object> rowData) throws Exception;\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do save.\n" +
                            "     *\n" +
                            "     * @param rowData the row data\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    public void "+fileNm+"_doSave(Map<String, Object> rowData) throws Exception;\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do insert.\n" +
                            "     *\n" +
                            "     * @param rowData the row data\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    public void "+fileNm+"_doInsert(Map<String, Object> rowData) throws Exception;\n" +
                            "\n" +
                            "    /**\n" +
                            "     * "+fileNm+" _ do update.\n" +
                            "     *\n" +
                            "     * @param rowData the row data\n" +
                            "     * @throws Exception the exception\n" +
                            "     */\n" +
                            "    public void "+fileNm+"_doUpdate(Map<String, Object> rowData) throws Exception;\n" +
                            "}\n");
                } else if(i == 3) {
                    c = String.format("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                            "<!DOCTYPE mapper PUBLIC \"-//ibatis.apache.org//DTD Mapper 3.0//EN\" \"http://mybatis.org/dtd/mybatis-3-mapper.dtd\">\n" +
                            "\n" +
                            "<mapper namespace=\""+pPath+"."+fileNm+"_Mapper\">\n" +
                            "\t<select id=\""+fileNm+"_doSearch\" parameterType=\"hashmap\" resultType=\"hashmap\">\n" +
                            "\t\t\n" +
                            "\t</select>\n" +
                            "\t\n" +
                            "\t<update id=\""+fileNm+"_doDelete\" parameterType=\"hashmap\">\n" +
                            "\t\t\n" +
                            "\t</update>\n" +
                            "\t\n" +
                            "\t<insert id=\""+fileNm+"_doSave\" parameterType=\"hashmap\">\n" +
                            "\t\t MERGE STOC AS A\n" +
                            "\t\t USING (SELECT #{ses.gateCd} AS GATE_CD) AS B\n" +
                            "            ON (A.GATE_CD = B.GATE_CD)\n" +
                            "\t\t  WHEN MATCHED THEN\n" +
                            "\t\tUPDATE SET\n" +
                            "\t\t  WHEN NOT MATCHED THEN\n" +
                            "\t\tINSERT (\n" +
                            "\t\t) VALUES (\n" +
                            "\t\t);\n" +
                            "\t</insert>\n" +
                            "\t\n" +
                            "\t<insert id=\""+fileNm+"_doInsert\" parameterType=\"hashmap\">\n" +
                            "\t\tINSERT INTO "+fileNm+" (\n" +
                            "\t\t) VALUES (\n" +
                            "\t\t)\n" +
                            "\t</insert>\n" +
                            "\t\n" +
                            "\t<update id=\""+fileNm+"_doUpdate\" parameterType=\"hashmap\">\n" +
                            "\t\tUPDATE "+fileNm+" SET\n" +
                            "\t\t WHERE \n" +
                            "\t</update>\n" +
                            "</mapper>");
                } else if(i == 4) {
                    sb.append("<%--\n" );
                    sb.append("  Date: "+ EverDate.getDateString() +"\n" );
                    sb.append("  Time: "+ EverDate.getTimeString() +"\n" );
                    sb.append("  Scrren ID : "+fileNm+"\n" );
                    sb.append("--%>\n" );
                    sb.append("<%@ page language=\"java\" contentType=\"text/html; charset=UTF-8\" pageEncoding=\"UTF-8\"%>\n" );
                    sb.append("<%@ taglib prefix=\"e\" uri=\"http://www.st-ones.com/eversrm\"%>\n" );
                    sb.append("<%@ taglib uri=\"http://java.sun.com/jsp/jstl/core\" prefix=\"c\"%>\n" );
                    sb.append("<e:ui locale=\"${ses.countryCd}\" lang=\"${ses.langCd}\" dateFmt=\"${ses.dateFormat}\">\n" );
                    sb.append("  <script>\n" );
                    sb.append("\n" );
                    sb.append("    var grid;\n" );
                    sb.append("    var baseUrl = '/"+sPath+"/"+fileNm+"';\n" );
                    sb.append("\n" );
                    sb.append("    function init() {\n" );
                    sb.append("\n" );
                    sb.append("      grid = EVF.getComponent('grid');\n" );
                    sb.append("      grid.setProperty('columnFit', true);\n" );
                    sb.append("      grid.setProperty('panelVisible', true);\n" );
                    sb.append("      grid.setProperty('multiSelect', true);\n" );
                    sb.append("      grid.setProperty('acceptZero', true);\n" );
                    sb.append("      grid.setProperty('enterToNextRow', true);\n" );

                    sb.append("\n" );
                    sb.append("      // Grid AddRow Event\n" );
                    sb.append("      grid.addRowEvent(function() {\n" );
                    sb.append("        grid.addRow();\n" );
                    sb.append("      });\n" );
                    sb.append("\n" );
                    sb.append("      // Grid Excel Event\n" );
                    sb.append("      grid.excelExportEvent({\n" );
                    sb.append("        allCol : \"${excelExport.allCol}\",\n" );
                    sb.append("        selRow : \"${excelExport.selRow}\",\n" );
                    sb.append("        fileType : \"${excelExport.fileType }\",\n" );
                    sb.append("        fileName : \"${screenName }\",\n" );
                    sb.append("        excelOptions : {\n" );
                    sb.append("          imgWidth      : 0.12,\n" );
                    sb.append("          imgHeight     : 0.26,\n" );
                    sb.append("          colWidth      : 20,\n" );
                    sb.append("          rowSize       : 500,\n" );
                    sb.append("          attachImgFlag : false\n" );
                    sb.append("        }\n" );
                    sb.append("      });\n" );
                    sb.append("\n" );
                    sb.append("      grid.cellClickEvent(function(rowId, celName, value, rowIdx, colIdx) {\n" );
                    sb.append("\n" );
                    sb.append("        if (celName == 'multiSelect') {\n" );
                    sb.append("        }\n" );
                    sb.append("\n" );
                    sb.append("      });\n" );
                    sb.append("\n" );
                    sb.append("      grid.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});\n" );
                    sb.append("    }\n" );
                    sb.append("\n" );
                    sb.append("    // Search\n" );
                    sb.append("    function doSearch() {\n" );
                    sb.append("      var store = new EVF.Store();\n" );
                    sb.append("\n" );
                    sb.append("      // form validation Check\n" );
                    sb.append("      if(!store.validate()) return;\n" );
                    sb.append("\n" );
                    sb.append("      store.setGrid([grid]);\n" );
                    sb.append("      store.load(baseUrl+'/doSearch.so', function() {\n" );
                    sb.append("        if(grid.getRowCount() == 0) {\n" );
                    sb.append("          return alert('${msg.M0002}');\n" );
                    sb.append("        }\n" );
                    sb.append("      });\n" );
                    sb.append("    }\n" );
                    sb.append("\n" );
                    sb.append("    // Save\n" );
                    sb.append("    function doSave() {\n" );
                    sb.append("      var store = new EVF.Store();\n" );
                    sb.append("\n" );
                    sb.append("      // form validation Check\n" );
                    sb.append("      if(!store.validate()) return;\n" );
                    sb.append("      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }\n" );
                    sb.append("      var validate = grid.validate();\n" );
                    sb.append("      if(!validate.flag) { return alert(validate.msg); }\n" );
                    sb.append("\n" );
                    sb.append("      store.setGrid([grid]);\n" );
                    sb.append("      store.getGridData(grid, 'sel');\n" );
                    sb.append("      if (!confirm(\"${msg.M0021}\")) return;\n" );
                    sb.append("      store.load(baseUrl + '/doSave.so', function() {\n" );
                    sb.append("        alert(this.getResponseMessage());\n" );
                    sb.append("        doSearch();\n" );
                    sb.append("      });\n" );
                    sb.append("    }\n" );
                    sb.append("\n" );
                    sb.append("    // Insert\n" );
                    sb.append("    function doInsert() {\n" );
                    sb.append("      var store = new EVF.Store();\n" );
                    sb.append("\n" );
                    sb.append("      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }\n" );
                    sb.append("\n" );
                    sb.append("      // Grid Validation Check\n" );
                    sb.append("      var validate = grid.validate();\n" );
                    sb.append("      if(!validate.flag) { return alert(validate.msg); }\n" );
                    sb.append("\n" );
                    sb.append("      store.setGrid([grid]);\n" );
                    sb.append("      store.getGridData(grid, 'sel');\n" );
                    sb.append("      if (!confirm(\"${msg.M0011}\")) return;\n" );
                    sb.append("      store.load(baseUrl + '/doInsert.so', function() {\n" );
                    sb.append("        alert(this.getResponseMessage());\n" );
                    sb.append("        doSearch();\n" );
                    sb.append("      });\n" );
                    sb.append("    }\n" );
                    sb.append("\n" );
                    sb.append("    // Update\n" );
                    sb.append("    function doUpdate() {\n" );
                    sb.append("      var store = new EVF.Store();\n" );
                    sb.append("      var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;\n" );
                    sb.append("\n" );
                    sb.append("      if(selRowIds.length == 0) {\n" );
                    sb.append("        return alert(\"${msg.M0004}\");\n" );
                    sb.append("      }\n" );
                    sb.append("\n" );
                    sb.append("      // Grid Validation Check\n" );
                    sb.append("      var validate = grid.validate();\n" );
                    sb.append("      if(!validate.flag) { return alert(validate.msg); }\n" );
                    sb.append("\n" );
                    sb.append("      store.setGrid([grid]);\n" );
                    sb.append("      store.getGridData(grid, 'sel');\n" );
                    sb.append("      if (!confirm(\"${msg.M0012}\")) return;\n" );
                    sb.append("      store.load(baseUrl + '/doUpdate.so', function() {\n" );
                    sb.append("        alert(this.getResponseMessage());\n" );
                    sb.append("        doSearch();\n" );
                    sb.append("      });\n" );
                    sb.append("    }\n" );
                    sb.append("\n" );
                    sb.append("    // Delete\n" );
                    sb.append("    function doDelete() {\n" );
                    sb.append("      if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {\n" );
                    sb.append("        alert(\"${msg.M0004}\");\n" );
                    sb.append("        return;\n" );
                    sb.append("      }\n" );
                    sb.append("\n" );
                    sb.append("      if (!confirm(\"${msg.M0013 }\")) return;\n" );
                    sb.append("\n" );
                    sb.append("      var store = new EVF.Store();\n" );
                    sb.append("      store.setGrid([grid]);\n" );
                    sb.append("      store.getGridData(grid, 'sel');\n" );
                    sb.append("      store.load(baseUrl + '/doDelete.so', function(){\n" );
                    sb.append("        alert(this.getResponseMessage());\n" );
                    sb.append("        doSearch();\n" );
                    sb.append("      });\n" );
                    sb.append("    }\n" );
                    sb.append("\n" );
                    sb.append("  </script>\n" );
                    sb.append("\n" );
                    sb.append("  <e:window id=\""+fileNm+"\" onReady=\"init\" title=\"${screenName }\" breadCrumbs=\"${breadCrumb }\" initData=\"${initData}\">\n" );
                    sb.append("    <e:searchPanel id=\"form\" title=\"${msg.M9999}\" labelWidth=\"100\" width=\"100%\" columnCount=\"3\" useTitleBar=\"true\" onEnter=\"doSearch\">\n" );
                    sb.append("      <e:row>\n" );
                    sb.append("        \n" );
                    sb.append("      </e:row>\n" );
                    sb.append("    </e:searchPanel>\n" );
                    sb.append("    <e:buttonBar width=\"100%\" align=\"right\">\n" );
                    sb.append("      <e:button id=\"doSearch\" name=\"doSearch\" label=\"${doSearch_N}\" onClick=\"doSearch\" disabled=\"${doSearch_D}\" visible=\"${doSearch_V}\"/>\n" );
                    sb.append("      <e:button id=\"doSave\"   name=\"doSave\"   label=\"${doSave_N}\"   onClick=\"doSave\"   disabled=\"${doSave_D}\"   visible=\"${doSave_V}\"/>\n" );
                    sb.append("\t  <e:button id=\"doInsert\" name=\"doInsert\" label=\"${doInsert_N}\" onClick=\"doInsert\" disabled=\"${doInsert_D}\" visible=\"${doInsert_V}\"/>\n" );
                    sb.append("\t  <e:button id=\"doUpdate\" name=\"doUpdate\" label=\"${doUpdate_N}\" onClick=\"doUpdate\" disabled=\"${doUpdate_D}\" visible=\"${doUpdate_V}\"/>\n" );
                    sb.append("      <e:button id=\"doDelete\" name=\"doDelete\" label=\"${doDelete_N}\" onClick=\"doDelete\" disabled=\"${doDelete_D}\" visible=\"${doDelete_V}\"/>\n");
                    sb.append("    </e:buttonBar>\n");
                    sb.append("    <e:gridPanel id=\"grid\" name=\"grid\" width=\"100%\" height=\"fit\" gridType=\"${_gridType}\"/>\n");
                    sb.append("  </e:window>\n");
                    sb.append("</e:ui>");
                }

                out.write(i != 4 ? c : sb.toString());
                out.newLine();
                out.close();
            }
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            isMakeFile = false;
        }
        return isMakeFile;
    }

    public List<File> makeDir(String path) {
        String dirPath = path.substring(0, path.lastIndexOf("\\"));
        File dirService = new File(dirPath+"\\service");
        File dirController = new File(dirPath+"\\web");
        File dirMapper = new File(dirPath);
        File dirMapperXml = new File(dirPath.replace("java", "resources\\mappers"));
        File dirJsp = new File(dirPath.replace("java\\com\\st_ones", "webapp\\WEB-INF\\views"));

        List<File> mkdirList = new ArrayList<File>();
        mkdirList.add(0, dirService);
        mkdirList.add(1, dirController);
        mkdirList.add(2, dirMapper);
        mkdirList.add(3, dirMapperXml);
        mkdirList.add(4, dirJsp);

        for(File dir : mkdirList) {
            if ( !dir.exists() ) {
                dir.mkdirs();
            }
        }

        return mkdirList;
    }


}
//D:\ST-OnesIDE\workspace\DPMS\src\main\resources\mappers\com\st_ones\eversrm\master\bom

//D:\ST-OnesIDE\workspace\DPMS\src\main\java\com\st_ones\eversrm\master\bom