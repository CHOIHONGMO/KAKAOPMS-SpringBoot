package com.st_ones.common.docNum.service;

import com.st_ones.common.docNum.DocNumMapper;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.domain.BaseMap;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.text.DecimalFormat;
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
 * @File Name : DocNumService.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Service(value = "docNumService")
public class DocNumService extends BaseService {

//	private static final String EVER_DBLINK = "everF.remote.database.link.name";

//	@Autowired private EverConfigService everConfigService;

	@Autowired private DocNumMapper docNumMapper;
    protected Logger logger = LoggerFactory.getLogger(getClass());

	@Autowired private MessageService msg;

	@Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
	public String getDocNumber(String docType) throws Exception {

		if (EverString.nullToEmptyString(docType).equals("")) {
			throw new NoResultException(msg.getMessageForService(this, "002"));
		}
		return this.getDocNumberRemote(null, docType);
	}

	@Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
	public String getDocNumber(String companyCd, String docType) throws Exception {

		if (EverString.nullToEmptyString(docType).equals("")) {
			throw new NoResultException(msg.getMessageForService(this, "002"));
		}
		return this.getDocNumberRemote(companyCd, docType);
	}

	public String getDocNumberRemote(String companyCd, String docType) throws Exception {

		synchronized (this) {


			logger.error("getDocNumberRemote============================================docType="+docType, docType);
			System.err.println("getDocNumberRemote============================================docType="+docType);
			if( EverString.nullToEmptyString(companyCd).equals("") ) {
				companyCd = PropertiesManager.getString("eversrm.default.company.code");
			}

			if ("TN".equals(docType)) { // 대용량 채번시 아래와같이
	    		Long datetime = System.currentTimeMillis();
	            //Timestamp timestamp = new Timestamp(datetime);
	            double dValue = Math.random();
	            int iValue = (int)(dValue * 10000);
	            String uKey = iValue+"-"+datetime;
	            return uKey;
			}



			Map<String, String> param = new HashMap<String, String>();
			param.put("companyCd", companyCd);
			param.put("docType", docType);

			// 채번테이블의 현재까지 채번된 번호를 가져온다.
			Map<String, String> result = this.getDocNum(param);
			if (result == null) {
				throw new NoResultException(msg.getMessage("0080") + docType);
			}

			double startNo = Double.parseDouble(result.get("START_NUM"));
			double endNo = Double.parseDouble(result.get("END_NUM2"));
			int endNoLength = result.get("END_NUM2").length();
			String currentNo = result.get("CURRENT_NUM");
			String prefixString = EverString.nullToEmptyString(result.get("PREFIX_STRING"));
			String currentValue = EverString.nullToEmptyString(result.get("CURRENT_VAL"));
			String yearFlag = EverString.nullToEmptyString(result.get("YEAR_FLAG"));
			String yearType = EverString.nullToEmptyString(result.get("YEAR_TYPE"));
			String monthFlag = EverString.nullToEmptyString(result.get("MONTH_FLAG"));
			String dayFlag = EverString.nullToEmptyString(result.get("DAY_FLAG"));
			if (currentNo == null) {
				currentNo = currentValue;
			}
			String currentVal = currentNo.substring(currentNo.length() - endNoLength, currentNo.length());
			double currentValLength = Double.parseDouble(currentVal);
			String returnCurrentVal = "";
			String newCurrentNo = "";
			String newCurrentVal = "";

			if (currentValLength + 1.0D > endNo) {
				throw new NoResultException(msg.getMessage("0087") + docType);
			}

			for (int j = 0; j < endNoLength; j++) {
				returnCurrentVal = returnCurrentVal + "0";
			}

			DecimalFormat decimalformat = new DecimalFormat(returnCurrentVal);
			newCurrentNo = prefixString;
			if (yearFlag.equals("1")) {
				if (yearType.equals("4")) {
					newCurrentNo = newCurrentNo + EverDate.getYear();
				} else {
					newCurrentNo = newCurrentNo + EverDate.getYear().substring(2, 4);
				}
			}

			if (monthFlag.equals("1")) {
				newCurrentNo = newCurrentNo + EverDate.getMonth();
			}

			if (dayFlag.equals("1")) {
				newCurrentNo = newCurrentNo + EverDate.getDay();
			}

			if (currentNo.indexOf(newCurrentNo) == -1) {
				newCurrentNo = newCurrentNo + decimalformat.format(startNo);
				newCurrentVal = decimalformat.format(startNo);
			} else {
				newCurrentNo = newCurrentNo + decimalformat.format(currentValLength + 1.0D);
				newCurrentVal = decimalformat.format(currentValLength + 1.0D);
			}

			// 새로 채번된 번호를 채번테이블에 Update한다.
			param.put("currentNo", newCurrentNo);
			param.put("currentVal", newCurrentVal);

			int rtn = this.et_setDocNumber(param);
			if (rtn < 1) {
				throw new NoResultException("Error occur duing document generation. Failed Processing");
			}
			return newCurrentNo;
		}
	}

	private Map<String, String> getDocNum(Map<String, String> param) throws Exception {
		return docNumMapper.getDocNum(param);
	}

	private int et_setDocNumber(Map<String, String> param) throws Exception {
		return docNumMapper.setDocNum(param);
	}

	public List<BaseMap> getDocNumbers(Map<String, String> param) throws Exception {
		return null;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] doDelete(List<Map<String, Object>> transDatas) throws Exception {

		String[] args = new String[2];

		try {
			args[0] = "";
			args[1] = "0000";
		} catch (Exception e) {
			getLog().error(e.getMessage(), e);
			args[0] = e.getMessage();
			args[1] = "0001";
		}
		return args;
	}
}