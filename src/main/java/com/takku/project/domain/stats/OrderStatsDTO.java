package com.takku.project.domain.stats;

import lombok.Data;

@Data
public class OrderStatsDTO {
    private String month;
    private int orderCount;
    private int revenue;
}
