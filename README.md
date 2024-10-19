# MySQL replication

# How to get things running
## 1. Setup env
```bash
cp .env.example .env
```
then setup your variables.

## 2. Generate ssl certificate for mysql servers to connect securely.
```bash
chmod +x generate-mysql-certs.sh
```
```bash
./chmod +x generate-mysql-certs.sh
```

## 3. Get the stack running
```bash
docker compose up
```

# How to setup replica
## 1. Get into `primary_database` container
```bash
docker exec -it primary_database /bin/bash
```

## 2. Get into `primary_database`'s mysql server
```bash
mysql -u root -p
```
Then enter the password.

## 3. Check log file and position on source
```shell
mysql> show master status\G;
*************************** 1. row ***************************
             File: mysql-bin.000003
         Position: 157
     Binlog_Do_DB: chat
 Binlog_Ignore_DB:
Executed_Gtid_Set:
1 row in set (0.00 sec)
```
Please not the file name (in this case `mysql-bin.000003`) and position (in this case `157`).

## 4. Get into `replica1_database` container
```bash
docker exec -it replica1_database /bin/bash
```

## 5. Get into `replica1_database`'s mysql server
```bash
mysql -u root -p
```
Then enter the password.

## 6. Config replica on `replica1_database`
```sql
change replication source to source_log_file='mysql-bin.000004', source_log_pos=370;
```

## 7. Start replication on replica
```sql
start replica user="replica_username" password="replica_password";
```
## 8. Check replica status
```shell
show replica status\G;
```
```shell
mysql> show replica status\G
*************************** 1. row ***************************
             Replica_IO_State: Waiting for source to send event
                  Source_Host: primary_database
                  Source_User: replica1
                  Source_Port: 3306
                Connect_Retry: 60
              Source_Log_File: mysql-bin.000003
          Read_Source_Log_Pos: 157
               Relay_Log_File: relay-bin.000003
                Relay_Log_Pos: 326
        Relay_Source_Log_File: mysql-bin.000003
           Replica_IO_Running: Yes
          Replica_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Source_Log_Pos: 157
              Relay_Log_Space: 710
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Source_SSL_Allowed: Yes
           Source_SSL_CA_File: /etc/mysql/certs/ca.pem
           Source_SSL_CA_Path:
              Source_SSL_Cert: /etc/mysql/certs/client-cert.pem
            Source_SSL_Cipher:
               Source_SSL_Key: /etc/mysql/certs/client-key.pem
        Seconds_Behind_Source: 0
Source_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Source_Server_Id: 1
                  Source_UUID: 28238f79-8dcf-11ef-a015-0242ac120004
             Source_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
    Replica_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Source_Retry_Count: 86400
                  Source_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Source_SSL_Crl:
           Source_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Source_TLS_Version:
       Source_public_key_path:
        Get_Source_public_key: 1
            Network_Namespace:
1 row in set (0.00 sec)
```
Please not if there's any error or else you can continue.

# Playing with replication
## 1. Create new table in `chat` database in `primary_database` server.
```sql
use chat;
create table message (id int, text varchar(1000));
create table user (id int, bio varchar(1000));
```
## 2. Check `chat` database in `replica1_database` server.
```sql
use chat;
show tables;
```
Your should see both table:
```shell
+----------------+
| Tables_in_chat |
+----------------+
| message        |
| user           |
+----------------+
2 rows in set (0.00 sec)
```
