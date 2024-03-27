package com.st_ones.common.util;

import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import net.htmlparser.jericho.*;
import org.apache.commons.lang3.StringUtils;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.UnsupportedEncodingException;
import java.text.*;
import java.util.*;
import java.util.regex.Pattern;

public class ContStringUtil {

	private static Logger logger = LoggerFactory.getLogger(ContStringUtil.class);

	/**
	 * Convert number to positional number.
	 * @param number
	 * @return
	 */
	public static String toPositionalNumber(String number) {
		String positionalNumber = "";
		NumberFormat nf = NumberFormat.getNumberInstance();
		positionalNumber = Pattern.compile("[^0-9.]").matcher(number).replaceAll("");
		try {
			if (EverString.isNotEmpty(number)) {
				nf.setMaximumFractionDigits(10);
				positionalNumber = nf.format(Double.parseDouble(number));
			}
		} catch (Exception e) {
			positionalNumber = number;
		}
		return positionalNumber;
	}

	public static String toDecimalNumber(String number) {
		String positionalNumber = "";
		DecimalFormat df = new DecimalFormat("##,###,###,##0.##");
		positionalNumber = Pattern.compile("[^0-9.]").matcher(number).replaceAll("");
		try {
			if (EverString.isNotEmpty(number)) {
				df.setMaximumFractionDigits(10);
				positionalNumber = df.format(Double.parseDouble(number));
			}
		} catch (Exception e) {
			positionalNumber = number;
		}
		return positionalNumber;
	}

	/**
	 * Get locale formatted date in order to convert the contract contents.
	 * @param source
	 * @param dateFormat
	 * @return
	 * @throws ParseException
	 */
	public static String getLocaleDate(String source, String dateFormat, String languageCd) {

		String resultDate = "";
		DateFormat df = null;

		String defaultLangCd = PropertiesManager.getString("eversrm.langCd.default", "KR");
		SimpleDateFormat sdf = new SimpleDateFormat(dateFormat.replaceAll("/", ""), Locale.getDefault());

		try {
			Date d = sdf.parse(source.replaceAll("/", ""));
			if (EverString.isNotEmpty(languageCd)) {
				if (languageCd.equalsIgnoreCase("KR") || languageCd.equalsIgnoreCase("KO")) {
				    SimpleDateFormat tobePattern = new SimpleDateFormat("yyyy년 M월 d일");
					resultDate = tobePattern.format(d);
				} else {
					df = DateFormat.getDateInstance(DateFormat.FULL, Locale.ENGLISH);
					resultDate = df.format(d);
				}
			} else {
				if (defaultLangCd.equalsIgnoreCase("KR") || defaultLangCd.equalsIgnoreCase("KO")) {
                    SimpleDateFormat tobePattern = new SimpleDateFormat("yyyy년 M월 d일");
					resultDate = tobePattern.format(d);
				} else {
					df = DateFormat.getDateInstance(DateFormat.FULL, Locale.ENGLISH);
					resultDate = df.format(d);
				}
			}
		} catch (ParseException e) {
			e.printStackTrace();
		}

		return resultDate;
	}

	/**
	 * Convert number to Korean number.
	 * @param number
	 * @return
	 */
	public static String numberToKorean(String number) {

		String result = Pattern.compile("[^0          -9.]").matcher(number).replaceAll("");

		if (EverString.isNotEmpty(number)) {

			String[] han1 = {"일", "이", "삼", "사", "오", "육", "칠", "팔", "구"};
			String[] han2 = {"천", "백", "십", "조", "천", "백", "십", "억", "천", "백", "십", "만", "천", "백", "십", ""};

			String chr16 = "";
			String tmp16 = "";
			boolean chk1 = false;

			tmp16 = number;
			int cnt16 = tmp16.length();
			for (int j = 1; j <= (16 - cnt16); j++)
				chr16 = chr16 + "0";
			for (int k = 1; k <= cnt16; k++) {
				chr16 = chr16 + tmp16.substring(k - 1, k);
			}
			result = "";
			chk1 = false;

			for (int i = 1; i <= 16; i++) {
				if (!chr16.substring(i - 1, i).equals("0")) {
					if (!chr16.substring(i - 1, i).equals("-")) {
						result = result + han1[Integer.parseInt(chr16.substring(i - 1, i)) - 1] + han2[i - 1];
                        chk1 = i % 4 != 0;
					} else {
						result = "△";
					}
				} else {
					if (chk1 && ((i % 4) == 0)) {
						result = result + han2[i - 1];
						chk1 = false;
					}
				}
			}
		}
		return result;
	}

	/**
	 * Make up the form values for locale.
	 * @param formControl
	 * @return
	 * @throws UserInfoNotFoundException
	 * @throws ParseException
	 */
	public static FormControl makeupFormValue(FormControl formControl) {

		String name = formControl.getName();
		String value = StringUtils.defaultIfEmpty(formControl.getAttributesMap().get("value"), "");
		String type = formControl.getAttributesMap().get("type");

		if (PropertiesManager.getBoolean("eversrm.system.database.encoding.useFlag")) {
			String dbValue = PropertiesManager.getString("eversrm.system.database.encoding.db.value");
			String appValue = PropertiesManager.getString("eversrm.system.database.encoding.app.value");
			try {
				value = new String(EverString.nullToEmptyString(value).getBytes(dbValue), appValue);
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}

		String[] numberTypeFormNames = {"SUPPLY_AMT","VAT_AMT","CONT_AMT", "ADV_GUAR_AMT", "ADV_GUAR_PERCENT", "CONT_GUAR_AMT", "CONT_GUAR_PERCENT", "WARR_GUAR_AMT", "WARR_GUAR_PERCENT", "WARR_GUAR_QTY", "CONT_LAST_DAYS"};
		String[] dateTypeFormNames = {"CONT_DATE", "CONT_START_DATE", "CONT_END_DATE"};
		String[] numberToKoreanNames = {"CONT_AMT_KR", "CONT_AMT_KR_VAT", "SUPPLY_AMT_KR", "VAT_AMT_KR"};

		// if form name matches number type, convert the value to positional number.
		for (String numberTypeName : numberTypeFormNames) {
			if (name.equals(numberTypeName)) {
				value = ContStringUtil.toPositionalNumber(value);
			}
		}

		for (String dateTypeName : dateTypeFormNames) {
			if (name.equals(dateTypeName)) {
				if(StringUtils.isNotEmpty(value)) {
					value = ContStringUtil.getLocaleDate(value, "yyyyMMdd", UserInfoManager.getUserInfo().getLangCd());
				}
			}
		}

		for (String toKoreanName : numberToKoreanNames) {
			if (name.equals(toKoreanName)) {
				if(StringUtils.isNotEmpty(value)) {
					value = ContStringUtil.numberToKorean(value);
				}
			}
		}

		formControl.setValue(value);

		return formControl;
	}

	/**
	 * Return HTML string whether escaped or not.
	 * @param beforeContents target string.
	 * @param isReadOnly HTML tags will be escaped if this parameter is true.
	 * @return
	 */
	public static String getHtmlContents(String beforeContents, boolean isReadOnly) {

		beforeContents = StringUtils.defaultIfEmpty(beforeContents, "");

		Source source = new Source(beforeContents);
		OutputDocument outputDocument = new OutputDocument(source);

		FormControlOutputStyle.ConfigDisplayValue.ElementName = "span";

		List<FormControl> formControls = source.getFormControls();
		for (FormControl formControl : formControls) {
			if (isReadOnly) {

				if(formControl.getFormControlType() == FormControlType.RADIO) {
					FormControlOutputStyle.ConfigDisplayValue.CheckedHTML = "▣";
					FormControlOutputStyle.ConfigDisplayValue.UncheckedHTML = "□";
				}

				formControl.setOutputStyle(FormControlOutputStyle.DISPLAY_VALUE);
				//formControl.getAttributesMap().remove("style");
				formControl.getAttributesMap().remove("onclick");

			} else {
				formControl.setOutputStyle(FormControlOutputStyle.NORMAL);
			}
			outputDocument.replace(formControl);
		}

		List<StartTag> allStartTags = source.getAllStartTags();
		for (StartTag allStartTag : allStartTags) {

			Attributes attributes = allStartTag.getAttributes();
			if(StringUtils.isNotEmpty(attributes.get("contenteditable"))) {
				Attribute contenteditableAttr = attributes.get("contenteditable");
				Attribute classAttr = attributes.get("class");
				outputDocument.remove(contenteditableAttr);
				if(classAttr != null) {
					outputDocument.remove(classAttr);
				}
			}
		}

		return outputDocument.toString();
	}

	/**
	 * 계약번호 등 사용자가 변경불가능한 부분은 수정을 하더라도 강제로 치환
	 * @param mainContractContents
	 * @return
	 */
	public static String replaceUserNotEditableForms(String mainContractContents, Map<String, String> formData) {

		Source source = new Source(mainContractContents.replaceAll("&lt;", "<").replaceAll("&gt;", ">"));
		OutputDocument outputDocument = new OutputDocument(source);

		boolean changeDQ = false;
		List<FormControl> formControls = source.getFormControls();
		for (FormControl formControl : formControls) {

			String name = formControl.getName();
			if(name.equals("CONT_NUM")) {
				if (EverString.isNotEmpty(name)) {
					if (formData.containsKey(name)) {
  						formControl.setValue(EverString.defaultIfEmpty(String.valueOf(formData.get(name)), ""));
						outputDocument.replace(formControl);
					}
				}
			} else if(name.equals("CONT_DATE")) {
				if (EverString.isNotEmpty(name)) {
					if (formData.containsKey(name)) {
						String dateValue = ContStringUtil.getLocaleDate(String.valueOf(formData.get(name)), "yyyyMMdd", UserInfoManager.getUserInfo().getLangCd());
						dateValue = EverString.defaultIfEmpty(dateValue, "");
  						formControl.setValue(dateValue);
						outputDocument.replace(formControl);
					}
				}
			} else if(name.equals("changeTxt_TEXTAREA")) {
				changeDQ = true;
			}
		}

		String rtnStr = outputDocument.toString();
		if(changeDQ) {
			int idxT = rtnStr.indexOf("<textarea");
			int idxV = rtnStr.indexOf("value=");
			if((idxT > -1 && idxV > -1) && (idxV > idxT)) {
				String tmpStr = rtnStr.substring(idxV, rtnStr.length());
				int idxE = tmpStr.indexOf("\">");
				tmpStr = tmpStr.substring(0, idxE + 1);
				rtnStr = rtnStr.replace(tmpStr, "");
			}
		}
		return rtnStr;
	}

	/**
	 * 계약번호 등 사용자가 변경불가능한 부분은 수정을 하더라도 강제로 치환
	 * @param mainContractContents
	 * @return
	 */
	public static String replaceTextareaValue(String mainContractContents) {

		Source source = new Source(mainContractContents.replaceAll("&lt;", "<").replaceAll("&gt;", ">"));
		OutputDocument outputDocument = new OutputDocument(source);

		boolean changeDQ = false;
		List<FormControl> formControls = source.getFormControls();
		for (FormControl formControl : formControls) {
			String name = formControl.getName();
			if(name.equals("changeTxt_TEXTAREA")) {
				changeDQ = true;
			}
		}

		String rtnStr = outputDocument.toString();
		if(changeDQ) {
			int idxT = rtnStr.indexOf("<textarea");
			int idxV = rtnStr.indexOf("value=");
			if((idxT > -1 && idxV > -1) && (idxV > idxT)) {
				String tmpStr = rtnStr.substring(idxV, rtnStr.length());
				int idxE = tmpStr.indexOf("\">");
				tmpStr = tmpStr.substring(0, idxE + 1);
				rtnStr = rtnStr.replace(tmpStr, "");
			}
		}
		return rtnStr;
	}

	@Test
	public void doTestHtmlReplace() {

		String html = "<p><input type=\"radio\" name=\"c1\" value=\"1\" checked=\"checked\"> 동의 <input type=\"radio\" name=\"c1\" value=\"1\"> 비동의 <input type=\"text\" value=\"AAA\"></p>";
		Source source = new Source(html);
		OutputDocument od = new OutputDocument(source);

		FormFields formFields = source.getFormFields();
		for (FormField formField : formFields) {
			logger.info("{}", formField.getName());
			Collection<FormControl> formControls = formField.getFormControls();
			for (FormControl formControl : formControls) {
				logger.info("--> {}", formControl.getName());
				formControl.setOutputStyle(FormControlOutputStyle.DISPLAY_VALUE);
				od.replace(formControl);
			}
			od.replace(formFields);
		}

		FormControlOutputStyle.ConfigDisplayValue.CheckedHTML = "▣";
		FormControlOutputStyle.ConfigDisplayValue.UncheckedHTML = "□";

		List<FormControl> formControls = source.getFormControls();
		for (FormControl formControl : formControls) {

			formControl.setOutputStyle(FormControlOutputStyle.DISPLAY_VALUE);
			od.replace(formControl);
		}

		logger.info("{}", od.toString());
	}

    public static String initString(String str, String findstr, String endstr, String replaceStr) {

		if(str == null) return str;

        StringBuffer sb = new StringBuffer(str);
        int k = str.indexOf(findstr);
        if (k==-1) return str;

        int g = (str.indexOf(endstr,k));
        int m = (str.indexOf("&gt;",k));

        str = sb.delete(k+(m-k+4), g).toString();
        return str.replaceAll(findstr+endstr, findstr+replaceStr+endstr);
    }

    public static String initStringTag(String str, String findstr, String endstr, String replaceStr) {

		if(str == null) return str;

        StringBuffer sb = new StringBuffer(str);
        int k = str.indexOf(findstr);
        if (k==-1) return str;

        int g = (str.indexOf(endstr,k));
        int m = (str.indexOf(">",k));

        str = sb.delete(k+(m-k+1), g).toString();
        return str.replaceAll(findstr+endstr, findstr+replaceStr+endstr);
    }

}