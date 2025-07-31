package com.takku.project.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.takku.project.domain.UserDTO;
import com.takku.project.domain.stats.SummaryResponse;
import com.takku.project.service.AIService;
import com.takku.project.service.ProductService;
import com.takku.project.service.StoreStatsService;
import com.takku.project.service.UserService;

@Controller
public class StoreStatsController {

	@Autowired
	private StoreStatsService statsService;

	@Autowired
	private UserService userService;

	@Autowired
	private AIService aiService;

	@Autowired
	private ProductService productService;

	// 상점 관리 완성 되면 이사해야하는 메소드
	@GetMapping("/seller/store/products")
	public String getPorductStats(@RequestParam("productId") int productId, Model model, HttpSession session) {

		// TODO: 세션으로 로그인 유저가 해당 storeId, productid의 소유자인지 검증
		Integer userId = 1;

		UserDTO user = userService.selectByUserId(userId);
		model.addAttribute("userDTO", user);
		model.addAttribute("productStats", statsService.getProductMonthlyStats(productId));
		model.addAttribute("productAgeStats", statsService.getProductAgeStats(productId));
		model.addAttribute("productGenderStats", statsService.getProductGenderStats(productId));
		model.addAttribute("productDTO", productService.selectByProductId(productId));
		try {
			SummaryResponse summary = aiService.getReviewSummary(productId); // 변경된 반환값
			model.addAttribute("positiveSummary", summary.getPositive());
			model.addAttribute("negativeSummary", summary.getNegative());
		} catch (Exception e) {
			model.addAttribute("summaryListError", "리뷰 요약을 불러오지 못했습니다.");
		}

		return "seller/productStats";
	}

	// ------------ 밑은 테스트 용 컨트롤러 ------------
	@GetMapping("/platform-stats")
	public String platformStats(Model model) {
		model.addAttribute("ageDistribution", statsService.getAgeDistribution());
		model.addAttribute("genderRatio", statsService.getGenderRatio());
		model.addAttribute("topTagsByGroup", statsService.getTopTagsByAgeGender());

		return "seller/platformStats";
	}

	@GetMapping("/funding/stats")
	public String getFundingStats(@RequestParam("fundingId") int fundingId, Model model) {

		// 펀딩 통계 데이터 조회
		int todayFundingAmount = statsService.getTodayFundingAmount(fundingId);
		int completeOrders = statsService.getFundingCompleteOrderCount(fundingId);
		int refundOrders = statsService.getFundingRefundOrderCount(fundingId);

		model.addAttribute("fundingId", fundingId);
		model.addAttribute("todayFundingAmount", todayFundingAmount);
		model.addAttribute("completeOrders", completeOrders);
		model.addAttribute("refundOrders", refundOrders);
		model.addAttribute("fundingGenderStats", statsService.getFundingGenderRatio(fundingId));
		model.addAttribute("fundingAgeStats", statsService.getFundingAgeDistribution(fundingId));

		return "seller/fundingStats";
	}

}
