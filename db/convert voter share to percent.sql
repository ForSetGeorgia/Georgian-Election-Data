update data as d, indicators as i, indicator_translations as it
set d.value = 100*d.value
where
i.id = it.indicator_id
and i.id = d.indicator_id
and it.locale = 'en' 
and it.name like 'voter share%'

