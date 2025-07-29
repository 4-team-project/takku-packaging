
package com.takku.project.controller;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.HttpSession;
import javax.websocket.Session;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.takku.project.domain.FundingDTO;
import com.takku.project.domain.ImageDTO;
import com.takku.project.domain.UserDTO;
import com.takku.project.service.AIService;
import com.takku.project.service.FundingService;
import com.takku.project.service.ImageService;
import com.takku.project.service.StoreService;

@Controller
public class HomeController {

	@Autowired
	FundingService fundingService;

	@Autowired
	ImageService imageService;

	@Autowired
	AIService aiService;

	@GetMapping({"/", "/user/home", "/takku", "/main"})
	public String homePage(String status, Model model, HttpSession session) {

		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
		int userId = 1;
		if (loginUser != null) {
			userId = loginUser.getUserId();
		}
		List<FundingDTO> recommendList = aiService.getRecommendations(userId);
		recommendList = recommendList.stream()
				.filter(f -> f.getEndDate() != null && !LocalDate.now().isAfter(f.getEndDate().toLocalDate()))
				.collect(Collectors.toList());

		for (FundingDTO funding : recommendList) {
			List<ImageDTO> images = imageService.selectImagesByFundingId(funding.getFundingId());
			funding.setImages(images);
			long days = ChronoUnit.DAYS.between(LocalDate.now(), funding.getEndDate().toLocalDate());
			funding.setDaysLeft((int) Math.max(days, 0));
		}

		List<String> statusList = (status != null && !status.isBlank()) ? Collections.singletonList(status)
				: Arrays.asList("진행중");

		List<FundingDTO> ongoingFundingList = fundingService.getFundingsByConditionWithPaging(null, null, null, null,
				statusList, "popular", 1, 8);

		for (FundingDTO funding : ongoingFundingList) {
			List<ImageDTO> images = imageService.selectImagesByFundingId(funding.getFundingId());
			funding.setImages(images);

			long days = ChronoUnit.DAYS.between(LocalDate.now(), funding.getEndDate().toLocalDate());
			funding.setDaysLeft((int) Math.max(days, 0));
		}

		model.addAttribute("user", loginUser);
		model.addAttribute("recommendList", recommendList);
		model.addAttribute("fundinglist", ongoingFundingList);

		return "user.home";
	}
}