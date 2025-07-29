package com.takku.project.domain.stats;

import lombok.Data;

@Data
public class ProductRePurchaseDTO {
	private String productName;
	private int rePurchaseCount;
}
