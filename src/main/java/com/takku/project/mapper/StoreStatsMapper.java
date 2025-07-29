package com.takku.project.mapper;

import com.takku.project.domain.stats.AgeGenderTagDTO;
import com.takku.project.domain.stats.LabelValueDTO;
import com.takku.project.domain.stats.OrderStatsDTO;
import com.takku.project.domain.stats.PopularProductDTO;
import com.takku.project.domain.stats.ProductRePurchaseDTO;
import com.takku.project.domain.stats.TagStatsDTO;

import java.util.List;

public interface StoreStatsMapper {
	List<OrderStatsDTO> selectMonthlyOrderStats(int storeId);

	List<PopularProductDTO> selectPopularProducts(int storeId);

	List<ProductRePurchaseDTO> getTopRePurchasedProducts(int storeId);

	List<TagStatsDTO> selectTagStats(int storeId);

	List<LabelValueDTO> selectAgeDistribution();

	List<LabelValueDTO> selectGenderRatio();

	List<AgeGenderTagDTO> selectTopTagsByAgeGender();

	// product 기준 통계 쿼리
	List<OrderStatsDTO> selectProductMonthlyStats(int productId);

	List<LabelValueDTO> selectProductAgeStats(int productId);

	List<LabelValueDTO> selectProductGenderStats(int productId);

	// store 기준 통계 쿼리
	int countTodayOrdersByStoreId(int storeId);

	Integer sumTodaySalesByStoreId(int storeId);

	int countOngoingFundingsByStoreId(int storeId);

	int countUpcomingFundingsByStoreId(int storeId);

	// Funding 기준 통계 쿼리
	int selectTodayFundingAmount(int fundingId); // 오늘 펀딩 금액

	List<LabelValueDTO> selectFundingGenderRatio(int fundingId); // 참여자 성별

	List<LabelValueDTO> selectFundingAgeDistribution(int fundingId); // 참여자 연령대

	int selectFundingCompleteOrderCount(int fundingId); // 결제 완료 수

	int selectFundingRefundOrderCount(int fundingId); // 환불 건수

}
