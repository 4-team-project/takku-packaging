package com.takku.project.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.takku.project.domain.UserDTO;
import com.takku.project.service.OrderService;
import com.takku.project.service.UserService;

@Controller
@RequestMapping("/user")
public class UserController {

	/*
	 * @GetMapping("/user/mypage") public String myPage(Model model) {
	 * model.addAttribute("pageName", "마이페이지"); return "user.mypage"; }
	 */

	@Autowired
	OrderService orderService;

	@Autowired
	UserService userService;


	@GetMapping("/mypage")
	public String myPage(Model model, HttpSession session) {
		// 페이지명 전달
		model.addAttribute("pageName", "마이페이지");

		// 테스트용 더미 데이터 생성
//		List<OrderDTO> testOrderList = new ArrayList<>();
//		testOrderList.add(OrderDTO.builder()
//				.orderId(13)
//				.userId(5)

//				.productName("???").qty(2).amount(17000).status("결제완료").paymentMethod("카드")
//				.fundingName("수제 돈까스 정식 할인 펀딩")
//				.purchasedAt(Date.valueOf("2025-06-18"))
//
//				.build());
//
//		testOrderList.add(OrderDTO.builder().orderId(13).userId(2).fundingId(4).fundingName("펀딩2").productName("파스타222")
//				.qty(1).amount(15000).usePoint(1000).discountAmount(1000).status("결제완료").paymentMethod("카드")
//				.fundingStatus("펀딩 진행 중").purchasedAt(Date.valueOf("2025-06-12")).build());


		//위에서 userid 세션에서 꺼내오는 거 나중에 추가하기
		// 모델에 테스트 데이터 넣기


		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
	    model.addAttribute("user", loginUser);

	    model.addAttribute("orderList", orderService.selectByUserId(loginUser.getUserId()));


		// 뷰 이름 반환 (mypage.jsp)
		return "user.mypage";
	}
	@PostMapping("/update")
	@ResponseBody  // 이걸 붙이면 리턴값이 View 이름이 아니라 응답 본문으로 간다
	public String updateUser(HttpServletRequest request, HttpSession session) {
	    //UserDTO user = (UserDTO) session.getAttribute("loginUser");

		UserDTO user = (UserDTO) session.getAttribute("loginUser");
		if (user == null) return "0";

	    String nickname = request.getParameter("nickname");
	    String password = request.getParameter("password");
	    String passwordConfirm = request.getParameter("passwordConfirm");
	    String sido = request.getParameter("sido");
	    String sigungu = request.getParameter("sigungu");

	    // 닉네임
	    if (nickname != null && !nickname.trim().isEmpty()) {
	        user.setNickname(nickname);
	    }

	    // 비밀번호
	    if (password != null && !password.isEmpty()) {
	        if (!password.equals(passwordConfirm)) {
	            return "-1";  // 비밀번호 불일치
	        }
	        user.setPassword(password);
	    }

	    // 주소
	    if (sido != null && !sido.isEmpty()) {
	        user.setSido(sido);
	    }

	    if (sigungu != null && !sigungu.isEmpty()) {
	        user.setSigungu(sigungu);
	    }

	    int result = userService.updateUser(user);

	    if (result > 0) {
	        session.setAttribute("loginUser", user);
	        return "1";  // 성공
	    } else {
	        return "0";  // 실패
	    }
	}


}
