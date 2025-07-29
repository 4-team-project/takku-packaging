package com.takku.project.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.takku.project.domain.TagDTO;
import com.takku.project.mapper.TagMapper;

@Service
public class TagService implements TagMapper {

	@Autowired
	SqlSession sqlSession;
	String namespace = "com.takku.project.mapper.TagMapper.";

	@Override
	public List<String> selectTagNamesByFundingId(Integer fundingId) {
		return sqlSession.selectList(namespace + "selectTagNamesByFundingId", fundingId);
	}

	@Override
	public Integer getTagIdByName(String tagName) {
		return sqlSession.selectOne(namespace + "selectTagIdByName", tagName);
	}

	@Override
	public void insertTag(TagDTO tagDTO) {
		sqlSession.insert(namespace + "insertTag", tagDTO);
	}

	@Override
	public void insertFundingTag(int fundingId, int tagId) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("fundingId", fundingId);
		paramMap.put("tagId", tagId);
		sqlSession.insert(namespace + "insertFundingTag", paramMap);
	}
}
