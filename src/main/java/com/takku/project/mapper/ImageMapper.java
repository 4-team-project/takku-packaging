package com.takku.project.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.takku.project.domain.ImageDTO;

public interface ImageMapper {

	// 등록
	int insertImageUrl(ImageDTO image);

	// 삭제
	int deleteImageUrl(String imageUrl);

	// 펀딩 이미지 조회
	List<ImageDTO> selectImagesByFundingId(int fundingId);

	// 리뷰 이미지 조회
	List<ImageDTO> selectImagesByReviewId(int reviewId);

	// 상품 이미지 조회
	List<ImageDTO> selectImagesByProductId(int productId);
	
	int updateFundingIdByImageId(@Param("imageId") Integer imageId, 
            @Param("fundingId") Integer fundingId);
}
