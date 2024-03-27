package com.st_ones.common.login.domain;

import com.st_ones.common.enums.system.Code;
import com.st_ones.common.util.clazz.EverString;

/**
 * @author ST-Ones
 * @version 1.0
 */
public class UserInfo {

    private String gateCd;
    private String manageCd;
    private String manageComNm;

    private String userId;
    private String userNm;
    private String userNmEng;

    private String companyCd;
    private String companyNm;
    private String companyNmEng;
    private String plantCd;
    private String plantNm;
    private String divisionCd;
    private String divisionNm;
    private String deptCd;
    private String deptNm;
    private String partCd;
    private String partNm;

    private String email;
    private String userType;
    private String langCd;
    private String isDev;
    private String databaseCd;
    private String countryCd;
    private String userGmt;
    private String systemGmt;
    private String dateFormat;
    private String dateValueFormat;
    private String numberFormat;
    private String ipAddress;
    private String singleId;
    private String retireDate;
    private String employeeNum;
    private String grantedAuthCd;
    private String actionAuthCd;
    private String validUserProfile;
    private String positionNm;
    private String superUserFlag;
    private String deptNmEng;
    private String telNum;
    private String cellNum;
    private String faxNum;
    private String workType;
    private String ctrlCd;
    private String finCtrlCd;
    private String pwWrongCnt;
    private String mngYn;
    private String dutyCd;
    private String dutyNm;
    private String lastLoginDate;
    private String irsNum;
    private String jsessionId;
    private String accCd;

    private String autoPoFlag;
    private String blockFlag;
    private String budgetDeptCode;
    private String budgetFlag;
    private String buyerApproveUseFlag;
    private String buyerBudgetUseFlag;
    private String buyerMySiteFlag;
    private String buyerTierCode;
    private String buyerWmsFlag;
    private String financialFlag;
    private String grFlag;
    private String mailFlag;
    private String mySiteFlag;
    private String selectFlag;
    private String smsFlag;
    private String wmsFlag;
    private String dataCreationType;
    private String pwResetType;


    private String zipCd;
    private String addr1;
    private String addr2;

    private String csdmSeq; // 기본배송지코드
    private String delyNm;  // 배송지명
    private String cublSeq;	// 기본청구지코드

    private String plantFlag;
    private String costCenterFlag;
    private String sourcingAutoPoFlag;
    private String oldCustCd;
    private String userAutoPoFlag;
    private String apchFlag;
    private String deptPriceFlag;
    private String relatYn;
    private String mUserId;

    private String ctrlType;	//구매권한
    private String erpIfFlag; 	//고객사 인터페이스 여부
    private String agreeYn; 	//개인정보 취급방침 동의여부

    public String getDelyNm() {
		return delyNm;
	}

	public void setDelyNm(String delyNm) {
		this.delyNm = delyNm;
	}

	public String getErpIfFlag() {
		return erpIfFlag;
	}

	public void setErpIfFlag(String erpIfFlag) {
		this.erpIfFlag = erpIfFlag;
	}

	public String getGateCd() {
        return gateCd;
    }

    public void setGateCd(String gateCd) {
        this.gateCd = gateCd;
    }

    public String getManageCd() {
    	return manageCd;
    }

    public void setManageCd(String manageCd) {
    	this.manageCd = manageCd;
    }

    public String getManageComNm() {
        return manageComNm;
    }

    public void setManageComNm(String manageComNm) {
        this.manageComNm = manageComNm;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserNm() {
        return userNm;
    }

    public void setUserNm(String userNm) {
        this.userNm = userNm;
    }

    public String getUserNmEng() {
        return userNmEng;
    }

    public void setUserNmEng(String userNmEng) {
        this.userNmEng = userNmEng;
    }

    public String getCompanyCd() {
        return companyCd;
    }

    public void setCompanyCd(String companyCd) {
        this.companyCd = companyCd;
    }

    public String getCompanyNm() {
        return companyNm;
    }

    public void setCompanyNm(String companyNm) {
        this.companyNm = companyNm;
    }

    public String getPlantCd() {
        return plantCd;
    }

    public void setPlantCd(String plantCd) {
        this.plantCd = plantCd;
    }

    public String getPlantNm() {
        return plantNm;
    }

    public void setPlantNm(String plantNm) {
        this.plantNm = plantNm;
    }

	public String getDivisionCd() {
		return divisionCd;
	}

	public void setDivisionCd(String divisionCd) {
		this.divisionCd = divisionCd;
	}

    public String getDeptCd() {
        return deptCd;
    }

    public void setDeptCd(String deptCd) {
        this.deptCd = deptCd;
    }

    public String getDeptNm() {
        return deptNm;
    }

    public void setDeptNm(String deptNm) {
        this.deptNm = deptNm;
    }

	public String getPartCd() {
		return partCd;
	}

	public void setPartCd(String partCd) {
		this.partCd = partCd;
	}

	public String getPartNm() {
		return partNm;
	}

	public void setPartNm(String partNm) {
		this.partNm = partNm;
	}

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUserType() {
        return userType;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }

    public String getLangCd() {
        return langCd;
    }

    public void setLangCd(String langCd) {
        this.langCd = langCd;
    }

    public String getIsDev() {
        return isDev;
    }

    public void setIsDev(String isDev) {
        this.isDev = isDev;
    }

    public String getDatabaseCd() {
        return databaseCd;
    }

    public void setDatabaseCd(String databaseCd) {
        this.databaseCd = databaseCd;
    }

    public String getCountryCd() {
        return countryCd;
    }

    public void setCountryCd(String countryCd) {
        this.countryCd = countryCd;
    }

    public String getUserGmt() {
        return userGmt;
    }

    public void setUserGmt(String userGmt) {
        this.userGmt = userGmt;
    }

    public String getSystemGmt() {
        return systemGmt;
    }

    public void setSystemGmt(String systemGmt) {
        this.systemGmt = systemGmt;
    }

    public String getDateFormat() {
        return dateFormat;
    }

    public void setDateFormat(String dateFormat) {
        this.dateFormat = dateFormat;
    }

    public String getDateValueFormat() {
        return dateValueFormat;
    }

    public void setDateValueFormat(String dateValueFormat) {
        this.dateValueFormat = dateValueFormat;
    }

    public String getNumberFormat() {
        return numberFormat;
    }

    public void setNumberFormat(String numberFormat) {
        this.numberFormat = numberFormat;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getSingleId() {
        return singleId;
    }

    public void setSingleId(String singleId) {
        this.singleId = singleId;
    }

    public String getRetireDate() {
        return retireDate;
    }

    public void setRetireDate(String retireDate) {
        this.retireDate = retireDate;
    }

    public String getEmployeeNum() {
        return employeeNum;
    }

    public void setEmployeeNum(String employeeNum) {
        this.employeeNum = employeeNum;
    }

    public String getGrantedAuthCd() {
        return grantedAuthCd;
    }

    public void setGrantedAuthCd(String grantedAuthCd) {
        this.grantedAuthCd = grantedAuthCd;
    }

    public String getActionAuthCd() {
        return actionAuthCd;
    }

    public void setActionAuthCd(String actionAuthCd) {
        this.actionAuthCd = actionAuthCd;
    }

    public String getValidUserProfile() {
        return validUserProfile;
    }

    public void setValidUserProfile(String validUserProfile) {
        this.validUserProfile = validUserProfile;
    }

    public String getPositionNm() {
        return positionNm;
    }

    public void setPositionNm(String positionNm) {
        this.positionNm = positionNm;
    }

    public String getSuperUserFlag() {
        return superUserFlag;
    }

    public void setSuperUserFlag(String superUserFlag) {
        this.superUserFlag = superUserFlag;
    }

    public String getCompanyNmEng() {
        return companyNmEng;
    }

    public void setCompanyNmEng(String companyNmEng) {
        this.companyNmEng = companyNmEng;
    }

    public String getDeptNmEng() {
        return deptNmEng;
    }

    public void setDeptNmEng(String deptNmEng) {
        this.deptNmEng = deptNmEng;
    }

    public String getTelNum() {
        return telNum;
    }

    public void setTelNum(String telNum) {
        this.telNum = telNum;
    }

    public String getCellNum() {
        return cellNum;
    }

    public void setCellNum(String cellNum) {
        this.cellNum = cellNum;
    }

    public String getWorkType() {
        return workType;
    }

    public void setWorkType(String workType) {
        this.workType = workType;
    }

    public String getCtrlCd() {
        return ctrlCd;
    }

    public void setCtrlCd(String ctrlCd) {
        this.ctrlCd = ctrlCd;
    }

    public String getFaxNum() {
        return faxNum;
    }

    public void setFaxNum(String faxNum) {
        this.faxNum = faxNum;
    }

    public String getMngYn() {
        return mngYn;
    }

    public void setMngYn(String mngYn) {
        this.mngYn = mngYn;
    }

    public String getFinCtrlCd() {
        return finCtrlCd;
    }

    public void setFinCtrlCd(String finCtrlCd) {
        this.finCtrlCd = finCtrlCd;
    }

    public String getPwWrongCnt() {
        return pwWrongCnt;
    }

    public void setPwWrongCnt(String pwWrongCnt) {
        this.pwWrongCnt = pwWrongCnt;
    }

    public String getDutyCd() {   return dutyCd;}
    public void setDutyCd(String dutyCd) { this.dutyCd = dutyCd;}

    public String getDutyNm() {   return dutyNm;}
    public void setDutyNm(String dutyNm) { this.dutyNm = dutyNm;}

    public String getLastLoginDate() {   return lastLoginDate;}
    public void setLastLoginDate(String lastLoginDate) { this.lastLoginDate = lastLoginDate;}

    public String getIrsNum() {   return irsNum;}
    public void setIrsNum(String irsNum) { this.irsNum = irsNum;}

    public String getJsessionId() { return jsessionId; }
    public void setJsessionId(String jsessionId) { this.jsessionId = jsessionId; }

    public String getAccCd() { return accCd; }
    public void setAccCd(String accCd) { this.accCd = accCd; }

    public String getAutoPoFlag() { return autoPoFlag;}
    public void setAutoPoFlag(String autoPoFlag) {this.autoPoFlag = autoPoFlag;}

    public String getBlockFlag() {return blockFlag;}
    public void setBlockFlag(String blockFlag) {this.blockFlag = blockFlag;}

    public String getBudgetDeptCode() {return budgetDeptCode;}
    public void setBudgetDeptCode(String budgetDeptCode) {this.budgetDeptCode = budgetDeptCode;}

    public String getBudgetFlag() {return budgetFlag;}
    public void setBudgetFlag(String budgetFlag) {this.budgetFlag = budgetFlag;}

    public String getBuyerApproveUseFlag() {return buyerApproveUseFlag;}
    public void setBuyerApproveUseFlag(String buyerApproveUseFlag) {this.buyerApproveUseFlag = buyerApproveUseFlag;}

    public String getBuyerBudgetUseFlag() {return buyerBudgetUseFlag;}
    public void setBuyerBudgetUseFlag(String buyerBudgetUseFlag) {this.buyerBudgetUseFlag = buyerBudgetUseFlag;}

    public String getBuyerMySiteFlag() {return buyerMySiteFlag;}
    public void setBuyerMySiteFlag(String buyerMySiteFlag) {this.buyerMySiteFlag = buyerMySiteFlag;}

    public String getBuyerTierCode() {return buyerTierCode;}
    public void setBuyerTierCode(String buyerTierCode) {this.buyerTierCode = buyerTierCode;}

    public String getBuyerWmsFlag() {return buyerWmsFlag;}
    public void setBuyerWmsFlag(String buyerWmsFlag) {this.buyerWmsFlag = buyerWmsFlag;}

    public String getFinancialFlag() {return financialFlag;}
    public void setFinancialFlag(String financialFlag) {this.financialFlag = financialFlag;}

    public String getGrFlag() {return grFlag;}
    public void setGrFlag(String grFlag) {this.grFlag = grFlag;}

    public String getMailFlag() {return mailFlag;}
    public void setMailFlag(String mailFlag) {this.mailFlag = mailFlag;}

    public String getMySiteFlag() {return mySiteFlag;}
    public void setMySiteFlag(String mySiteFlag) {this.mySiteFlag = mySiteFlag;}

    public String getSelectFlag() {return selectFlag;}
    public void setSelectFlag(String selectFlag) {this.selectFlag = selectFlag;}

    public String getSmsFlag() {return smsFlag;}
    public void setSmsFlag(String smsFlag) {this.smsFlag = smsFlag;}

    public String getWmsFlag() {return wmsFlag;}
    public void setWmsFlag(String wmsFlag) {this.wmsFlag = wmsFlag;}

    public String getZipCd() {return zipCd;}
    public void setZipCd(String zipCd) {this.zipCd = zipCd;}

    public String getAddr1() {return addr1;}
    public void setAddr1(String addr1) {this.addr1 = addr1;}

    public String getAddr2() {return addr2;}
    public void setAddr2(String addr2) {this.addr2 = addr2;}

    public String getCsdmSeq() {return csdmSeq;}
    public void setCsdmSeq(String csdmSeq) {this.csdmSeq = csdmSeq;}

    public String getCublSeq() {return cublSeq;}
    public void setCublSeq(String cublSeq) {this.cublSeq = cublSeq;}

    public String getPlantFlag() {return plantFlag;}
    public void setPlantFlag(String plantFlag) {this.plantFlag = plantFlag;}

    public String getCostCenterFlag() {return costCenterFlag;}
    public void setCostCenterFlag(String costCenterFlag) {this.costCenterFlag = costCenterFlag;}

    public String getSourcingAutoPoFlag() {return sourcingAutoPoFlag;}
    public void setSourcingAutoPoFlag(String sourcingAutoPoFlag) {this.sourcingAutoPoFlag = sourcingAutoPoFlag;}

    public String getOldCustCd() {return oldCustCd;}
    public void setOldCustCd(String oldCustCd) {this.oldCustCd = oldCustCd;}

    public String getUserAutoPoFlag() {return userAutoPoFlag;}
    public void setUserAutoPoFlag(String userAutoPoFlag) {this.userAutoPoFlag = userAutoPoFlag;}

    public String getApchFlag() {return apchFlag;}
    public void setApchFlag(String apchFlag) {this.apchFlag = apchFlag;}

    public String getDeptPriceFlag() {return deptPriceFlag;}
    public void setDeptPriceFlag(String deptPriceFlag) {this.deptPriceFlag = deptPriceFlag;}

    public String getRelatYn() {return relatYn;}
    public void setRelatYn(String relatYn) {this.relatYn = relatYn;}

    /**
     * 운영사 여부
     *
     * @return
     */
    public boolean isOperator() {
        return Code.OPERATOR.equals(this.userType);
    }

    /**
     * 고객사 여부
     *
     * @return
     */
    public boolean isCustomer() {
        return Code.CUSTOMER.equals(this.userType);
    }

    /**
     * 협력회사 여부
     *
     * @return
     */
    public boolean isSupplier() {
        return Code.SUPPLIER.equals(this.userType);
    }

    public boolean isSuperUser() {
        return EverString.nullToEmptyString(superUserFlag).equals("1");
    }

    /**
     * 관리직무자 여부
     * @return
     */
    public boolean hasCOST() {
        return (this.ctrlType != null && this.ctrlType.indexOf("COST") > -1);
    }

    /**
     * 구매직무자 여부
     * @return
     */
    public boolean hasNPUR() {
    	return (this.ctrlType != null && this.ctrlType.indexOf("NPUR") > -1);
    }

    /**
     * 품목직무자 여부
     * @return
     */
    public boolean hasITEM() {
    	return (this.ctrlType != null && this.ctrlType.indexOf("ITEM") > -1);
    }

    /**
     * 영업직무자 여부
     * @return
     */
    public boolean hasINVT() {
    	return (this.ctrlType != null && this.ctrlType.indexOf("INVT") > -1);
    }

    /**
     * 지원직무자 여부
     * @return
     */
    public boolean hasSUPT() {
    	return (this.ctrlType != null && this.ctrlType.indexOf("SUPT") > -1);
    }

    public String getmUserId() {
    	return mUserId;
    }

    public void setmUserId(String mUserId) {
    	this.mUserId = mUserId;
    }

	public String getCtrlType() {
		return ctrlType;
	}

	public void setCtrlType(String ctrlType) {
		this.ctrlType = ctrlType;
	}

	public String getDivisionNm() {
		return divisionNm;
	}

	public void setDivisionNm(String divisionNm) {
		this.divisionNm = divisionNm;
	}

	// 개인정보 취급방침 동의여부
	public String getAgreeYn() {
		return agreeYn;
	}

	public void setAgreeYn(String agreeYn) {
		this.agreeYn = agreeYn;
	}

	public String getDataCreationType() {
		return dataCreationType;
	}

	public void setDataCreationType(String dataCreationType) {
		this.dataCreationType = dataCreationType;
	}

	public String getPwResetType() {
		return pwResetType;
	}

	public void setPwResetType(String pwResetType) {
		this.pwResetType = pwResetType;
	}
}
