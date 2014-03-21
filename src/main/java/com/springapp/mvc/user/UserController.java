package com.springapp.mvc.user;

import com.google.gson.Gson;
import com.springapp.mvc.MongoDBConfig;
import net.tanesha.recaptcha.ReCaptcha;
import net.tanesha.recaptcha.ReCaptchaResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.data.mongodb.core.MongoOperations;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;

import javax.servlet.ServletRequest;
import java.util.List;

@Controller
public class UserController extends WebMvcConfigurerAdapter {

    private final MongoOperations mongoOperation;
    private final Gson gson = new Gson();
    @Autowired
    private ReCaptcha reCaptchaService = null;

    UserController() { //create mongobd object on start
        ApplicationContext ctx = new AnnotationConfigApplicationContext(MongoDBConfig.class);
        mongoOperation = (MongoOperations) ctx.getBean("mongoTemplate");
    }

    @ResponseBody
    @RequestMapping(value = "/user", method = RequestMethod.GET)
    public String doGet() {
        List<User> listUser = mongoOperation.findAll(User.class);
        return gson.toJson(listUser);
    }

    /**
     * Create record
     * @param firstName
     * @param lastName
     * @param phone
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/user/insert", method = RequestMethod.POST)
    @ResponseStatus(value = HttpStatus.OK)
    public String doPost(@RequestParam(value = "firstName", required = true) String firstName,
                         @RequestParam(value = "lastName", required = true) String lastName,
                         @RequestParam(value = "phone", required = false) String phone) {

        User user = new User(firstName, lastName, phone);
        mongoOperation.save(user);
        return gson.toJson(new Response(user, true, "Registired :)"));
    }

    /**
     * Update record
     * @param id
     * @param firstName
     * @param lastName
     * @param phone
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/user/update/{id}", method = RequestMethod.POST)
    @ResponseStatus(value = HttpStatus.OK)
    public String doPut(@PathVariable(value = "id") String id,
                        @RequestParam(value = "firstName", required = true) String firstName,
                        @RequestParam(value = "lastName", required = true) String lastName,
                        @RequestParam(value = "phone", required = false) String phone) {

        Query query = new Query();
        query.addCriteria(Criteria.where("id").is(id));

        User user = mongoOperation.findOne(query, User.class);

        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setPhone(phone);
        mongoOperation.save(user);

        return gson.toJson(new Response(user, true, "Updated :)"));

    }

    /**
     * Delete record
     * @param id
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/user/{id}", method = RequestMethod.DELETE)
    @ResponseStatus(value = HttpStatus.OK)
    public String doDelete(@PathVariable(value = "id") String id) {

        Query query = new Query();
        query.addCriteria(Criteria.where("id").is(id));

        User user = mongoOperation.findOne(query, User.class);

        mongoOperation.remove(user);

        return "{\"success\":true, \"msg\":\"User Deleted :|\"}";
    }

}