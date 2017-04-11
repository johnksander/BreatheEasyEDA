function BEEDAdata = get_BEEDApoints(BEEDAdata)

%SCRpoints = were onset index
%SCRlevels = were onset levels

BEEDAdata.index_events = NaN(size(BEEDAdata.event));
for idx = 1:numel(BEEDAdata.event)
    [~,BEEDAdata.index_events(idx)] = min(abs(BEEDAdata.sampletimes - BEEDAdata.event(idx).time));
end


