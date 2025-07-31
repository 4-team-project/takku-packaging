package com.takku.project.common;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.UserDTO;
import com.takku.project.service.StoreService;

@ControllerAdvice
public class GlobalStoreInfoAdvice {

    @Autowired
    private StoreService storeService;

    @ModelAttribute
    public void addCommonStoreAttributes(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser != null) {
            int userId = loginUser.getUserId();
            List<StoreDTO> storeList = storeService.selectStoreListByUserId(userId);
            StoreDTO currentStore = (StoreDTO) session.getAttribute("currentStore");

            model.addAttribute("storeList", storeList);
            model.addAttribute("currentStore", currentStore);
        }
    }
}
