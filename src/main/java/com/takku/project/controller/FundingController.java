package com.takku.project.controller;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.takku.project.domain.FundingDTO;
import com.takku.project.domain.ImageDTO;
import com.takku.project.domain.ProductDTO;
import com.takku.project.domain.ReviewDTO;
import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.UserDTO;
import com.takku.project.service.FundingService;
import com.takku.project.service.ImageService;
import com.takku.project.service.ProductService;
import com.takku.project.service.ReviewService;
import com.takku.project.service.StoreService;
import com.takku.project.service.TagService;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;

@Api(tags = "펀딩 사용자 페이지 API")
@Controller
@RequestMapping("/fundings")
public class FundingController {

	@Autowired
	private FundingService fundingService;

	@Autowired
	private ProductService productService;

	@Autowired
	private ImageService imageService;

	@Autowired
	private StoreService storeService;

	@Autowired
	private ReviewService reviewService;

	@Autowired
	private TagService tagService;

	private List<String> splitKeywords(String keyword) {
		if (keyword == null || keyword.trim().isEmpty())
			return Collections.emptyList();
		return Arrays.stream(keyword.trim().split("\\s+")).filter(k -> !k.isBlank()).map(String::toLowerCase)
				.collect(Collectors.toList());
	}

	@GetMapping("/search/fragment")
	public String getSortedFundingFragment(
			@RequestParam(required = false) String status,
	        @RequestParam("sort") String sort,
	        @RequestParam(name = "page", defaultValue = "1") int page,
	        @RequestParam(name = "size", defaultValue = "8") int size,
	        Model model) {

		List<String> statusList = (status != null && !status.isBlank())
		        ? Collections.singletonList(status)
		        : Arrays.asList("진행중");
	    List<FundingDTO> list = fundingService.getFundingsByConditionWithPaging(
	        null, null, null, null, statusList, sort, page, size
	    );

	    for (FundingDTO funding : list) {
	        long days = ChronoUnit.DAYS.between(LocalDate.now(), funding.getEndDate().toLocalDate());
	        funding.setDaysLeft((int) Math.max(days, 0));
	    }

	    model.addAttribute("fundinglist", list);
	    return "common/fundingFragment";
	}


	@ApiOperation(value = "펀딩 검색 (페이징)", notes = "검색 조건에 따라 펀딩을 필터링하고 페이징된 목록을 조회합니다.")
	@GetMapping("/search")
	public String searchFundingWithPaging(@RequestParam(required = false) String keyword,
			@RequestParam(required = false) Integer categoryId, @RequestParam(required = false) String sido,
			@RequestParam(required = false) String sigungu, @RequestParam(required = false) String status, @RequestParam(defaultValue = "latest") String sort,
			@RequestParam(defaultValue = "1") int page, @RequestParam(defaultValue = "10") int size, Model model) {

		if (size <= 0)
			size = 10;

		List<String> keywordList = splitKeywords(keyword);
		List<String> statusList = (status != null && !status.isBlank())
		        ? Collections.singletonList(status)
		        : Arrays.asList("진행중");
		List<FundingDTO> fundingList = fundingService.getFundingsByConditionWithPaging(keywordList, categoryId, sido,
				sigungu, statusList, sort, page, size);

		for (FundingDTO funding : fundingList) {
			long days = ChronoUnit.DAYS.between(LocalDate.now(), funding.getEndDate().toLocalDate());
			funding.setDaysLeft((int) Math.max(days, 0));
		}

		int total = fundingService.getFundingCountByCondition(keywordList, categoryId, sido, sigungu, statusList);
		int totalPages = (int) Math.ceil((double) total / size);

		model.addAttribute("fundinglist", fundingList);
		model.addAttribute("currentPage", page);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("sort", sort);

		return "common/funding";
	}

	@ApiOperation(value = "펀딩 검색 (JSON 응답)", notes = "검색 조건에 따라 펀딩을 필터링하고 JSON 응답으로 반환합니다.")
	@GetMapping("/search/json")
	@ResponseBody
	public Map<String, Object> searchFundingJson(
	    @RequestParam(required = false) String keyword,
	    @RequestParam(required = false) Integer categoryId,
	    @RequestParam(required = false) String sido,
	    @RequestParam(required = false) String sigungu,
	    @RequestParam(required = false) String status,
	    @RequestParam(defaultValue = "latest") String sort,
	    @RequestParam(defaultValue = "1") int page,
	    @RequestParam(defaultValue = "10") int size
	) {
	    Map<String, Object> result = new HashMap<>();
	    try {
	        if (size <= 0) size = 10;

	        if (keyword != null) {
	            keyword = URLDecoder.decode(keyword, StandardCharsets.UTF_8);
	        }

	        List<String> keywordList = splitKeywords(keyword);
	        List<String> statusList = (status != null && !status.isBlank())
	                ? Collections.singletonList(status)
	                : Arrays.asList("진행중");

	        List<FundingDTO> fundingList = fundingService.getFundingsByConditionWithPaging(
	                keywordList, categoryId, sido, sigungu, statusList, sort, page, size
	        );

	        for (FundingDTO funding : fundingList) {
	            long days = ChronoUnit.DAYS.between(LocalDate.now(), funding.getEndDate().toLocalDate());
	            funding.setDaysLeft((int) Math.max(days, 0));
	        }

	        int total = fundingService.getFundingCountByCondition(
	                keywordList, categoryId, sido, sigungu, statusList
	        );
	        int totalPages = (int) Math.ceil((double) total / size);

	        result.put("fundinglist", fundingList);
	        result.put("currentPage", page);
	        result.put("totalPages", totalPages);
	        result.put("sort", sort);

	    } catch (Exception e) {
	        e.printStackTrace();
	        result.clear();
	        result.put("error", "서버 오류: " + e.getMessage());
	    }

	    return result;
	}


	@ApiOperation(value = "펀딩 전체 목록 조회", notes = "기본 조건으로 펀딩 목록을 조회합니다.")
	@GetMapping
	public String getFundings(@RequestParam(required = false) String keyword,
			@RequestParam(required = false) Integer categoryId, @RequestParam(required = false) String sido,
			@RequestParam(required = false) String sigungu, @RequestParam(required = false) String status, @RequestParam(defaultValue = "1") int page,
			@RequestParam(defaultValue = "10") int size, Model model) {

		List<String> keywordList = splitKeywords(keyword);
		List<String> statusList = (status != null && !status.isBlank())
		        ? Collections.singletonList(status)
		        : Arrays.asList("진행중");
		List<FundingDTO> fundingList = fundingService.getFundingsByConditionWithPaging(
				keywordList, categoryId, sido, sigungu, statusList, "latest", page, size);

		int total = fundingService.getFundingCountByCondition(keywordList, categoryId, sido, sigungu, statusList);
		int totalPages = (int) Math.ceil((double) total / size);

		model.addAttribute("fundinglist", fundingList);
		model.addAttribute("currentPage", page);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("sort", "latest");

		return "user.home";
	}

	@ApiOperation(value = "펀딩 상세 조회", notes = "특정 펀딩의 상세 정보를 조회합니다.")
	@GetMapping("/{fundingId}")
	public String getFundingDetail(@PathVariable("fundingId") int fundingId, Model model) {
		FundingDTO funding = fundingService.selectFundingByFundingId(fundingId);
		if (funding == null)
			return "error/error";

		ProductDTO product = productService.selectByProductId(funding.getProductId());
		List<ImageDTO> productImages = imageService.selectImagesByProductId(funding.getProductId());
		StoreDTO store = storeService.selectStoreById(funding.getStoreId());
		List<ReviewDTO> reviewlist = reviewService.reviewByProductId(funding.getProductId());
		for (ReviewDTO review : reviewlist) {
			List<ImageDTO> imageList = imageService.selectImagesByReviewId(review.getReviewId());
			review.setImages(imageList);
		}
		List<String> taglist = tagService.selectTagNamesByFundingId(fundingId);
		double avgRating = reviewlist.stream().mapToInt(ReviewDTO::getRating).average().orElse(0.0);
		int reviewCount = reviewlist.size();

		model.addAttribute("funding", funding);
		model.addAttribute("store", store);
		model.addAttribute("product", product);
		model.addAttribute("productImages", productImages);
		model.addAttribute("reviewlist", reviewlist);
		model.addAttribute("avgRating", avgRating);
		model.addAttribute("reviewCount", reviewCount);
		model.addAttribute("taglist", taglist);

		return "user.funding_detail";
	}

	public String getFundingDetail(@PathVariable("fundingId") int fundingId, @RequestParam(defaultValue = "1") int page,
			@RequestParam(defaultValue = "10") int size, Model model) {
		FundingDTO funding = fundingService.selectFundingByFundingId(fundingId);
		if (funding == null)
			return "error/error";

		ProductDTO product = productService.selectByProductId(funding.getProductId());
		List<ImageDTO> productImages = imageService.selectImagesByProductId(funding.getProductId());
		StoreDTO store = storeService.selectStoreById(funding.getStoreId());
		List<String> taglist = tagService.selectTagNamesByFundingId(fundingId);

		int totalReviews = reviewService.countByProductId(funding.getProductId());
		int totalPages = (int) Math.ceil((double) totalReviews / size);

		List<ReviewDTO> reviewlist = reviewService.reviewByProductIdWithPaging(funding.getProductId(), page, size);
		double avgRating = reviewlist.stream().mapToInt(ReviewDTO::getRating).average().orElse(0.0);

		model.addAttribute("funding", funding);
		model.addAttribute("store", store);
		model.addAttribute("product", product);
		model.addAttribute("productImages", productImages);
		model.addAttribute("reviewlist", reviewlist);
		model.addAttribute("avgRating", avgRating);
		model.addAttribute("reviewCount", totalReviews);
		model.addAttribute("taglist", taglist);
		model.addAttribute("currentPage", page);
		model.addAttribute("totalPages", totalPages);

		return "user.funding_detail";
	}

	// 리뷰 페이지 처리
	@GetMapping("/{fundingId}/reviews")
	@ResponseBody
	public Map<String, Object> getReviews(@PathVariable("fundingId") int fundingId,
			@RequestParam(defaultValue = "1") int page, @RequestParam(defaultValue = "10") int size) {

		FundingDTO funding = fundingService.selectFundingByFundingId(fundingId);
		if (funding == null) {
			return Map.of("error", "존재하지 않는 펀딩입니다.");
		}

		int totalReviews = reviewService.countByProductId(funding.getProductId());
		int totalPages = (int) Math.ceil((double) totalReviews / size);
		List<ReviewDTO> reviewList = reviewService.reviewByProductIdWithPaging(funding.getProductId(), page, size);

		return Map.of("reviewlist", reviewList, "totalPages", totalPages, "currentPage", page);

	}

	// 기존 - 전체리스트
	@GetMapping("/list")
	public String selectFundingListByStatus(@RequestParam("status") String status, Model model,HttpSession session) {
		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");


		if ("allfundinglist".equals(status)) {
			status = null; // 전체 조회 - 조건에서 status 제외
		} else if ("progressing".equals(status)) {
			status = "진행중";
		} else if ("achieved".equals(status)) {
			status = "성공";
		} else if ("failed".equals(status)) {
			status = "실패";
		}

		List<FundingDTO> fundingList = fundingService.selectFundingListByStatus(loginUser.getUserId(), status);
		model.addAttribute("fundingList", fundingList);

		return "pages/user/myPage_fundingList";
	}

	// 시작일, 종료일 보여주기

	@PostMapping("/showDates")
	public String showDates(@RequestParam("startDate") @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
			@RequestParam("endDate") @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate, Model model) {

		model.addAttribute("startDate", startDate);
		model.addAttribute("endDate", endDate);

		return "pages/seller/create_insertDetail"; // 다시 step2.jsp 렌더링
	}

}
