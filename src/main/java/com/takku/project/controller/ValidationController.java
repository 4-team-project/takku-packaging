package com.takku.project.controller;

import java.util.Collections;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.takku.project.service.StoreService;
import com.takku.project.service.UserService;

@RestController
@RequestMapping("/api/v1/validations")
public class ValidationController {
	
	@Autowired
	private UserService userService; 
	
	@Autowired
	private StoreService storeService;
		
	@PostMapping("/email")
	public Map<String, Boolean> checkEmail(@RequestBody Map<String, String> map) {
		String email = map.get("email");
		int count = userService.countByEmail(email);
		boolean valid = (count == 0); // 이메일 count가 0이면(중복없음) 사용 가능
        return Collections.singletonMap("valid", valid);
	}
	
	@PostMapping("/password-format")
	public Map<String, Boolean> checkPasswordFormat(@RequestBody Map<String, String> map) {
		String pwd = map.get("password");
		boolean valid = pwd.matches("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d\\W]{6,}$"); // 영어+숫자 조합, 특수문자 없음, 6자 이상
		return Collections.singletonMap("valid", valid);
	}
	
	@PostMapping("/business-number")
    public Map<String, Boolean> checkBusinessNumber(@RequestBody Map<String, String> body) {
        String businessNumber = body.get("businessNumber");
        int count = storeService.countByBusinessNumber(businessNumber);
        boolean valid = (count == 0); //사업자번호 count가 0이면(중복없음) 사용 가능
        return Collections.singletonMap("valid", valid);
    }
}
