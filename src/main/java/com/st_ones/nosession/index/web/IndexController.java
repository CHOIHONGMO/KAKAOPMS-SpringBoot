package com.st_ones.nosession.index.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.page.PageNaviBean;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.IM03.service.IM0301_Service;
import com.st_ones.evermp.PRINT.service.PRINT_Service;
import com.st_ones.nosession.index.service.IndexService;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.xerces.impl.dv.util.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.*;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.*;
import java.security.spec.RSAPublicKeySpec;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/")
public class IndexController extends BaseController {

    private static final String START_PAGE   = "/indexBS";    // 일반 로그인
    private static final String START_PAGE_P = "/indexBS";    // 고객 및 공급사 로그인
    private static final String M_START_PAGE = "/indexBS";    // 모바일 로그인
    private static final String S_START_PAGE = "/sso";        // 운영 및 고객사 SSO 로그인
    @Autowired
    private ServletContext servletContext;

    @Autowired
    private PRINT_Service print_service;

    @Autowired
    IndexService indexService;
    @Autowired
    IM0301_Service im0301Service;
    @Autowired
    LargeTextService largeTextService;

    @Autowired
    FileAttachService fileAttachService;

    @RequestMapping("/gateway")
    public String gateway(EverHttpRequest req, EverHttpResponse resp) {
        req.setAttribute("isLocalServer", PropertiesManager.getBoolean("eversrm.system.localserver"));
        return "/gateway";
    }

    @RequestMapping("/m/welcome")
    public String getMobileLoginLayer(EverHttpRequest req, EverHttpResponse resp) throws UnsupportedEncodingException {
        req.setAttribute("returnUrl", URLDecoder.decode(req.getParameter("returnUrl"), "UTF-8"));
        initRsa(req); // RSA 키 생성
        return "/mLoginLayer";
    }

    @RequestMapping("/loginLayer")
    public String getLoginLayer(EverHttpRequest req, EverHttpResponse resp) {

        String systemName = "";
        req.setAttribute("userId", req.getParameter("id"));
        req.setAttribute("systemName", systemName);

        initRsa(req);// RSA 키 생성
        return "/loginLayer";
    }

    @GetMapping("/")
    public String redirectToWelcome() {
        return "redirect:/welcome";
    }

    @RequestMapping("/welcome")
    public String welcomePage(HttpServletRequest req, HttpServletResponse response) throws Exception {

        req.setAttribute("getYear", EverDate.getYear());
        req.setAttribute("getMonth", EverDate.getMonth());
        req.setAttribute("getDay", EverDate.getDay());
        req.setAttribute("getFormattedTime", EverDate.getFormattedTime());

        UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
        if (baseInfo != null && !baseInfo.getUserId().equals("VIRTUAL")) {
            UserInfoManager.createUserInfo(baseInfo);
            Map<String, String> initDataMap = new HashMap<String, String>();
            initDataMap.put("langCd", UserInfoManager.getUserInfo().getLangCd());
            initDataMap.put("sessionType", (UserInfoManager.getUserInfo().getUserId().equals("VIRTUAL") ? "virtual" : "normal"));
            initDataMap.put("userId", UserInfoManager.getUserInfo().getUserId());
            initDataMap.put("userType", UserInfoManager.getUserInfo().getUserType());
            req.setAttribute("initData", new ObjectMapper().writeValueAsString(initDataMap));

            return "forward:/home";
        }

        // 공지사항 팝업 목록
        List<Map<String, String>> noticeList = new ArrayList<Map<String, String>>();
        noticeList = indexService.getNoticeListPopup(noticeList);
        req.setAttribute("noticeListPopup", noticeList);

        List<Map<String, String>> MainnoticeList = new ArrayList<Map<String, String>>();
        MainnoticeList = indexService.getNoticeListMain(MainnoticeList);
        req.setAttribute("noticeListMain", MainnoticeList);

        req.setAttribute("eversrmSystemDomainPort", PropertiesManager.getString("eversrm.system.domainPort"));
        req.setAttribute("eversrmSystemDomainUrl", PropertiesManager.getString("eversrm.system.domainUrl"));
        req.setAttribute("eversrmSystemDomainPortHttp", PropertiesManager.getString("eversrm.system.domainPort.http"));
        req.setAttribute("eversrmDevelopmentFlag", PropertiesManager.getBoolean("eversrm.system.developmentFlag"));

        if (StringUtils.isNotEmpty(req.getParameter("returnUrl"))) {
            req.setAttribute("returnUrl", URLDecoder.decode(req.getParameter("returnUrl"), "UTF-8"));
        }

        // RSA 키 생성 FIXME
        initRsa(req);

        String userAgent = req.getHeader("User-Agent");
        if (StringUtils.containsIgnoreCase(userAgent, "android") || StringUtils.containsIgnoreCase(userAgent, "iphone")) {
            return M_START_PAGE;    // 모바일 로그인 페이지
        } else {
            return START_PAGE;      // 고객 및 공급사 로그인 페이지
        }
    }

    /**
     * [미사용] indexBS.jsp에서 호출 : 고객사, 공급사의 index 페이지가 별도로 존재하는 경우에 사용
     * @param req
     * @param response
     * @return
     * @throws Exception
     */
    @RequestMapping("/welcomeBS")
    public String welcomePageForPromotion(EverHttpRequest req, EverHttpResponse response) throws Exception {

        getLog().info("/welcomeBS page start");

        req.setAttribute("getYear", EverDate.getYear());
        req.setAttribute("getMonth", EverDate.getMonth());
        req.setAttribute("getDay", EverDate.getDay());
        req.setAttribute("getFormattedTime", EverDate.getFormattedTime());

        UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
        if (baseInfo != null && !baseInfo.getUserId().equals("VIRTUAL")) {
            UserInfoManager.createUserInfo(baseInfo);
            Map<String, String> initDataMap = new HashMap<String, String>();
            initDataMap.put("langCd", UserInfoManager.getUserInfo().getLangCd());
            initDataMap.put("sessionType", (UserInfoManager.getUserInfo().getUserId().equals("VIRTUAL") ? "virtual" : "normal"));
            initDataMap.put("userId", UserInfoManager.getUserInfo().getUserId());
            initDataMap.put("userType", UserInfoManager.getUserInfo().getUserType());
            req.setAttribute("initData", new ObjectMapper().writeValueAsString(initDataMap));

            return "forward:/home";
        }

        req.setAttribute("eversrmSystemDomainPort", PropertiesManager.getString("eversrm.system.domainPort"));
        req.setAttribute("eversrmSystemDomainUrl", PropertiesManager.getString("eversrm.system.domainUrl"));
        req.setAttribute("eversrmSystemDomainPortHttp", PropertiesManager.getString("eversrm.system.domainPort.http"));
        req.setAttribute("eversrmDevelopmentFlag", PropertiesManager.getBoolean("eversrm.system.developmentFlag"));

        if (StringUtils.isNotEmpty(req.getParameter("returnUrl"))) {
            req.setAttribute("returnUrl", URLDecoder.decode(req.getParameter("returnUrl"), "UTF-8"));
        }

        // RSA 키 생성
        initRsa(req);

        String userAgent = req.getHeader("User-Agent");
        if (StringUtils.containsIgnoreCase(userAgent, "android") || StringUtils.containsIgnoreCase(userAgent, "iphone")) {
            return M_START_PAGE;    // 모바일 로그인 페이지
        } else {
            return START_PAGE_P;    // 고객 및 공급사 로그인 페이지
        }
    }

    /**
     * SSO 로그인
     *
     * @param req
     * @param response
     * @return
     * @throws Exception
     */
    @RequestMapping("/welcomeSSO")
    public String welcomePageSSO(EverHttpRequest req, EverHttpResponse response) throws Exception {

        // SSO 로그인 여부
        req.setAttribute("ssoFlag", "true");
        req.setAttribute("getYear", EverDate.getYear());
        req.setAttribute("getMonth", EverDate.getMonth());
        req.setAttribute("getDay", EverDate.getDay());
        req.setAttribute("getFormattedTime", EverDate.getFormattedTime());

        UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
        if (baseInfo != null && !baseInfo.getUserId().equals("VIRTUAL")) {
            UserInfoManager.createUserInfo(baseInfo);
            Map<String, String> initDataMap = new HashMap<String, String>();
            initDataMap.put("langCd", UserInfoManager.getUserInfo().getLangCd());
            initDataMap.put("sessionType", (UserInfoManager.getUserInfo().getUserId().equals("VIRTUAL") ? "virtual" : "normal"));
            initDataMap.put("userId", UserInfoManager.getUserInfo().getUserId());
            initDataMap.put("userType", UserInfoManager.getUserInfo().getUserType());
            initDataMap.put("appDocNum", EverString.nullToEmptyString(req.getParameter("appDocNum")));
            initDataMap.put("appDocCnt", EverString.nullToEmptyString(req.getParameter("appDocCnt")));
            initDataMap.put("docType", EverString.nullToEmptyString(req.getParameter("docType")));

            req.setAttribute("initData", new ObjectMapper().writeValueAsString(initDataMap));
            return "forward:/homeSSO.so";
        }

        // 공지사항 팝업 목록
        List<Map<String, String>> noticeList = new ArrayList<Map<String, String>>();
        noticeList = indexService.getNoticeListPopup(noticeList);
        req.setAttribute("noticeListPopup", noticeList);

        List<Map<String, String>> MainnoticeList = new ArrayList<Map<String, String>>();
        MainnoticeList = indexService.getNoticeListMain(MainnoticeList);
        req.setAttribute("noticeListMain", MainnoticeList);

        req.setAttribute("eversrmSystemDomainPort", PropertiesManager.getString("eversrm.system.domainPort"));
        req.setAttribute("eversrmSystemDomainUrl", PropertiesManager.getString("eversrm.system.domainUrl"));
        req.setAttribute("eversrmSystemDomainPortHttp", PropertiesManager.getString("eversrm.system.domainPort.http"));
        req.setAttribute("eversrmDevelopmentFlag", PropertiesManager.getBoolean("eversrm.system.developmentFlag"));

        if (StringUtils.isNotEmpty(req.getParameter("returnUrl"))) {
            req.setAttribute("returnUrl", URLDecoder.decode(req.getParameter("returnUrl"), "UTF-8"));
        }

        // RSA 키 생성
        initRsa(req);

        String userAgent = req.getHeader("User-Agent");
        if (StringUtils.containsIgnoreCase(userAgent, "android") || StringUtils.containsIgnoreCase(userAgent, "iphone")) {
            return M_START_PAGE; // 모바일 로그인 페이지
        } else {
            return S_START_PAGE; // SSO 로그인 페이지
        }
    }

    /**
     * rsa 공개키, 개인키 생성
     *
     * @param request
     */
    public void initRsa(HttpServletRequest request) {
        HttpSession session = request.getSession();

        KeyPairGenerator generator;
        try {
            generator = KeyPairGenerator.getInstance("RSA");
            generator.initialize(1024);

            KeyPair keyPair = generator.genKeyPair();
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            PublicKey publicKey = keyPair.getPublic();
            PrivateKey privateKey = keyPair.getPrivate();

            session.setAttribute("_RSA_WEB_Key_", privateKey); // session에 RSA 개인키를 세션에 저장

            RSAPublicKeySpec publicSpec = keyFactory.getKeySpec(publicKey, RSAPublicKeySpec.class);
            String publicKeyModulus = publicSpec.getModulus().toString(16);
            String publicKeyExponent = publicSpec.getPublicExponent().toString(16);

            request.setAttribute("RSAModulus", publicKeyModulus); // rsa modulus 를 request 에 추가
            request.setAttribute("RSAExponent", publicKeyExponent); // rsa exponent 를 request 에 추가
        } catch (Exception e) {
            getLog().error(e.getMessage(), e);
        }
    }

    @RequestMapping("userAgreeCheck")
    public String userAgreeCheck(EverHttpRequest req) {
        String userid = EverString.nullToEmptyString(req.getParameter("USER_ID"));
        req.setAttribute("userId", userid);

        return "/common/userAgreeCheck";
    }

    /**
     * 공지사항 팝업
     *
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping("/evermp/MY01/screenNotice/view")
    public String screenNotice(EverHttpRequest req) throws Exception {
        Map<String, String> param = new HashMap<String, String>();

        String noticeNo = EverString.nullToEmptyString(req.getParameter("NOTICE_NUM"));
        param.put("NOTICE_NUM", noticeNo);

        Map<String, Object> formData = indexService.getNoticePopupInfo(param);
        List<Map<String, Object>> filesInfo = null;
        if (formData != null && formData.size() > 0) {
            filesInfo = fileAttachService.getFilesInfo("NT", (String) formData.get("ATT_FILE_NUM"));
        }

        req.setAttribute("formData", formData);
        req.setAttribute("attachedFiles", filesInfo);

        return "/evermp/MY01/screenNotice";
    }

    @RequestMapping("/ymro/mainNoticeList")
    public void mainNoticeList(EverHttpRequest req, EverHttpResponse resp, @ModelAttribute("pBean") PageNaviBean pBean) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        // ************** 페이징 구현 ***********************//
        int totalCount = indexService.mainNoticeTotalCount(param);
        // paging 정보 셋팅
        pBean.setPagingValue(Integer.parseInt(param.get("pageNo")), 10);
        // start, end 주입
        param.put("startNo", String.valueOf(pBean.getStartNo()));
        param.put("endNo", String.valueOf(pBean.getEndNo()));
        param.put("totalCount", String.valueOf(totalCount));
        // ************** 페이징 구현 ***********************//

        if ("1".equals(param.get("countFlag"))) {
            resp.sendJSON(param);
        } else {
            resp.sendJSON(indexService.mainNoticeList(param));
        }
    }

    @RequestMapping("/ymro/mainNoticeDetail")
    public void mainNoticeDetail(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> reqMap = req.getParamDataMap();
        resp.sendJSON(indexService.mainNoticeDetail(req.getParamDataMap()));
    }

    /**
     * 메인화면 Sub Page View
     */
    @RequestMapping("/mainHtmlView")
    public String company_intro(EverHttpRequest req) throws Exception {
        return "/../../mainHtml/" + req.getParameter("pageFolder") + "/" + req.getParameter("pageNm");
    }


    @RequestMapping("/nosession/FIND01/view")
    public String FIND01(EverHttpRequest req, EverHttpResponse resp) {
        return "/nosession/FIND01";
    }

    /**
     * 공급사 거래제안 팝업
     */
    @RequestMapping("/nosession/BS03_012/view")
    public String BS03_011P(EverHttpRequest req) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        Map<String, Object> formData = new HashMap<String, Object>();
        String noticeType = "PCR";

        String noticeTextNum = largeTextService.selectLargeText("TN221125000009");

        formData.put("NOTICE_CONTENTS", noticeTextNum);
        formData.put("START_DATE", EverDate.getDay());
        formData.put("REG_DATE", EverDate.getDay());
        formData.put("INS_DATE", EverDate.getDay());
        param.put("NOTICE_TYPE", noticeType);
        formData.put("NOTICE_TYPE", noticeType);

        req.setAttribute("formData", formData);

        return "/nosession/BS03_012";
    }

    @RequestMapping(value = "/nosession/BS03_012_doSave")
    public void BS03_011P_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> rtnMap = indexService.BS03_012_doSave(req.getFormData());
        resp.setParameter("NOTICE_NUM", rtnMap.get("NOTICE_NUM"));
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value = "/tmsLogin")
    public void tmsLogin(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setResponseMessage(indexService.tmsLogin(param));
    }

    @RequestMapping("/nosession/POLIST01/view")
    public String POLIST01(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateDay(EverDate.getDate2(), -7));
        req.setAttribute("addToDate", EverDate.getDate2());
        return "/nosession/POLIST01";
    }

    @RequestMapping(value = "/poList01")
    public void poList01(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("grid", indexService.poList01(param));
    }


    @RequestMapping("/nosession/POLIST02/view")
    public String POLIST02(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate2(), -5));
        req.setAttribute("addToDate", EverDate.getDate2());

        Map<String, String> param = req.getParamDataMap();
        req.setAttribute("form", indexService.getTmsInfo(param));


        return "/nosession/POLIST02";
    }


    @RequestMapping(value = "/poList02")
    public void poList02(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("grid", indexService.poList02(param));
    }

    /**
     * 대명소노시즌 DGNS에서 MRO 사이트의 상품정보 상세보기 팝업
     * @param req
     * @param resp
     * @return
     * @throws Exception
     */
    @RequestMapping("/itemspec/view")
    public String ITEM01(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String cms_categ_id   = null2sp(req.getParameter("st_cms_categ_id"));
        String cms_catlg_id   = null2sp(req.getParameter("st_cms_catlg_id"));
        String ITEM_NO        = null2sp(req.getParameter("ITEM_NO"));       // 고객사품목코드
        String BYCA_MNG_CODE  = null2sp(req.getParameter("BYCA_MNG_CODE")); // 고객사코드

        //System.err.println("===============================================================cms_categ_id="+cms_categ_id);
        //System.err.println("===============================================================cms_catlg_id="+cms_catlg_id);
        //System.err.println("===============================================================ITEM_NO="+ITEM_NO);
        //System.err.println("===============================================================BYCA_MNG_CODE="+BYCA_MNG_CODE);

        Map<String,String> param = new HashMap<String,String>();
        param.put("cms_categ_id",cms_categ_id);
        param.put("cms_catlg_id",cms_catlg_id);
        param.put("ITEM_NO",ITEM_NO);
        param.put("BYCA_MNG_CODE",BYCA_MNG_CODE);
        Map<String, String> formData = new HashMap<String, String>();
        formData = im0301Service.getItemViewData(param);

        // 상세품목이미지
        if(StringUtils.isNotEmpty(formData.get("ITEM_DETAIL_FILE_NUM"))) {
            Map<String, String> detailImgInfo = im0301Service.im03014_detailImgInfo(formData);
            if(detailImgInfo!=null){
            	req.setAttribute("ITEM_DETAIL_FILE_PATH", "/fileAttach/downloadImg.so?UUID=" + detailImgInfo.get("UUID") + "&UUID_SQ=" + detailImgInfo.get("UUID_SQ"));
            }
        }else { //상품상세이미지 없으면 메인이미지가 상세이미지로 대체
        	 Map<String, String> detailImgInfo = im0301Service.im03014_detailImgInfo2(formData);
             if(detailImgInfo!=null){
             	req.setAttribute("ITEM_DETAIL_FILE_PATH", "/fileAttach/downloadImg.so?UUID=" + detailImgInfo.get("UUID") + "&UUID_SQ=" + detailImgInfo.get("UUID_SQ"));
             }
        }

        String largeTextNum = formData.get("ITEM_DETAIL_TEXT_NUM");
        if(StringUtils.isNotEmpty(largeTextNum)) {
            req.setAttribute("TEXT_CONTENTS", largeTextService.selectLargeText(formData.get("ITEM_DETAIL_TEXT_NUM")));
        }

        req.setAttribute("formData", formData);
    	return "/nosession/ITEM01";
    }

    public String null2sp(String str) {
        if ( str == null || str == "" || str == "null" || str.equals("") || str.equals("null") || str.equals(null)) return "";
          else return str;
    }

   public String null2ALL(String str) {
    if ( str == null || str == "" || str == "null" || str.equals("") || str.equals("null") || str.equals(null)) return "ALL";
      else return str;
   }


   @RequestMapping(value = "/fileAttach/getUploadedFileInfo")
   public void getUploadedFileInfo(HttpServletRequest req,
                                   EverHttpResponse resp,
                                   @RequestParam(value = "bizType", required = false, defaultValue = "-") String bizType,
                                   @RequestParam("fileId") String uuid,
                                   @RequestParam(value = "caller", required = false, defaultValue = "-") String caller) throws Exception {

       List<Map<String, Object>> fileInfo = fileAttachService.getFilesInfo(bizType, uuid);
       if(bizType.equals("IMG")) {
           for (Map<String, Object> file : fileInfo) {

               try {
                   File imageFile = new File(file.get("FILE_PATH") + "/" + file.get("FILE_NM") + "." + file.get("FILE_EXTENSION"));
                   String encode = Base64.encode(FileUtils.readFileToByteArray(imageFile));
                   file.put("BYTE_ARRAY", encode);
               } catch(FileNotFoundException e) {
                   File imageFile = new File(servletContext.getRealPath("/images/noimage.jpg"));
                   String encode = Base64.encode(FileUtils.readFileToByteArray(imageFile));
                   file.put("BYTE_ARRAY", encode);
               }
           }
       }

       ObjectMapper om = new ObjectMapper();

       if(StringUtils.equals(caller, "fileManager")) {

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


   @RequestMapping(value = "/fileAttach/downloadImg")
   public void fileAttachDownloadImg(EverHttpRequest req, EverHttpResponse resp) throws Exception {

       File finalFile = null;
       boolean shouldDecryptFile = false;

       DataInputStream in = null;
       ServletOutputStream op = null;

       try {

           String userAgent = req.getHeader("User-Agent");

           String uuid = req.getParameter("UUID");
           String uuid_seq = req.getParameter("UUID_SQ");

           Map<String, String> fileInfo = fileAttachService.getFileInfo(uuid, uuid_seq);
           if(fileInfo == null || fileInfo.size() == 0) {
               throw new FileNotFoundException();
           }

           String sourceFile = fileInfo.get("FILE_PATH") + "/" + fileInfo.get("FILE_NM") + "." + fileInfo.get("FILE_EXTENSION");
           String originalFileName = fileInfo.get("REAL_FILE_NM");
           int length = 0;
           ServletContext context = req.getSession().getServletContext();
           String mimeType = context.getMimeType(sourceFile);

           finalFile = new File(sourceFile);
           if (!finalFile.isFile()) {
               finalFile = new File(servletContext.getRealPath("/images/noimage.jpg"));
               throw new FileNotFoundException("FILE NOT FOUND");
           }

           resp.setContentLength((int) finalFile.length());
           resp.setContentType((mimeType != null) ? mimeType : "application/octet-stream;");

           boolean ie = (userAgent.indexOf("MSIE") > -1) || (userAgent.indexOf("Trident") > -1);

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

           resp.setHeader("Content-Disposition", "attachment; filename=\""+ fileName +"\"");

           try {
               op = resp.getOutputStream();
               byte[] bbuf = new byte[4096];

               in = new DataInputStream(new FileInputStream(finalFile));
               while ((length = in.read(bbuf)) != -1) {
                   op.write(bbuf, 0, length);
               }
           } catch(Exception e) {

           } finally {
               if(in != null) {
                   in.close();
               }
               if(op != null) {
                   op.close();
               }
           }

       } catch(FileNotFoundException fne) {
           resp.setContentType("text/html; charset=UTF-8");
           resp.setCharacterEncoding("utf-8");
           resp.getWriter().write("<script type='text/javascript'>alert('첨부파일이 존재하지 않습니다.');</script>");
       } catch (Exception e) {
           resp.setContentType("text/html; charset=UTF-8");
           resp.setCharacterEncoding("utf-8");
           resp.getWriter().write("<script type='text/javascript'>alert('잘못된 접근을 시도했거나 서버에서 오류가 발생했습니다.\\n관리자에게 문의바랍니다.');</script>");
       } finally {

           if(shouldDecryptFile) {
               boolean deleteStatus = finalFile.delete();
           }

           if(op != null) {
               op.flush();
           }
           if(in != null) {
               in.close();
           }
           if(op != null) {
               op.close();
           }
       }
   }


   /**
    * DGNS 거래명세서
    *
    * @param req
    * @return
    * @throws Exception
    */
   @RequestMapping(value="/invoice/view")
   public String PRT_041_DGNS(EverHttpRequest req) throws Exception {
   	String INV_NO = req.getParameter("inv_no"); //Invoice JSON list

   	Map<String, Object> param = new HashMap<String, Object>();

   	param.put("SCREEN_ID", "PRT_041_DGNS");
   	param.put("INV_NO", INV_NO);

   	UserInfo baseinfo = new UserInfo();
    baseinfo.setIsDev(PropertiesManager.getString("eversrm.system.developmentFlag"));
    baseinfo.setGateCd(PropertiesManager.getString("eversrm.gateCd.default"));
    baseinfo.setLangCd(PropertiesManager.getString("eversrm.langCd.default"));
    baseinfo.setManageCd(PropertiesManager.getString("eversrm.default.company.code"));
    baseinfo.setDateFormat("yyyy-MM-dd");
    baseinfo.setSystemGmt(PropertiesManager.getString("eversrm.gmt.default"));
    baseinfo.setUserGmt(PropertiesManager.getString("eversrm.gmt.default"));
    UserInfoManager.createUserInfo(baseinfo);

   	ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
   	req.setAttribute("printData", EverConverter.getJsonString(printData));

   	return "/evermp/PRINT/PRT_041_DGNS";
   }
}