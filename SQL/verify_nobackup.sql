select d.tablespace_name, b.time
from dba_data_files d, v$backup b
where
d.file_id = b.FILE#
and b.STATUS = 'ACTIVE';
