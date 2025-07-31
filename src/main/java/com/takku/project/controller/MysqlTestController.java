package com.takku.project.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.takku.project.domain.User;
import com.takku.project.mysql.MysqlTestMapper;

@Controller
@RequestMapping("/mysql")
public class MysqlTestController {

    @Autowired
    private MysqlTestMapper mapper;

    @GetMapping("/test")
    public String showPage(Model model) {
        List<User> users = mapper.selectAll();
        model.addAttribute("users", users);
        model.addAttribute("user", new User()); // 신규 입력 폼용
        return "mysql.test"; // Tiles ID 유지
    }

    @PostMapping("/insert")
    public String insert(@ModelAttribute User user) {
        mapper.insertUser(user);
        return "redirect:/mysql/test";
    }

    @PostMapping("/update")
    public String update(@ModelAttribute User user) {
        mapper.updateUser(user);
        return "redirect:/mysql/test";
    }

    @PostMapping("/delete")
    public String delete(@RequestParam Long id) {
        mapper.deleteUser(id);
        return "redirect:/mysql/test";
    }
}
