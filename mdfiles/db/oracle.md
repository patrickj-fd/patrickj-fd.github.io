[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 常用命令
## 连接（登录）
```shell
# 管理员身份连接
sqlplus /nolog
> connect /as sysdba
# 或者
sqlplus / as sysdba


# 一般用户
sqlplus username/pwd@host/service_name
```

## 其他
```shell
# 查看状态
lsnrctl status
```

- 查看是否为归档模式： `select name,log_mode from V$database;`


# 外部表
## 1. 创建外部目录
```sql
-- 1. 用管理员创建外部目录并授权给用户
connect /as sysdba

-- 1.1 创建存放数据文件的目录。除了存放数据文件的目录外，最好再创建日志目录和错误数据目录
create or replace directory outfile_dat_dir as '/yours-path/...'; 
create or replace directory outfile_log_dir as '/yours-path/.../log'; 
create or replace directory outfile_bad_dir as '/yours-path/.../bad'; 
-- 1.2 授权给 oracle 用户
grant read  on directory outfile_dat_dir to someuser; 
grant write on directory outfile_log_dir to someuser; 
grant write on directory outfile_bad_dir to someuser;


-- 2. 给用户授予创建外部目录的权限，由用户自己创建外部目录
connect /as sysdba
grant create any directory to test;

connect someuser/pwd
create or replace directory outfile_dat_dir as '/yours-path/...'; 
create or replace directory outfile_log_dir as '/yours-path/.../log'; 
create or replace directory outfile_bad_dir as '/yours-path/.../bad'; 
```

## 2. 加载外部表
```sql
create table some_table(
  duid   NUMBER(10),
  name   VARCHAR2(8),
  info   VARCHAR2(20)
)
organization external(
  type ORACLE_LOADER
  default directory outfile_dat_dir
  access parameters 
  (
        RECORDS DELIMITED BY NEWLINE
        CHARACTERSET ZHS16GBK
        BADFILE outfile_bad_dir:'rst%a_%p.bad'
        DISCARDFILE outfile_bad_dir:'rst%a_%p.dis'
        LOGFILE outfile_log_dir:'rst%a_%p.log'
        READSIZE 1048576
        FIELDS TERMINATED BY ","
  )
  location ('user-gbk.txt')     -- 可以写多个文件，逗号分开
)
parallel
reject limit UNLIMITED;
```