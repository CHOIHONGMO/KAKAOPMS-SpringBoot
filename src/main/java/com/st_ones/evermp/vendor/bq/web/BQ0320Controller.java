package com.st_ones.evermp.vendor.bq.web;

import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.bq.service.BQ0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value="/evermp/vendor/bq")
public class BQ0320Controller {

    @Autowired
    BQ0300Service bq0300Service;

    @RequestMapping(value="/BQ0320/view")
    public String QT0120(EverHttpRequest req) throws Exception{

        Map<String, String> param = req.getParamDataMap();

        Map<String,String> formData = bq0300Service.getBqHdSubmitData(param);
        req.setAttribute("formData",formData);
        req.setAttribute("isDevEnv", PropertiesManager.getBoolean("eversrm.system.developmentFlag"));

        return "/evermp/vendor/bq/BQ0320";
    }

    @RequestMapping(value="/BQ0320/doSearch")
    public void BQ0320_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        resp.setGridObject("grid", bq0300Service.getBqdtSubmitData(req.getFormData()));
    }

    @RequestMapping(value="/BQ0320/doSave")
    public void BQ0320_doSubmit(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String,String> formData = req.getFormData();
        List<Map<String,Object>> gridDatas = req.getGridData("grid");
        Map<String,String> rtnMap = bq0300Service.saveOrSubmitBq(formData, gridDatas);

        resp.getParameter(rtnMap.get("rtnMsg"));
    }


}
