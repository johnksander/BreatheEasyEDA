function BEEDAdata = make_TOI_history(BEEDAdata)
%specified trials of interest have changed, don't lose old TOI data
%make TOI history from scratch
history = BEEDAdata.TOI;
%rename current types to "types", they're historic now..
history.types = history.current_types;
history = rmfield(history,'current_types');
%remove all "undo" data 
history = rmfield(history,'undo_deleted');
history = rmfield(history,'undo_deleted_resp_segments');

BEEDAdata.TOI.history = history;
