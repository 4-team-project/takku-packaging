package com.takku.project.mysql;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import com.takku.project.domain.User;

@Mapper
public interface MysqlTestMapper {
    List<User> selectAll();
    User selectById(Long id);
    void insertUser(User user);
    void updateUser(User user);
    void deleteUser(Long id);
}
