package com.st_ones.evermp.BOD1.service;

import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BOD1.BOD101_Mapper;
import com.st_ones.evermp.BOD1.BOD103_Mapper;
import com.st_ones.evermp.SIV1.SIV101_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service(value = "bod101Service")
public class BOD101_Service extends BaseService {

	@Autowired
	BOD101_Mapper bod101Mapper;

	@Autowired
	MessageService msg;

	@Autowired
	private QueryGenService queryGenService;
    @Autowired DocNumService  docNumService;  // 문서번호채번
    @Autowired BOD103_Mapper  bod103_Mapper;  // 주문Cart

	@Autowired
	SIV101_Mapper siv101_Mapper;
	@Autowired
	private RealtimeIF_Service realtimeifService;
	public Map<String, String> getBackMaster(Map<String, String> formData) throws Exception {
		return bod101Mapper.getBackMaster(formData);
	}



	/**
	 * ***************************************************************************************************************
	 * 주문 조회 (품목현황)
	 *
	 * @param formData
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> bod1010_doSearch(Map<String, String> formData, String gridType) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		String mySiteYn = EverString.nullToEmptyString(userInfo.getBuyerMySiteFlag());

		List<Map<String, Object>> returnList = new ArrayList<Map<String,Object>>();

		Map<String, String> sParam = new HashMap<String, String>();

		if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
			sParam.put("COL_VAL", formData.get("ITEM_DESC"));
			sParam.put("COL_NM", "A.ITEM_DESC||A.ITEM_SPEC");
			formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}

		// MySite 고객사여부에 따라 조회쿼리다름
		String domainNm   = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort = PropertiesManager.getString("eversrm.system.domainPort");

		String siteUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { siteUrl = "https://"; }
		else { siteUrl = "http://"; }
		siteUrl += domainNm;

		formData.put("DOMAIN", siteUrl);
		formData.put("PORT", domainPort);
		formData.put("localYN", PropertiesManager.getString("eversrm.system.localserver"));
		formData.put("publicImagePath", PropertiesManager.getString("everf.imageUpload.path"));

		if(EverString.isNotEmpty(formData.get("ITEM_CD"))) {
			formData.put("ITEM_CD_ORG", formData.get("ITEM_CD"));
			formData.put("ITEM_CD", EverString.forInQuery(formData.get("ITEM_CD"), ","));
			formData.put("ITEM_CNT", formData.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		String MgInfo = bod101Mapper.bod1010_getMgInfo(formData);
		formData.put("MG_CD", MgInfo);

		Map<String, Object> itemList = new HashMap<>();
		itemList.putAll(formData);
		itemList.put("ITEM_DESC_LIST", Arrays.asList(EverString.nullToEmptyString(itemList.get("ITEM_DESC")).split("\\+")));

		if(mySiteYn.equals("1")){
			returnList = bod101Mapper.bod1010_doSearch_MySiteYes(itemList);
		} else {
			returnList = bod101Mapper.bod1010_doSearch_MysiteNo(itemList);
		}

		// 썸네일
		if(gridType.equals("I")) {
			for (Map<String, Object> result : returnList) {

				result.put("ITEM_DESC_SPEC", EverString.nullToEmptyString(result.get("ITEM_DESC")) + "\n" + EverString.nullToEmptyString(result.get("ITEM_SPEC")));
				result.put("MAKER_NMS", EverString.nullToEmptyString(result.get("MAKER_NM")) + "\n" + EverString.nullToEmptyString(result.get("MAKER_PART_NO")));
				result.put("BRAND_NMS", EverString.nullToEmptyString(result.get("BRAND_NM")) + "\n" + EverString.nullToEmptyString(result.get("ORIGIN_NM")));
				result.put("VAT_REG_NM", EverString.nullToEmptyString(result.get("VAT_NM")) + "\n" + EverString.nullToEmptyString(result.get("CONT_REGION_NM")));

				String moqQty = EverMath.EverNumberType(Double.parseDouble(String.valueOf(result.get("MOQ_QTY"))), "###,###");
				String rvQty = EverMath.EverNumberType(Double.parseDouble(String.valueOf(result.get("RV_QTY"))), "###,###");
				result.put("MVIEW_QTY", moqQty + "\n" + rvQty);
				String leadTime = EverMath.EverNumberType(Double.parseDouble(String.valueOf(result.get("LEAD_TIME"))), "###,###");
				result.put("MVIEW_UNIT", EverString.nullToEmptyString(result.get("UNIT_NM")) + "\n" + leadTime);

				// 풀경로를 가져온다. ex) "MAIN_IMG" -> "/home/tomcat/source/mro.war/temp/uploads/images/2018/201812/115707m.jpg"
				String main_img = String.valueOf(result.get("MAIN_IMG"));
				// 확장자를 가져온다. ex) jpg
				String extension = String.valueOf(result.get("FILE_EXTENSION"));

				// 썸네일을 저장할 Path 를 가져온다. ex) /home/tomcat/source/mro.war/temp/uploads/images/2018/201812/
				String imgFileNum = main_img.split("/")[main_img.split("/").length - 1];
				String thumbnail_Path = main_img.substring(0, main_img.indexOf(imgFileNum));
				String sumNm = imgFileNum.replaceAll("\\." + extension, "") + "_" + "S" + "." + extension;
				String real_Path = "/img/" + main_img.substring((main_img.indexOf("Public") + 7), main_img.indexOf(imgFileNum));

				// 썸네일에 저장할 파일명을 변경한다. ex) /home/tomcat/source/mro.war/temp/uploads/images/2018/201812/1300000001_1_S.jsp
				if (EverString.nullToEmptyString(String.valueOf(result.get("FILE_PATH"))).equals("") || EverString.nullToEmptyString(String.valueOf(result.get("FILE_PATH"))).equals("null")) {
					result.put("MAIN_IMG", "/images/noimage.jpg");
				}
				else {
					String imageUrl  = "";
					if (sslFlag) { imageUrl = "https://"; }
					else { imageUrl = "http://"; }
					if ("80".equals(domainPort)) {
						imageUrl += domainNm;
					} else {
						imageUrl += domainNm + ":" + domainPort;
					}
					result.put("MAIN_IMG", imageUrl + "/common/file/fileAttach/download.so?UUID="+result.get("IMG_ATT_FILE_NUM")+"&UUID_SQ="+result.get("MAIN_IMG_SQ"));

					//System.err.println("============================MAIN_IMG="+result.get("MAIN_IMG"));
					/*
					String thumbnailNm = thumbnail_Path + sumNm;
					System.err.println("===================================================="+thumbnailNm);
					File thumbnail = new File(thumbnailNm);
					// getLog().info(thumbnailNm);
					if (thumbnail.exists()) {
						String encode = Base64.encode(FileUtils.readFileToByteArray(thumbnail));
						result.put("MAIN_IMG_TOOLTIP", "<div><img src=\"data:image/" + extension + ";base64," + encode + "\"></div>");

//						result.put("MAIN_IMG", (developmentFlag.equals("false") ? PropertiesManager.getString("eversrm.system.domainName") : "http://" + PropertiesManager.getString("eversrm.system.domainUrl") + ":" + PropertiesManager.getString("eversrm.system.domainPort")) + real_Path + sumNm);
						result.put("MAIN_IMG", "http://localhost:8480/common/file/fileAttach/download.so?UUID=81625&UUID_SQ=1669876670100");
						System.err.println("============================MAIN_IMG="+result.get("MAIN_IMG"));
					} else {
						File image = new File(main_img);
						// getLog().info(main_img + " / exists? : " + image.exists());
						if (image.exists()) {
							thumbnail.getParentFile().mkdirs();

							try {
								// Thumbnails.of(image).size(80, 80).outputQuality(1.0f).outputFormat(extension).toFile(thumbnail);
								Thumbnails.of(image).size(80, 80).toFile(thumbnail);
							} catch (Exception e) {
								e.printStackTrace();
							} finally {
								//Thumbnails.of(image).size(80, 80).toFile(thumbnail);
							}
							result.put("MAIN_IMG", (developmentFlag.equals("false") ? PropertiesManager.getString("eversrm.system.domainName") : "http://" + PropertiesManager.getString("eversrm.system.domainUrl") + ":" + PropertiesManager.getString("eversrm.system.domainPort")) + real_Path + sumNm);
						}
						else {
							result.put("MAIN_IMG", "/images/noimage.jpg");
						}
					}*/
				}
			}
		}
		return returnList;
	}





    public Map<String,String> getQueryParam(Map<String, String> param, String COL_NM, String COL_VAL, String key) {
        param.put("COL_NM", COL_NM);
        param.put("COL_VAL", COL_VAL);

        param.put(key, EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

        return param;
    }

    public List<Map<String, Object>> bod1110Dosearch(Map<String, String> param) {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	param.put("CUST_CD",userInfo.getCompanyCd());
        }




    	if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
            param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
			param = getQueryParam(param, "YPODT.ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_03");
			param = getQueryParam(param, "YPODT.CUST_ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_04");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
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

        return bod101Mapper.bod1110Dosearch(param);
    }




    public List<Map<String, Object>> bod1120Dosearch(Map<String, String> param) {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	param.put("CUST_CD",userInfo.getCompanyCd());
        }

    	if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
            param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
			param = getQueryParam(param, "YPODT.ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_03");
			param = getQueryParam(param, "YPODT.CUST_ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_04");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
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

        return bod101Mapper.bod1120Dosearch(param);
    }


    public List<Map<String, Object>> bod1111Dosearch(Map<String, String> param) {
        return bod101Mapper.bod1111Dosearch(param);
    }



    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doBack(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
    	int cpoSeq = 1;
    	String custCd = String.valueOf(gridDatas.get(0).get("CUST_CD"));
    	String plantCd = String.valueOf(gridDatas.get(0).get("PLANT_CD"));
    	formData.put("CUST_CD",  custCd);
    	formData.put("PLANT_CD",  plantCd);

    	formData.put("NEW_CPO_NO",docNumService.getDocNumber("TB"));
        bod101Mapper.doInsertUPOHD(formData);

        for (Map<String, Object> gridData : gridDatas) {
        	gridData.put("NEW_CPO_NO", formData.get("NEW_CPO_NO") );
        	gridData.put("PLANT_CD", formData.get("PLANT_CD") );
        	gridData.put("HOPE_DUE_DATE", formData.get("HOPE_DUE_DATE") );
        	gridData.put("NEW_CPO_SEQ", cpoSeq++ );
            bod101Mapper.doInsertUPODT(gridData);
        }

        String PO_NO = docNumService.getDocNumber("TBP");
        Map<String, Object> poData = new HashMap<String,Object>();
        poData.put("CPO_NO",  formData.get("NEW_CPO_NO"));
        poData.put("PO_NO",   PO_NO);
        poData.put("CUST_CD", custCd);
        poData.put("PROGRESS_CD", "5300");
        bod101Mapper.doInsertYPOHD(poData);
        bod101Mapper.doInsertYPODT(poData);


        //if(1==1) throw new Exception("==============================================================");
        return msg.getMessageByScreenId("BOD1_111", "002");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doBackCancel(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
        for (Map<String, Object> gridData : gridDatas) {
        	bod101Mapper.delupodt(gridData);
        	bod101Mapper.delypodt(gridData);
        	bod101Mapper.delupohd(gridData);
        	bod101Mapper.delypohd(gridData);
        }

        //if(1==1) throw new Exception("==============================================================");
        return msg.getMessageByScreenId("BOD1_120", "006");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doBackAgree(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
		/*
		 * 인터페이스주문 반품 납품명세서  -> 끝
		 * 일반주문 반품 입고 -> 끝
		 */
		Map<String,String> ifMap = new HashMap<String,String>();
		for (Map<String, Object> gridData : gridDatas) {
			//일반주문 반품 입고 -> 끝
        	if(gridData.get("IF_CPO_NO") == null || "".equals(gridData.get("IF_CPO_NO"))) {
        		String IV_NO    = docNumService.getDocNumber("IV"); // 공급사 납품서 번호
				String INV_NO   = docNumService.getDocNumber("INV"); // 운영사 납품서 번호

				gridData.put("IV_NO",  IV_NO);
				gridData.put("INV_NO", INV_NO);
				gridData.put("IV_SEQ", "1");
				gridData.put("INV_SEQ", "1");


				gridData.put("INV_QTY",  gridData.get("CPO_QTY"));

				siv101_Mapper.siv1020_doCreateYIVHD(gridData);
				siv101_Mapper.siv1020_doCreateUIVHD(gridData);
				siv101_Mapper.siv1020_doCreateYIVDT(gridData);
				siv101_Mapper.siv1020_doCreateUIVDT(gridData);

				bod101Mapper.siv1020_doUpdateYPODT(gridData);
				bod101Mapper.siv1020_doUpdateUPODT(gridData);


        		String GR_NO = docNumService.getDocNumber("GR");
            	gridData.put("GR_NO",GR_NO);
            	bod101Mapper.doGrSaveGRDT(gridData);
        	}
        	else {//인터페이스 주문 반품 납품명세서  -> 끝
        		String IV_NO  = docNumService.getDocNumber("IV"); // 공급사 납품서 번호
				String INV_NO = docNumService.getDocNumber("INV"); // 운영사 납품서 번호

				gridData.put("IV_NO",  IV_NO);
				gridData.put("INV_NO", INV_NO);
				gridData.put("IV_SEQ", "1");
				gridData.put("INV_QTY",  gridData.get("CPO_QTY"));

				siv101_Mapper.siv1020_doCreateYIVHD(gridData);
				siv101_Mapper.siv1020_doCreateUIVHD(gridData);
				siv101_Mapper.siv1020_doCreateYIVDT(gridData);
				siv101_Mapper.siv1020_doCreateUIVDT(gridData);
				bod101Mapper.siv1020_doUpdateYPODT(gridData);
				bod101Mapper.siv1020_doUpdateUPODT(gridData);

				ifMap.put(INV_NO, "*");
        	}
        }
		
		// ================ 반품승인시 DGNS I/F 데이터 등록 =============== //
		Set set = ifMap.keySet();
		if(set.size() > 0) {
			realtimeifService.regDgnsInvoice(ifMap);
		}
		// ================ 반품승인시 DGNS I/F 데이터 등록 =============== //
		
        return msg.getMessageByScreenId("BOD1_120", "005");
    }



}