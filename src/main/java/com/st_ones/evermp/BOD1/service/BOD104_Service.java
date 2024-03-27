package com.st_ones.evermp.BOD1.service;

import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.evermp.BOD1.BOD104_Mapper;
import net.coobird.thumbnailator.Thumbnails;
import org.apache.commons.io.FileUtils;
import org.apache.xerces.impl.dv.util.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

@Service(value = "bod104_Service")
public class BOD104_Service extends BaseService {

	@Autowired
	private QueryGenService queryGenService;

	@Autowired
	BOD104_Mapper bod104_Mapper;

	@Autowired
	MessageService msg;

	@Autowired
	private EverMailService everMailService;

	/** ******************************************************************************************
     * 고객사 > 주문관리 > 주문관리 > 주문조회/수정
     * @param param
     * @return List
     * @throws Exception
     */
	public List<Map<String, Object>> bod1040_doSearch(Map<String, String> param) throws Exception {

		if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param.put("COL_NM", "UPODT.ITEM_DESC");
			param.put("COL_VAL", param.get("ITEM_DESC"));

			param.put("ITEM_DESC_01", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

			param.put("COL_NM", "UPODT.ITEM_SPEC");
			param.put("COL_VAL", param.get("ITEM_DESC"));
			param.put("ITEM_DESC_02", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param.put("COL_NM", "UPODT.MAKER_CD");
			param.put("COL_VAL", param.get("MAKER_CD"));

			param.put("MAKER_CD_01", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param.put("COL_NM", "UPODT.MAKER_NM");
			param.put("COL_VAL", param.get("MAKER_NM"));

			param.put("MAKER_NM_01", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			 param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			 param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			 param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		//System.out.println("=====> param.get(DOC_CNT).length() : " + param.get("DOC_CNT"));
		Map<String, Object> fParam = new HashMap<String, Object>(param);
		fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));
/*		if(!EverString.nullToEmptyString(param.get("DOC_NUM")).equals("")) {
			fParam.put("DOC_NUM_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("DOC_NUM")).split(",")));
		}*/
		return bod104_Mapper.bod1040_doSearch(fParam);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bod1040_doSave(List<Map<String, Object>> gridList) throws Exception {

		String cpoNo = "";
		Map<String, Object> cpoSeqMap = null;
		List<Map<String, Object>> cpoSeqList = new ArrayList<Map<String, Object>>();
		for(Map<String, Object> gridData : gridList) {

			bod104_Mapper.bod1040_doSaveUPODT(gridData);

            bod104_Mapper.bod1040_doSaveYPODT(gridData);

			BigDecimal ocpoItemAmt = new BigDecimal(String.valueOf(gridData.get("O_CPO_ITEM_AMT")));
			BigDecimal cpoItemAmt = new BigDecimal(String.valueOf(gridData.get("CPO_ITEM_AMT")));
			BigDecimal calItemAmt = ocpoItemAmt.subtract(cpoItemAmt);
			String calItemAmtStr = calItemAmt.toString();

			// MP102에 등록된 CUST_CD와 ses.companyCd가 같은 경우, 고정계정을 사용하는 고객사이므로 고정계정을 사용한다.
			//gridData.put("P_ACCOUNT_CD", gridData.get("ACCOUNT_CD"));
			//String pAccountCd = bod104_Mapper.bod1040_getAccountCd(gridData);
			gridData.put("ACCOUNT_CD", gridData.get("ACCOUNT_CD"));

			// 예산변경
			gridData.put("O_CPO_ITEM_AMT", 0);
			gridData.put("CPO_ITEM_AMT", calItemAmtStr);
			bod104_Mapper.bod1040_doSaveCCUBD(gridData);

			// 동일한 주문건별로 변경이 이루어짐
			if( "".equals(cpoNo) ){
				cpoNo = gridData.get("CPO_NO").toString();
			}
			cpoSeqMap = new HashMap<String, Object>();
			cpoSeqMap.put("CPO_SEQ", String.valueOf(gridData.get("CPO_SEQ")));
			cpoSeqList.add(cpoSeqMap);
		}

		// EMAIL 및 SMS 발송
		try {
			Map<String, Object> param = new HashMap<String, Object>();
			param.put("CPO_NO", cpoNo);
			param.put("cpoSeqList", cpoSeqList);
			sendEmailNSms(param);
		} catch ( Exception ex ){
			System.out.println("=====> 고객새 주문변경(BOD1_040) 메일발송 오류 : " + ex);
		}

		return msg.getMessage("0031");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bod1040_doCancel(List<Map<String, Object>> gridList) throws Exception {

		String cpoNo = "";
		Map<String, Object> cpoSeqMap = null;
		List<Map<String, Object>> cpoSeqList = new ArrayList<Map<String, Object>>();
		for(Map<String, Object> gridData : gridList) {

		    String CPO_CNT = String.valueOf(gridData.get("CPO_CNT"));
            String PO_CNT  = String.valueOf(gridData.get("PO_CNT"));

//          if("1".equals(CPO_CNT)) {
//          	bod104_Mapper.bod1040_doCancelUPOHD(gridData);
//          }
            bod104_Mapper.bod1040_doCancelUPODT(gridData);

            if("1".equals(PO_CNT)) {
                bod104_Mapper.bod1040_doCancelYPOHD(gridData);
            }
            bod104_Mapper.bod1040_doCancelYPODT(gridData);

			// MP102에 등록된 CUST_CD와 ses.companyCd가 같은 경우, 고정계정을 사용하는 고객사이므로 고정계정을 사용한다.
//			gridData.put("P_ACCOUNT_CD", gridData.get("ACCOUNT_CD"));
//			String pAccountCd = bod104_Mapper.bod1040_getAccountCd(gridData);
			gridData.put("ACCOUNT_CD",  gridData.get("ACCOUNT_CD"));

			// 예산원복
            // gridData.put("CPO_ITEM_AMT", 0);
            bod104_Mapper.bod1040_doSaveCCUBD(gridData);

            // 동일한 주문건별로 취소가 이루어짐
 			if( "".equals(cpoNo) ){
				cpoNo = gridData.get("CPO_NO").toString();
			}

 			cpoSeqMap = new HashMap<String, Object>();
			cpoSeqMap.put("CPO_SEQ", String.valueOf(gridData.get("CPO_SEQ")));
			cpoSeqList.add(cpoSeqMap);
		}

		// EMAIL 및 SMS 발송
		/*try {
			Map<String, Object> param = new HashMap<String, Object>();
			param.put("CPO_NO", cpoNo);
			param.put("cpoSeqList", cpoSeqList);
			sendEmailNSms(param);
		} catch ( Exception ex ){
			System.out.println("=====> 고객새 주문취소(BOD1_040) 메일발송 오류 : " + ex);
		}
		2022 12 22 주문 수정시 메일발송 삭제*/

		return msg.getMessageByScreenId("BOD1_040", "008");
	}

    /** ******************************************************************************************
     * 고객사 > 주문관리 > 주문관리 > 주문조회/수정 > 주문상세정보
     * @param param
     * @return List
     * @throws Exception
     */
    public List<Map<String, Object>> bod1041_doSearch(Map<String, String> param) throws Exception {
        return bod104_Mapper.bod1041_doSearch(param);
    }

    public List<Map<String, Object>> bod1041_doSearchINV(Map<String, String> param) throws Exception {
        return bod104_Mapper.bod1041_doSearchINV(param);
    }

    public List<Map<String, Object>> bod1041_doSearchINV2(Map<String, String> param) throws Exception {
        return bod104_Mapper.bod1041_doSearchINV2(param);
    }

	/** ******************************************************************************************
     * 고객사 > 주문관리 > 주문상세정보
     * @param param
     * @return List
     * @throws Exception
     */
    public Map<String, Object> bod1042_doSearchHD(Map<String, String> param) throws Exception {
        return bod104_Mapper.bod1042_doSearchHD(param);
    }

    public List<Map<String, Object>> bod1042_doSearchDT(Map<String, String> param, String gridType) throws Exception {

		List<Map<String, Object>> returnList = new ArrayList<Map<String, Object>>();
		if(gridType.equals("I")) {
			
			String domainNm   = PropertiesManager.getString("eversrm.system.imageDomainName");
			String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
			
			String siteUrl  = "";
			boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
			if (sslFlag) { siteUrl = "https://"; }
			else { siteUrl = "http://"; }
			if ("80".equals(domainPort)) {
				siteUrl += domainNm;
			} else {
				siteUrl += domainNm + ":" + domainPort;
			}
			
            param.put("publicImagePath", PropertiesManager.getString("everf.imageUpload.path"));
            returnList = bod104_Mapper.bod1042_doSearchImgDT(param);
			for (Map<String, Object> result : returnList) {

				result.put("CUST_ITEM_CDS", String.valueOf(EverString.nullToEmptyString(result.get("ITEM_CD"))) + "\n" + String.valueOf(EverString.nullToEmptyString(result.get("CUST_ITEM_CD"))));
				result.put("PRIOR_GR_NAP_FLAG", String.valueOf(EverString.nullToEmptyString(result.get("PRIOR_GR_FLAG"))) + "\n" + String.valueOf(EverString.nullToEmptyString(result.get("NAP_FLAG"))));
				result.put("PROGRESS_CD_REF_MNG_NO", String.valueOf(EverString.nullToEmptyString(result.get("PROGRESS_NM"))) + "\n" + String.valueOf(EverString.nullToEmptyString(result.get("REF_MNG_NO"))));
				result.put("ITEM_DESC_SPEC", String.valueOf(EverString.nullToEmptyString(result.get("ITEM_DESC"))) + "\n" + String.valueOf(EverString.nullToEmptyString(result.get("ITEM_SPEC"))));
				result.put("MAKER_NM_MAKER_PART_NO", String.valueOf(EverString.nullToEmptyString(result.get("MAKER_NM"))) + "\n" + String.valueOf(EverString.nullToEmptyString(result.get("MAKER_PART_NO"))));
				result.put("BRAND_NM_ORIGIN_CD", String.valueOf(EverString.nullToEmptyString(result.get("BRAND_NM"))) + "\n" + String.valueOf(EverString.nullToEmptyString(result.get("ORIGIN_NM"))));
				result.put("BD_DEPT_NM_ACCOUNT_CD", String.valueOf(EverString.nullToEmptyString(result.get("BD_DEPT_NM"))) + "\n" + String.valueOf(EverString.nullToEmptyString(result.get("ACCOUNT_NM"))));
				result.put("PLANT", String.valueOf(EverString.nullToEmptyString(result.get("PLANT_CD"))) + "\n" + String.valueOf(EverString.nullToEmptyString(result.get("PLANT_NM"))));
				result.put("UNIT_CD_CUR", String.valueOf(EverString.nullToEmptyString(result.get("UNIT_CD"))) + "\n" + String.valueOf(EverString.nullToEmptyString(result.get("CUR"))));
				result.put("CPO_QTY_UNIT_PRC", String.valueOf(result.get("CPO_QTY")) + "\n" + String.valueOf(result.get("UNIT_PRC")));
				result.put("LEAD_TIME_HOPE_DUE_DATE", String.valueOf(result.get("REG_DATE")) + "\n" + String.valueOf(result.get("HOPE_DUE_DATE")));
				result.put("CSDM_SEQ_DELY_NM", String.valueOf(result.get("CSDM_SEQ")) + "\n" + String.valueOf(result.get("DELY_NM")));
				result.put("RECIPIENT_NM_DEPT_NM", String.valueOf(result.get("RECIPIENT_NM")) + "\n" + String.valueOf(result.get("RECIPIENT_DEPT_NM")));
				result.put("RECIPIENT_TEL_FAX_NUM", String.valueOf(result.get("RECIPIENT_TEL_NUM")) + "\n" + String.valueOf(result.get("RECIPIENT_FAX_NUM")));
				result.put("RECIPIENT_CELL_EMAIL", String.valueOf(result.get("RECIPIENT_CELL_NUM")) + "\n" + String.valueOf(result.get("RECIPIENT_EMAIL")));
				result.put("DELY_ADDR", String.valueOf(result.get("DELY_ADDR_1")) + "\n" + String.valueOf(result.get("DELY_ADDR_2")));


				UserInfo userInfo = UserInfoManager.getUserInfo();
				if(userInfo.getUserType().equals("C")) {
					result.put("CPO_QTY_CONT_UNIT_PRC", String.valueOf(result.get("CPO_QTY")) + "\n" + String.valueOf(result.get("CONT_UNIT_PRC")));
				}

				// 풀경로를 가져온다. ex) "MAIN_IMG" -> "/home/tomcat/source/mro.war/temp/uploads/images/2018/201812/115707m.jpg"
				//String main_img = (localFlag.equals("true") ? "C:/temp/uploads/images/" : PropertiesManager.getString("everf.imageUpload.path")) + String.valueOf(result.get("MAIN_IMG"));
				String main_img = String.valueOf(result.get("MAIN_IMG"));
				// 확장자를 가져온다. ex) jpg
				String extension = String.valueOf(result.get("FILE_EXTENSION"));

				// 썸네일을 저장할 Path 를 가져온다. ex) /home/tomcat/source/mro.war/temp/uploads/images/2018/201812/
				String imgFileNum = main_img.split("/")[main_img.split("/").length - 1];
				/*String realImgFileNum = String.valueOf(result.get("MAIN_IMG")).split("/")[String.valueOf(result.get("MAIN_IMG")).split("/").length - 1];*/
				String thumbnail_Path = main_img.substring(0, main_img.indexOf(imgFileNum));
				String sumNm = imgFileNum.replaceAll("\\." + extension, "") + "_" + "S" + "." + extension;
				//String real_Path = "/img/" + String.valueOf(result.get("MAIN_IMG")).substring(0, String.valueOf(result.get("MAIN_IMG")).indexOf(realImgFileNum));
				String real_Path = "/img/" + main_img.substring((main_img.indexOf("Public") + 7), main_img.indexOf(imgFileNum));

				// 썸네일에 저장할 파일명을 변경한다. ex) /home/tomcat/source/mro.war/temp/uploads/images/2018/201812/1300000001_1_S.jsp
				if (EverString.nullToEmptyString(String.valueOf(result.get("FILE_PATH"))).equals("") || EverString.nullToEmptyString(String.valueOf(result.get("FILE_PATH"))).equals("null")) {
					result.put("MAIN_IMG", "/images/noimage.jpg");
				}
				else {
					/*String thumbnailNm = thumbnail_Path + result.get("IMG_FILE_NUM") + "_" + "S" + "." + extension;*/
					String thumbnailNm = thumbnail_Path + sumNm;
					File thumbnail = new File(thumbnailNm);
					if (thumbnail.exists()) {
						String encode = Base64.encode(FileUtils.readFileToByteArray(thumbnail));
						result.put("MAIN_IMG_TOOLTIP", "<div><img src=\"data:image/" + extension + ";base64," + encode + "\"></div>");
						//result.put("MAIN_IMG", siteUrl + real_Path + result.get("IMG_FILE_NUM") + "_" + "S" + "." + extension);
						result.put("MAIN_IMG", siteUrl + real_Path + sumNm);
					}
					else {
						File image = new File(main_img);
						if (image.exists()) {
							thumbnail.getParentFile().mkdirs();
							try {
								//Thumbnails.of(image).size(80, 80).outputQuality(1.0f).outputFormat(extension).toFile(thumbnail);
								Thumbnails.of(image).size(80, 80).toFile(thumbnail);
							} catch (IOException e) {
								e.printStackTrace();
							}
							//result.put("MAIN_IMG", siteUrl + real_Path + result.get("IMG_FILE_NUM") + "_" + "S" + "." + extension);
							result.put("MAIN_IMG", siteUrl + real_Path + sumNm);
						}
						else {
							result.put("MAIN_IMG", "/images/noimage.jpg");
						}
					}
				}
			}
		} else {
            returnList = bod104_Mapper.bod1042_doSearchDT(param);
        }
    	return returnList;
    }

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bod1042_doCart(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

		String itemCdStr = "'";
		for (Map<String, Object> gridData : gridDatas) {
			itemCdStr = itemCdStr + String.valueOf(gridData.get("ITEM_CD")) + "','";
		}
		if(itemCdStr.length() > 1) { itemCdStr = itemCdStr.substring(0, itemCdStr.length() - 2); }

		Map<String, String> param = new HashMap<String, String>();
		param.put("CPO_NO", formData.get("CPO_NO"));
		param.put("ITEM_CD_STR", itemCdStr);

		List<Map<String, Object>> addList = bod104_Mapper.bod1042_getAddList(param);

		UserInfo userInfo = UserInfoManager.getUserInfo();
		for (Map<String, Object> addData : addList) {
			addData.put("USER_ID", userInfo.getUserId());
			bod104_Mapper.bod1042_doCart(addData);
		}

		return msg.getMessageByScreenId("BOD1_042", "014");
	}

    // 주문변경 EMAIL 보내기
 	@AuthorityIgnore
 	public void sendEmailNSms(Map<String, Object> param) throws Exception {

        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.CPO_CHNG_TemplateFileName");

        String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");
		
		String maintainUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { maintainUrl = "https://"; }
		else { maintainUrl = "http://"; }
		if ("80".equals(domainPort)) {
			maintainUrl += domainNm;
		} else {
			maintainUrl += domainNm + ":" + domainPort;
		}
		maintainUrl += contextNm;

        // 주문변경 품목정보 가져오기
		String fileContents = "";
		fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");

		Map<String, Object> cpoHeader = bod104_Mapper.getCpoChangeHeaderInfo(param);
        fileContents = EverString.replace(fileContents, "$CPO_NO$", EverString.nullToEmptyString(cpoHeader.get("CPO_NO"))); // 주문번호
        fileContents = EverString.replace(fileContents, "$CPO_DATE$", EverString.nullToEmptyString(cpoHeader.get("CPO_DATE"))); // 주문일자
        fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(cpoHeader.get("USER_NM"))); // 운영사의 진행관리담당자

        String tblBody = "<tbody>";
        String enter = "\n";
        // 주문품목(UPODT) 가져오기
        List<Map<String, Object>> itemList = bod104_Mapper.getCpoChangeDetailInfo(param);
        if( itemList.size() > 0 ){
            for( Map<String, Object> itemData : itemList ){
                // 품목명
            	String itemDesc = (String)itemData.get("ITEM_DESC");
                if(itemDesc.length() > 29) { itemDesc = itemDesc.substring(0, 30) + "..."; }
                // 품목규격
                String itemSpec = (String)itemData.get("ITEM_SPEC");
                if(itemSpec.length() > 29) { itemSpec = itemSpec.substring(0, 30) + "..."; }

                // 품목리스트
                String tblRow = "<tr>"
                		+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd' rowspan='2'>" + EverString.nullToEmptyString(itemData.get("ITEM_CD")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:right;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_QTY")) + "</td>"
                        + enter + "</tr>"
                        + enter + "<tr>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("UNIT_CD")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</td>"
                        + enter + "</tr>";
                tblBody += tblRow;
            }
        }
        fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
        fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
        fileContents = EverString.rePreventSqlInjection(fileContents);

    	if( !"".equals(cpoHeader.get("EMAIL")) ){
            Map<String, String> mdata = new HashMap<String, String>();
            mdata.put("SUBJECT", "[대명소노시즌] 주문번호("+EverString.nullToEmptyString(cpoHeader.get("CPO_NO"))+")에 대해 주문수정/취소가 발생하였습니다.");
            mdata.put("CONTENTS_TEMPLATE", fileContents);
            mdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoHeader.get("CPO_USER_ID")));
            mdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoHeader.get("CPO_USER_NM")));
            mdata.put("SEND_EMAIL", EverString.nullToEmptyString(cpoHeader.get("CPO_EMAIL")));
            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoHeader.get("USER_ID")));
            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoHeader.get("USER_NM")));
            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(cpoHeader.get("EMAIL")));
            mdata.put("REF_NUM", EverString.nullToEmptyString(cpoHeader.get("CPO_NO")));
            mdata.put("REF_MODULE_CD", "CPO"); // 참조모듈

            // Mail 발송
            everMailService.sendMail(mdata);
			mdata.clear();
        }
 	}

}
