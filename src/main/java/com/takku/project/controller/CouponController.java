package com.takku.project.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.takku.project.domain.CouponDTO;
import com.takku.project.domain.FundingDTO;
import com.takku.project.domain.ImageDTO;
import com.takku.project.domain.ProductDTO;
import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.UserDTO;
import com.takku.project.service.CouponService;
import com.takku.project.service.FundingService;
import com.takku.project.service.ImageService;
import com.takku.project.service.ProductService;
import com.takku.project.service.StoreService;

@Controller
public class CouponController {

	@Autowired
	private CouponService couponService;
	@Autowired
	private FundingService fundingService;
	@Autowired
	private ProductService productService;
	@Autowired
	private StoreService storeService;
	@Autowired
	private ImageService imageService;

	/**
	 * [1] 쿠폰 QR 상세 정보
	 */
	@GetMapping("/user/coupon/qr")
	public String showCouponQR(@RequestParam("couponId") Integer couponId, Model model, HttpServletRequest request) {
		CouponDTO coupon = couponService.selectByCouponId(couponId);
		if (coupon == null) {
			return "coupon.error";
		}

		FundingDTO funding = fundingService.selectFundingByFundingId(coupon.getFundingId());
		ProductDTO product = productService.selectByProductId(funding.getProductId());

		String scheme = request.getScheme();
		String host = request.getHeader("host");
		String contextPath = request.getContextPath();
		String rawUrl = scheme + "://" + host + contextPath + "/coupon/sellerCheck?couponCode="
				+ coupon.getCouponCode();

		String qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=" + rawUrl;

		model.addAttribute("couponCode", coupon.getCouponCode());
		model.addAttribute("qrUrl", qrUrl);
		model.addAttribute("funding", funding);
		model.addAttribute("product", product);
		model.addAttribute("storeName", funding.getStoreName());

		return "user.coupon_detail";
	}

	/**
	 * [2] 쿠폰 사용 처리 버튼 눌렀을때
	 */
	@GetMapping("/coupon/use")
	public String useCoupon(@RequestParam("couponCode") String couponCode) {
		couponService.updateCouponUseStatus(couponCode, "사용");
		return "user.home";
	}

	/**
	 * [3] 가맹점에서 QR로 쿠폰 확인 (큐알 찍고 타고 가는 곳)
	 */
	@GetMapping("/coupon/sellerCheck")
	public String sellerCheck(Model model, @RequestParam("couponCode") String couponCode) {
		CouponDTO coupon = couponService.selectByCouponCode(couponCode);
		model.addAttribute("coupon", coupon);

		if (coupon != null) {
			FundingDTO funding = fundingService.selectFundingByFundingId(coupon.getFundingId());
			ProductDTO product = productService.selectByProductId(funding.getProductId());
			StoreDTO store = storeService.selectStoreById(funding.getStoreId());
			List<ImageDTO> image = imageService.selectImagesByProductId(product.getProductId());

			model.addAttribute("pageName", "쿠폰 확인");
			model.addAttribute("funding", funding);
			model.addAttribute("product", product);
			model.addAttribute("store", store);
			model.addAttribute("image", image);
		}
		return "coupon.sellerCheck";
	}

	/**
	 * [4] 리뷰 작성 체크
	 */
	@PostMapping("/{couponId}/reviewed")
	public String markReviewed(@PathVariable("couponId") Integer couponId) {
		couponService.updateCouponReviewed(couponId);
		return "redirect:/user/coupon";
	}

	/**
	 * [5] 사용자 쿠폰 목록
	 */
	 @GetMapping("/user/coupon")
	    public String userCouponList(HttpSession session, Model model) {
	        model.addAttribute("pageName", "내 쿠폰함");
	        // 세션에서 로그인한 사용자 정보 가져오기
	        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
	        int userId = loginUser.getUserId(); // 로그인한 사용자 ID
	        List<CouponDTO> coupons = couponService.selectCouponByUserId(userId);
	        model.addAttribute("coupons", coupons);
	        Map<Integer, FundingDTO> fundingMap = new HashMap<>();
	        Map<Integer, ProductDTO> productMap = new HashMap<>();
	        Map<Integer, StoreDTO> storeMap = new HashMap<>();
	        for (CouponDTO coupon : coupons) {
	            int fundingId = coupon.getFundingId();
	            FundingDTO funding = fundingService.selectFundingByFundingId(fundingId);
	            fundingMap.put(fundingId, funding);
	            ProductDTO product = productService.selectByProductId(funding.getProductId());
	            productMap.put(funding.getProductId(), product);
	            StoreDTO store = storeService.selectStoreById(funding.getStoreId());
	            storeMap.put(funding.getStoreId(), store);
	        }
	        model.addAttribute("fundingMap", fundingMap);
	        model.addAttribute("productMap", productMap);
	        model.addAttribute("storeMap", storeMap);
	        return "user.coupon";
	    }
}
