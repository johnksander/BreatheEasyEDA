function write2csv(FN,data)
%---writes a cell array to specified file in csv format

FN = [FN '.csv']; %append file ext.
Nrow = size(data,1);
Ncol = size(data,2);

f = fopen(FN,'w');
for i = 1:Nrow
    for j = 1:Ncol
        entry = data{i,j};
        if ischar(entry)
            fmt = '%s';
        else
            fmt = '%f';
        end
        if j == Ncol
            dlm = '\n';
        else
            dlm = ',';
        end
        fprintf(f,[fmt,dlm],entry);
    end
end
fclose(f);
