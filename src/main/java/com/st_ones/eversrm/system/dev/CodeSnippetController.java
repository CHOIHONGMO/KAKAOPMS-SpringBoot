package com.st_ones.eversrm.system.dev;

import com.st_ones.everf.serverside.web.BaseController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Created by FIC02961 on 2017-05-25.
 */
@Controller
@RequestMapping(value = "/eversrm/system/")
public class CodeSnippetController extends BaseController {

    @RequestMapping(value = "codeSnippet/view")
    public String getCodeSnippetView() {

        return "/eversrm/system/dev/codeSnippet";
    }
}