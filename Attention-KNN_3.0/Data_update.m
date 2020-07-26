data_path = fullfile(folder,'result_folder','Worm_Result.mat');
C=load(data_path);
Data = C.OutputResult;
Interval = squeeze(struct2cell(Data));
Mov_folder = Interval(1,:);
Mov_name = Interval(2,:);
%%
len = size(OutputResult,2);
for i =1:len
    gene_folder = OutputResult(i).genefolder;
    mov_name = OutputResult(i).movname;
    [index1,~] = ismember(gene_folder,Mov_folder);
    if index1
        [index2,location] = ismember(mov_name,Mov_name);
        if index2
            Data(location) = OutputResult(i);
        end
    end
    
end

OutputResult = Data;
save(data_path,'OutputResult');
