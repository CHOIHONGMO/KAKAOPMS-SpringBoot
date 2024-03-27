package com.st_ones.eversrm.system.org.service;

import com.st_ones.common.config.service.EverConfigService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.org.BSYO_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Iterator;
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
 * @File Name : BSYO_Service.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Service(value = "bsyo_Service")
public class BSYO_Service extends BaseService {

	private static final String EVER_DBLINK = "ever.remote.database.link.name";

	@Autowired
	private EverConfigService everConfigService;

	@Autowired
	private MessageService msg;

	@Autowired
	BSYO_Mapper bsyo_Mapper;

	public List<Map<String, Object>> selectGate(Map<String, String> param) throws Exception {
		return bsyo_Mapper.selectGate(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveGate(Map<String, String> formData) throws Exception {

		int check = bsyo_Mapper.checkGateUnitExists(formData);

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGHU");
		//formData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

		if (check > 0) {
			bsyo_Mapper.updateGate(formData);
		} else {
			bsyo_Mapper.insertGate(formData);
		}
		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteGate(Map<String, String> formData) throws Exception {

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGHU");
		//formData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

		bsyo_Mapper.deleteGate(formData);
		return msg.getMessage("0017");
	}

//	/* Test function for PDF printing */
//	public String printGate(Map<String, Object> formData, Document document) throws Exception {
//
//		Map<String, Object> houseInfo = bsyo_Mapper.selectGateInfo(formData);
//		if (houseInfo == null) {
//			return msg.getMessage("0009");
//		}
//
//		buildPdf_page(document, houseInfo);
//		buildPdf_metadata(document);
//		return msg.getMessage("0001");
//	}

	public List<Map<String, Object>> selectCompany(Map<String, String> param) throws Exception {
		return bsyo_Mapper.selectCompany(param);
	}


	public List<Map<String, Object>> selectDeptGrid(Map<String, String> param) throws Exception {
		return bsyo_Mapper.selectDeptGrid(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveCompany(Map<String, String> formData) throws Exception {

		int transCnt = -1;

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGCM");
		//formData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

		int check = bsyo_Mapper.checkCompanyExists(formData);

		if (check > 0) {
			transCnt = bsyo_Mapper.updateCompany(formData);
		} else {
			transCnt = bsyo_Mapper.insertCompany(formData);
		}

		if (transCnt < 1) {
			throw new NoResultException(msg.getMessageForService(this, "exception_msg"));
		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteCompany(Map<String, String> formData) throws Exception {

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGCM");
		bsyo_Mapper.deleteCompany(formData);

		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> selectPurchaseComMapping(Map<String, String> param) throws Exception {
		return bsyo_Mapper.selectPurchaseComMapping(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String savePurchaseComMapping(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCOGCM");

			bsyo_Mapper.savePurchaseComMapping(gridData);
		}

		return msg.getMessage("0001");
	}

	public List<Map<String, Object>> selectPurchaseOrg(Map<String, String> param) throws Exception {
		return bsyo_Mapper.selectPurchaseOrg(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String savePurchaseOrg(Map<String, String> formData) throws Exception {

		int rtn = -1;

		int check = bsyo_Mapper.checkPurchaseOrgExists(formData);

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGPU");

		if (check > 0) {
			rtn = bsyo_Mapper.updatePurchaseOrg(formData);
		} else {
			rtn = bsyo_Mapper.insertPurchaseOrg(formData);
		}

		if (rtn < 1) {
			throw new NoResultException(msg.getMessage("0003"));
		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deletePurchaseOrg(Map<String, String> formData) throws Exception {

		int rtn = -1;

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGPU");

		rtn = bsyo_Mapper.deletePurchaseOrg(formData);
		if (rtn < 1) {
			throw new NoResultException(msg.getMessage("0003"));
		}

		return msg.getMessage("0001");
	}

	public List<Map<String, Object>> selectPlant(Map<String, String> param) throws Exception {
		return bsyo_Mapper.selectPlant(param);
	}

	@SuppressWarnings("rawtypes")
	public Map<String, String> getPlantInfo(Map<String, String> param) throws Exception {

		Map<String, String> saveParam = new HashMap<String, String>();
		saveParam.putAll(param);

		Map<String, String> result = bsyo_Mapper.getPlantInfo(param);
		if (result == null) {
			result = new HashMap<String, String>();
		}
		Iterator iterator = saveParam.keySet().iterator();
		while (iterator.hasNext()) {
			String key = (String)iterator.next();
			if (!result.containsKey(key)) {
				result.put(key, null);
			}
		}

		return result;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String savePlant(Map<String, String> formData) throws Exception {

		String buyerCd = formData.get("BUYER_CD");
		String buyerCdOri = formData.get("BUYER_CD_ORI");

		String plantCd = formData.get("PLANT_CD");
		if (plantCd == null || "".equals(plantCd)) {
			plantCd = bsyo_Mapper.getPlantCd( formData );
			formData.put("PLANT_CD" , plantCd);
		}
		
		String plantCdOri = formData.get("PLANT_CD_ORI");
		String overwriteMode = formData.get("OVERWRITE_MODE");

		if (!overwriteMode.equals("1") && (!buyerCd.equals(buyerCdOri) || !plantCd.equals(plantCdOri))) {

			/* This parameter is use for sync of each database server. */
			formData.put("TABLE_NM", "STOCOGPL");
			//formData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

			if (bsyo_Mapper.checkPlantExists(formData) > 0) {
				bsyo_Mapper.updatePlant(formData);
			} else {
				bsyo_Mapper.insertPlant(formData);
			}

		} else {

			/* This parameter is use for sync of each database server. */
			formData.put("TABLE_NM", "STOCOGPL");
			bsyo_Mapper.updatePlant(formData);
		}
		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deletePlant(Map<String, String> formData) throws Exception {

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGPL");
		bsyo_Mapper.deletePlant(formData);

		return msg.getMessage("0017");
	}

	public List<Map<String, String>> doSearch(Map<String, String> param) throws Exception {
		List<Map<String, String>> datalist = bsyo_Mapper.doSearch(param);
		return datalist;
	}


	public List<Map<String, String>> doSearchDeptINFO(Map<String, String> param) throws Exception {
		List<Map<String, String>> datalist = bsyo_Mapper.doSearchDeptINFO(param);
		return datalist;
	}

	public String doSearchJson(Map<String, String> param) throws Exception {
		List<Map<String, String>> datalist = bsyo_Mapper.doSearch(param);

		StringBuffer retrunText = new StringBuffer();
		retrunText.append("[     \n");
		int cou = 0;
		for( Map<String,String> data1 : datalist ) {

			String temp_pid = data1.get("PARENT_DEPT_CD");
			if (temp_pid==null) temp_pid = "";


			if ( temp_pid.length() !=0          ) continue;

			if ( cou !=0   ) {
				retrunText.append(" , ");
			}
			cou++;

			retrunText.append("{ \"title\" : \"" + data1.get("TITLE") + "\"       ,  \"DEPT_CD\" : \""+data1.get("DEPT_CD")+"\"           \n");
			param.put("PARENT_DEPT_CD", data1.get("DEPT_CD"));
			List<Map<String, String>> datalist2 = bsyo_Mapper.doSearch2(param);

			for (int k=0;k<datalist2.size();k++) {
				Map<String, String> data2 = datalist2.get(k);
				if (k==0) {
					retrunText.append(", \"isFolder\": true, \"children\"  : [   \n");
				} else {
					retrunText.append(",  ");
				}

				retrunText.append("{ \"title\" : \"" + data2.get("TITLE") + "\" ,  \"DEPT_CD\" : \""+data2.get("DEPT_CD")+"\"   \n");
				param.put("PARENT_DEPT_CD", data2.get("DEPT_CD"));
				List<Map<String, String>> datalist3 = bsyo_Mapper.doSearch2(param);
				for (int g=0;g<datalist3.size();g++) {
					Map<String, String> data3 = datalist3.get(g);
					if (g==0) {
						retrunText.append(", \"isFolder\": true, \"children\"  : [   \n");
					} else {
						retrunText.append(",  ");
					}
					retrunText.append("{ \"title\" : \"" + data3.get("TITLE") + "\" ,  \"DEPT_CD\" : \""+data3.get("DEPT_CD")+"\"  \n");

					param.put("PARENT_DEPT_CD", data3.get("DEPT_CD"));
					List<Map<String, String>> datalist4 = bsyo_Mapper.doSearch2(param);
					for (int m=0;m<datalist4.size();m++) {
						Map<String, String> data4 = datalist4.get(m);
						if (m==0) {
							retrunText.append(" , \"isFolder\": true  , \"children\"  : [   \n");
						} else {
							retrunText.append(",  ");
						}
						retrunText.append("{ \"title\" : \"" + data4.get("TITLE") + "\"  ,  \"DEPT_CD\" : \""+data4.get("DEPT_CD")+"\"  }\n");
						if (m==datalist4.size()-1) {
							retrunText.append("] \n");
						}
					}

					retrunText.append("} \n");
					if (g==datalist3.size()-1) {
						retrunText.append("] \n");
					}
				}

				retrunText.append("} \n");

				if (k==datalist2.size()-1) {
					retrunText.append("] \n");
				}
			}
			retrunText.append("} \n");
		}

		retrunText.append("]     \n");
		return retrunText.toString();
	}

	public Map<String, String> getDeptInfo(Map<String, String> param) throws Exception {
		Map<String, String> saveParam = new HashMap<String, String>();
		saveParam.putAll(param);

		Map<String, String> result = bsyo_Mapper.getInfo_Dept(param);
		if (result == null) {
			result = new HashMap<String, String>();
		}
		Iterator iterator = saveParam.keySet().iterator();
		while (iterator.hasNext()) {
			String key = (String)iterator.next();
			if (!result.containsKey(key)) {
				result.put(key, "");
			}
		}

		return result;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSave(Map<String, String> formData) throws Exception {
		int chk = bsyo_Mapper.checkExists_Dept(formData);
		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGDP");
		if (chk > 0) {
			bsyo_Mapper.doUpdate_Dept(formData);
		} else {
			bsyo_Mapper.doInsert_Dept(formData);
		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDelete(Map<String, String> formData) throws Exception {
		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGDP");
		bsyo_Mapper.doDelete_Dept(formData);

		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> selectDeptParent(Map<String, String> param) throws Exception {
		return bsyo_Mapper.selectDeptParent(param);
	}

	public List<Map<String, Object>> selectWareHouse(Map<String, String> param) throws Exception {
		return bsyo_Mapper.selectWareHouse(param);
	}

	public List<Map<String, Object>> selectWareHouseDetail(Map<String, String> param) throws Exception {
		return bsyo_Mapper.selectWareHouseDetail(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveWareHouse(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

		int check = bsyo_Mapper.checkWareHouseExists(formData);

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGWM");
		if (check > 0) {
			bsyo_Mapper.updateWareHouse(formData);
		} else {
			bsyo_Mapper.insertWareHouse(formData);
		}

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGSL");
		Map<String, Object> castData = (Map) formData;
		bsyo_Mapper.deleteDetailByMaster(castData);

		for (Map<String, Object> gridData : gridDatas) {

			if (!"D".equals(gridData.get("INSERT_FLAG"))) {

				gridData.put("BUYER_CD", formData.get("BUYER_CD"));
				gridData.put("PLANT_CD", formData.get("PLANT_CD"));
				gridData.put("WH_CD", formData.get("WH_CD"));

				/* This parameter is use for sync of each database server. */
				gridData.put("TABLE_NM", "STOCOGSL");
				//formData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

				int chkKey = bsyo_Mapper.existsWareHouseDetailKey(gridData);

				if (chkKey > 0) {
					bsyo_Mapper.updateDetailByMaster(gridData);
				} else {
					bsyo_Mapper.insertDetailByMaster(gridData);
				}
			}
		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteWareHouse(Map<String, String> formData) throws Exception {

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGSL");
		Map<String, Object> castData = (Map) formData;
		bsyo_Mapper.deleteDetailByMaster(castData);

		/* This parameter is use for sync of each database server. */
		formData.put("TABLE_NM", "STOCOGWM");
		bsyo_Mapper.deleteWareHouse(formData);

		return msg.getMessage("0017");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteDetailByMaster(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCOGSL");
			//formData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

			bsyo_Mapper.deleteDetailByMaster(gridData);
		}

		return msg.getMessage("0017");
	}

//	private void buildPdf_page(Document document, Map<String, Object> houseInfo) {
//
//		// Set default page size (A4)!
//		document.setPageSize(PageFormat.getSize());
//
//		/* Case Add page! */
//		// Page page = new Page(document);
//		// document.getPages().add(page);
//
//		/* Case Using current form */
//		Page page = document.getPages().get(0);
//
//		Dimension2D pageSize = page.getSize();
//
//		PrimitiveComposer composer = new PrimitiveComposer(page);
//		//StandardType1Font titleFont = new StandardType1Font(document, StandardType1Font.FamilyEnum.Times, true, false);
//		//StandardType1Font bodyFont = new StandardType1Font(document, StandardType1Font.FamilyEnum.Helvetica, false, false);
//
//		Font customFont = Font.get(document, "D:/ST-OnesIDE/workspace/WisePro/adobeResources" + java.io.File.separator + "MyungjoStd.otf");
//
//		BlockComposer blockComposer = new BlockComposer(composer);
//		blockComposer.setHyphenation(true);
//
//		int oriX = 160, oriY = 174;
//		int gapX = 245, gapY = 22;
//		Rectangle2D.Double frame = new Rectangle2D.Double(oriX, oriY, pageSize.getWidth() - 110, pageSize.getHeight() - 150);
//
//		composer.setFont(customFont, 14);
//		blockComposer.begin(frame, AlignmentXEnum.Left, AlignmentYEnum.Top);
//		blockComposer.showText(houseInfo.get("GATE_CD").toString());
//		blockComposer.end();
//
//		frame.x = oriX;
//		frame.y = oriY + 1 * gapY;
//		blockComposer.begin(frame, AlignmentXEnum.Left, AlignmentYEnum.Top);
//		blockComposer.showText(houseInfo.get("HOUSE_NAME").toString());
//		blockComposer.end();
//
//		frame.x = oriX + gapX;
//		frame.y = oriY + 1 * gapY;
//		blockComposer.begin(frame, AlignmentXEnum.Left, AlignmentYEnum.Top);
//		blockComposer.showText(houseInfo.get("HOUSE_NAME_ENG").toString());
//		blockComposer.end();
//
//		frame.x = oriX;
//		frame.y = oriY + 2 * gapY;
//		blockComposer.begin(frame, AlignmentXEnum.Left, AlignmentYEnum.Top);
//		blockComposer.showText(houseInfo.get("GMT_CD").toString());
//		blockComposer.end();
//
//		frame.x = oriX;
//		frame.y = oriY + 3 * gapY;
//		blockComposer.begin(frame, AlignmentXEnum.Left, AlignmentYEnum.Top);
//		blockComposer.showText(houseInfo.get("REG_USER_NAME").toString());
//		blockComposer.end();
//
//		frame.x = oriX + gapX;
//		frame.y = oriY + 3 * gapY;
//		blockComposer.begin(frame, AlignmentXEnum.Left, AlignmentYEnum.Top);
//		blockComposer.showText(houseInfo.get("REG_DATE").toString());
//		blockComposer.end();
//
//		composer.flush();
//	}
//
//	private void buildPdf_metadata(Document document) {
//		// Document metadata.
//		Information info = new Information(document);
//		document.setInformation(info);
//		info.setAuthor("Stefano Chizzolini");
//		info.setCreationDate(new Date());
//		//info.setCreator(HelloWorld.class.getName());
//		info.setTitle("Sample document");
//		info.setSubject("Online PDF creation sample through servlet.");
//	}
}