CHANGE MASTER TO
  MASTER_HOST='database',
  MASTER_USER='root',
  MASTER_PASSWORD='secret',
  master_use_gtid=slave_pos;
START SLAVE;
