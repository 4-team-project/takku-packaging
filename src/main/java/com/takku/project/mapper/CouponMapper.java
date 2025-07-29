package com.takku.project.mapper;

import java.util.List;
import java.util.Map;

import com.takku.project.domain.CouponDTO;

public interface CouponMapper {

	// 쿠폰 발급 (insert)
	int insertCoupon(CouponDTO coupon);

	// 특정 사용자의 쿠폰 목록 조회
	List<CouponDTO> selectCouponByUserId(Integer userId);

	// 쿠폰 사용여부 업데이트
	int updateCouponUseStatus(Map<String, Object> map);

	// 리뷰 여부 업데이트
	int updateCouponReviewed(Integer couponId);

	// 특정 쿠폰 상세 조회
	CouponDTO selectByCouponCode(String couponCode);

	// coupon_id로 단건 조회
	CouponDTO selectByCouponId(Integer couponId);

	List<Map<String, Object>> selectParticipantsWithQtyByFundingId(int fundingId);

}
