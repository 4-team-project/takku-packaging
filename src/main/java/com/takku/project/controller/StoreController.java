package com.takku.project.controller;

import java.io.IOException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.websocket.server.PathParam;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.SessionAttributes;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.takku.project.domain.FundingDTO;
import com.takku.project.domain.ImageDTO;
import com.takku.project.domain.ProductDTO;
import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.UserDTO;
import com.takku.project.service.FundingService;
import com.takku.project.service.ImageService;
import com.takku.project.service.ProductService;
import com.takku.project.service.StoreService;
import com.takku.project.service.StoreStatsService;
import com.takku.project.service.UserService;

import io.swagger.annotations.Api;

@Api(tags = "상점 관련 API")
@Controller
@RequestMapping("/seller/store")
@SessionAttributes({ "tempFunding", "currentProcessingUserId" })
public class StoreController {

	@Autowired
	private StoreService storeService;

	@Autowired
	private UserService userService;

	@Autowired
	private FundingService fundingService;

	@Autowired
	private ProductService productService;

	@Autowired
	private StoreStatsService storeStatsService;

	@Autowired
	private ImageService imageService;

	@PostMapping("/changeStore")
	@ResponseBody
	public String changeStore(@RequestBody Map<String, Integer> data, HttpSession session) {
		Integer storeId = data.get("storeId");
		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

		if (storeId != null && loginUser != null) {
			StoreDTO selectedStore = storeService.selectStoreById(storeId);

			if (selectedStore != null && selectedStore.getUserId().equals(loginUser.getUserId())) {
				session.setAttribute("currentStore", selectedStore);
				session.setAttribute("store", selectedStore);
				return "상점이 변경되었습니다.";
			} else {
				return "상점 권한이 없습니다.";
			}
		}
		return "상점 변경 실패";
	}

	@GetMapping()
	public String showStoreManagement(HttpSession session, Model model) {
		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

		StoreDTO currentStore = (StoreDTO) session.getAttribute("currentStore");

		if (currentStore != null) {
			int storeId = currentStore.getStoreId();

			List<ProductDTO> productDTOList = productService.selectProductByStoreId(storeId);
			for (ProductDTO product : productDTOList) {
				List<ImageDTO> imageList = imageService.selectImagesByProductId(product.getProductId());
				product.setImages(imageList);
			}
			model.addAttribute("productDTO", productDTOList);
		} else {
			model.addAttribute("message", "등록된 상점이 없습니다.");
		}

		model.addAttribute("userDTO", loginUser);
		return "seller.storeManagement";
	}

	@GetMapping("/new")
	public String showStoreForm() {
		return "seller.store";
	}

	// 상점 등록 처리
	@PostMapping(value = "/insert", consumes = "application/json")
	@ResponseBody
	public ResponseEntity<String> insertStoreJson(HttpSession session, @RequestBody StoreDTO storeDTO) {
		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

		if (loginUser == null) {
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("로그인이 필요합니다.");
		}

		storeDTO.setUserId(loginUser.getUserId());
		int result = storeService.insertStore(storeDTO);

		if (result > 0) {
			List<StoreDTO> updatedList = storeService.selectStoreListByUserId(loginUser.getUserId());
			session.setAttribute("storeList", updatedList);
			return ResponseEntity.ok(String.valueOf(storeDTO.getStoreId()));
		} else {
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("상점 등록 실패");
		}
	}

	// 상점 수정 폼
	@GetMapping("/edit/{storeId}")
	public String showEditForm(@PathVariable("storeId") Integer storeId, Model model) {
		StoreDTO store = storeService.selectStoreById(storeId);
		model.addAttribute("storeDTO", store);
		return "seller.store";
	}

	// storeId로 상점 정보 조회
	@GetMapping(value = "/info/{storeId}", produces = "application/json")
	@ResponseBody
	public StoreDTO getStoreinfoByStoreId(@PathVariable int storeId, HttpServletRequest request) {
		StoreDTO store = storeService.selectStoreById(storeId);
		return store;
	}

	// 상점 수정 처리
	@PostMapping("/update/{storeId}")
	@ResponseBody
	public ResponseEntity<String> updateStore(HttpSession session, @PathVariable("storeId") Integer storeId,
			@RequestBody StoreDTO storeDTO) {
		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
		storeDTO.setStoreId(storeId);
		storeDTO.setUserId(loginUser.getUserId());

		int result = storeService.updateStore(storeDTO);

		if (result > 0) {

			List<StoreDTO> updatedList = storeService.selectStoreListByUserId(loginUser.getUserId());
			session.setAttribute("storeList", updatedList);

			StoreDTO currentStore = (StoreDTO) session.getAttribute("currentStore");
			if (currentStore != null && currentStore.getStoreId().equals(storeId)) {
				StoreDTO updatedStore = storeService.selectStoreById(storeId);
				session.setAttribute("currentStore", updatedStore);
			}

			return ResponseEntity.ok(String.valueOf(storeId));
		} else {
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("상점 수정 실패");
		}
	}

	// 상점 삭제 처리
	@PostMapping("/delete/{storeId}")
	@ResponseBody
	public String deleteStore(@PathVariable("storeId") Integer storeId, HttpSession session) {
		if (storeId == null)
			return "삭제 실패 (ID 없음)";

		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
		if (loginUser == null)
			return "삭제 실패 (로그인 필요)";

		try {
			int result = storeService.deleteStore(storeId);

			if (result > 0) {
				List<StoreDTO> updatedList = storeService.selectStoreListByUserId(loginUser.getUserId());
				session.setAttribute("storeList", updatedList);

				StoreDTO currentStore = (StoreDTO) session.getAttribute("currentStore");
				if (currentStore != null && currentStore.getStoreId().equals(storeId)) {
					if (!updatedList.isEmpty()) {
						session.setAttribute("currentStore", updatedList.get(0));
					} else {
						session.removeAttribute("currentStore");
					}
				}

				return "삭제 성공";
			} else {
				return "삭제 실패 (DB 처리 실패)";
			}
		} catch (Exception e) {
			e.printStackTrace();
			return "삭제 실패 (서버 오류)";
		}
	}

	// 상점 목록 보기
	@GetMapping("/storeList")
	public String showStoreList(HttpSession session, Model model) {
		UserDTO userDTO = (UserDTO) session.getAttribute("loginUser");
		model.addAttribute("userDTO", userDTO);
		return "seller.storeList";
	}

	@GetMapping("/list/byUserId")
	@ResponseBody
	public Map<String, Object> getPagedStoreList(@RequestParam(defaultValue = "1") int page, HttpSession session) {
		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
		int userId = loginUser.getUserId();
		int pageSize = 5;

		List<StoreDTO> allStores = storeService.selectStoreListByUserId(userId);
		applyCategoryNames(allStores);

		List<Map<String, Object>> ratingList = storeService.getAverageRatingByUserId(userId);
		Map<Integer, Double> ratingMap = new HashMap<>();
		for (Map<String, Object> rating : ratingList) {
			Integer storeId = ((Number) rating.get("STOREID")).intValue();
			Object ratingObj = rating.get("AVERAGERATING");
			Double avgRating = (ratingObj != null) ? ((Number) ratingObj).doubleValue() : 0.0;
			ratingMap.put(storeId, avgRating);
		}

		int total = allStores.size();
		int totalPages = (int) Math.ceil((double) total / pageSize);

		int fromIndex = (page - 1) * pageSize;
		int toIndex = Math.min(fromIndex + pageSize, total);
		List<StoreDTO> pagedStores = allStores.subList(fromIndex, toIndex);

		Map<String, Object> result = new HashMap<>();
		result.put("storelist", pagedStores);
		result.put("currentPage", page);
		result.put("totalPages", totalPages);
		result.put("ratingMap", ratingMap);
		return result;
	}

	// 카테고리 ID로 카테고리 이름 추출
	private void applyCategoryNames(List<StoreDTO> stores) {
		Map<Integer, String> categoryMap = Map.of(0, "전체", 1, "한식", 2, "분식", 3, "중식", 4, "일식", 5, "양식", 6, "아시안", 7,
				"패스트푸드", 8, "카페&디저트", 9, "도시락");

		for (StoreDTO store : stores) {
			String categoryName = categoryMap.getOrDefault(store.getCategoryId(), "기타");
			store.setCategoryName(categoryName);
		}
	}

	// 펀딩 상세 정보 세션
	@ModelAttribute("tempFunding")
	public FundingDTO createTempFunding() {
		return new FundingDTO();
	}

	// 유저 id (로그인 세션으로 받을 듯?)
	@ModelAttribute("currentProcessingUserId")
	public Integer createCurrentProcessingUserId(HttpSession session) {
		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

		return loginUser.getUserId();
	}

	// 상점 펀딩 현황 (초기 페이지 로드 시)
	@GetMapping("/list")
	public String findFundingByStoreId(HttpSession session, Model model) {
		UserDTO user = (UserDTO) session.getAttribute("loginUser");
		StoreDTO currentStore = (StoreDTO) session.getAttribute("currentStore");
		List<StoreDTO> userStore = storeService.selectStoreListByUserId(user.getUserId());
		List<FundingDTO> funding = Collections.emptyList();
		if (currentStore == null && userStore != null && !userStore.isEmpty()) {
			currentStore = userStore.get(0);
			// 두 키 모두 설정
			session.setAttribute("currentStore", currentStore);
			session.setAttribute("store", currentStore);
		}
		if (currentStore != null) {
			funding = fundingService.selectFudingListByStoreId(currentStore.getStoreId());
		} else {
			model.addAttribute("message", "등록된 상점이 없습니다. 새로운 상점을 등록해주세요.");
		}
		model.addAttribute("userStores", userStore);
		model.addAttribute("store", currentStore);
		model.addAttribute("funding", funding);
		model.addAttribute("userId", user.getUserId());
		model.addAttribute("user", user);
		return "seller/list";
	}

	// store 리스트 반환 (AJAX 호출용)
	@GetMapping("/stores/byUser")
	@ResponseBody // JSON 형태로 응답하도록 지정
	public List<StoreDTO> getStoresByUser(@RequestParam int userId) { // @Param 대신 @RequestParam 사용 권장
		return storeService.selectStoreListByUserId(userId);
	}

	// Store에 속한 펀딩 리스트 반환 (AJAX 호출용)
	@GetMapping("/fundings/byStore")
	@ResponseBody // JSON 형태로 응답하도록 지정
	public List<FundingDTO> getFundingsByStore(@RequestParam int storeId) {
		return fundingService.selectFudingListByStoreId(storeId);
	}

	// 사용자 펀딩 현황
	@GetMapping("/funding/stats")
	public String showFundingStats(@RequestParam("fundingId") Integer fundingId, Model model) {
		FundingDTO funding = fundingService.selectFundingByFundingId(fundingId);
		StoreDTO ownerStore = storeService.selectStoreById(funding.getStoreId());
		Integer fundingUserId = ownerStore.getUserId();

		// KST(한국 표준시) 시간대 설정
		ZoneId koreaZoneId = ZoneId.of("Asia/Seoul");

		// 오늘 날짜를 KST 기준으로 LocalDate로 변환 (시간 정보 없음)
		LocalDate todayLocalDate = LocalDate.now(koreaZoneId);

		Long remainingDays = null; // 남은 일수 (long 타입으로 초기화)
		Long totalDays = null; // 총 펀딩 일수 (long 타입으로 초기화)
		String fundingStatusMessage = "종료일 정보가 없습니다.";

		// 펀딩 종료일이 존재하는 경우
		if (funding.getEndDate() != null) {
			// funding.getEndDate() (java.util.Date 또는 java.sql.Date)를 LocalDate로 변환
			// KST를 기준으로 변환하여 정확성 확보
			LocalDate endDateLocalDate = Instant.ofEpochMilli(funding.getEndDate().getTime()).atZone(koreaZoneId)
					.toLocalDate();

			// 남은 일수 계산: 오늘부터 종료일까지의 일수
			// ChronoUnit.DAYS.between(start, end)는 start를 포함하지 않고 end까지의 일수 차이를 반환
			remainingDays = ChronoUnit.DAYS.between(todayLocalDate, endDateLocalDate);

			if (remainingDays > 0) {
				fundingStatusMessage = "펀딩 종료까지 " + remainingDays + "일 남았습니다.";
			} else if (remainingDays == 0) {
				fundingStatusMessage = "펀딩이 오늘 종료됩니다!";
			} else { // remainingDays < 0 (종료일이 이미 지남)
				// Math.abs(remainingDays)를 사용하여 '몇 일 전'인지 양수로 표시
				fundingStatusMessage = "펀딩이 이미 종료되었습니다. (" + Math.abs(remainingDays) + "일 전)";
			}
		}

		// 총 펀딩 일수 계산 (시작일이 존재하는 경우에만)
		if (funding.getStartDate() != null && funding.getEndDate() != null) {
			LocalDate startDateLocalDate = Instant.ofEpochMilli(funding.getStartDate().getTime()).atZone(koreaZoneId)
					.toLocalDate();
			LocalDate endDateLocalDate = Instant.ofEpochMilli(funding.getEndDate().getTime()).atZone(koreaZoneId)
					.toLocalDate();

			// 시작일과 종료일 모두 포함하는 일수 계산 (예: 1월 1일 ~ 1월 1일 = 1일)
			totalDays = ChronoUnit.DAYS.between(startDateLocalDate, endDateLocalDate) + 1;
		}

		model.addAttribute("remainingDays", remainingDays);
		model.addAttribute("fundingStatusMessage", fundingStatusMessage);
		model.addAttribute("totalDays", totalDays); // 모든 경우에 totalDays를 모델에 추가

		int totalSalesQuantity = funding.getCurrentQty(); // 현재 펀딩 판매 수량
		double salePrice = funding.getSalePrice(); // 펀딩 판매 금액

		// 일 평균 펀딩 금액 계산 (추가)
		double averageDailyFundingAmount = 0.0;
		if (totalDays != null && totalDays > 0) {
			averageDailyFundingAmount = (double) totalSalesQuantity * salePrice / totalDays;
		}
		model.addAttribute("averageDailyFundingAmount", averageDailyFundingAmount);

		int todayFundingAmount = storeStatsService.getTodayFundingAmount(fundingId);
		int completeOrders = storeStatsService.getFundingCompleteOrderCount(fundingId);
		int refundOrders = storeStatsService.getFundingRefundOrderCount(fundingId);

		model.addAttribute("userId", fundingUserId);
		model.addAttribute("fundingId", fundingId);
		model.addAttribute("todayFundingAmount", todayFundingAmount);
		model.addAttribute("completeOrders", completeOrders);
		model.addAttribute("refundOrders", refundOrders);
		model.addAttribute("fundingGenderStats", storeStatsService.getFundingGenderRatio(fundingId));
		model.addAttribute("fundingAgeStats", storeStatsService.getFundingAgeDistribution(fundingId));

		model.addAttribute("funding", funding);
		model.addAttribute("today", new java.util.Date()); // java.util.Date를 import했다면 문제 없음

		return "seller/sellerFundingStats";
	}

	// 사용자 펀딩 상세보기
	@GetMapping("/detail")
	public String showFundingDetail(@RequestParam("fundingId") Integer fundingId, Model model) {
		FundingDTO funding = fundingService.selectFundingByFundingId(fundingId);
		ProductDTO product = productService.selectByProductId(funding.getProductId());
		StoreDTO ownerStore = storeService.selectStoreById(funding.getStoreId());
		Integer fundingUserId = ownerStore.getUserId();
		boolean isEditable = "준비중".equals(funding.getStatus());

		model.addAttribute("isEditable", isEditable);
		model.addAttribute("funding", funding);
		model.addAttribute("product", product);
		model.addAttribute("userId", fundingUserId);

		return "seller/detail";
	}

	// 펀딩 수정 시작
	@GetMapping("/funding/edit/{fundingId}")
	public String startFundingEdit(@PathVariable Integer fundingId, Model model) {
		FundingDTO fundingToEdit = fundingService.selectFundingByFundingId(fundingId);
		// DB에서 가져온 펀딩 객체를 "tempFunding" 이라는 이름으로 모델에 추가
		// @SessionAttributes("tempFunding") 설정 덕분에 이 객체가 세션에 저장됩니다.
		model.addAttribute("tempFunding", fundingToEdit);
		StoreDTO ownerStore = storeService.selectStoreById(fundingToEdit.getStoreId());
		Integer fundingUserId = ownerStore.getUserId();
		model.addAttribute("currentProcessingUserId", fundingUserId);

		// 첫 번째 수정 폼 페이지로 리다이렉트
		return "forward:/seller/store/edit/step1";
	}

	// 1단계 폼 페이지 요청
	@GetMapping("/edit/step1")
	public String showCreateFundingStep1(@ModelAttribute("tempFunding") FundingDTO tempFunding,
			@ModelAttribute("currentProcessingUserId") Integer userId, Model model, HttpSession session) {

		ProductDTO productDTO = productService.selectByProductId(tempFunding.getProductId());
		model.addAttribute("product", productDTO);

		return "seller/fundingFormStep1";
	}

	// 1단계 데이터 제출 및 세션 저장
	@PostMapping(value = "/edit/step1", consumes = "application/json")
	public String processCreateFundingStep1(@RequestBody FundingDTO funding, HttpSession session, // 세션 직접 접근하여 파일 URL
																									// 저장
			Model model, @ModelAttribute("currentProcessingUserId") Integer userId,
			@ModelAttribute("tempFunding") FundingDTO sessionFunding) {

		// 펀딩 기본 정보 세팅
		sessionFunding.setFundingName(funding.getFundingName());
		sessionFunding.setFundingDesc(funding.getFundingDesc());
		sessionFunding.setProductId(funding.getProductId());
		sessionFunding.setFundingId(funding.getFundingId());

		// 이미지 URL 리스트 복사
		List<ImageDTO> processedImages = new ArrayList<>();
		if (funding.getImages() != null) {
			for (ImageDTO img : funding.getImages()) {
				String fileName = img.getImageUrl(); // UUID.jpg 형식 그대로
				if (fileName != null && fileName.contains(".")) {
					ImageDTO imageDTO = ImageDTO.builder().imageUrl(fileName).build();
					processedImages.add(imageDTO);
				}
			}
		}
		sessionFunding.setImages(processedImages);

		// 세션 업데이트
		model.addAttribute("tempFunding", sessionFunding);

		return "redirect:/seller/store/edit/step2";
	}

	// 2단계 폼 페이지 요청
	@GetMapping("/edit/step2")
	public String showCreateFundingStep2(@ModelAttribute("tempFunding") FundingDTO funding, Model model) {
		// 1단계에서 저장된 funding 객체가 Model에 자동으로 주입됩니다.
		// 여기서 isEditable 등 추가적인 모델 속성을 필요에 따라 설정할 수 있습니다.

		ProductDTO product = productService.selectByProductId(funding.getProductId());
		model.addAttribute("product", product);

		return "seller/fundingFormStep2";
	}

	// 2단계 데이터 제출 및 최종 저장
	@PostMapping("/edit/step2")
	public String processCreateFundingStep2(@ModelAttribute("tempFunding") FundingDTO funding,
			@ModelAttribute("currentProcessingUserId") Integer userId, HttpSession session,
			SessionStatus sessionStatus) {

		// 세션에서 이미지 무조건 복원 (images가 null이거나 비어있든 관계없이)
		FundingDTO sessionFunding = (FundingDTO) session.getAttribute("tempFunding");
		if (sessionFunding != null && sessionFunding.getImages() != null && !sessionFunding.getImages().isEmpty()) {
			funding.setImages(sessionFunding.getImages());
		}

		System.out.println("최종 이미지 리스트: " + funding.getImages());
		if (funding.getImages() != null) {
			for (ImageDTO img : funding.getImages()) {
				try {
					String imageUrl = img.getImageUrl();

					// 상품 이미지 그대로 사용하는 경우 (이미 서버에 존재하는 이미지)
					if (imageUrl != null && imageUrl.startsWith("/image/") || imageUrl.startsWith("http")) {
						// 그대로 저장 (파일 이동 없이 DB만 insert)
						img.setFundingId(funding.getFundingId());
						System.out.println("이미지 가져오기 : " + img.getImageUrl());
						imageService.insertImageUrl(img);

					} else {
						// 임시 이미지인 경우: 서버 이동 + URL 업데이트
						String newFileName = imageService.moveImageFromTemp(imageUrl); // UUID.jpg 형태
						img.setFundingId(funding.getFundingId());
						img.setImageUrl(newFileName);
						System.out.println("이미지 가져오기 : " + funding.getFundingId());
						imageService.insertImageUrl(img);
					}

				} catch (IOException e) {
					e.printStackTrace(); // 실패해도 다른 이미지 계속 처리
				}
			}
		}
		fundingService.updateFunding(funding);

		sessionStatus.setComplete(); // 세션에 저장된 "tempFunding" 객체를 비웁니다.
		return "redirect:/seller/store/list?userId=" + userId; // 최종 펀딩 목록으로 리다이렉트
	}

}