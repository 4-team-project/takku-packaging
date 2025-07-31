package com.takku.project.domain;

import java.sql.Date;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FundingDTO {

	private Integer fundingId;
	private Integer productId;
	private Integer storeId;
	private String fundingType;
	private String fundingName;
	private String fundingDesc;
	private Date startDate;
	private Date endDate;
	private Integer salePrice;
	private Integer targetQty;
	private Integer maxQty;
	private Integer currentQty;
	private Integer perQty;
	private String status;
	private Date createdAt;
	private List<String> tagList;
	private List<ImageDTO> images;
	private String thumbnailImageUrl;
	private String storeName;
	private Integer price;
	private Date purchasedAt;
	private String storeAddress;
	private Double avgRating;
	private Integer reviewCnt;

	// 추천 펀딩 list를 위한 추가 필드
	private Double score;
  
	private Integer daysLeft;
	private String mainImageUrl; 
}
