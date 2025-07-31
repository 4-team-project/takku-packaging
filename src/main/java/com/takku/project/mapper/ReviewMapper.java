package com.takku.project.mapper;

import java.util.List;

import com.takku.project.domain.ReviewDTO;

public interface ReviewMapper {
	//리뷰 등록
	int insertReview(ReviewDTO review);

	//리뷰 삭제
	int deleteReview(Integer reviewId);

	//리뷰 수정
	int updateReview(ReviewDTO review);

	//메뉴 id 리뷰보기
	List<ReviewDTO> reviewByProductId(Integer productId);

	//내 리뷰 보기
	List<ReviewDTO> reviewByUserID(Integer userId);

	List<ReviewDTO> reviewByProductIdWithPaging(Integer productId, int page, int size);

	int countByProductId(Integer productId);
}
