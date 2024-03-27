package com.st_ones.common.page;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 10 오전 9:51
 */

import java.io.Serializable;

public class PageNaviBean implements Serializable {

	private static final long serialVersionUID = 1L;

	private int startNo = 0;

	private int endNo = 0;

	//	private String sortStr = "RegDate DESC";
	private String sortStr = "1";

	/** 한페이지당 표시되는 아이템의 수 */
	private int listScale = 10;

	/** 현재페이지 */
	private Integer pageNo = 1;

	/** 총아이템수 */
	private int totalCount = 0;
	/** 리턴 URL*/
	private String pageUrl;

	private String langCd;
	private String basicFl;
	private String isPaging = "N";

	public void setPagingValue(int pageNo, int listScale) {
		if(pageNo == 0) {
			pageNo = 1;
		}

		startNo = (pageNo * listScale) - (listScale - 1);
		endNo = startNo + (listScale - 1);
	}

	public int getStartNo() {
		return startNo;
	}

	public void setStartNo(int startNo) {
		this.startNo = startNo;
	}

	public int getEndNo() {
		return endNo;
	}

	public void setEndNo(int endNo) {
		this.endNo = endNo;
	}

	public String getSortStr() {
		return sortStr;
	}

	public void setSortStr(String sortStr) {
		this.sortStr = sortStr;
	}

	/**
	 * @return pageNo
	 */
	public Integer getPageNo() {
		return pageNo;
	}

	/**
	 * @param pageNo 설정하려는 pageNo
	 */
	public void setPageNo(Integer pageNo) {
		if(pageNo == null) pageNo = 1;
		this.pageNo = pageNo;
	}

	/**
	 * @return listScale
	 */
	public int getListScale() {
		return listScale;
	}

	/**
	 * @param listScale 설정하려는 listScale
	 */
	public void setListScale(int listScale) {
		this.listScale = listScale;
	}

	/**
	 * @return totalCount
	 */
	public int getTotalCount() {
		return totalCount;
	}

	/**
	 * @param totalCount 설정하려는 totalCount
	 */
	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public String getPageUrl() {
		return pageUrl;
	}

	public void setPageUrl(String pageUrl) {
		this.pageUrl = pageUrl;
	}

	public String getLangCd() {
		return langCd;
	}

	public void setLangCd(String langCd) {
		this.langCd = langCd;
	}

	public String getBasicFl() {
		return basicFl;
	}

	public void setBasicFl(String basicFl) {
		this.basicFl = basicFl;
	}

	public int getTotalPage(int totCnt, int listScale) {
		int totPageNavi = 0 ;
		if( totCnt % listScale == 0 ) {
			totPageNavi = totCnt / listScale ;
		} else {
			totPageNavi = (totCnt / listScale) + 1 ;
		}
		if(totPageNavi == 0 ){
			totPageNavi = 1 ;
		}
		return totPageNavi ;
	}

	public String getIsPaging() {
		return isPaging;
	}

	public void setIsPaging(String isPaging) {
		this.isPaging = isPaging;
	}
}
