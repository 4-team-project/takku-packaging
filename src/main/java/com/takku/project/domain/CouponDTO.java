package com.takku.project.domain;

import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CouponDTO {
  
	private Integer couponId;
	private Integer fundingId;
	private Integer userId;
	private Integer storeId;
	private String couponCode;
	private String useStatus;
	private Integer reviewed;
	private Date createdAt;
	private Date expiredAt;
	private Date usedAt;
}
