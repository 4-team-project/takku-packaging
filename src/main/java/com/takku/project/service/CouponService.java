package com.takku.project.service;

import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.takku.project.domain.CouponDTO;
import com.takku.project.domain.FundingDTO;
import com.takku.project.mapper.CouponMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class CouponService implements CouponMapper {

	@Autowired
	private SqlSession sqlSession;

	private final String namespace = "com.takku.project.mapper.CouponMapper.";

	/**
	 * 랜덤 쿠폰 코드 생성
	 */
	public String generateRandomCode() {
		return UUID.randomUUID().toString().replace("-", "").substring(0, 12).toUpperCase();
	}

	/**
	 * 펀딩 성공 시 참여 유저에게 쿠폰 자동 발급 (스케줄러 사용)
	 */
	public void issueCouponsForFunding(FundingDTO funding, LocalDate today) {
		// Null 체크 추가
		if (funding == null) {
			log.error("펀딩 정보가 null입니다.");
			return;
		}

		if (funding.getFundingId() == null) {
			log.error("펀딩 ID가 null입니다.");
			return;
		}

		if (funding.getStoreId() == null) {
			log.error("스토어 ID가 null입니다. fundingId={}", funding.getFundingId());
			return;
		}

		if (today == null) {
			log.error("날짜 정보가 null입니다. fundingId={}", funding.getFundingId());
			return;
		}

		try {
			List<Map<String, Object>> participantList = selectParticipantsWithQtyByFundingId(funding.getFundingId());

			if (participantList == null || participantList.isEmpty()) {
				log.warn("펀딩 참여자가 없습니다. fundingId={}", funding.getFundingId());
				return;
			}

			log.info("펀딩 참여자 수: {}, fundingId={}", participantList.size(), funding.getFundingId());

			for (Map<String, Object> row : participantList) {
				if (row == null) {
					log.warn("참여자 정보가 null입니다. fundingId={}", funding.getFundingId());
					continue;
				}

				Object userIdObj = row.get("userId");
				Object qtyObj = row.get("totalQty");

				if (userIdObj == null || qtyObj == null) {
					log.warn("사용자 ID 또는 수량이 null입니다.");
					log.warn("fundingId: {}", funding.getFundingId());
					log.warn("userId: {}", userIdObj);
					log.warn("qty: {}", qtyObj);
					continue;
				}

				Integer userId = ((Number) userIdObj).intValue();
				Integer qty = ((Number) qtyObj).intValue();

				if (qty <= 0) {
					log.warn("수량이 0 이하입니다.");
					log.warn("fundingId: {}", funding.getFundingId());
					log.warn("userId: {}", userId);
					log.warn("qty: {}", qty);
					continue;
				}

				for (int i = 0; i < qty; i++) {
					try {
						CouponDTO coupon = new CouponDTO();
						coupon.setFundingId(funding.getFundingId());
						coupon.setUserId(userId);
						coupon.setStoreId(funding.getStoreId());
						coupon.setCouponCode("TK" + UUID.randomUUID().toString().substring(0, 10).toUpperCase());
						coupon.setUseStatus("미사용");
						coupon.setReviewed(0);
						coupon.setCreatedAt(Date.valueOf(today));
						coupon.setExpiredAt(Date.valueOf(today.plusMonths(6)));

					} catch (Exception e) {
						log.error("쿠폰 발급 중 오류 발생");
						log.error("userId: {}", userId);
						log.error("fundingId: {}", funding.getFundingId());
						log.error("index: {}/{}", i + 1, qty);
						log.error("오류 내용: ", e);
					}
				}
			}
		} catch (Exception e) {
			log.error("펀딩 쿠폰 발급 처리 중 오류 발생");
			log.error("fundingId: {}", funding.getFundingId());
			log.error("오류 내용: ", e);
			throw e; // 상위 레벨에서 처리할 수 있도록 다시 던지기
		}
	}

	@Override
	public int insertCoupon(CouponDTO coupon) {
		if (coupon == null) {
			log.error("쿠폰 정보가 null입니다.");
			return 0;
		}
		return sqlSession.insert(namespace + "insertCoupon", coupon);
	}

	@Override
	public List<CouponDTO> selectCouponByUserId(Integer userId) {
		if (userId == null) {
			log.error("사용자 ID가 null입니다.");
			return new ArrayList<>();
		}
		return sqlSession.selectList(namespace + "selectCouponsByUserId", userId);
	}

	@Override
	public int updateCouponUseStatus(Map<String, Object> map) {
		if (map == null || map.isEmpty()) {
			log.error("업데이트 파라미터가 null 또는 비어있습니다.");
			return 0;
		}
		return sqlSession.update(namespace + "updateCouponUseStatus", map);
	}

	/**
	 * 쿠폰 상태 업데이트 (사용 처리 포함)
	 */
	public int updateCouponUseStatus(String couponCode, String useStatus) {
		if (couponCode == null || couponCode.trim().isEmpty()) {
			log.error("쿠폰 코드가 null 또는 비어있습니다.");
			return 0;
		}

		if (useStatus == null || useStatus.trim().isEmpty()) {
			log.error("사용 상태가 null 또는 비어있습니다.");
			return 0;
		}

		Map<String, Object> map = new HashMap<>();
		map.put("couponCode", couponCode);
		map.put("useStatus", useStatus);
		map.put("usedAt", new Date(System.currentTimeMillis()));
		return updateCouponUseStatus(map);
	}

	@Override
	public int updateCouponReviewed(Integer couponId) {
		if (couponId == null) {
			log.error("쿠폰 ID가 null입니다.");
			return 0;
		}
		return sqlSession.update(namespace + "updateCouponReviewed", couponId);
	}

	@Override
	public CouponDTO selectByCouponCode(String couponCode) {
		if (couponCode == null || couponCode.trim().isEmpty()) {
			log.error("쿠폰 코드가 null 또는 비어있습니다.");
			return null;
		}
		return sqlSession.selectOne(namespace + "selectByCouponCode", couponCode);
	}

	@Override
	public CouponDTO selectByCouponId(Integer couponId) {
		if (couponId == null) {
			log.error("쿠폰 ID가 null입니다.");
			return null;
		}
		return sqlSession.selectOne(namespace + "selectByCouponId", couponId);
	}

	@Override
	public List<Map<String, Object>> selectParticipantsWithQtyByFundingId(int fundingId) {
		try {
			List<Map<String, Object>> result = sqlSession.selectList(namespace + "selectParticipantsWithQtyByFundingId",
					fundingId);
			return result != null ? result : new ArrayList<>();
		} catch (Exception e) {
			log.error("참여자 목록 조회 중 오류 발생: fundingId={}", fundingId, e);
			return new ArrayList<>();
		}
	}
}