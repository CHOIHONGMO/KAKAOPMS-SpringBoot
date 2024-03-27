package com.st_ones.common.generator.domain;

import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.domain.BaseDomain;

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
 * @File Name : GridMeta.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

public class GridMeta extends BaseDomain {

	private static final long serialVersionUID = 3360099543681721656L;

	private String columnId;
	private String columnType;
	private String commonId;
	private String text;
	private String width;
	private String maxLength;
	private String editable;
	private String align;
	private String fontColor;
	private String backgroundColor;
	private String essential;
	private String dataType;
	private String langCd;
	private String imageName;
	private String multiType;
	private String dataFormat;
	private String textWrap;
	private boolean dynamicColumn;
	private boolean frozeFlag;
	private boolean ftColumn;
	private String maskType;
	private boolean visible;
	private String decimalYn;

	public String getTextWrap() { return textWrap; }

	public void setTextWrap(String textWrap) { this.textWrap = textWrap; }

	public boolean isFtColumn() {
		return ftColumn;
	}

	public void setFtColumn(boolean _ftColumn) {
		this.ftColumn = _ftColumn;
	}

	private List<Map<String, String>> combos;

	public GridMeta() { }

	public GridMeta(GridMeta gridMeta) {
		this.columnId = cloneString(gridMeta.getColumnId());
		this.columnType = cloneString(gridMeta.getColumnType());
		this.commonId = cloneString(gridMeta.getCommonId());
		this.text = cloneString(gridMeta.getText());
		this.width = cloneString(gridMeta.getWidth());
		this.maxLength = cloneString(gridMeta.getMaxLength());
		this.editable = cloneString(gridMeta.getEditable());
		this.align = cloneString(gridMeta.getAlign());
		this.fontColor = cloneString(gridMeta.getFontColor());
		this.backgroundColor = cloneString(gridMeta.getBackgroundColor());
		this.essential = cloneString(gridMeta.getEssential());
		this.dataType = cloneString(gridMeta.getDataType());
		this.langCd = cloneString(gridMeta.getLangCd());
		this.imageName = cloneString(gridMeta.getImageName());
		this.multiType = cloneString(gridMeta.getMultiType());
		this.dataFormat = cloneString(gridMeta.getDataFormat());
		this.dynamicColumn = gridMeta.isDynamicColumn();
		this.frozeFlag = gridMeta.isFrozeFlag();
		this.combos = gridMeta.getCombos();
		this.textWrap = gridMeta.getTextWrap();
		this.maskType = gridMeta.getMaskType();
		this.visible = gridMeta.isVisible();
		this.decimalYn = gridMeta.isDecimalYn();
	}

	private String cloneString(String str){
		if(str == null)
			return null;
		return str;
	}

	public String getColumnId() {
		return columnId;
	}

	public void setColumnId(String _columnId) {
		this.columnId = _columnId;
	}

	public String getColumnType() {
		return columnType;
	}

	public void setColumnType(String _columnType) {
		this.columnType = _columnType;
	}

	public String getCommonId() {
		return commonId;
	}

	public void setCommonId(String _commonId) {
		this.commonId = _commonId;
	}

	public String getText() {
		return text;
	}

	public void setText(String _text) {
		this.text = _text;
	}


	/**
	 * ft unit의 width 인경우 입력된 문자열에 대한 넓이 반영을 수행 하지 않습니다.
	 * @return
	 */
	public String getWidth() {

		return width;
//		if(isFtColumn()) return width;
//		if(width == null) return "0";
//		if(Integer.valueOf(width) > 0 && Integer.valueOf(width) < 10) {setFtColumn(true); return width;}
//
//		String str = EverString.nullToEmptyString(this.text);
//		if(EverString.isEmpty(width))
//			width = "0";
//		width = String.valueOf(Math.round(Double.parseDouble(width)));
//		int colWidthLen = Integer.parseInt(width);
//		int contentsLen = text.length();
//		double temLen = 0;
//		int tmpWidth = 0;
//		double len2Bytes = 10;
//		double len1BytesU = contentsLen < 5 ? 15 : (contentsLen < 10 ? 12 : (contentsLen < 15 ? 9 : (contentsLen < 20 ? 9 : 5)));
//		double len1BytesL = contentsLen < 5 ? 13 : (contentsLen < 10 ? 10 : (contentsLen < 15 ? 8 : (contentsLen < 20 ? 8 : 4)));
//
//		if (!EverString.isEmpty(width)) {
//			if (!width.equals("0")) {
//				if ((this.columnId).equals("SELECTED")) {
//					tmpWidth = 40;
//				} else {
//					// Grid Column Text 중 한글이 있는 경우 12씩 증가, 다른 문자는 대분자는 8, 소문자는 5씩 증가.
//					for (int i = 0; i < str.length(); i++) {
//						char character = str.charAt(i);
//						if (Character.getType(character) == 5) {
//							temLen = temLen + len2Bytes;
//						} else {
//							boolean isUp = isUpperCase(character);
//							if (isUp) {
//								temLen = temLen + len1BytesU;
//								//								len1Bytes = len1BytesU;
//							} else {
//								temLen = temLen + len1BytesL;
//								//								len1Bytes = len1BytesL;
//							}
//						}
//					}
//					//tmpWidth = (int)((contentsLen * (langCd.equals("KO") ? len2Bytes : len1Bytes)) < colWidthLen ? colWidthLen : ((contentsLen * (langCd.equals("KO") ? len2Bytes : len1Bytes)) - colWidthLen) + temLen);
//					tmpWidth = colWidthLen > Integer.parseInt(String.valueOf(Math.round(temLen))) ? colWidthLen : Integer.parseInt(String.valueOf(Math.round(temLen)));
//				}
//			}
//		}
//
//		return String.valueOf(tmpWidth);
	}

	public boolean isUpperCase(char ch) {
		String string = String.valueOf(ch);
		String ret = string.replaceAll("[A-Z]", "true");
        return ret.equalsIgnoreCase("true");
    }

	public void setWidth(String _width) {
		this.width = _width;
	}

	public String getMaxLength() {
		return EverString.isEmpty(maxLength) ? "0" : maxLength;
	}

	public void setMaxLength(String maxlength) {
		this.maxLength = maxlength;
	}

	public String getEditable() {
		return editable;
	}

	public void setEditable(String _editable) {
		this.editable = _editable;
	}

	public String getAlign() {
		return align;
	}

	public void setAlign(String _align) {
		this.align = _align;
	}

	public String getFontColor() {
		return fontColor;
	}

	public void setFontColor(String _fontColor) {
		this.fontColor = _fontColor;
	}

	public String getBackgroundColor() {
		return backgroundColor;
	}

	public void setBackgroundColor(String _backgroundColor) {
		this.backgroundColor = _backgroundColor;
	}

	public String getEssential() {
		return essential;
	}

	public void setEssential(String _essential) {
		this.essential = _essential;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String _dataType) {
		this.dataType = _dataType;
	}

	public String getLangCd() {
		return langCd;
	}

	public void setLangCode(String _langCd) {
		this.langCd = _langCd;
	}

	public String getImageName() {
		return imageName;
	}

	public void setImageName(String _imageName) {
		this.imageName = _imageName;
	}

	public String getMultiType() {
		return multiType;
	}

	public void setMultiType(String _multiType) {
		this.multiType = _multiType;
	}

	public List<Map<String, String>> getCombos() {
		return combos;
	}

	public void setCombos(List<Map<String, String>> _combos) throws Exception {
		this.combos = _combos;
	}

	public String getDataFormat() {
		return dataFormat;
	}

	public void setDataFormat(String _dataFormat) {
		this.dataFormat = _dataFormat;
	}

	public boolean isDynamicColumn() {
		return dynamicColumn;
	}

	public void setDynamicColumn(boolean _dynamicColumn) {
		this.dynamicColumn = _dynamicColumn;
	}

	public boolean isFrozeFlag() {  return frozeFlag;  }

	public void setFrozeFlag(boolean frozeFlag) {  this.frozeFlag = frozeFlag;  }

	public String getMaskType() {
		return maskType;
	}

	public void setMaskType(String maskingType) {
		this.maskType = maskingType;
	}

	public boolean isVisible() {
		return visible;
	}

	public void setVisible(boolean visible) {
		this.visible = visible;
	}

	public String isDecimalYn() { return decimalYn; }

	public void setDecimalYn(String decimalYn) { this.decimalYn = decimalYn; }
}