package com.takku.project.domain.stats;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.List;

@Data
@AllArgsConstructor
public class SummaryResponse {
	private int productId;
	private List<String> positive;
	private List<String> negative;
}
