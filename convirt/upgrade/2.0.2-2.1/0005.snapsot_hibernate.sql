UPDATE operations
SET name = 'RESTORE_HIBERNATED',description= 'RESTORE_HIBERNATED',display_name= 'Restore Hibernated',display_id='restore_hibernated'
WHERE operations.name= 'RESTORE_VM';

UPDATE operations
SET name = 'HIBERNATE_VM',description= 'HIBERNATE_VM',display_name= 'Hibernate',display_id='hibernate'
WHERE operations.name= 'SNAPSHOT_VM';

