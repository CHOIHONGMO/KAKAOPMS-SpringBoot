package com.st_ones.eversrm.system.batch.web;

import com.st_ones.batch.bdOpen.web.BdOpen;
import com.st_ones.batch.comDeptIf.web.ComDeptJob;
import com.st_ones.batch.comDivisionIf.web.ComDivisionJob;
import com.st_ones.batch.comPartIf.web.ComPartJob;
import com.st_ones.batch.comPlantIf.web.ComPlantJob;
import com.st_ones.batch.comUserIf.web.ComUserJob;
import com.st_ones.batch.cpoIF.web.CPOIF;
import com.st_ones.batch.custCfmReqMail.web.CustCfmReqMail;
import com.st_ones.batch.custUnitPrcIF.web.CustUnitPrcIF;
import com.st_ones.batch.delyAlarmIf.web.CurDelyAlarmIf;
import com.st_ones.batch.delyAlarmIf.web.DelyAlarmIf;
import com.st_ones.batch.grIF.web.GRIF;
import com.st_ones.batch.grRequestDelaySms.web.GrRequestDelaySms;
import com.st_ones.batch.gwApprovalIf.web.GwApprovalIF;
import com.st_ones.batch.invoiceDelayIf.web.InvoiceDelayIf;
import com.st_ones.batch.itemIF.web.ITEMIF;
import com.st_ones.batch.rfqNoticeMail.web.RfqNoticeMail;
import com.st_ones.batch.userBlock.web.UserBlockJob;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.batch.service.BatchListService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/eversrm/system/batch")
public class BatchListController extends BaseController {

    @Autowired private MessageService msg;
    @Autowired private BatchListService batchListService;
    @Autowired private CommonComboService commonComboService;

    @Autowired private ComPlantJob comPlantJob;
    @Autowired private ComDivisionJob comDivisionJob;
    @Autowired private ComDeptJob comDeptJob;
    @Autowired private ComPartJob comPartJob;
    @Autowired private ComUserJob comUserJob;

    @Autowired private ITEMIF itemJob;
    @Autowired private CPOIF cpoJob;
    @Autowired private GRIF grJob;

    @Autowired private UserBlockJob userBlockJob;
    @Autowired private InvoiceDelayIf invoiceDelayIf;
    @Autowired private DelyAlarmIf delyAlarmIf;
    @Autowired private CurDelyAlarmIf curDelyAlarmIf;
    @Autowired private GrRequestDelaySms grRequestDelaySms;
    @Autowired private RfqNoticeMail rfqNoticeMail;
    @Autowired private CustCfmReqMail custCfmReqMail;

    @Autowired private GwApprovalIF gwApprovalIf;
    @Autowired private CustUnitPrcIF custUnitPrcIF;

    @Autowired private BdOpen bdOpen;



    @RequestMapping("/batchListNew/view")
    public String batchListNewView(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}
        String curDate = EverDate.getDate();
        req.setAttribute("refExecCd", commonComboService.getCodeComboAsJson("M177"));
        req.setAttribute("refProgressCd", commonComboService.getCodeComboAsJson("M169"));
        req.setAttribute("fromDate", curDate);
        req.setAttribute("toDate", curDate);

        return "/eversrm/system/batch/batchListNew";
    }

    @RequestMapping(value = "/batchListNew/doSearchBatchList")
    public void doSearchBatchList(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	resp.setGridObject("gridBatchList", batchListService.doSearchBatchList(req.getFormData()));
    }

    @RequestMapping(value = "/batchListNew/doSearch")
    public void doSearchBatchLogList(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo baseInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = req.getFormData();
        param.put("JOB_ID", EverString.nullToEmptyString(req.getParameter("JOB_ID")));
        param.put("JOB_DATE_FROM", EverDate.getGmtFromDate(param.get("JOB_DATE_FROM"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
        param.put("JOB_DATE_TO", EverDate.getGmtToDate(param.get("JOB_DATE_TO"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

        resp.setGridObject("grid", batchListService.doSearchBatchLogList(param));
    }

    @RequestMapping(value = "/batchListNew/doExecute")
    public void doExecute(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String rtnMsg = msg.getMessage("0001");

        List<Map<String, Object>> gridDatas = req.getGridData("gridBatchList");

        for(Map<String, Object> gridData : gridDatas) {

            String execCd = String.valueOf(gridData.get("BATCH_ID"));
            try {
                if ("ComPlantIf".equals(execCd)) { 					// 고객 사업장 I/F
                	comPlantJob.execute(null);
                } else if ("ComDivisionIf".equals(execCd)) { 		// 고객 사업부 I/F
                	comDivisionJob.execute(null);
                } else if ("ComDeptIf".equals(execCd)) { 			// 고객 부서 I/F
                	comDeptJob.execute(null);
                } else if ("ComPartIf".equals(execCd)) { 			// 고객 파트(영업장) I/F
                	comPartJob.execute(null);
                } else if ("ComUserIf".equals(execCd)) { 			// 사용자 I/F
                	comUserJob.execute(null);
                } else if ("ITEM_IF".equals(execCd)) { 				// 신규품목 등록요청 I/F
                	itemJob.execute(null);
                } else if ("CPO_IF".equals(execCd)) { 				// 주문정보 I/F
                	cpoJob.execute(null);
                } else if ("GR_IF".equals(execCd)) { 				// 입고정보 I/F
                	grJob.execute(null);
                } else if ("UserBlock".equals(execCd)) { 			// 사용자 Block
                	userBlockJob.execute(null);
                } else if ("InvoiceDelayIf".equals(execCd)) { 		// 납품지연알림(D+1)
                	invoiceDelayIf.execute(null);
                } else if ("DelyAlarmIf".equals(execCd)) { 			// 납품예정알림(D-1)
                	delyAlarmIf.execute(null);
                } else if ("CurDelyInvoiceIf".equals(execCd)) { 	// 금일납품알림(D+0)
                	curDelyAlarmIf.execute(null);
                } else if ("GrRequestDelaySms".equals(execCd)) { 	// 입고완료처리 요청(고객사, 입고담당자)
                	grRequestDelaySms.execute(null);
                } else if ("CUST_CFM_REQ_MAIL".equals(execCd)) { 	// 마감확정요청(고객)
                	custCfmReqMail.execute(null);
                } else if ("RfqNoticeMail".equals(execCd)) { 		// 견적지연 안내
                	rfqNoticeMail.execute(null);
                } else if ("GWAPPROVAL_IF".equals(execCd)) { 		// G/W 결재승인 후 프로세스
                	gwApprovalIf.execute(null);
	            } else if ("CustUnitPrcIF".equals(execCd)) { 		// G/W 결재승인 후 프로세스
	            	custUnitPrcIF.execute(null);
	            } else if ("BD_OPEN".equals(execCd)) { 		// 입찰 마감 개찰자한테 SMS 보내기
	            	bdOpen.execute(null);
	            }
            } catch (Exception e) {
                getLog().error(e.getMessage(), e);
                rtnMsg = msg.getMessage("0003");
            }
        }
        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping("/batchList/view")
    public String batchListView(EverHttpRequest req) throws Exception {

        String curDate = EverDate.getDate();
        req.setAttribute("refExecCd", commonComboService.getCodeComboAsJson("M177"));
        req.setAttribute("refProgressCd", commonComboService.getCodeComboAsJson("M169"));
        req.setAttribute("fromDate", curDate);
        req.setAttribute("toDate", curDate);

        return "/eversrm/system/batch/batchList";
    }
}
