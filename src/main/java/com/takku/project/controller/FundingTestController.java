package com.takku.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/test")
public class FundingTestController {

	@Autowired
	private FundingSchedulerController fundingScheduler;

	@GetMapping("/update-status")
	public String testUpdateStatus() {
	    fundingScheduler.checkFundingResultsAndIssueCoupons();
	    return "펀딩 상태 업데이트 테스트 완료!";
	}
}
