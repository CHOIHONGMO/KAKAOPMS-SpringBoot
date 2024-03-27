package com.st_ones.evermp.vendor.qt.web;

import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.qt.service.QT0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value="/eversrm/vendor/qt")
public class QT0120Controller {

    @Autowired  QT0100Service qt0100Service;

    @RequestMapping(value="/QT0120/view")
    public String QT0120(EverHttpRequest req) throws Exception{

        Map<String, String> param = req.getParamDataMap();

        Map<String,String> formData = qt0100Service.getQtHdSubmitData(param);
        req.setAttribute("formData",formData);

        return "/eversrm/vendor/qt/QT0120";
    }

    @RequestMapping(value="/QT0120/doSearch")
    public void QT0120_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        resp.setGridObject("grid", qt0100Service.getQtdtSubmitData(req.getFormData()));
    }

    @RequestMapping(value="/QT0120/doSave")
    public void QT0120_doSubmit(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String,String> formData = req.getFormData();
        List<Map<String,Object>> gridDatas = req.getGridData("grid");
        Map<String,String> rtnMap = qt0100Service.saveOrSubmitQT(formData, gridDatas);

        resp.getParameter(rtnMap.get("rtnMsg"));
    }


}
