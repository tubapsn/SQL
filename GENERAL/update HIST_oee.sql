                                                
                                                
UPDATE [HIST_OEE]
SET

--  OEE_A=   (CASE WHEN HHO.[OEE_PLANNED_TIME_CNT]>0 THEN  OEE_UPTIME_CNT / (OEE_PLANNED_TIME_CNT *1.0) ELSE 0 end ), 
--  OEE_P= (CASE WHEN HHO.[OEE_UPTIME_CNT]>0 THEN  OEE_PERF_CNT / (OEE_UPTIME_CNT *1.0) ELSE 0 end ),
--  OEE_Q= (CASE WHEN  HHO.[OEE_SCRAP] > 0 or OEE_GOODS > 0 then (OEE_GOODS *1.0) / (OEE_GOODS + OEE_SCRAP) ELSE 0 end),
  OEE= HHO.[OEE_PLANNED_TIME_CNT]
--  UPTIME_CNT= (CASE WHEN HHO.[OEE_UPTIME_CNT] is null then 0 else HHO.[OEE_UPTIME_CNT] end),
--  PLANNED_TIME_CNT= (CASE WHEN HHO.[OEE_PLANNED_TIME_CNT] is null then 0 else HHO.[OEE_PLANNED_TIME_CNT] end),
--  PERF_CNT= (CASE WHEN HHO.[OEE_PERF_CNT] is null then 0 else HHO.[OEE_PERF_CNT] end), 
--  GOODS_QTY= (CASE WHEN HHO.[OEE_GOODS] is null then 0 else HHO.[OEE_GOODS] end),
--  SCRAP_QTY= (CASE WHEN HHO.[OEE_SCRAP] is null then 0 else HHO.[OEE_SCRAP] end),
--  OFFTIME= (CASE WHEN HHO.[OFFTIME] is null then 0 else HHO.[OFFTIME] end),
--  PREPTIME= (CASE WHEN HHO.[PREPTIME] is null then 0 else HHO.[PREPTIME] end),
--  PLANNED_DOWN= (CASE WHEN HHO.[PLANNED_DOWN] is null then 0 else HHO.[PLANNED_DOWN] end),
--  UNPLANNED_DOWN= (CASE WHEN HHO.[UNPLANNED_DOWN] is null then 0 else HHO.[UNPLANNED_DOWN] end)

FROM [HIST_OEE]
INNER JOIN [HELPER_HIST_OEE]  HHO ON dbo.[HIST_OEE].[MACHINE_ID] = HHO.[MACHINE_ID] 

--SELECT * FROM [HIST_OEE]
WHERE 
   --[REC_TIME] =@RecTime AND
   --[MACHINE_ID] =@MachineId 
     
     dbo.[HIST_OEE].[REC_TIME] BETWEEN  '2022.03.16 16:00:00' AND '2022.03.16 16:00:59' AND
     dbo.[HIST_OEE].[MACHINE_ID] =61
   
 
   
   
   
  