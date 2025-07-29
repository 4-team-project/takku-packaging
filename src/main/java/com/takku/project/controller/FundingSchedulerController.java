package com.takku.project.controller;

import java.time.LocalDate;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import com.takku.project.domain.FundingDTO;
import com.takku.project.service.FundingService;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class FundingSchedulerController {
	@Autowired
	private FundingService fundingService;

	// @Scheduled(cron = "0 0 0 * * *") // 매일 00:00:00에 실행
	// @Scheduled(cron = "0,10 * * * * *") // 매 10초마다 실행

	@Scheduled(cron = "0 0 0 * * *") // 매일 00:00:00에 실행
	public void checkFundingResultsAndIssueCoupons() {
		log.info(">> 스케줄러 실행 시작");
		LocalDate today = LocalDate.now();
		log.info("현재 날짜: {}", today);

		try {
			// 1. 마감된 펀딩 처리
			processEndedFundings(today);
			// 2. 시작 펀딩 처리
			processStartingFundings(today);
		} catch (Exception e) {
			log.error("스케줄러 실행 중 예외 발생", e);
		}
		log.info(">> 스케줄러 실행 종료");
	}

	private void processEndedFundings(LocalDate today) {
		try {
			List<FundingDTO> endedFundings = fundingService.selectByFundingStatus("진행중");
			log.info("진행중 펀딩 개수: {}", endedFundings.size());

			int processedCount = 0;
			for (FundingDTO funding : endedFundings) {
				try {
					if (funding.getEndDate() == null) {
						log.warn("펀딩 종료일 없음: fundingId={}", funding.getFundingId());
						continue;
					}

					LocalDate endDate = funding.getEndDate().toLocalDate();

					// 날짜 비교 로직 검증
					boolean isToday = today.isEqual(endDate);
					boolean isAfterEndDate = today.isAfter(endDate);
					boolean shouldProcess = isToday || isAfterEndDate;

					// 오늘이 마감일과 같거나 이후인 경우 (마감 처리)
					if (shouldProcess) {
						log.info("🔥 펀딩 마감 처리 시작: fundingId={}", funding.getFundingId());
						fundingService.processEndedFunding(funding, today);
						processedCount++;
						log.info("✅ 펀딩 마감 처리 완료: fundingId={}", funding.getFundingId());
					} else {
						long daysLeft = java.time.temporal.ChronoUnit.DAYS.between(today, endDate);
						log.info("⏳ 펀딩 남은일수: {}", daysLeft);
					}
				} catch (Exception e) {
					log.error("펀딩 종료 처리 중 오류 발생: fundingId={}", funding.getFundingId(), e);
				}
			}
			log.info("🎯 마감 처리된 펀딩 수: {}", processedCount);
		} catch (Exception e) {
			log.error("종료된 펀딩 목록 조회 중 오류 발생", e);
		}
	}

	private void processStartingFundings(LocalDate today) {
		try {
			List<FundingDTO> isStartFundings = fundingService.selectByFundingStatus("준비중");
			log.info("준비중 펀딩 개수: {}", isStartFundings.size());

			int processedCount = 0;
			for (FundingDTO funding : isStartFundings) {
				try {
					if (funding.getStartDate() == null) {
						log.warn("펀딩 시작일 없음: fundingId={}", funding.getFundingId());
						continue;
					}

					LocalDate startDate = funding.getStartDate().toLocalDate();

					// 날짜 비교 로직 검증
					boolean isToday = today.isEqual(startDate);
					boolean isAfterStartDate = today.isAfter(startDate);
					boolean shouldProcess = isToday || isAfterStartDate;

					// 오늘이 시작일과 같거나 이후인 경우 (시작 처리)
					if (shouldProcess) {
						fundingService.updateFundingStatusIfExpired(funding.getFundingId(), "진행중");
						processedCount++;
					}
				} catch (Exception e) {
					log.error("펀딩 시작 처리 중 오류 발생: fundingId={}", funding.getFundingId(), e);
				}
			}
			log.info("🎯 시작 처리된 펀딩 수: {}", processedCount);
		} catch (Exception e) {
			log.error("시작 대기 펀딩 목록 조회 중 오류 발생", e);
		}
	}
}