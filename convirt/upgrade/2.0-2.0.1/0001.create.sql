CREATE TABLE `avail_current` (
  `entity_id` varchar(50) NOT NULL,
  `avail_state` int(11) default NULL,
  `monit_state` int(11) default NULL,
  `timestamp` datetime default NULL,
  `description` varchar(256) default NULL,
  PRIMARY KEY  (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `avail_history` (
  `id` varchar(50) NOT NULL,
  `entity_id` varchar(50) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `monit_state` int(11) DEFAULT NULL,
  `endtime` datetime DEFAULT NULL,
  `period` int(11) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ah_eid_st_time` (`entity_id`,`state`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cms_locks` (
  `id` int(11) NOT NULL auto_increment,
  `sub_system` varchar(50) default NULL,
  `entity_id` varchar(50) default NULL,
  `operation` varchar(50) default NULL,
  `table_name` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `custom_search` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `user_name` varchar(255) default NULL,
  `created_date` datetime default NULL,
  `modified_date` datetime default NULL,
  `description` text,
  `condition` text,
  `node_level` varchar(50) default NULL,
  `lists_level` varchar(50) default NULL,
  `max_count` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `entity_tasks` (
  `worker` varchar(255) NOT NULL,
  `entity_id` varchar(50) NOT NULL,
  `worker_id` varchar(50) NOT NULL,
  `finished` tinyint(1) default NULL,
  `start_time` datetime default NULL,
  `estimated_time` datetime default NULL,
  `end_time` datetime default NULL,
  `last_ping_time` datetime default NULL,
  PRIMARY KEY  (`worker`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `outside_vms` (
  `id` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `node_id` varchar(50) NOT NULL,
  `status` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `ovm_nid_name` (`node_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `upgrade_data` (
  `id` varchar(50) NOT NULL,
  `name` varchar(50) default NULL,
  `version` varchar(50) default NULL,
  `description` varchar(100) default NULL,
  `upgraded` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


