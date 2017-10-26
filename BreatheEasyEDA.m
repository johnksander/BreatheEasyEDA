function BreatheEasyEDA
% Breathe Easy EDA (BEEDA)
% Written by John C Ksander and Christopher R Madan
% Please see the accompanying documentation with this software. 
%
% Copyright (C) 2016 Ksander & Madan
%
% This program is free software: you can redistribute it and/or 
% modify it under the terms of the GNU General Public License as 
% published by the Free Software Foundation, either version 3 of
% the License, or (at your option) any later version. 
%
% This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied 
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
% PURPOSE. See the GNU General Public License for more details. 
%
% You should have received a copy of the GNU General Public 
% License along with this program. If not, see 
% <http://www.gnu.org/licenses/>. 



%Start BEEDA 
curr_dir = strsplit(which(mfilename('fullpath')),'BreatheEasyEDA.m');
run(fullfile(curr_dir{1},'BEEDA','gui_files','startBEEDA.m'))

