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
public class ReviewDTO {

	private Integer reviewId;
	private Integer userId;
	private Integer productId;
	private Integer rating;
	private String content;
	private Date createdAt;
	private List<ImageDTO> images;
    private List<String> imageUrls;
	private String nickname;
}
