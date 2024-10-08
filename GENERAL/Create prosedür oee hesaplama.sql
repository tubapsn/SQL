CREATE PROCEDURE OEEHESAPLA 
AS
begin
declare 
  @Now datetime
  ,@StartTime datetime
  ,@PlannedTimeCnt int
  ,@OrderType varchar(6)
  ,@MachineId int
  ,@RecTime datetime
  ,@off int 
  ,@preptime int
  

set @RecTime = '2022-03-16 15:09:26.128'

select @MachineId = ID from CNFG_MACHINE where NAME = 'P02-31'
select @OrderType = ORDER_TYPE FROM LIVE_PLANT where MACHINE_ID = @MachineId
--set @Now = getdate()
--set @StartTime = dateadd(hour,-8,@Now)

set @Now =  '2022-03-16 16:00:26.128' 
set @StartTime = '2022-03-16 08:00:26.128'

delete HELPER_HIST_OEE
WHERE [MACHINE_ID]=@MachineId

  
insert into HELPER_HIST_OEE (
   MACHINE_ID
  ,OEE_UPTIME_CNT
  ,OEE_PLANNED_TIME_CNT
  
) 

select  
  @MachineId ,
  T2.OEE_UPTIME_CNT "OEE_UPTIME_CNT",
  T2.OEE_PLANNED_TIME_CNT "OEE_PLANNED_TIME_CNT"

FROM LIVE_PLANT 
left join(
  select 
    MACHINE_ID,
    sum(case when (PRD_STEP = 2 or PRD_STEP = 3) and STATUS = 1 then (datediff(second,START_TIME,END_TIME)) else 0 end) / 60 "OEE_UPTIME_CNT",
    sum(case when PRD_STEP != 0 and PLANNED != 1 then (datediff(second,START_TIME,END_TIME)) else 0 end) / 60 "OEE_PLANNED_TIME_CNT"
  from (
  select MACHINE_ID,
    case when START_TIME < @StartTime then @StartTime else START_TIME end "START_TIME", 
    case when END_TIME is null then @Now else END_TIME  end "END_TIME", 
    STATUS, 
    REASON_ID, 
    PRD_STEP,
    PLANNED
  FROM HIST_DOWNTIME, CNFG_MACHINE, CNFG_DOWNTIME_REASON
  where 
    (END_TIME > @StartTime or END_TIME is NULL)
    and HIST_DOWNTIME.MACHINE_ID = CNFG_MACHINE.ID
    and ((CNFG_MACHINE.ID < 1000) or (CNFG_MACHINE.ID > 1000 and CNFG_MACHINE.MACHINE_TYPE > 1000))
    and CNFG_DOWNTIME_REASON.ID = HIST_DOWNTIME.REASON_ID
    and dbo.[CNFG_MACHINE].[ID]=@MachineId
    and dbo.[HIST_DOWNTIME].[START_TIME] BETWEEN @StartTime AND @Now
  ) T1
  group by MACHINE_ID
) T2
on LIVE_PLANT.MACHINE_ID = T2.MACHINE_ID
 WHERE dbo.[LIVE_PLANT].[MACHINE_ID]= @MachineId

------

select 
  HIST_PROD_STEP.MACHINE_ID,
  sum(case when HIST_PROD_STEP.ID  = 0 then
    datediff(
      second, 
      (case when HIST_PROD_STEP.START_TIME < @StartTime then @StartTime else HIST_PROD_STEP.START_TIME end),
      (case when HIST_PROD_STEP.END_TIME is null then @Now else HIST_PROD_STEP.END_TIME end)
    )
    else 0 end
  )"OFFTIME",
  sum(case when HIST_PROD_STEP.ID = 1 then
    datediff(
      second, 
      (case when HIST_PROD_STEP.START_TIME < @StartTime then @StartTime else HIST_PROD_STEP.START_TIME end),
      (case when HIST_PROD_STEP.END_TIME is null then @Now else HIST_PROD_STEP.END_TIME end)
    )
    else 0 end
  )"PREPTIME"
 into #TempTable1
 from HIST_PROD_STEP, HELPER_HIST_OEE
 where HIST_PROD_STEP.MACHINE_ID = HELPER_HIST_OEE.MACHINE_ID
 and (
  (HIST_PROD_STEP.START_TIME between @StartTime and @Now)
  or (HIST_PROD_STEP.END_TIME between @StartTime and @Now)
  or (HIST_PROD_STEP.END_TIME is null)
 )
 group by HIST_PROD_STEP.MACHINE_ID
 

--  UNPLANNED_DOWN  -  PLANNED_DOWN

select MACHINE_ID,
  sum(case when CNFG_DOWNTIME_REASON.PLANNED = 1 then
    datediff(
      second, 
      (case when HIST_DOWNTIME.START_TIME < @StartTime then @StartTime else HIST_DOWNTIME.START_TIME end),
      (case when HIST_DOWNTIME.END_TIME is null then @Now else HIST_DOWNTIME.END_TIME end)
    )
    else 0 end
  ) "PLANNED_DOWN",
  sum(case when CNFG_DOWNTIME_REASON.PLANNED = 0 then
    datediff(
      second, 
      (case when HIST_DOWNTIME.START_TIME < @StartTime then @StartTime else HIST_DOWNTIME.START_TIME end),
      (case when HIST_DOWNTIME.END_TIME is null then @Now else HIST_DOWNTIME.END_TIME end)
    )
    else 0 end
  ) "UNPLANNED_DOWN"
into #TempTable2
FROM HIST_DOWNTIME, CNFG_DOWNTIME_REASON
where (PRD_STEP = 1 or PRD_STEP = 2 or PRD_STEP = 3)
and STATUS = 0
and dbo.HIST_DOWNTIME.REASON_ID = dbo.CNFG_DOWNTIME_REASON.ID
and (
  (HIST_DOWNTIME.START_TIME between @StartTime and @Now)
  or (HIST_DOWNTIME.END_TIME between @StartTime and @Now)
  or (HIST_DOWNTIME.END_TIME is null)
 )
group by MACHINE_ID



--ooftime and preptime
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
    AND dbo.[HIST_DOWNTIME].[MACHINE_ID] in ( @MachineId)
    AND dbo.[CNFG_DOWNTIME_REASON].[ID] = dbo.[HIST_DOWNTIME].[REASON_ID]
    at isolation read uncommitted
    ) T1, [CNFG_MACHINE]
    WHERE dbo.[CNFG_MACHINE].[ID] = T1.MACHINE_ID

GROUP BY NAME


update HELPER_HIST_OEE SET
  OFFTIME = @off 
 ,PREPTIME =  @preptime 
from #TempTable1 tt
where tt.MACHINE_ID = HELPER_HIST_OEE.MACHINE_ID

update HELPER_HIST_OEE SET
  PLANNED_DOWN = tt.PLANNED_DOWN / 60
 ,UNPLANNED_DOWN = tt.UNPLANNED_DOWN / 60
from #TempTable2 tt
where tt.MACHINE_ID = HELPER_HIST_OEE.MACHINE_ID



drop table #TempTable1
drop table #TempTable2 
  

UPDATE [HIST_OEE]
SET

  OEE_A=   (CASE WHEN HHO.[OEE_PLANNED_TIME_CNT]>0 THEN  OEE_UPTIME_CNT / (OEE_PLANNED_TIME_CNT *1.0) ELSE 0 end ), 
  OEE_P= (CASE WHEN HHO.[OEE_UPTIME_CNT]>0 THEN  OEE_PERF_CNT / (OEE_UPTIME_CNT *1.0) ELSE 0 end ),
  OEE_Q= (CASE WHEN  HHO.[OEE_SCRAP] > 0 or OEE_GOODS > 0 then (OEE_GOODS *1.0) / (OEE_GOODS + OEE_SCRAP) ELSE 0 end),
  OEE= 0,
  UPTIME_CNT= (CASE WHEN HHO.[OEE_UPTIME_CNT] is null then 0 else HHO.[OEE_UPTIME_CNT] end),
  PLANNED_TIME_CNT= (CASE WHEN HHO.[OEE_PLANNED_TIME_CNT] is null then 0 else HHO.[OEE_PLANNED_TIME_CNT] end),
  PERF_CNT= (CASE WHEN HHO.[OEE_PERF_CNT] is null then 0 else HHO.[OEE_PERF_CNT] end), 
  GOODS_QTY= (CASE WHEN HHO.[OEE_GOODS] is null then 0 else HHO.[OEE_GOODS] end),
  SCRAP_QTY= (CASE WHEN HHO.[OEE_SCRAP] is null then 0 else HHO.[OEE_SCRAP] end),
  OFFTIME= (CASE WHEN HHO.[OFFTIME] is null then 0 else HHO.[OFFTIME] end),
  PREPTIME= (CASE WHEN HHO.[PREPTIME] is null then 0 else HHO.[PREPTIME] end),
  PLANNED_DOWN= (CASE WHEN HHO.[PLANNED_DOWN] is null then 0 else HHO.[PLANNED_DOWN] end),
  UNPLANNED_DOWN= (CASE WHEN HHO.[UNPLANNED_DOWN] is null then 0 else HHO.[UNPLANNED_DOWN] end)

FROM [HIST_OEE]
INNER JOIN [HELPER_HIST_OEE]  HHO ON dbo.[HIST_OEE].[MACHINE_ID] = HHO.[MACHINE_ID] 

WHERE 
     
     dbo.[HIST_OEE].[REC_TIME] BETWEEN  '2022.03.16 16:00:00' AND '2022.03.16 16:00:59' AND -- uyarı parametreye çevir
     dbo.[HIST_OEE].[MACHINE_ID] =@MachineId

  



end


GO