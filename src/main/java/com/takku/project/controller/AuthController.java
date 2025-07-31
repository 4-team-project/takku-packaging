
package com.takku.project.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.UserDTO;
import com.takku.project.service.SmsService;
import com.takku.project.service.StoreService;
import com.takku.project.service.UserService;

@Controller
@RequestMapping("/auth")
public class AuthController {

	@Autowired
	UserService userService;

	@Autowired
	private SmsService smsService;

	@Autowired
	private StoreService storeService;

	// 회원가입 폼
	@GetMapping("/signup")
	public String signup(Model model) {
		model.addAttribute("pageName", "회원가입");
		return "auth.signup";
	}

	// 회원가입 처리
	@PostMapping("/signup")
	public String signup(UserDTO userDTO, Model model) {
		String phone = formatPhone(userDTO.getPhone());
		userDTO.setPhone(phone);

		int result = userService.insertUser(userDTO);
		model.addAttribute("resultMessage", result > 0 ? "회원가입 성공" : "회원가입 실패");
		model.addAttribute("isSuccess", result > 0);
		return "auth.signup"; // redirect 제거!
	}

	// 중복 확인
	@PostMapping("/check-duplicate")
	@ResponseBody
	public Map<String, Object> checkDuplicate(@RequestParam String phone, @RequestParam String userType) {
		Map<String, Object> result = new HashMap<>();
		phone = formatPhone(phone);

		boolean exists = userService.countByPhoneAndUserType(phone, userType); // 메서드명 그대로 사용
		result.put("exists", exists);
		return result;
	}

	// 로그인 폼
	@GetMapping("/login")
	public String login(Model model) {
		model.addAttribute("pageName", "로그인");
		return "auth.login";
	}

	// 로그인 처리
	@PostMapping("/login")
	public String login(String phone, String password, String userType, HttpSession session,
			RedirectAttributes redirectAttributes, @RequestParam(required = false) String msg) {
		// 입력된 번호를 010-0000-0000 형식으로 포맷팅
		phone = formatPhone(phone);
		UserDTO user = userService.selectByPhone(phone, password, userType);

		if (user != null) {
			session.setAttribute("loginUser", user); // 전역에서 사용 가능

			if (userType.equals("사용자")) {
				return "redirect:/takku"; // 사용자 홈 페이지
			}

			// 소상공인
			else {
				List<StoreDTO> storeList = storeService.selectStoreListByUserId(user.getUserId());

				session.setAttribute("storeList", storeList);

				if (storeList != null && !storeList.isEmpty()) {
					session.setAttribute("currentStore", storeList.get(0)); // 첫 번째 상점을 기본값으로 저장
				} else {
					session.setAttribute("currentStore", null); // 상점 없음
				}

				return "redirect:/seller/takku"; // 소상공인 홈으로 이동
			}
		} else {
			redirectAttributes.addFlashAttribute("resultMessage", "로그인 실패: 정보를 확인해주세요");
			return "redirect:/auth/login";
		}
	}

	// 로그아웃
	@PostMapping("/logout")
	public String logout(HttpSession session) {
		session.invalidate();
		return "redirect:/auth/login";
	}

	// 본인인증
	@PostMapping("/send-auth-code")
	@ResponseBody
	public String sendAuthCode(@RequestParam String phone, HttpSession session) {
		try {
			String authCode = smsService.generateCode();
			smsService.sendSms(phone, authCode);
			session.setAttribute("authCode", authCode); // 세션에 저장
			return "success";
		} catch (Exception e) {
			e.printStackTrace();
			return "fail";
		}
	}

	@PostMapping("/verify-auth-code")
	@ResponseBody
	public String verifyAuthCode(@RequestParam String inputCode, HttpSession session) {
		String savedCode = (String) session.getAttribute("authCode");
		if (savedCode != null && savedCode.equals(inputCode)) {
			session.removeAttribute("authCode"); // 재사용 방지
			return "success";
		}
		return "fail";
	}

	private String formatPhone(String phone) {
		if (phone != null && phone.matches("^\\d{10,11}$")) {
			if (phone.length() == 11) {
				return phone.replaceFirst("(\\d{3})(\\d{4})(\\d{4})", "$1-$2-$3");
			} else {
				return phone.replaceFirst("(\\d{3})(\\d{3})(\\d{4})", "$1-$2-$3");
			}
		}
		return phone;
	}

	@PostMapping("/addr")
	public String registerUser(UserDTO user) {
		userService.insertUser(user);
		return "redirect:/user/login";
	}

	// 비밀번호 찾기
	@GetMapping("/findPassword")
	public String findPassword(Model model) {
		model.addAttribute("pageName", "비밀번호 찾기");
		return "auth.findPassword";
	}

	@PostMapping("/findPassword")
	@ResponseBody
	public String findPassword(@RequestParam String phone, @RequestParam String userType, @RequestParam String name) {
		phone = formatPhone(phone);
		// 사용자 찾기
		UserDTO user = userService.findUserPassword(userType, name, phone);

		if (user != null) {
			// 복호화 없이 평문 저장이라면 그대로 전달 (주의!)
			return user.getPassword(); // 또는 JSON으로 {"password": "abc123"} 등
		} else {
			return "not-found";
		}
	}
}
