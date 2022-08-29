package com.tplink.testmodule.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @RequestMapping(value = "/hello", method = RequestMethod.GET)
    public String getHello(){
        return "test-module hello\n";
    }
    @RequestMapping(value = "/info", method = RequestMethod.GET)
    public String getInfo(){
        return "test-module echo info\n";
    }
    @RequestMapping(value = "/test", method = RequestMethod.GET)
    public String getTest() { return "best wish to you!\n";}
}
