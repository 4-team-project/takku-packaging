package com.takku.project.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ImageDTO {

	private Integer imageId;
	private Integer productId;
	private Integer fundingId;
	private Integer reviewId;
	private String imageUrl;
}
