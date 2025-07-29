package com.takku.project.domain;

import java.sql.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SettlementDTO {

    private Integer settlementId;
    private Integer fundingId;
    private Integer storeId;
    private Integer fee;
    private Integer amount;
    private String status;
    private Date settledAt;
    private FundingDTO funding;
}
