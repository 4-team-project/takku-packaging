
package com.takku.project.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.takku.project.domain.UserDTO;
import com.takku.project.mapper.UserMapper;

@Service
public class UserService implements UserMapper {

	@Autowired
	SqlSession sqlSession;
	String namespace = "com.takku.project.mapper.UserMapper.";

	@Override
	public int insertUser(UserDTO user) {
		int count = countByPhone(user.getPhone(), user.getUserType());
		if (count > 0) {
			throw new RuntimeException("이미 존재하는 사용자 번호입니다.");
		}

		int result = sqlSession.insert(namespace + "insertUser", user);
		return result;
	}

	@Override
	public UserDTO selectByPhone(String phone, String password, String userType) {
		Map<String, Object> map = new HashMap<>();
		map.put("phone", phone);
		map.put("password", password);
		map.put("userType", userType);

		UserDTO user = sqlSession.selectOne(namespace + "selectByPhone", map);
		return user;
	}

	@Override
	public UserDTO selectByUserId(Integer userId) {
		UserDTO user = sqlSession.selectOne(namespace + "selectByUserId", userId);
		return user;
	}

	@Override
	public int updateUser(UserDTO user) {
		int result = sqlSession.update(namespace + "updateUser", user);
		return result;
	}

	@Override
	public int countByEmail(String email) {
		int result = sqlSession.selectOne(namespace + "countByEmail", email);
		return result;
	}

	@Override
	public int countByPhone(String phone, String userType) {
		Map<String, Object> map = new HashMap<>();
		map.put("phone", phone);
		map.put("userType", userType);
		int result = sqlSession.selectOne(namespace + "countByPhone", map);
		return result;
	}

	@Override
	public int updatePointAfterPayment(int userId, int usePoint) {
		Map<String, Object> map = new HashMap<>();
		map.put("userId", userId);
		map.put("usePoint", usePoint);
		return sqlSession.update(namespace + "updatePointAfterPayment", map);
	}

	@Override
	public int restorePointAfterCancel(int userId, int usePoint) {
		Map<String, Object> map = new HashMap<>();
		map.put("userId", userId);
		map.put("usePoint", usePoint);
		return sqlSession.update(namespace + "restorePointAfterCancel", map);
	}

	@Override
	public boolean countByPhoneAndUserType(String phone, String userType) {
		Map<String, Object> map = new HashMap<>();
		map.put("phone", phone);
		map.put("userType", userType);

		Integer count = sqlSession.selectOne(namespace + "countByPhoneAndUserType", map);
		return count != null && count > 0;
	}

	@Override
	public UserDTO findUserPassword(String userType, String name, String phone) {
		Map<String, Object> map = new HashMap<>();
		map.put("userType", userType);
		map.put("name", name);
		map.put("phone", phone);

		UserDTO user = sqlSession.selectOne(namespace + "findUserPassword", map);
		return user;
	}

	@Override
	public List<UserDTO> selectUsersByFundingId(int fundingId) {
		return sqlSession.selectList(namespace + "selectUsersByFundingId", fundingId);
	}

}
