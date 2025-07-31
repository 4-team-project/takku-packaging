package com.takku.project.mapper;

import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.takku.project.domain.FundingDTO;

public interface FundingMapper {

	// 조건 + 정렬 + 페이징
	List<FundingDTO> selectFundingByConditionWithPaging(Map<String, Object> param);

	// 조건별 전체 개수
	int countFundingByCondition(Map<String, Object> param);

	// 상세 조회
	FundingDTO selectFundingByFundingId(@Param("fundingId") Integer fundingId);

	// 등록/수정/삭제
	int insertFunding(FundingDTO funding);

	int updateFunding(FundingDTO funding);

	int deleteFunding(@Param("fundingId") Integer fundingId);

	// 상점별 조회
	List<FundingDTO> findFundingByStoreId(@Param("storeId") int storeId);

	// 종료일 조회
	Date selectEndDateByFundingId(@Param("fundingId") int fundingId);

	// 상태별 조회 - 매일 마감 처리용 조회
	List<FundingDTO> selectByFundingStatus(@Param("status") String status);

	// 펀딩 상태 갱신
	int updateFundingStatus(@Param("fundingId") Integer fundingId, @Param("status") String status);

	// 사용자별 상태 조회 -> 상태별 조회랑 중복?? 상태별 조회 안 쓰면 추후 삭제
	List<FundingDTO> selectFundingListByStatus(@Param("userId") int userId, @Param("status") String status);

	int updateFundingStatusIfExpired(@Param("fundingId") Integer fundingId, @Param("status") String status);

	// 상점별 펀딩 조회
	List<FundingDTO> selectFudingListByStoreId(@Param("storeId") int storeId);
}
