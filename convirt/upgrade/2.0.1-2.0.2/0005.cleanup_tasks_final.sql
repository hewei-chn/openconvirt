select 'Delete successful task results older than 90 days' as '';
DELETE FROM task_results WHERE task_results.task_id in (4,9,10) AND status = 3 and datediff(now() , task_results.timestamp) >= 90;

select 'Delete successful task results older than 60 days' as '';
DELETE FROM task_results WHERE task_results.task_id in (4,9,10) AND status = 3 and datediff(now() , task_results.timestamp) >= 60;

select 'Delete successful task results older than 30 days' as '';
DELETE FROM task_results WHERE task_results.task_id in (4,9,10) AND status = 3 and datediff(now() , task_results.timestamp) >= 30;

select 'Delete successful task results older than 15 days' as '';
DELETE FROM task_results WHERE task_results.task_id in (4,9,10) AND status = 3 and datediff(now() , task_results.timestamp) >= 15;

select 'Delete successful CHILD task results older than 90 days' as '';
delete  FROM task_results WHERE task_id in (SELECT tasks.task_id AS tasks_task_id FROM tasks WHERE datediff(now() , tasks.submitted_on) >= 90 AND tasks.parent_task_id in (4,9,10)) and status=3;
select 'Delete successful CHILD task results older than 60 days' as '';
delete  FROM task_results WHERE task_id in (SELECT tasks.task_id AS tasks_task_id FROM tasks WHERE datediff(now() , tasks.submitted_on) >= 60 AND tasks.parent_task_id in (4,9,10)) and status=3;
select 'Delete successful CHILD task results older than 30 days' as '';
delete  FROM task_results WHERE task_id in (SELECT tasks.task_id AS tasks_task_id FROM tasks WHERE datediff(now() , tasks.submitted_on) >= 30 AND tasks.parent_task_id in (4,9,10)) and status=3;
select 'Delete successful CHILD task results older than 15 days' as '';
delete  FROM task_results WHERE task_id in (SELECT tasks.task_id AS tasks_task_id FROM tasks WHERE datediff(now() , tasks.submitted_on) >= 15 AND tasks.parent_task_id in (4,9,10)) and status=3;

select 'Delete successful TASKS older than 90 days' as '';
delete FROM tasks WHERE datediff(now() , tasks.submitted_on) >= 90 AND tasks.parent_task_id in (4,9,10) and task_id not in (select task_id from task_results);
select 'Delete successful TASKS older than 60 days' as '';
delete FROM tasks WHERE datediff(now() , tasks.submitted_on) >= 60 AND tasks.parent_task_id in (4,9,10) and task_id not in (select task_id from task_results);
select 'Delete successful TASKS older than 30 days' as '';
delete FROM tasks WHERE datediff(now() , tasks.submitted_on) >= 30 AND tasks.parent_task_id in (4,9,10) and task_id not in (select task_id from task_results);
select 'Delete successful TASKS older than 15 days' as '';
delete FROM tasks WHERE datediff(now() , tasks.submitted_on) >= 15 AND tasks.parent_task_id in (4,9,10) and task_id not in (select task_id from task_results);

