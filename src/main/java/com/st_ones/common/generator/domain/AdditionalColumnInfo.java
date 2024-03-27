package com.st_ones.common.generator.domain;

import java.io.Serializable;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : AdditionalColumnInfo.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

public class AdditionalColumnInfo implements Serializable{

	private static final long serialVersionUID = 6084444863456898023L;
	private String templateId;
	private String columnId;
	private String text;
	private String userData;

	public AdditionalColumnInfo() {
	}
	
	public AdditionalColumnInfo(String _templateId, String _columnId, String _text) {
		super();
		this.templateId = _templateId;
		this.columnId = _columnId;
		this.text = _text;
	}

	public String getUserData() {
		return userData;
	}

	public void setUserData(String _userData) {
		this.userData = _userData;
	}

	public String getTemplateId() {
		return templateId;
	}

	public void setTemplateId(String _templateId) {
		this.templateId = _templateId;
	}

	public String getColumnId() {
		return columnId;
	}

	public void setColumnId(String _columnId) {
		this.columnId = _columnId;
	}

	public String getText() {
		return text;
	}

	public void setText(String _text) {
		this.text = _text;
	}

	@Override
	public String toString() {
		return "AdditionalColumnInfo [templateId=" + templateId + ", columnId=" + columnId + ", text=" + text + ", userData=" + userData + "]";
	}
}