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
public class ProductDTO {

	private Integer productId;
	private Integer storeId;
	private String productName;
	private Integer price;
	private String description;
	private Date createdAt;
	private List<ImageDTO> images;
	private String thumbnailImageUrl;
	private Double averageRating; // 평점 평균 (null 가능성 있어서 Double)

}
