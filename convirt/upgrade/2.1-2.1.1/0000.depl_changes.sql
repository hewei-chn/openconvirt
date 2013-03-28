ALTER TABLE `deployment` ADD COLUMN `distro_name` VARCHAR(50) ,
 ADD COLUMN `distro_ver` VARCHAR(50) ,
 ADD COLUMN `tot_sockets` INTEGER ,
 ADD COLUMN `tot_cores` INTEGER ,
 ADD COLUMN `tot_mem` FLOAT ,
 ADD COLUMN `host_sockets` INTEGER ,
 ADD COLUMN `host_cores` INTEGER ,
 ADD COLUMN `host_mem` FLOAT ;

