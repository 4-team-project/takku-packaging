package com.takku.project.domain.stats;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class SummaryResponse {
	private int productId;
	private List<String> positive;
	private List<String> negative;
}
