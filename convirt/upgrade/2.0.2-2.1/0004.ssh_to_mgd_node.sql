INSERT INTO operations (name,description,display_name,display_id,display,has_separator,display_seq,icon,created_by,created_date,modified_by,modified_date)
VALUES ('OPEN SSH','OPEN SSH','Open SSH Terminal','ssh_node',1,0,41,'file_edit.png','',now(),'',now());
insert into operation_opgroup(op_id,opgroup_id) select operations.id,operation_groups.id from operations,operation_groups where operations.name='OPEN SSH' AND operation_groups.name='FULL_MANAGED_NODE';
insert into operation_opgroup(op_id,opgroup_id) select operations.id,operation_groups.id from operations,operation_groups where operations.name='OPEN SSH' AND operation_groups.name='OP_MANAGED_NODE';
insert into ops_enttypes(op_id,entity_type_id) select operations.id,entity_types.id from operations,entity_types where operations.name='OPEN SSH' AND entity_types.name='MANAGED_NODE';

