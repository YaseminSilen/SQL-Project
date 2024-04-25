-- comp9311 22T1 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(subject_name)
as
select distinct name 
from subjects s
where (s._prereq like '%COMP%COMP3%' or s._prereq like '%COMP3%COMP%' );

-- Q2:
create or replace view Q2(course_id)
as
select C.id 
from rooms r, buildings b ,courses c,class_types ct, classes
where r.building=b.id and classes.ctype=ct.id 
and classes.room=r.id and c.id=classes.course
and ct.name='Studio'
group by c.id
having count(distinct b.id)>=3
;

-- Q3:
create or replace view Q3(course_id, use_rate) as 
select inq.id, inq.use_rate 
from ( select c.id, count( * ) as use_rate,rank() OVER (PARTITION BY b.id ORDER BY count( * ) DESC) rank_value
from rooms r, buildings b ,courses c,class_types ct, classes cl, semesters s
where r.building=b.id and cl.ctype=ct.id 
and cl.room=r.id and c.id=cl.course
and b.name='Central Lecture Block' and s."year"=2008
and c.semester=s.id
group by b.id , c.id) inq
where inq.rank_value =1
order by inq.id asc
;

-- Q4:
create or replace view Q4(facility)
as
select description from facilities
except
select distinct description from rooms r, buildings b, room_facilities rf , Facilities f
where r.building=b.id and rf.facility=f.id
and rf.room=r.id and substr(gridref,1,1)='C' and campus='K'
;

--Q5:
create or replace view Q5(unsw_id, student_name)
as
select distinct p.unswid, p."name" 
from course_enrolments , students s ,people p
where course_enrolments.student=s.id and p.id=s.id and stype='local'
group by p.unswid, p."name" 
having sum(case when grade = 'HD' then 1 else 0 end) = count( * ) and count( * ) > 0
;

-- Q6:
create or replace view Q6(subject_name, non_null_mark_count, null_mark_count)
as
select su1.name,sum(case when mark is not null then 1 else 0 end) non_null_mark_count,
sum(case when mark is null then 1 else 0 end) null_mark_count
from Subjects su,courses c, semesters s , course_enrolments ce,Subjects su1
where   s.longname='Semester 1 2006'
and c.semester=s.id and c.subject=su.id and ce.course=c.id and su.id=su1.id
group by Su.id,su1.name
having sum(case when mark is null then 1 else 0 end)>10 and sum(case when mark>0 then 1 else 0 end)>0
order by 2 desc
;

-- Q7:
create or replace view Q7(school_name, stream_count)
as
select o.longname, count(distinct s."name" )
 from Orgunits o,orgunit_types ot, 
 programs p,
 program_enrolments pe,
 stream_enrolments se, streams s
 where se.partof = pe.id
and s.id = se.stream
 and  o.utype=ot.id and ot."name"='School' 
 and  p.offeredby = o.id
and p.id=pe.program
group by o.longname
having count(distinct s."name")>(select count(distinct s.name)
 from Orgunits o,orgunit_types ot, 
 programs p,
 program_enrolments pe,
 stream_enrolments se, streams s,semesters ss
 where se.partof = pe.id and   pe.semester = ss.id
and s.id = se.stream
and o.longname='School of Computer Science and Engineering'
 and  o.utype=ot.id and ot."name"='School' 
 and  p.offeredby = o.id
and p.id=pe.program)
;

-- Q8: 
create or replace view Q8(student_name_local, student_name_intl)
as
select distinct  local.name,intl.name 
from (select p."name",mark,dense_rank() OVER (ORDER BY mark deSC) AS wam
from courses c, people p, course_enrolments ce , students s , semesters ss,subjects su
where c.id=ce.course and p.id=ce.student and stype='local' and s.id=p.id
and  ss."year"=2012 and ss.term='S1'
and c.semester=ss.id
and c.subject=su.id
and su."name"='Engineering Design'
and mark>98) local, 
(select p."name" ,mark , dense_rank() over( ORDER BY mark DESC) AS wam
from courses c, people p, course_enrolments ce , students s , semesters ss,subjects su
where c.id=ce.course and p.id=ce.student and stype='intl' and s.id=p.id
and  ss."year"=2012 and ss.term='S1'
and c.semester=ss.id
and c.subject=su.id
and su."name"='Engineering Design'
and mark>98) intl
where intl.wam=local.wam
;

-- Q9:
create or replace view Q9(ranking, course_id, subject_name, student_diversity_score)
as
select rank_last as ranking , id course_id,name subject_name,diversity  from (
select id,name,diversity,rank() over (order by diversity desc) rank_last from  (select q1.id,q1.name,diversity,rank () over (partition by q1.id order by diversity desc) rank_value
from (select c.id,su."name",  rank() OVER (partition by c.id 																		  ORDER BY count(origin) aSC) AS diversity
from courses c, people p, course_enrolments ce , students s ,subjects su
where c.id=ce.course and p.id=ce.student  and s.id=p.id
and c.subject=su.id group by c.id,origin,su."name" order by 1,2,3 desc)q1
group by q1.id,q1.name,diversity
				order by 3,2 desc
) q2
where q2.rank_value=1
order by 3 desc) q4
where rank_last<=6
;

-- Q10:
create or replace view Q10(subject_code, avg_mark)
as
select s.code,avg(coalesce(mark,0))::numeric(4,2) avg_mark
from subjects s,Orgunits o, course_enrolments ce,semesters se,
 courses c 
 where   c.subject = s.id and
         ce.course = c.id and
         se.id = c.semester and
         s.offeredby = o.id and 
		 se."year"=2010 and
		 s.career='PG' and
         se.term = 'S1' 
  and o.longname='School of Computer Science and Engineering'
 group by se.year, se.term, s.code
				  having  count(*)>10
				  order by 2 desc
;

-- Q11:
create or replace view Q11(subject_code, inc_rate)
as
select q.code, inc_rate::numeric(4,4)  from (select s1.code,(s2.avg_mark-s1.avg_mark)/s1.avg_mark inc_rate  ,rank () over (order by (s2.avg_mark-s1.avg_mark)/s1.avg_mark desc) rank
from (select s.code,avg(mark) avg_mark
from subjects s,Orgunits o, course_enrolments ce,semesters se,
 courses c 
 where   c.subject = s.id and
         ce.course = c.id and
         se.id = c.semester and
         s.offeredby = o.id and 
		 se."year"=2008 and
		 se.term = 'S1' and mark is not null
  and o.longname in ('School of Chemistry','School of Accounting')
 group by se.year, se.term, s.code
				  			  order by 2 desc)s1,				  
				  (select s.code,avg(mark) avg_mark
from subjects s,Orgunits o, course_enrolments ce,semesters se,
 courses c 
 where   c.subject = s.id and
         ce.course = c.id and
         se.id = c.semester and
         s.offeredby = o.id and 
		 se."year"=2008 and
		 se.term = 'S2' and mark is not null
  and o.longname in ('School of Chemistry','School of Accounting')
 group by se.year, se.term, s.code
				   order by 2 desc) s2
				  where s1.code=s2.code and s1.avg_mark<s2.avg_mark
				  order by 2 desc) q
				  where q.rank=1
;

-- Q12:
create or replace view  Q12 (name, subject_code, year, term,
lab_time_per_week) as  select p.name , su.code,se.year,se.term, sum((cl.endtime-cl.starttime))
from people p ,course_staff cs,staff_roles sr,courses c ,semesters se,subjects su,classes cl,class_types ct
where sr.id=cs.role and p.id=cs.staff and c.id=cs.course and se.id=c.semester
and c.subject=su.id and  cl.course=c.id and ct.id=cl.ctype 
and sr.name like '%Lecturer%' 
and p.title='Dr' 
and ct.unswid='LAB' 
and su.code like 'COMP%'
group by p.name , su.code,se.year,se.term
order by  1,2
;

-- Q13:
create or replace view Q13(subject_code, year, term, fail_rate)
as
select  su.code,           t.year, t.term ,round( CAST(float8  ((sum(case when mark<50 then 1 else 0 end)::float)/ 
											 (sum(case when mark is not null then 1 else 0 end)))as numeric),4) aa
 						 from Students s join Course_enrolments e on (e.student = s.id)
                         join Courses c on (c.id = e.course)
                         join Subjects su on (c.subject = su.id)
                         join Semesters t on (c.semester = t.id)
                     	 , (select         su.code,
                         t.year, t.term,                         
             				   count(*) total,
						  rank() over (partition by su.code  order by count (*) desc) rr
                from Students s join Course_enrolments e on (e.student = s.id)
                         join Courses c on (c.id = e.course)
                         join Subjects su on (c.subject = su.id)
                         join Semesters t on (c.semester = t.id)
                     	 where  su.code LIKE 'COMP%'
						 group by su.code,
                         t.year, t.term                       
						  having count(*)>150) q1
						  where rr=1  and  su.code LIKE 'COMP%' and q1.code=su.code 
						  and q1.year=t.year and q1.term=t.term 
						  group by su.code,
                         t.year, t.term 
						 order by 2 desc,3
						 ;