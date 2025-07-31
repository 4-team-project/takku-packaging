package com.takku.project.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.takku.project.domain.FundingDTO;
import com.takku.project.domain.ImageDTO;
import com.takku.project.domain.OrderDTO;
import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.UserDTO;
import com.takku.project.service.FundingService;
import com.takku.project.service.ImageService;
import com.takku.project.service.OrderService;
import com.takku.project.service.StoreService;
import com.takku.project.service.UserService;

@Controller
@RequestMapping("/order")
public class OrderController {

	@Autowired
	private FundingService fundingService;

	@Autowired
	private OrderService orderService;

	@Autowired
	private StoreService storeService;

	@Autowired
	private UserService userService;

	@Autowired
	private ImageService imageService;

	@Value("${iamport.api.key}")
    private String iamportApiKey;



	// 주문 폼
	@GetMapping
	public String orderForm(@RequestParam int fundingId, @RequestParam int quantity, @RequestParam int totalPrice,
			Model model, @SessionAttribute(name = "loginUser", required = false) UserDTO loginUser) {
		FundingDTO funding = fundingService.selectFundingByFundingId(fundingId);
		StoreDTO store = storeService.selectStoreById(funding.getStoreId());
		if (loginUser == null) {
	        return "redirect:/auth/login";
	    }

		model.addAttribute("pageName", "결제하기");
		model.addAttribute("funding", funding);
		model.addAttribute("store", store);
		model.addAttribute("loginUser", loginUser);
		model.addAttribute("quantity", quantity);
		model.addAttribute("totalPrice", totalPrice);
		model.addAttribute("iamportApiKey", iamportApiKey);
		return "user.order";
	}

	// 주문 처리
    @PostMapping("/payment")
    public String processOrder(@RequestParam int fundingId, @RequestParam int quantity, @RequestParam int totalPrice,
            @RequestParam int usePoint, @RequestParam String imp_uid, @RequestParam String merchant_uid,
            RedirectAttributes redirectAttributes,
            @SessionAttribute(name = "loginUser", required = false) UserDTO loginUser) {
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        int finalPrice = totalPrice - usePoint;
        OrderDTO order = new OrderDTO();
        order.setUserId(loginUser.getUserId());
        order.setFundingId(fundingId);
        order.setQty(quantity);
        order.setAmount(totalPrice);
        order.setUsePoint(usePoint);
        order.setDiscountAmount(finalPrice);
        order.setStatus("결제완료");
        order.setFundingStatus("펀딩 진행중");
        order.setImpUid(imp_uid);
        order.setMerchantUid(merchant_uid);
        userService.updatePointAfterPayment(loginUser.getUserId(), usePoint);
        int result = orderService.insertOrder(order);
        if (result > 0) {
            fundingService.increaseCurrentQty(fundingId, quantity); // ✅ 펀딩 수량 증가
        }
        redirectAttributes.addAttribute("orderId", order.getOrderId());
        redirectAttributes.addAttribute("success", result > 0);
        return "redirect:payment/result";
    }

	// 주문 결과
	@GetMapping("/payment/result")
	public String paymentResult(@RequestParam int orderId, @RequestParam boolean success, Model model) {
		OrderDTO saveOrder = orderService.selectOrderByOrderId(orderId);
		FundingDTO funding = fundingService.selectFundingByFundingId(saveOrder.getFundingId());

		model.addAttribute("funding", funding);
		model.addAttribute("saveOrder", saveOrder);
		model.addAttribute("isSuccess", success);
		return "user.payment";
	}


	@GetMapping("/detail")
	@ResponseBody
	public Map<String, Object> getOrderDetail(@RequestParam("orderId") int orderId) {
		OrderDTO order = orderService.selectOrderByOrderId(orderId);
		String fundingName = orderService.getFundingNameByOrderId(orderId);

		Map<String, Object> result = new HashMap<>();
		result.put("orderId", orderId);
		result.put("fundingName", fundingName);
		result.put("qty", order.getQty());
		result.put("purchasedAt", order.getPurchasedAt());
		result.put("paymentMethod", order.getPaymentMethod());
		result.put("status", order.getStatus());

		return result;
	}

	@GetMapping("/list")
	public String getOrdersByStatus(@RequestParam String status, Model model, @SessionAttribute(name = "loginUser", required = false) UserDTO loginUser) {
		List<OrderDTO> orderList = new ArrayList<>();

		if ("allbuylist".equals(status)) {
			orderList = orderService.selectByUserId(loginUser.getUserId()); // 전체 조회
		} else if ("complete".equals(status)) {
			orderList = orderService.getOrdersByUserAndStatus(loginUser.getUserId(), "결제완료");
		} else if ("cancel".equals(status)) {
			orderList = orderService.getOrdersByUserAndStatus(loginUser.getUserId(), "환불");
		} else if ("null".equals(status)) {
			orderList = orderService.selectByUserId(loginUser.getUserId());
		}

		model.addAttribute("orderList", orderList);
		return "pages/user/mypage_orderList";
	}

	@PostMapping("/cancel")
	@ResponseBody
	public Map<String, Object> updateOrderFundingStatus(@RequestParam("orderId") Integer orderId) {
	    Map<String, Object> result = new HashMap<>();
	    OrderDTO order = orderService.selectOrderByOrderId(orderId);

	    if (order == null) {
	        result.put("success", false);
	        result.put("message", "해당 주문을 찾을 수 없습니다.");
	        return result;
	    }

	    int updateResult = orderService.updateOrderFundingStatus(orderId);
	    if (updateResult > 0) {
	        if (order.getUsePoint() > 0) {
	            userService.restorePointAfterCancel(order.getUserId(), order.getUsePoint());
	        }
	        fundingService.decreaseCurrentQty(order.getFundingId(), order.getQty());
	        result.put("success", true);
	        result.put("message", "주문이 성공적으로 취소되었습니다.");
	    } else {
	        result.put("success", false);
	        result.put("message", "주문 취소 처리 실패.");
	    }

	    return result;
	}

	//검색하기
	@PostMapping("/search")
	public ResponseEntity<List<OrderDTO>> searchOrders(@RequestBody Map<String, String> body,
	    @SessionAttribute("loginUser") UserDTO loginUser) {

	    String keyword = body.get("keyword");
	    int userId = loginUser.getUserId();

	    List<OrderDTO> list = orderService.searchOrders(userId, keyword);

		  for (OrderDTO order : list) {
			  List<ImageDTO> images = imageService.selectImagesByFundingId(order.getFundingId());
			  order.setImages(images);
		}

	    return ResponseEntity.ok(list);

}
}
