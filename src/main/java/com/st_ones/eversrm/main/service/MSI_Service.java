package com.st_ones.eversrm.main.service;

import com.st_ones.common.enums.system.Code;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.mail.web.EverMailVo;
import com.st_ones.common.mail.web.MailTemplate;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.everf.serverside.util.clazz.SessionIgnore;
import com.st_ones.eversrm.main.MSI_Mapper;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * <pre>
 * *****************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 * *****************************************************************************
 * </pre>
 *
 * @author Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @version 1.0
 * @File Name : BMSI_Service.java
 * @date 2013. 07. 22.
 * @see
 */

@Service(value = "msi_Service")
public class MSI_Service extends BaseService {

    @Autowired
    private MessageService msg;

    @Autowired
    private MailTemplate mt;

    @Autowired
    private EverMailService everMailService;

    @Autowired
    private EverSmsService everSmsService;

    @Autowired
    private MSI_Mapper msiMapper;

    @Autowired
    LargeTextService largeTextService;

    @AuthorityIgnore
    public Map<String, Object> doFindIDFindIdPassword(Map<String, String> param) throws Exception {
        param.put("CELL_NUM", param.get("CELL_NUM").replace("-", "").replace("(", "").replace(")", ""));
        param.put("IRS_NUM", param.get("IRS_NUM").replace("-", ""));
        List<Map<String, Object>> lstUser = msiMapper.doFindIDFindIdPassword(param);
        Map<String, Object> user = new HashMap<String, Object>();
        if (lstUser.size() <= 0) {
            user.put("MSG_RETURN", msg.getMessageByScreenId("MSI_030", "USERNOTFOUND"));
            return user;
        } else if (lstUser.size() > 1) {
            user.put("MSG_RETURN", msg.getMessageByScreenId("MSI_030", "TOOMANYUSERS"));
            return user;
        }
        lstUser.get(0).put("MSG_RETURN", "");
        return lstUser.get(0);
    }

    @AuthorityIgnore
    public String doFindPasswordFindIdPassword(Map<String, String> param) throws Exception {

        param.put("CELL_NUM", param.get("CELL_NUM").replace("-", "").replace("(", "").replace(")", ""));
        param.put("IRS_NUM", param.get("IRS_NUM").replace("-", ""));
        List<Map<String, Object>> lstUsers = msiMapper.doFindPasswordFindIdPassword(param);

        if (lstUsers.size() <= 0) {
            return msg.getMessageByScreenId("MSI_030", "USERNOTFOUND");
        } else if (lstUsers.size() > 1) {
            return msg.getMessageByScreenId("MSI_030", "TOOMANYUSERS");
        }
        Map<String, Object> userInfo = lstUsers.get(0);

        String password = UUID.randomUUID().toString().replace("-", "").substring(0, 6);
        userInfo.put("PASSWORD", password);

        if ("true".equals(param.get("smsMailPasswordFlag").toString())) {
            String content = msg.getMessageByScreenId("MSI_030", "CONTENT_MAIL");
            content = content.replace("@@USER_NM", userInfo.get("USER_NM").toString()).replace("@@USER_ID", userInfo.get("USER_ID").toString()).replace("@@PASSWORD", userInfo.get("PASSWORD").toString());
            String subject = msg.getMessageByScreenId("MSI_030", "SUBJECT_MAIL");
            EverMailVo wmv = new EverMailVo();
            wmv.setContents(content);
            wmv.setSubject(subject);
            wmv.setInterfaceType("BEAN");
            wmv.setSenderEmail("");
            wmv.setSenderNm("");
            wmv.setRefNum(param.get("USER_ID"));
            wmv.setRefModuleCd("PASSWORD");
            wmv.setReceiverEmail(userInfo.get("EMAIL").toString());
            wmv.setReceiverNm(userInfo.get("USER_NM").toString());
            wmv.setReceiverUserId(userInfo.get("USER_ID").toString());
            wmv.setContents("");//mt.getMailTemplate("", wmv.getSubject(), wmv.getContents(), "", ""));
            // 2020.10.06 견적, 발주만 Mail/SMS 발송처리.
            // everMailService.SendMail(wmv);
        }
        if ("true".equals(param.get("smsFindPasswordFlag").toString())) {
            Map<String, String> paramSms = new HashMap<String, String>();
            paramSms.put("RECV_TEL_NUM", userInfo.get("CELL_NUM").toString());
            paramSms.put("RECV_USER_NM", userInfo.get("USER_NM").toString());
            paramSms.put("RECV_USER_ID", userInfo.get("USER_ID").toString());
            paramSms.put("CONTENTS", msg.getMessageByScreenId("MSI_030", "SMS_CONTENT"));
            // 2020.10.06 견적, 발주만 Mail/SMS 발송처리.
            // everSmsService.sendSms(paramSms);
        }

        userInfo.put("PASSWORD", EverEncryption.getEncryptedUserPassword(password));
        msiMapper.doSavePassword(userInfo);

        return msg.getMessageByScreenId("MSI_030", "PASSWORD_SENT");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> doRegister(Map<String, String> param) throws Exception {
        Map<String, Object> returnMap = new HashMap<String, Object>();
        returnMap.put("gateCd", param.get("GATE_CD"));
        returnMap.put("langCd", param.get("LANG_CD"));
        returnMap.put("irsNum", param.get("IRS_NUM"));
        returnMap.put("portalType", "NEW");
        List<Map<String, Object>> lstVendor = msiMapper.checkVendor(param);
        if (lstVendor.size() > 0) {
            String delFlag = (String) lstVendor.get(0).get("DEL_FLAG");
            String progressCode = (String) lstVendor.get(0).get("PROGRESS_CD");
            if (delFlag.equals("1")) {
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "HAS_DELETED"));
            } else if (progressCode.equals("E")) {
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "HAS_APPROVED"));
            } else if (progressCode.equals("R")) {
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "HAS_REJECTED"));
            } else {
                //count(*) > 0
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "HAS_EXIST"));
            }
        }

        //Move to BBV_010 screen. Transfer gateCd/langCd/irsNo/portalType=NEW
        return returnMap;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> doChange(Map<String, String> param) throws Exception {
        Map<String, Object> returnMap = new HashMap<String, Object>();
        List<Map<String, Object>> lstVendor = msiMapper.checkVendor(param);
        if (lstVendor.size() <= 0) {
            throw new NoResultException(msg.getMessageByScreenId("MSI_060", "VNGL_NOT_EXIST"));
        } else if (lstVendor.size() > 0) {
            String delFlag = (String) lstVendor.get(0).get("DEL_FLAG");
            String progressCode = (String) lstVendor.get(0).get("PROGRESS_CD");
            if (delFlag.equals("1")) {
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "HAS_DELETED"));
            } else if (progressCode.equals("E")) {
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "HAS_APPROVED"));
            } else if (progressCode.equals("R")) {
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "HAS_REJECTED"));
            }
        }

        param.put("PASSWORD", EverEncryption.getEncryptedUserPassword(param.get("PASSWORD").toString()));
        List<Map<String, Object>> lstUser = msiMapper.checkUser(param);
        if (lstUser.size() <= 0) {
            throw new NoResultException(msg.getMessageByScreenId("MSI_060", "NOT_EXIST"));
        } else if (lstUser.size() > 0) {
            String delFlag = (String) lstUser.get(0).get("DEL_FLAG");
            String useFlag = (String) lstUser.get(0).get("USE_FLAG");
            String progressCode = (String) lstUser.get(0).get("PROGRESS_CD");
            if (delFlag.equals("1")) {
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "NOT_EXIST"));
            } else if (useFlag.equals("0")) {
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "CAN_NOT_LOGIN"));
            } else if (!progressCode.equals("P")) {
                throw new NoResultException(msg.getMessageByScreenId("MSI_060", "CAN_NOT_LOGIN_2"));
            }
        }
        //Move to BBV_010 screen. Transfer gateCd/langCd/userId/vendorCd/irsNo/portalType=CHANGE.
        returnMap.put("userId", lstUser.get(0).get("USER_ID").toString());
        returnMap.put("vendorCd", lstVendor.get(0).get("VENDOR_CD").toString());
        returnMap.put("langCd", param.get("LANG_CD"));
        returnMap.put("irsNum", param.get("IRS_NUM"));
        returnMap.put("gateCd", param.get("GATE_CD"));
        return returnMap;
    }

    @AuthorityIgnore
    public HashMap<String, String> selectUser(Map<String, String> param) throws UserInfoNotFoundException {

        getLog().info("{}", UserInfoManager.getUserInfo());

        String userType = UserInfoManager.getUserInfo().getUserType();
        HashMap<String, String> rtn;

        //운영사
//        if (userType.equals("C")) {
            rtn = msiMapper.selectUser(param);
            //협력사, 고객사
//        } else {
//            rtn = msiMapper.selectUserCS(param);
//        }

        return rtn;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String saveUser(Map<String, String> formData) throws Exception {

        String newPass1 = formData.get("PASSWORD_CHECK1");
        String newPass2 = formData.get("PASSWORD_CHECK2");
        formData.put("P_PASSWORD", EverEncryption.getEncryptedUserPassword(formData.get("P_PASSWORD")));

        //비밀번호 업데이트 x
        if (newPass1.equals("") && newPass2.equals("")) {

        } else {
            // 사용자정보체크(현재비밀번호체크)
            HashMap<String, String> originalUserInfo = this.selectUser(formData);
            // 현재 비밀번호가 빈 값이 아닐 때는 비밀번호를 변경하려는 것으로 간주하고 기존 비밀번호를 제대로 입력했는지 확인한다.
            if (StringUtils.isNotEmpty(formData.get("PASSWORD_CHECK1"))) {

                if (originalUserInfo == null) {
                    // 비밀번호가 틀리면 저장하지 않고 리턴한다.
                    throw new EverException(msg.getMessageByScreenId("MY01_005", "005"));
                }
                if (!StringUtils.equals(newPass1, newPass2)) {
                    throw new EverException(msg.getMessage("0028"));
                }
                formData.put("PASSWORD", EverEncryption.getEncryptedUserPassword(formData.get("PASSWORD_CHECK1")));
            }
        }

        String userType = UserInfoManager.getUserInfo().getUserType();
        // 운영사
        if (userType.equals("C")) {
            msiMapper.doUpdate(formData);
            // 협력사, 고객사
        } else {
            msiMapper.doUpdateCS(formData);
        }
        return msg.getMessage("0031");
    }

    @SessionIgnore
    public Map<String, String> getBaseLoginInfo(Map<String, String> certificateInfoMap) throws Exception {
        Map<String, String> ssnMap = msiMapper.getBaseLoginInfo(certificateInfoMap);
        if (ssnMap == null) {
            return null;
        } else if (ssnMap.get("USER_TYPE").equals(Code.OPERATOR)) {
//			throw new EverException("협력회사 사용자만 인증서 로그인을 할 수 있습니다.");
        }
        return ssnMap;
    }

    public HashMap<String, String> getUserDateFormat(Map<String, String> formData) throws Exception {
        return msiMapper.getDateFormatValue(formData);
    }

    public HashMap<String, String> getUserNumberFormat(Map<String, Object> formData) throws Exception {
        return msiMapper.getNumberFormatValue(formData);
    }

//	@AuthorityIgnore
//	public List<HashMap<String, String>> getCTRLInfo(com.st-ones.wisef.info.BaseInfo CTRLData) throws Exception {
//		return msiMapper.getCTRLInfo(CTRLData);
//	}

}