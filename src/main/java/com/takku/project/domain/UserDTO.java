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
public class UserDTO {
	private Integer userId;
    private String userType;
    private String phone;
    private String password;
    private String name;
    private String gender;
    private Date birth;
    private String nickname;
    private String postcode; //우편번호
    private String sido; //시도
    private String sigungu; //시군도
    private String detailAddr; //상세주소
    private String isPartner;
    private Date createdAt;
    private Integer point;
    private String fundingType;

}
