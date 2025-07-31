package com.takku.project.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.takku.project.domain.FundingDTO;
import com.takku.project.domain.ImageDTO;
import com.takku.project.domain.ProductDTO;
import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.TagDTO;
import com.takku.project.domain.UserDTO;
import com.takku.project.service.AIService;
import com.takku.project.service.FundingService;
import com.takku.project.service.ImageService;
import com.takku.project.service.ProductService;
import com.takku.project.service.StoreService;
import com.takku.project.service.TagService;

@Controller
@RequestMapping("/seller/fundings")
public class FundingManagementController {

	@Autowired
	FundingService fundingService;
	@Autowired
	StoreService storeService;
	@Autowired
	ProductService productService;
	@Autowired
	ImageService imageService;
	@Autowired
	TagService tagService;
	@Autowired
	AIService aiService;

	@GetMapping("/create-step1")
	public String selectStoreNameByUserId(Model model, HttpSession session) {
		StoreDTO store = (StoreDTO) session.getAttribute("store");

		model.addAttribute("storeDTO", store);

		FundingDTO funding = new FundingDTO();
		funding.setStoreId(store.getStoreId());

		session.setAttribute("funding", funding);
		session.removeAttribute("aiRetryCount");

		return "seller.createFunding";
	}

	@GetMapping("/create-step2")
	public String createStep2(@RequestParam("type") String type, Model model, HttpSession session) {
		StoreDTO store = (StoreDTO) session.getAttribute("store");
		FundingDTO funding = (FundingDTO) session.getAttribute("funding");

		if (store == null || funding == null) {
			return "redirect:/seller/fundings/create-step1";
		}

		model.addAttribute("storeDTO", store);

		if ("general".equals(type)) {
			funding.setFundingType("일반");
			session.setAttribute("funding", funding);
			session.setAttribute("fundingType", "general");
			return "seller.normalFunding";
		} else if ("limited".equals(type)) {
			funding.setFundingType("한정");
			session.setAttribute("funding", funding);
			session.setAttribute("fundingType", "limited");
			return "seller.existMenu";
		}
		return "seller.createFunding";
	}

	@PostMapping("/create-step3")
	public String insertFundingMenuDetail(@ModelAttribute FundingDTO fundingInput, HttpSession session, Model model) {
		FundingDTO funding = (FundingDTO) session.getAttribute("funding");
		StoreDTO store = (StoreDTO) session.getAttribute("store");

		model.addAttribute("storeDTO", store);

		funding.setProductId(fundingInput.getProductId());
		funding.setSalePrice(fundingInput.getSalePrice());

		if ("한정".equals(funding.getFundingType())) {
			funding.setTargetQty(0);
		} else {
			funding.setTargetQty(fundingInput.getTargetQty());
		}
		funding.setMaxQty(fundingInput.getMaxQty());
		funding.setPerQty(fundingInput.getPerQty());

		ProductDTO product = productService.selectByProductId(funding.getProductId());
		model.addAttribute("productDTO", product);
		session.setAttribute("funding", funding);

		return "seller.insertDetail";
	}

	@PostMapping(value = "/create-step4", consumes = "application/json")
	public String handleFundingDateAndImages(@RequestBody FundingDTO fundingInput, HttpSession session, Model model) {
		try {
			StoreDTO store = (StoreDTO) session.getAttribute("store");
			FundingDTO funding = (FundingDTO) session.getAttribute("funding");

			if (store == null || funding == null) {
				return "redirect:/seller/fundings/create-step1";
			}

			funding.setStartDate(fundingInput.getStartDate());
			funding.setEndDate(fundingInput.getEndDate());

			List<ImageDTO> processedImages = new ArrayList<>();
			if (fundingInput.getImages() != null) {
				for (ImageDTO img : fundingInput.getImages()) {
					String fileName = img.getImageUrl();
					if (fileName != null && fileName.contains(".")) {
						processedImages.add(
							ImageDTO.builder()
								.imageId(img.getImageId())
								.imageUrl(fileName)
								.build()
						);
					}
				}
			}

			System.out.println("✔️ 이미지 목록 확인");
			if (fundingInput.getImages() != null) {
				for (ImageDTO img : fundingInput.getImages()) {
					System.out.println("🖼️ imageId: " + img.getImageId() + ", imageUrl: " + img.getImageUrl());
				}
			}

			funding.setImages(processedImages);

			Date today = new Date();
			funding.setStatus(funding.getStartDate().after(today) ? "준비중" : "진행중");

			session.setAttribute("funding", funding);
			funding.setMainImageUrl(fundingInput.getMainImageUrl());

			ProductDTO product = productService.selectByProductId(funding.getProductId());

			model.addAttribute("storeDTO", store);
			model.addAttribute("product", product);

			return "seller.selectWriteType";

		} catch (Exception e) {
			e.printStackTrace();
			return "redirect:/seller/fundings/create-step1";
		}
	}

	@GetMapping("/create-step5")
	public String redirectWriteTypePage(HttpSession session, Model model) {
		FundingDTO funding = (FundingDTO) session.getAttribute("funding");
		ProductDTO product = productService.selectByProductId(funding.getProductId());
		model.addAttribute("product", product);
		return "seller.selectWriteType";
	}

	@PostMapping("/create-step5")
	public String writeType(@RequestParam("type") String type, HttpSession session) {
		if ("ai".equals(type)) {
			session.setAttribute("aiRetryCount", 0);
			return "redirect:/seller/fundings/ai-form";
		} else if ("directly".equals(type)) {
			return "redirect:/seller/fundings/direct-form";
		}
		return "redirect:/seller/fundings/selectWriteType";
	}

	@GetMapping("/ai-form")
	public String showAiForm(HttpSession session, Model model) {
		FundingDTO funding = (FundingDTO) session.getAttribute("funding");
		ProductDTO product = productService.selectByProductId(funding.getProductId());
		Integer retryCount = (Integer) session.getAttribute("aiRetryCount");
		model.addAttribute("product", product);
		model.addAttribute("aiRetryCount", retryCount == null ? 0 : retryCount);
		return "seller.aiInsertForm";
	}

	@GetMapping("/direct-form")
	public String showDirectInputForm(HttpSession session, Model model) {
		FundingDTO funding = (FundingDTO) session.getAttribute("funding");
		ProductDTO product = productService.selectByProductId(funding.getProductId());
		model.addAttribute("product", product);
		return "seller.directInsert";
	}

	@PostMapping("/submit-funding")
	public String handleFundingBasicInfo(@ModelAttribute FundingDTO fundingInput,
			@RequestParam("keywords") String keywords, HttpSession session) {

		FundingDTO funding = (FundingDTO) session.getAttribute("funding");
		if (funding == null)
			return "redirect:/seller/fundings/create-step1";

		funding.setFundingName(fundingInput.getFundingName());
		funding.setFundingDesc(fundingInput.getFundingDesc());

		// 펀딩 등록 (fundingId 생성)
		fundingService.insertFunding(funding);

		int fundingId = funding.getFundingId();
		System.out.println("🔥 펀딩 ID 확인: " + fundingId);

		if (funding.getImages() != null) {
		    for (ImageDTO img : funding.getImages()) {
		        try {
		            String imageUrl = img.getImageUrl();
		            System.out.println("📷 이미지 ID: " + img.getImageId());
		            System.out.println("🖼️ 이미지 URL: " + imageUrl);

		            if (img.getImageId() != null) {
		                // ✅ 기존 이미지일 경우: fundingId만 update
		                imageService.updateFundingIdByImageId(img.getImageId(), fundingId);
		            } else if (imageUrl != null) {
		                img.setFundingId(fundingId);

		                // ✅ 새 이미지이고 /image/tmp/ 경로인 경우 이동 처리
		                if (imageUrl.startsWith("/image/tmp/")) {
		                    String fileName = imageUrl.substring("/image/tmp/".length());
		                    String newFileName = imageService.moveImageFromTemp(fileName);

		                    // prefix 붙이기
		                    if (!newFileName.startsWith("/image/")) {
		                        newFileName = "/image/" + newFileName;
		                    }

		                    img.setImageUrl(newFileName);
		                    imageService.insertImageUrl(img);
		                }
		                // ✅ 새 이미지인데 경로가 이미 /image/인 경우 그대로 insert
		                else if (imageUrl.startsWith("/image/")) {
		                    imageService.insertImageUrl(img);
		                }
		                // 🔴 잘못된 경로인 경우 로그만 출력
		                else {
		                    System.err.println("🚫 잘못된 이미지 URL 형식: " + imageUrl);
		                }
		            }

		        } catch (IOException e) {
		            e.printStackTrace();
		        }
		    }
		}

		// 태그 처리
		for (String tagName : extractTags(keywords)) {
			Integer tagId = tagService.getTagIdByName(tagName);
			if (tagId == null) {
				TagDTO tag = new TagDTO();
				tag.setTagName(tagName);
				tagService.insertTag(tag);
				tagId = tag.getTagId();
			}
			tagService.insertFundingTag(fundingId, tagId);
		}

		return "redirect:/seller/fundings/complete";
	}

	@GetMapping("/complete")
	public String fundingComplete(HttpSession session, Model model) {
		FundingDTO funding = (FundingDTO) session.getAttribute("funding");
		if (funding == null)
			return "redirect:/seller/fundings/create-step1";

		model.addAttribute("fundingName", funding.getFundingName());
		model.addAttribute("startDate", funding.getStartDate());
		model.addAttribute("fundingId", funding.getFundingId());

		session.removeAttribute("funding");
		session.removeAttribute("aiRetryCount");

		return "seller.result";
	}

	@GetMapping
	public String sellerFundings(@ModelAttribute("loginUser") UserDTO loginUser, Model model) {
		Integer storeId = storeService.findStoreIdByUserId(loginUser.getUserId());
		if (storeId == null) {
			model.addAttribute("fundingList", Collections.emptyList());
			model.addAttribute("message", "상점이 등록되지 않았습니다.");
			return "seller_fundings";
		}
		List<FundingDTO> fundingList = fundingService.findFundingByStoreId(storeId);
		model.addAttribute("fundingList", fundingList);
		return "seller_fundings";
	}

	@GetMapping("/{fundingId:[0-9]+}")
	public String fundingDetail(@PathVariable int fundingId, Model model) {
		FundingDTO funding = fundingService.selectFundingByFundingId(fundingId);
		model.addAttribute("fundingDTO", funding);
		return "seller_funding_detail";
	}

	@GetMapping("/{fundingId}/edit")
	public String editFundingForm(@PathVariable int fundingId, Model model) {
		FundingDTO funding = fundingService.selectFundingByFundingId(fundingId);
		model.addAttribute("fundingDTO", funding);

		return "seller_funding_edit";
	}

	@PutMapping("/{fundingId}")
	public String updateFunding(@ModelAttribute FundingDTO fundingDTO, @PathVariable int fundingId,
			RedirectAttributes redirectAttributes) {
		fundingDTO.setFundingId(fundingId);
		int result = fundingService.updateFunding(fundingDTO);
		redirectAttributes.addFlashAttribute("resultMessage", result > 0 ? "펀딩이 수정되었습니다." : "수정 실패");
		return "redirect:/seller/fundings";
	}

	@DeleteMapping("/{fundingId}")
	public String deleteFunding(@PathVariable int fundingId, RedirectAttributes redirectAttributes) {
		int result = fundingService.deleteFunding(fundingId);
		redirectAttributes.addFlashAttribute("resultMessage", result > 0 ? "펀딩이 삭제되었습니다." : "삭제 실패");
		return "redirect:/seller/fundings";
	}

	public List<String> extractTags(String rawInput) {
		return Arrays.stream(rawInput.replaceAll("[\\[\\]#]", "").split("[,\\s]+")).map(String::trim)
				.filter(s -> !s.isBlank()).distinct().collect(Collectors.toList());
	}
}