package com.takku.project.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.takku.project.domain.FundingDTO;
import com.takku.project.domain.SettlementDTO;
import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.UserDTO;
import com.takku.project.service.FundingService;
import com.takku.project.service.SettlementService;

@Controller
@RequestMapping("/seller/settlements")
public class SettlementController {
	
	@Autowired
	private SettlementService settlementService;
	
	@Autowired
	private FundingService fundingService;

	@GetMapping()
	public String getSettlement(HttpSession session, Model model, Integer storeId) {
		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
		model.addAttribute("userDTO", loginUser);
		return "seller.settlement";
	}
	
	@GetMapping("/list")
	@ResponseBody
	public Map<String, Object> getSettlementsByStore(
	        @ModelAttribute("currentStore") StoreDTO currentStore,
	        @RequestParam(defaultValue = "1") int page,
	        @RequestParam(defaultValue = "5") int size) {

	    int storeId = currentStore.getStoreId(); 

	    int startRow = (page - 1) * size + 1;
	    int endRow = page * size;

	    List<SettlementDTO> pagedList = settlementService.selectSettlementByStoreIdWithPaging(storeId, startRow, endRow);
	    int totalCount = settlementService.countSettlementByStoreId(storeId);
	    int totalPages = (int) Math.ceil((double) totalCount / size);

	    for (SettlementDTO settlement : pagedList) {
	        FundingDTO funding = fundingService.selectFundingByFundingId(settlement.getFundingId());
	        settlement.setFunding(funding);
	    }

	    Map<String, Object> result = new HashMap<>();
	    result.put("settlementlist", pagedList);
	    result.put("currentPage", page);
	    result.put("totalPages", totalPages);
	    return result;
	}


}
