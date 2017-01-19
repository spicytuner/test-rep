select count(*)
  from MASTERM.BZ_INCIDENT_DAT i, aradmin.bz_incident@remprd b
where i.STATUS in ('Closed', 'Resolved')
  and i.RESOLUTION_DATE is null
and b.incident_id=i.incident_id
and b.last_modified_by='AR_ESCALATOR' ;

/*
select i.incident_id, b.last_modified_by, b.closed_date, b.resolution_date
  from MASTERM.BZ_INCIDENT_DAT i, aradmin.bz_incident@remprd b
where i.STATUS in ('Closed', 'Resolved')
  and i.RESOLUTION_DATE is null
and b.incident_id=i.incident_id ;

select  i.CREATE_DATE, i.CLOSED_DATE, i.RESOLUTION_DATE, i.START_DATE,
i.STATUS, i.CTI_TYPE, i.Category, i.Type
from MASTERM.BZ_INCIDENT_DAT i
where i.STATUS in ('Closed', 'Resolved')
and i.RESOLUTION_DATE is null
and i.CREATE_DATE > to_date('2008-01-01', 'yyyy-mm-dd');

*/
