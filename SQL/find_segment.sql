select owner
    , segment_name
    , segment_type
    , tablespace_name
    , block_id
    , blocks
from dba_extents
where file_id=12
and block_id in (
    select max(block_id)
    from dba_extents
    where file_id=12
    and block_id <= 344638
);
