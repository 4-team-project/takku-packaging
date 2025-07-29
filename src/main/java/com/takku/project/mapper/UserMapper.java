
package com.takku.project.mapper;

import java.util.List;

import com.takku.project.domain.UserDTO;

public interface UserMapper {

	// 회원 가입
	int insertUser(UserDTO user);

	// 휴대폰 번호로 조회
	UserDTO selectByPhone(String phone, String password, String userType);

	// 사용자 번호로 조회
	UserDTO selectByUserId(Integer userId);

	// 회원 정보 수정
	int updateUser(UserDTO user);

	// 이메일 중복 검사, validationcontroller에서 중복검사
	int countByEmail(String email);

	// 휴대폰 번호 중복 검사(회원 가입시 중복 검사)
	int countByPhone(String phone, String userType);

	// 포인트 차감
	int updatePointAfterPayment(int userId, int usePoint);

	// 포인트 반환
	int restorePointAfterCancel(int userId, int usePoint);

	boolean countByPhoneAndUserType(String phone, String userType);

	UserDTO findUserPassword(String userType, String name, String phone);

	public List<UserDTO> selectUsersByFundingId(int fundingId);
}
