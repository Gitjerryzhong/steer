-- 导入督导员角色名
insert into tm.role(id,name)values('ROLE_SUPERVISOR','现任督导');
insert into tm.role(id,name)values('ROLE_SUPERVISOR_ADMIN','督导管理员');

-- 导入督导权限
insert into tm.permission(id,name)values('PERM_SUPERVISOR_WRITE','督导写');
insert into tm.permission(id,name)values('PERM_ADMIN_SUPERVISOR_WRITE','督导管理员写');
insert into tm.permission(id,name)values('PERM_SUPERVISOR_PUBLIC','督导听课记录查看');
insert into tm.permission(id,name)values('PERM_CO_SUPERVISOR_APPROVE','学院督导听课发布');
insert into tm.permission(id,name)values('PERM_CO_SUPERVISOR_ADMIN','学院督导管理');

-- 设置角色权限
insert into tm.role_permission(role_id,permission_id)values('ROLE_SUPERVISOR','PERM_SUPERVISOR_WRITE');
insert into tm.role_permission(role_id,permission_id)values('ROLE_SUPERVISOR_ADMIN','PERM_ADMIN_SUPERVISOR_WRITE');
insert into tm.role_permission(role_id,permission_id)values('ROLE_SUPERVISOR_ADMIN','PERM_SUPERVISOR_WRITE');
insert into tm.role_permission(role_id,permission_id)values('ROLE_SUPERVISOR_ADMIN','PERM_SUPERVISOR_READ');
insert into tm.role_permission(role_id,permission_id)values('ROLE_SUPERVISOR_ADMIN','PERM_CO_SUPERVISOR_APPROVE');
insert into tm.role_permission(role_id,permission_id)values('ROLE_IN_SCHOOL_TEACHER','PERM_SUPERVISOR_PUBLIC');
insert into tm.role_permission(role_id,permission_id)values('ROLE_DEAN_OF_TEACHING','PERM_CO_SUPERVISOR_APPROVE');
insert into tm.role_permission(role_id,permission_id)values('ROLE_ACADEMIC_SECRETARY','PERM_CO_SUPERVISOR_ADMIN');

-- 设置听课记录初始编号10001
select setval('observation_form_id_seq',10001,false);