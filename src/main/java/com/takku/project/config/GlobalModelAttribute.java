package com.takku.project.config;

import javax.servlet.http.HttpSession;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.UserDTO;

@ControllerAdvice
public class GlobalModelAttribute {

	@ModelAttribute("loginUser")
    public UserDTO loginUser(HttpSession session) {
        return (UserDTO) session.getAttribute("loginUser");
    }
	
	@ModelAttribute("store")
    public StoreDTO addStore(HttpSession session) {
        return (StoreDTO) session.getAttribute("store");
    }
}
