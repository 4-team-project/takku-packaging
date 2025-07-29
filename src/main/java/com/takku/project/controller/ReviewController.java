package com.takku.project.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.takku.project.domain.CouponDTO;
import com.takku.project.domain.FundingDTO;
import com.takku.project.domain.ImageDTO;
import com.takku.project.domain.ReviewDTO;
import com.takku.project.service.CouponService;
import com.takku.project.service.FundingService;
import com.takku.project.service.ImageService;
import com.takku.project.service.ReviewService;

@Controller
@RequestMapping("/review")
public class ReviewController {

	@Autowired
	private CouponService couponService;
	@Autowired
	private ReviewService reviewService;
	@Autowired
	private FundingService fundingService;
	@Autowired
	private ImageService imageService;

	// 리뷰 작성폼
	@GetMapping("/write/{couponId}")
	public String reviewForm(@PathVariable("couponId") int couponId, Model model) {
		CouponDTO coupon = couponService.selectByCouponId(couponId);
		FundingDTO funding = fundingService.selectFundingByFundingId(coupon.getFundingId());

		model.addAttribute("couponDTO", coupon);
		model.addAttribute("fundingDTO", funding);
		return "user.review";
	}

	// 리뷰 등록 처리 - JSON 응답
	@PostMapping(value = "/submit", consumes = "application/json")
	@ResponseBody
	public ResponseEntity<String> submitReview(@RequestBody ReviewDTO reviewDTO,
			@RequestParam("couponId") Integer couponId) {

// 로그인 구현하면 사용
//		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
//		if (loginUser == null) {
//			redirectAttributes.addFlashAttribute("error", "로그인이 필요합니다.");
//			return "redirect:/login";
//		}
//		reviewDTO.setUserId(loginUser.getUserId());
		int result = reviewService.insertReview(reviewDTO);
		if (result > 0 && reviewDTO.getImageUrls() != null) {
			for (String url : reviewDTO.getImageUrls()) {
				String ext = url.substring(url.lastIndexOf("."));
				String timestamp = String.valueOf(System.currentTimeMillis());
				String newFilename = timestamp + ext;
				ImageDTO image = ImageDTO.builder().reviewId(reviewDTO.getReviewId()).imageUrl(newFilename).build();
				imageService.insertImageUrl(image);
			}

		}
		// ✅ 쿠폰 리뷰 완료 처리 (couponId가 ReviewDTO에 있어야 함)
		if (reviewDTO != null) {
			couponService.updateCouponReviewed(couponId);
		}
		return ResponseEntity.ok("등록 성공");
	}

	// 리뷰 목록 보기 -> 펀딩 상세보기로 가는걸로 변경됨
	@GetMapping("/product/{fundingId}/review")
	public String productReviewList(@PathVariable("fundingId") Integer fundingId, Model model) {
		/*
		 * List<ReviewDTO> reviewList = reviewService.reviewByProductId(productId); for
		 * (ReviewDTO review : reviewList) { List<ImageDTO> imageList =
		 * imageService.selectImagesByReviewId(review.getReviewId());
		 * review.setImages(imageList); } model.addAttribute("reviewList", reviewList);
		 */
		model.addAttribute(fundingId);
		return "redirect:/fundings/" + fundingId;
	}
}
