col sumb format 999,999,999,999
col extents format 9999
col bytes format 999,999,999,999
col largest format 999,999,999,999
col Tot_Size format 999,999,999,999
col Tot_Free format 999,999,999,999
col Pct_Free format 999,999,999,999
col Chunks_Free format 999,999,999,999
col Max_Free format 999,999,999,999
col file_name format a50
col owner format a15
col segment_name format a30
col tablespace format a20
set echo off
set linesize 200
set pagesize 120


PROMPT SEGMENTS WHERE THERE'S NOT ENOUGH ROOM FOR THE NEXT EXTENT

select a.segment_name, b.tablespace_name,
decode(ext.extents,1,b.next_extent,
a.bytes*(1+b.pct_increase/100)) nextext,
freesp.largest
from user_extents a,
user_segments b,
(select segment_name, max(extent_id) extent_id,
count(*) extents
from user_extents
group by segment_name) ext,
(select tablespace_name, max(bytes) largest
from user_free_space
group by tablespace_name) freesp
where
a.segment_name=b.segment_name and
a.segment_name=ext.segment_name and
a.extent_id=ext.extent_id and
b.tablespace_name = freesp.tablespace_name and
b.tablespace_name='&TBSP_NAME' and
decode(ext.extents,1,b.next_extent,
a.bytes*(1+b.pct_increase/100)) > freesp.largest;

select tablespace_name from dba_tablespaces;
