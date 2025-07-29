package com.takku.project.mysql;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import com.takku.project.domain.User;

@Mapper
public interface MysqlTestMapper {
    List<User> selectAll();
}
