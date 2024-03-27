package com.st_ones.eversrm.system.batch.web;

import com.st_ones.batch.userBlock.web.UserBlockJob;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.IOException;
import java.util.Map;

@Controller
@RequestMapping(value = "/eversrm/system/batch")
public class BatchLogController extends BaseController {

	@Autowired private MessageService msg;
	@Autowired private CommonComboService commonComboService;
	@Autowired private UserBlockJob userBlockjob;

	@RequestMapping("/batchLog/view")
	public String BatchLog(EverHttpRequest req) throws Exception {

		req.setAttribute("refExecCd", commonComboService.getCodeComboAsJson("M177"));
		return "/eversrm/system/batch/batchLog";
	}

	@RequestMapping(value = "/batchLog/doDownload")
	public void doDownload(EverHttpRequest req, EverHttpResponse resp) throws IOException {

		Map<String, String> formData = req.getFormData();
		String logFile = formData.get("logFile");
	}

	@RequestMapping(value = "/batchLog/doExecute")
	public void doExecute(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		String execCd = param.get("EXEC_CD");
		String rtnMsg = "";
		
        try {
			if("userBlock".equals(execCd)) { // User Block
				userBlockjob.execute(null);
			}
			rtnMsg = msg.getMessage("0001");
        } catch (Exception e) {
			getLog().error(e.getMessage(), e);
        	rtnMsg = msg.getMessage("0003");
        }
        
		resp.setResponseMessage(rtnMsg);
	}
}
