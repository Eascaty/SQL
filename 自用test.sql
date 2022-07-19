# 1.查询" 01 “课程比” 02 "课程成绩高的学生的信息及课程分数
select t1.sid, t1.score as class1, t2.score as class2
from (select sid, cid, score from sc where Cid = '01') t1,
     (select sid, cid, score from sc where CId = '02') t2
where t1.sid = t2.SId
  and t1.score > t2.score;

#left join 测试
select *
from student
         left join sc
                   on student.SId = sc.SId;

# 1.1查询同时存在” 01 “课程和” 02 “课程的情况
Select sc.sid
from sc
Where sc.cid = '01'
  and sc.sid in (select sid from sc where cid = '02');

# 1.2查询存在” 01 “课程但可能不存在” 02 “课程的情况(不存在时显示为 null )
Select *
from (select * from sc where sc.cid = '01') t1
         Left join (select * from sc where sc.cid = '02') t2
                   On t1.sid = t2.sid;

# 1.3查询不存在” 01 “课程但存在” 02 "课程的情况
select *
from sc
where sc.CId = '02'
  and sc.SId not in (select sc.CId = '01');
# 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
# select sc.SId,avg(sc.score) avg_score from sc
# join student st
# On sc.sid = st.SId
# GROUP BY  sc.SId
# HAVING  avg_score >=60

select t1.sid, s.sname, t1.avg
from student s
         join
     (select sc.sid, AVG(score) as avg from sc GROUP BY sc.sid having avg >= 60) t1
     on
         t1.sid = s.sid;

# 查询在 SC 表存在成绩的学生信息
Select sc.*, st.*
from sc
         Left join student st
                   On sc.sid = st.sid;

# select s.sage,s.sname,s.ssex,s.sid from student s
# where s.sid in (select SId from sc where score >=0)

# 4查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
select Max(st.Sname), Max(st.SId), count(sc.cid), sum(sc.score)
from student st
         left join sc on st.SId = sc.SId
GROUP BY st.SId;


# 4.1查有成绩的学生信息
select distinct student.*
from sc
         left join student on student.SId = sc.SId
where sc.score >= 0;

Select t.*
from student t
Where t.sid in (select sid from sc);


# 查询「李」姓老师的数量
select count(teacher.tname) as '李老师数量'
from teacher
Where tname like '李%';


# 查询学过「张三」老师授课的同学的信息
Select sc.sid, st.*
from sc
         Left join student st
                   On sc.sid = st.sid
Where sc.cid in (Select c.cid
                 from course c
                          Join teacher t
                               On c.tid = t.tid
                 Where t.tname = '张三');


select distinct student.*
from sc
         left join student on student.SId = sc.SId
where (select sc.CId
       from course
       where course.CId = (select course.Tid from teacher where teacher.Tid = 01)
      );

# 查询没有学全所有课程的同学的信息
select student.*
from student
where student.SId not in (select sc.sid from sc group by sc.sid having count(CId) = (select count(CId) from course));

# 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
select student.*
from student
where sid in (select distinct SId
              from sc
              where sc.cid in (
                  select CId
                  from sc
                  where sid = 01));



Select distinct sc.sid, st.*
from sc
         Join student st
              On sc.sid = st.sid
Where sc.cid in (Select cid from sc where sid = 01);

# 查询和" 01 "号的同学学习的课程 完全相同的其他同学的信息
select *
from student
where sid in (
    select sid
    from sc
    group by sid
    having group_concat(cid ORDER BY cid) = (
        select group_concat(cid ORDER BY cid)
        from sc
        where sid = '01')
       and sid != '01');

# 查询没学过"张三"老师讲授的任一门课程的学生姓名
select  sname
from student
where  student.sid not in(select sid
             from sc
             where cid  in (select cid from course where tid = (select Tid from teacher where Tname = '张三')));


select st.sname from student st
where st.sname not in
(select st.sname from student st,sc,course c,teacher t
where st.sid = sc.sid and sc.cid = c.cid and c.tid = t.tid and t.tname = '张三');



# 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
Select SID as 学号,Avg(Score) as 平均成绩 From sc
Where (Select Count(*) From sc s1 Where s1.SId=sc.SId And  Score<60 )>=2 Group By SId;


# 检索" 01 "课程分数小于 60，按分数降序排列的学生信息
select student.* from student where SId in (select sid from sc where sc.score<60 and sc.CId=01 order by sc.score desc );


select sc.sid,st.sname from sc
join student st
on sc.sid = st.sid
where sc.cid = '01' and sc.score <60
order by sc.score desc;

# 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select sid,avg(score) over(partition by sid) as avg_score,cid,score from sc
order by avg_score desc;

# 查询各科成绩最高分、最低分和平均分
select max(score),min(score),avg(score) from sc group by  CId;


# 以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率 及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90 要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
select
 s.cid
 ,c.cname
 ,max(s.score)
 ,min(s.score)
 ,round(avg(s.score), 2)
 ,round(100 * (sum(case when s.score >= 60 then 1 else 0 end) / sum(case when s.score then 1 else 0 end)), 2) as 及格率
 ,round(100 * (sum(case when s.score >= 70 and s.score <= 80 then 1 else 0 end) / sum(case when s.score then 1 else 0 end)), 2) as 中等率
 ,round(100 * (sum(case when s.score >= 80 and s.score <= 90 then 1 else 0 end) / sum(case when s.score then 1 else 0 end)), 2) as 优良率
 ,round(100 * (sum(case when s.score >= 90 then 1 else 0 end) / sum(case when s.score then 1 else 0 end)), 2) as 优秀率
from Sc s
left join Course c
on s.cid = c.cid
group by s.cid, c.cname;


# 按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺

    select s.sid,s1.课程1排名,s2.课程2排名,s3.课程3排名
    from Student s left join
    (select sid,rank() over (order by score desc) 课程1排名
    from SC
    where cid='01')s1 on s.sid=s1.sid
    left join
    (select sid,rank() over (order by score desc) 课程2排名
    from SC
    where cid='02')s2  on s.sid=s2.sid
    left join
    (select sid,rank() over (order by score desc) 课程3排名
    from SC
    where cid='03')s3 on s.sid=s3.sid;





# 按各科成绩进行排序，并显示排名， Score 重复时合并名次
# select sid,sum(score) 总分, dense_rank() over (order by sum(score) desc) 总分排名
# from SC
# group by sid;

select sid,sum(score) 总分, dense_rank() over (order by sum(score)desc )总分排名
from sc
group by  sid;



# 要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
select cid, count(sid) from sc
group by cid
order by 2 desc,1;

# 查询学生的总成绩，并进行排名，总分重复时保留名次空缺
SELECT *, rank() over (ORDER BY 总成绩 DESC) AS 排名
FROM (SELECT `SId`, SUM(`score`) AS 总成绩
      FROM `sc`
      GROUP BY `SId`
     ) a;

# 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
SELECT *,
       dense_rank() over (ORDER BY 总成绩 DESC) AS 排名
FROM (SELECT `SId`, SUM(`score`) AS 总成绩
      FROM `sc`
      GROUP BY `SId`
     ) a;

# 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
select cid,
sum(case when score between 85 and 100 then 1 else 0 end)*1.0/count(sid) '85-100',
sum(case when score between 70 and 85 then 1 else 0 end)*1.0/count(sid) '70-85',
sum(case when score between 60 and 70 then 1 else 0 end)*1.0/count(sid) '60-70',
sum(case when score between 0 and 60 then 1 else 0 end)*1.0/count(sid) '0-60'
from sc group by cid;

# 查询各科成绩前三名的记录
select * from sc
where
(select count(*) from sc a
where sc.cid=a.cid and sc.score<a.score)<3
order by cid asc,sc.score desc;

# 查询每门课程被选修的学生数
select cid, count(sid) from sc
group by cid;

# 查询出只选修两门课程的学生学号和姓名
select sc.sid from sc
group by sid
having count(distinct cid)=2;


# 查询男生、女生人数
select count(distinct t1.sid) 男,count(distinct t2.sid) 女 from
(select sid from student where ssex = '男') t1,
(select sid from student where ssex = '女') t2;

# 查询名字中含有「风」字的学生信息
select * from student
where sname like '%风%';

# 查询同名同性学生名单，并统计同名人数
SELECT sname,COUNT(*)
FROM student
GROUP BY sname
HAVING COUNT(*) > 1;

# 查询 1990 年出生的学生名单
select * from student
where sage between '1990-01-01' and '1991-01-01';

# 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
select avg(score),cid from sc group by cid
order by 1 desc, 2;

select distinct cid, avg(score) over (partition by cid) avg_score from sc
order by 2 desc,1;

# 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩
select * from
(select distinct sid , avg(score) over (partition by sid) avg_score from sc) t1
where avg_score >= 85;

# 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
select st.sname,sc.*,c.cname from sc
join course c
on sc.cid = c.cid and c.cname = '数学'
join student st
on sc.sid = st.sid
where sc.score < 60;

# 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
select st.sid, st.sname,sc.* from student st
left join sc
on st.sid = sc.sid;

# 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
select sc.sid, st.sname, c.cname, sc.score from sc
join  student st
on sc.sid = st.sid
join course c
on sc.cid = c.cid
where sc.score > 70;

# 查询不及格的课程
select sc.sid, st.sname, c.cname, sc.score from sc
join  student st
on sc.sid = st.sid
join course c
on sc.cid = c.cid
where sc.score < 60;



# 查询课程编号为 01 且课程成绩在 80 分以上的学生的学号和姓名

select sc.cid, sc.sid, st.sname,sc.score from sc
join student st
on sc.sid = st.sid
where sc.cid = '01' and sc.score >=80;

# 求每门课程的学生人数
select sc.cid, count(sc.sid) from sc
group by sc.cid;

# 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
SELECT Student.*,SC.CId,score
FROM Student JOIN SC ON Student.SId = SC.SId
JOIN Course ON SC.CId = Course.CId
JOIN Teacher ON Course.TId = Teacher.TId
WHERE Tname = '张三'
ORDER BY score DESC LIMIT 1;

# 这个因为有max会有类型报错
# select st.*,max(sc.score) from sc
# join course c
# on sc.cid = c.cid
# join teacher t
# on c.tid = t.tid
# join student st
# on sc.sid = st.sid
# WHERE Tname = '张三'


# 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
SELECT Student.*,SC.CId,score
FROM Student JOIN SC ON Student.SId = SC.SId
JOIN Course ON SC.CId = Course.CId
JOIN Teacher ON Course.TId = Teacher.TId
WHERE Tname = '张三' AND score IN
(SELECT MAX(score) FROM
SC JOIN Course ON SC.CId = Course.CId
JOIN Teacher ON Course.TId = Teacher.TId
WHERE Tname = '张三');

# 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
select distinct a.* from sc a join sc b on a.SId=b.SId
where a.score=b.score and a.CId!=b.CId;


# 查询每门功成绩最好的前两名
SELECT A.CId,A.SId,A.score,COUNT(B.score) +1 as ranking
FROM SC AS A LEFT JOIN SC AS B
ON A.CId = B.CId AND A.score<B.score
GROUP BY A.CId,A.SId,A.score
HAVING ranking <= 2
ORDER BY A.CId,ranking;
# 统计每门课程的学生选修人数（超过 5 人的课程才统计）。
select * from
(select cid, count(distinct sid) as num from sc
group by cid) t1
where num > 5;



# 检索至少选修两门课程的学生学号

select sid
from (select sid, count(cid) as num from sc group by sid) t1
where num > 2;



# 查询选修了全部课程的学生信息
select sid from sc
group by sid
having count(distinct cid) = (select count(distinct cid) from course);

# 查询各学生的年龄，只按年份来算
select sid, sname, timestampdiff(year, sage, current_date()) age from student

# 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
SELECT sname,
   CASE
    WHEN (DATE_FORMAT(NOW(),'%m-%d') - DATE_FORMAT(sage,'%m-%d')) < 0
        THEN YEAR(NOW()) - YEAR(sage) - 1
        ELSE YEAR(NOW()) - YEAR(sage)
    END AS age
FROM student;

# 查询本周过生日的学生
select *
from student
where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(current_date())

# 查询下周过生日的学生
select *
from student
where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(current_date())+1

# 查询本月过生日的学生
select *
from student
where MONTH(student.Sage)=MONTH(current_date())

# 查询下月过生日的学生
select *
from student
where MONTH(student.Sage)=MONTH(current_date())+1

