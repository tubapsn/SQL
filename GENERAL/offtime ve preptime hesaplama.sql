declare 
@off int ,
@preptime int,
@Now datetime
  ,@StartTime datetime


set @Now =  '2022-03-16 16:00:26.128' 
set @StartTime = '2022-03-16 08:00:26.128'

SELECT 
@off= ISNULL(sum(case when T1.PRD_STEP = 0 then  datediff(second, START_TIME, END_TIME) end),0)/60 , 
@preptime= ISNULL(sum(case when T1.PRD_STEP = 1 then  datediff(second, START_TIME, END_TIME) end),0)/60 


FROM
(
SELECT [MACHINE_ID], 
case when [START_TIME] < @StartTime then @StartTime else START_TIME end "START_TIME", 
case when [END_TIME] > @Now  or END_TIME is null then @Now  else END_TIME end "END_TIME", 
STATUS, 
[REASON_ID], 
[INSERT_BY], 
PRD_STEP,
PLANNED
FROM [HIST_DOWNTIME], [CNFG_DOWNTIME_REASON]
WHERE (START_TIME  between @StartTime and @Now
    or END_TIME between @StartTime and @Now
    or (START_TIME < @StartTime and (END_TIME > @Now  or END_TIME is null)))
    AND dbo.[HIST_DOWNTIME].[MACHINE_ID] in (61)
    AND dbo.[CNFG_DOWNTIME_REASON].[ID] = dbo.[HIST_DOWNTIME].[REASON_ID]
    at isolation read uncommitted
    ) T1, [CNFG_MACHINE]
    WHERE dbo.[CNFG_MACHINE].[ID] = T1.MACHINE_ID

GROUP BY NAME

select @off, @preptime
