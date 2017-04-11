function [dragdata] = swapXcoords(dragdata)

start = dragdata.Xvals(2);
stop = dragdata.Xvals(1);

dragdata.Xvals(1) = start;
dragdata.Xvals(2) = stop;

end

