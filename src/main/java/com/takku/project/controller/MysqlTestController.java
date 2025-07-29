package com.takku.project.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.takku.project.domain.User;
import com.takku.project.mysql.MysqlTestMapper;

@Controller
@RequestMapping("/mysql")
public class MysqlTestController {

	@Autowired
	private MysqlTestMapper mapper;

	@GetMapping("/test")
	public String test(Model model) {
	    List<User> users = mapper.selectAll();
	    model.addAttribute("users", users);
	    return "mysql.test";
	}

}	
