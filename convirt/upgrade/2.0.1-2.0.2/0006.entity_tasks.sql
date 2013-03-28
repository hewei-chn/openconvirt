ALTER TABLE `entity_tasks` MODIFY COLUMN `worker_id` VARCHAR(50) DEFAULT NULL;
update `entity_tasks` set `worker_id`=null, `finished`=1 ;


