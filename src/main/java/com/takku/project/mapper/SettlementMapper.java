package com.takku.project.mapper;

import java.util.List;
import java.util.Map;

import com.takku.project.domain.SettlementDTO;

public interface SettlementMapper {

	// 1. ���� ���
	int insertSettlement(SettlementDTO settlement);

    // 2. ���� ID�� ���� ���� ��ȸ
    List<SettlementDTO> selectSettlementByStoreId(Integer storeId);

    // 3. ���� ���� ����
    int updateSettlementStatus(Map<String, Object> map);

    // 4. ���� �� ��ȸ
    SettlementDTO selectSettlementById(Integer settlementId);

    List<SettlementDTO> selectSettlementByStoreIdWithPaging(int storeId, int startRow, int endRow);

    int countSettlementByStoreId(int storeId);
}
