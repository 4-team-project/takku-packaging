package com.takku.project.service;

import com.takku.project.domain.stats.AgeGenderTagDTO;
import com.takku.project.domain.stats.LabelValueDTO;
import com.takku.project.domain.stats.OrderStatsDTO;
import com.takku.project.domain.stats.PopularProductDTO;
import com.takku.project.domain.stats.ProductRePurchaseDTO;
import com.takku.project.domain.stats.TagStatsDTO;
import com.takku.project.mapper.StoreStatsMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class StoreStatsService {

	@Autowired
	private StoreStatsMapper statsMapper;

	// 1. 월별 주문 및 매출
	public List<OrderStatsDTO> getMonthlyOrderStats(int storeId) {
		return statsMapper.selectMonthlyOrderStats(storeId);
	}

	// 2. 인기 상품 TOP 5
	public List<PopularProductDTO> getPopularProducts(int storeId) {
		return statsMapper.selectPopularProducts(storeId);
	}

	// 3. 재구매 상품 TOP 5
	public List<ProductRePurchaseDTO> getTopRePurchasedProducts(int storeId) {
		return statsMapper.getTopRePurchasedProducts(storeId);
	}

	// 4. 태그별 주문 수
	public List<TagStatsDTO> getTagStats(int storeId) {
		return statsMapper.selectTagStats(storeId);
	}

	// 5. 전체 사용자 연령대 분포
	public List<LabelValueDTO> getAgeDistribution() {
		List<LabelValueDTO> rawData = statsMapper.selectAgeDistribution();
		return calculatePercentage(rawData);
	}

	// 6. 전체 사용자 성별 분포
	public List<LabelValueDTO> getGenderRatio() {
		List<LabelValueDTO> rawData = statsMapper.selectGenderRatio();
		return calculatePercentage(rawData);
	}

	// 7. 상품 월별 주문/매출
	public List<OrderStatsDTO> getProductMonthlyStats(int productId) {
		return statsMapper.selectProductMonthlyStats(productId);
	}

	// 8. 상품 연령대 분포
	public List<LabelValueDTO> getProductAgeStats(int productId) {
		List<LabelValueDTO> rawData = statsMapper.selectProductAgeStats(productId);
		return calculatePercentage(rawData);
	}

	// 9. 상품 성별 비율
	public List<LabelValueDTO> getProductGenderStats(int productId) {
		List<LabelValueDTO> rawData = statsMapper.selectProductGenderStats(productId);
		return calculatePercentage(rawData);
	}

	// 10. 연령대·성별별 인기 태그
	public List<AgeGenderTagDTO> getTopTagsByAgeGender() {
		return statsMapper.selectTopTagsByAgeGender();
	}

	// 11. 오늘 상점 참여 수
	public int countTodayOrdersByStoreId(int storeId) {
		return statsMapper.countTodayOrdersByStoreId(storeId);
	}

	// 12. 오늘 상점 매출
	public Integer sumTodaySalesByStoreId(int storeId) {
		return statsMapper.sumTodaySalesByStoreId(storeId);
	}

	// 13. 진행중인 펀딩 수
	public int countOngoingFundingsByStoreId(int storeId) {
		return statsMapper.countOngoingFundingsByStoreId(storeId);
	}

	// 14. 진행 예정 펀딩 수
	public int countUpcomingFundingsByStoreId(int storeId) {
		return statsMapper.countUpcomingFundingsByStoreId(storeId);
	}

	// 15. 오늘 펀딩 금액
	public int getTodayFundingAmount(int fundingId) {
		return statsMapper.selectTodayFundingAmount(fundingId);
	}

	// 16. 펀딩 참여자 성별 분포
	public List<LabelValueDTO> getFundingGenderRatio(int fundingId) {
		List<LabelValueDTO> rawData = statsMapper.selectFundingGenderRatio(fundingId);
		return calculatePercentage(rawData);
	}

	// 17. 펀딩 참여자 연령대 분포
	public List<LabelValueDTO> getFundingAgeDistribution(int fundingId) {
		List<LabelValueDTO> rawData = statsMapper.selectFundingAgeDistribution(fundingId);
		return calculatePercentage(rawData);
	}

	// 18. 펀딩 결제 완료 수
	public int getFundingCompleteOrderCount(int fundingId) {
		return statsMapper.selectFundingCompleteOrderCount(fundingId);
	}

	// 19. 펀딩 환불 건수
	public int getFundingRefundOrderCount(int fundingId) {
		return statsMapper.selectFundingRefundOrderCount(fundingId);
	}

	// 🔁 공통 퍼센트 계산 함수
	private List<LabelValueDTO> calculatePercentage(List<LabelValueDTO> rawData) {
		double total = rawData.stream().mapToDouble(LabelValueDTO::getValue).sum();
		for (LabelValueDTO item : rawData) {
			double percent = (item.getValue() * 100.0) / total;
			item.setLabel(item.getLabel() + " (" + String.format("%.1f", percent) + "%)");
			item.setValue(percent);
		}
		return rawData;
	}
}
