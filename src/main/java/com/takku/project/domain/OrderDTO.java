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
public class OrderDTO {
   
	private Integer orderId;
	private Integer userId;
	private Integer fundingId;
	private Integer qty;
	private Integer amount;
	private Integer usePoint;
	private Integer discountAmount;
	private String paymentMethod; //결제수단
	private String status;
	private String fundingStatus;
	private Date purchasedAt;
	private Date refundAt;
	private String productName;
	private String fundingName;
	private String impUid;
	private String merchantUid;
	private List<ImageDTO> images;
	
}	
