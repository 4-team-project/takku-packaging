package com.takku.project.domain;

import java.sql.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StoreDTO {
  
	private Integer storeId;
	private Integer userId;
	private String businessNumber;
	private String bankAccount;
	private String storeName;
	private String sido;
	private String sigungu;
	private String dong;
	private String addressDetail;
	private Integer categoryId;
	private String description;
	private Date createdAt;
	private String categoryName; //db에는 x
	private Integer postCode; //db에는 x
}
