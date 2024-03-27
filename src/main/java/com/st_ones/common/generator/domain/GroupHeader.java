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
 * @File Name : GroupHeader.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

public class GroupHeader implements Serializable {

	private static final long serialVersionUID = 5115796520440071416L;
	private String text;
	private String id;
	private String childColumns;
	private String userData;

	public GroupHeader(){
		
	}
	
	public GroupHeader(String _id, String _text) {
		this.text = _text;
		this.id = _id;
	}

	public String getText() {
		return text;
	}

	public void setText(String _text) {
		this.text = _text;
	}

	public String getId() {
		return id;
	}

	public void setId(String _id) {
		this.id = _id;
	}
	
	public void setChildColumns(String _childColumns) {
		this.childColumns = _childColumns;
	}

	public String getChildColumns(){
		return childColumns;
	}

	public void addChildColumn(String childColumn) {
		if(childColumns == null){
			childColumns = childColumn;
		} else {
			childColumns += "," + childColumn;
		}
	}

	public String getUserData() {
		return userData;
	}

	public void setUserData(String _userData) {
		this.userData = _userData;
	}

	@Override
	public String toString() {
		return "GroupHeader [text=" + text + ", id=" + id + ", childColumns=" + childColumns + ", userData=" + userData + "]";
	}
}