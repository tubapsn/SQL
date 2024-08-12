                   
declare 
  @Now datetime
  ,@StartTime datetime
  ,@PlannedTimeCnt int
  ,@OrderType varchar(6)
  ,@MachineId int
  ,@RecTime datetime
  
  
select @MachineId = ID from CNFG_MACHINE where NAME = 'P02-31' 
set @Now =  '2022-03-16 16:00:26.128' 
set @StartTime = '2022-03-16 08:00:26.128'

--SELECT @MachineId
--SELECT * FROM [CNFG_DOWNTIME_REASON]
SELECT  TOP 1 [MACHINE_ID], dbo.[HIST_DOWNTIME].[REASON_ID] , dbo.[CNFG_DOWNTIME_REASON].OPER_PLANNED,

 SUM(
 case when CNFG_DOWNTIME_REASON.PLANNED = 0 then datediff(minute,
 (case when HIST_DOWNTIME.START_TIME < @StartTime then @StartTime else HIST_DOWNTIME.START_TIME end),
 (case when HIST_DOWNTIME.END_TIME is null then @Now else HIST_DOWNTIME.END_TIME end))   
 else 0 end
  )
 ,
 
  SUM(
 case when CNFG_DOWNTIME_REASON.PLANNED = 1 then datediff(minute,
 (case when HIST_DOWNTIME.START_TIME < @StartTime then @StartTime else HIST_DOWNTIME.START_TIME end),
 (case when HIST_DOWNTIME.END_TIME is null then @Now else HIST_DOWNTIME.END_TIME end))   
 else 0 end
  )
 
 FROM [HIST_DOWNTIME],[CNFG_DOWNTIME_REASON]  
 
--FROM [HIST_DOWNTIME]
--INNER JOIN [CNFG_DOWNTIME_REASON] ON dbo.[HIST_DOWNTIME].[REASON_ID]= dbo.[CNFG_DOWNTIME_REASON].[ID]
WHERE 
(PRD_STEP = 1 or PRD_STEP = 2 or PRD_STEP = 3) AND 
[MACHINE_ID]=@MachineId AND  
 STATUS = 0 AND
 dbo.[CNFG_DOWNTIME_REASON].[ID]= dbo.[HIST_DOWNTIME].[REASON_ID] AND 
(dbo.[HIST_DOWNTIME].[START_TIME] BETWEEN @StartTime AND @Now
OR
dbo.[HIST_DOWNTIME].[END_TIME] BETWEEN @StartTime AND @Now)
group by MACHINE_ID







