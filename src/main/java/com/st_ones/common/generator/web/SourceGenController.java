package com.st_ones.common.generator.web;

import com.st_ones.common.generator.service.SourceGenService;
import com.st_ones.everf.serverside.util.clazz.SessionIgnore;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by azure on 2015-10-12.
 */
@Controller
@RequestMapping(value = "/generator/source")
public class SourceGenController extends BaseController {

    @Autowired
    private SourceGenService sourceGenService;

    /**
     * View string.
     *
     * @param req the req
     * @param resp the resp
     * @return the string
     * @throws Exception the exception
     */
    @SessionIgnore
    @RequestMapping(value = "/view.so")
    public String view(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        sourceGenService.getMultilanguageData(req, resp);
        sourceGenService.getActionData(req, resp);

        return "/common/generator/sourceGenView";
    }

    /**
     * Create controller.
     *
     * @param req the req
     * @param resp the resp
     * @throws Exception the exception
     */
    @RequestMapping(value = "/createController")
    public void createController(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> conInfo = new HashMap<String, String>();
        conInfo.put("createFolder", req.getParameter("createFolder"));
        conInfo.put("fileName", req.getParameter("fileName"));

        sourceGenService.createController(conInfo);
    }
}
