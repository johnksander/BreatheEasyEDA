function BEEDAdata = get_BEEDAevent_array(BEEDAdata)

event_array = cell(numel(BEEDAdata.event),3);

for idx = 1:numel(BEEDAdata.event)
     event_array{idx,1} = BEEDAdata.event(idx).time;
     event_array{idx,2} = BEEDAdata.event(idx).nid;
     event_array{idx,3} = BEEDAdata.event(idx).name;

end
BEEDAdata.event_array = event_array;
