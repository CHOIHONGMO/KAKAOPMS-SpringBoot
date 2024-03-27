package com.st_ones.evermp.vendor.qt.web;

import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.qt.service.QT0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value="/evermp/vendor/qt")
public class QT0320Controller {

    @Autowired
    QT0300Service qt0300Service;

    @RequestMapping(value="/QT0320/view")
    public String QT0120(EverHttpRequest req) throws Exception{

        Map<String, String> param = req.getParamDataMap();

        Map<String,String> formData = qt0300Service.getQtHdSubmitData(param);
        req.setAttribute("formData",formData);

        return "/evermp/vendor/qt/QT0320";
    }

    @RequestMapping(value="/QT0320/doSearch")
    public void QT0320_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        resp.setGridObject("grid", qt0300Service.getQtdtSubmitData(req.getFormData()));
    }

    @RequestMapping(value="/QT0320/doSave")
    public void QT0320_doSubmit(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String,String> formData = req.getFormData();
        List<Map<String,Object>> gridDatas = req.getGridData("grid");
        Map<String,String> rtnMap = qt0300Service.saveOrSubmitQT(formData, gridDatas);

        resp.getParameter(rtnMap.get("rtnMsg"));
    }


}
