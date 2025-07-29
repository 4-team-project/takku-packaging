package com.takku.project.mapper;

import java.util.List;

import com.takku.project.domain.TagDTO;

public interface TagMapper {

	List<String> selectTagNamesByFundingId(Integer fundingId);

	Integer getTagIdByName(String tagName);
	
	void insertTag(TagDTO tagDTO);
	
	void insertFundingTag(int fundingId, int tagId);
}
