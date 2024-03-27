package com.st_ones.evermp.buyer.rq.web;

import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping(value = "/evermp/buyer/rq")
public class RQ0110P01Controller extends BaseController {

    @RequestMapping(value="/RQ0110P01/view")
    public String RQ0110P01(EverHttpRequest req) throws Exception{
        return "/evermp/buyer/rq/RQ0110P01";
    }


}
