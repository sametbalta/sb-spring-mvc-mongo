package com.springapp.mvc;

import javax.servlet.ServletRequest;

import net.tanesha.recaptcha.ReCaptcha;
import net.tanesha.recaptcha.ReCaptchaResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;


@Controller
public class PanelController {

    @RequestMapping(value = {"/"}, method = RequestMethod.GET)
    public String panel() {
        return "panel";
    }

}