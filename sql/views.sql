--引用杨老师的时段表;

CREATE OR REPLACE VIEW tm.dv_course_section AS
 SELECT *
   FROM tm.booking_section
  WHERE booking_section.id <> 0 AND booking_section.id <> '-5'::integer;

  -- 统计老师被听课次数（与课程无关）;

CREATE OR REPLACE VIEW tm.dv_observation_count AS
 SELECT teacher.id AS teacher_id,
    teacher.name AS teacher_name,
    department.name AS department_name,
    count(*) AS supervise_count
   FROM tm.observation_form form
     JOIN tm.observer_type role ON form.observer_type_id = role.id
     JOIN ea.teacher ON form.teacher_id::text = teacher.id::text
     JOIN ea.term ON form.term_id = term.id
     JOIN ea.department ON teacher.department_id::text = department.id::text
  WHERE term.active IS TRUE AND role.name::text = '校督导'::text
  GROUP BY teacher.id, teacher.name, department.name
 HAVING count(*) > 1;

-- 历史遗留数据视图，避免修改;

CREATE OR REPLACE VIEW tm.dv_observation_legacy_form AS
 SELECT *
   FROM tm.observation_legacy_form form;


-- 优先听课名单视图:本学期有课，且查询的当下还有课，近4个学期未被听课，是否新老师;

CREATE OR REPLACE VIEW tm.dv_observation_priority AS
 WITH active_term AS (
         SELECT term.id
           FROM ea.term
          WHERE term.active IS TRUE
        ), course_teacher AS (
         SELECT DISTINCT courseclass.teacher_id,
            courseclass.term_id AS termid
           FROM ea.task_schedule schedule
             JOIN ea.task task ON schedule.task_id = task.id
             JOIN ea.course_class courseclass ON task.course_class_id = courseclass.id
             JOIN ea.course course_1 ON courseclass.course_id::text = course_1.id::text
        ), active_teacher AS (
         SELECT DISTINCT courseteacher.id AS teacher_id,
            courseteacher.name AS teacher_name,
            courseteacher.academic_title,
            department.name AS department_name,
            courseclass.term_id AS termid
           FROM ea.task_schedule schedule
             JOIN ea.task task ON schedule.task_id = task.id
             JOIN ea.course_class courseclass ON task.course_class_id = courseclass.id
             JOIN ea.course course_1 ON courseclass.course_id::text = course_1.id::text
             JOIN ea.teacher courseteacher ON courseclass.teacher_id::text = courseteacher.id::text
             JOIN ea.department department ON courseteacher.department_id::text = department.id::text
          WHERE courseclass.term_id = (( SELECT active_term.id
                   FROM active_term)) AND schedule.end_week::double precision > (( SELECT date_part('week'::text, now()) - date_part('week'::text, term.start_date) + 1::double precision AS d
                   FROM ea.term
                  WHERE term.active IS TRUE))
        ), new_teacher AS (
         SELECT course_teacher.teacher_id
           FROM course_teacher
          GROUP BY course_teacher.teacher_id
         HAVING min(course_teacher.termid) = (( SELECT active_term.id
                   FROM active_term))
        ), inspect4 AS (
         SELECT DISTINCT inspector.teachercode AS teacher_id
           FROM tm.observation_legacy_form inspector
          WHERE inspector.teachercode IS NOT NULL AND inspector.type::text = '督导'::text AND (inspector.term_id + 20) > (( SELECT active_term.id
                   FROM active_term))
        UNION
         SELECT DISTINCT supervisor.teacher_id
           FROM tm.observation_form supervisor
             JOIN tm.observer_type role ON supervisor.observer_type_id = role.id
             JOIN ea.task_schedule schedule ON supervisor.task_schedule_id = schedule.id
             JOIN ea.task ON schedule.task_id = task.id
             JOIN ea.course_class courseclass ON task.course_class_id = courseclass.id
          WHERE role.name::text = '校督导'::text AND (courseclass.term_id + 20) > (( SELECT active_term.id
                   FROM active_term))
        )
 SELECT DISTINCT active.teacher_id,
    active.teacher_name,
    active.department_name,
    active.academic_title,
    a.teacher_id AS isnew,
    inspect4.teacher_id AS has_supervisor
   FROM active_teacher active
     LEFT JOIN new_teacher a ON active.teacher_id::text = a.teacher_id::text
     LEFT JOIN inspect4 ON active.teacher_id::text = inspect4.teacher_id::text;

-- 督导听课视图，合并了新旧数据，只抽取重要的字段信息;

CREATE OR REPLACE VIEW tm.dv_observation_public AS
 SELECT view.id,
    false AS is_legacy,
    view.supervisor_date,
    view.evaluate_level,
    view.type_name,
    view.termid AS term_id,
    view.department_name,
    view.teacher_id,
    view.teacher_name,
    view.course_name,
    concat('星期', "substring"('一二三四五六日'::text, view.day_of_week, 1), ' ', view.start_section::text, '-', (view.start_section + view.total_section - 1)::text, '节 ', view.place_name) AS course_other_info
   FROM tm.dv_observation_view view
  WHERE view.status = 2
UNION ALL
 SELECT legacy_form.id,
    true AS is_legacy,
    legacy_form.listentime AS supervisor_date,
    legacy_form.evaluategrade AS evaluate_level,
    legacy_form.type AS type_name,
    legacy_form.term_id,
    legacy_form.collegename AS department_name,
    legacy_form.teachercode AS teacher_id,
    legacy_form.teachername AS teacher_name,
    legacy_form.coursename AS course_name,
    legacy_form.classpostion AS course_other_info
   FROM tm.dv_observation_legacy_form legacy_form
  WHERE legacy_form.state::text = 'yes'::text;

  -- JOIN课表，抽取最全常用字段;

CREATE OR REPLACE VIEW tm.dv_observation_view AS
 SELECT form.id,
    form.attendant_stds,
    form.due_stds,
    form.earlier,
    form.evaluate_level,
    form.evaluation_text,
    form.late,
    form.late_stds,
    form.leave,
    form.leave_stds,
    form.lecture_week,
    form.status,
    form.suggest,
    supervisor.id AS supervisor_id,
    form.supervisor_date,
    form.teaching_methods,
    form.total_section AS form_total_section,
    form.record_date,
    form.reward_date,
    supervisor.name AS supervisor_name,
    role.name AS type_name,
    courseteacher.id AS teacher_id,
    courseteacher.academic_title,
    courseclass.name AS course_class_name,
    schedule.start_week,
    schedule.end_week,
    schedule.odd_even,
    schedule.day_of_week,
    schedule.start_section,
    schedule.total_section,
    course_1.name AS course_name,
    place.name AS place_name,
    courseteacher.name AS teacher_name,
    department.name AS department_name,
    courseclass.term_id AS termid
   FROM tm.observation_form form
     JOIN tm.observer_type role ON form.observer_type_id = role.id
     JOIN ea.teacher supervisor ON form.observer_id::text = supervisor.id::text
     JOIN ea.task_schedule schedule ON form.task_schedule_id = schedule.id
     JOIN ea.task task ON schedule.task_id = task.id
     JOIN ea.course_class courseclass ON task.course_class_id = courseclass.id
     JOIN ea.department department ON courseclass.department_id::text = department.id::text
     JOIN ea.course course_1 ON courseclass.course_id::text = course_1.id::text
     JOIN ea.teacher courseteacher ON courseclass.teacher_id::text = courseteacher.id::text
     LEFT JOIN ea.place ON schedule.place_id::text = place.id::text;


-- 应用权限
create or replace view tm.dv_teacher_role as
-- 在原来的代码后面增加
UNION ALL
SELECT s.teacher_id AS user_id,
'ROLE_SUPERVISOR_ADMIN'::text AS role_id
FROM tm.supervisor s
WHERE s.role_type = 0
UNION ALL
SELECT DISTINCT s.teacher_id AS user_id,
'ROLE_SUPERVISOR'::text AS role_id
FROM tm.supervisor s
JOIN tm.supervisor_role r ON s.role_type = r.id
JOIN ea.term t ON s.term_id = t.id
WHERE (r.name::text = '校督导'::text OR r.name::text = '院督导'::text) AND t.active IS TRUE;


--