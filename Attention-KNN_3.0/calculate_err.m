function [cut_pos,err,mean_err,std_err,min_err,min_ind]=calculate_err(folder,...
    orimov_path,orimov_name,mean_x,mean_y,cut_corr,scale)
    % folder = '/Users/jiaweisun/Desktop/Object_Tracking/groundtruth/';
    if  ~exist(folder,'dir')
        mkdir(folder)
    end
    mat_full_name=strcat(folder,orimov_path,'_',orimov_name,'.mat');
    load(mat_full_name,'gTruth');

    
    Label_Data=gTruth.LabelData;
    num_label=1;
    [l,~]=size(Label_Data);
    Output=zeros(l,3);
    for frame=1:l
        A=Label_Data(frame,:).Worm;
        data=A{1,1};
        if ~isempty(data)
            data=data{1};
            mean_data=int16(mean(data));
            Output(num_label,1)=frame;
            Output(num_label,2)=mean_data(1);
            Output(num_label,3)=mean_data(2);
            num_label=num_label+1;
        end
    end
    for i=num_label:l
        Output(num_label,:)=[];
    end
    % add cut_image coordinate information
    % delete all zeros in cut_corr
    cut_corr=cut_corr(find(cut_corr(:,3)),:);
    
    % Output is original frames, because it is from the labeled data 
    % while cut_pos should be cut_frames
    
    cut_pos=zeros(length(Output),3);
    num_label_frame=1;
    for i=1:length(Output)
        frame=Output(i,1);
        corr_ind=find(abs(cut_corr(:,3)-frame)<1e-3, 1);% find actual frame
        if ~isempty(corr_ind)
            cut_pos(num_label_frame,1)=corr_ind;% cut_corr (y,x,frame)
            cut_pos(num_label_frame,2)=Output(i,2)-cut_corr(corr_ind,2); 
            cut_pos(num_label_frame,3)=Output(i,3)-cut_corr(corr_ind,1);
            num_label_frame=num_label_frame+1;
        end
    end
    
    for i=num_label_frame:length(Output)
        cut_pos(num_label_frame,:)=[];
    end
    
    err=zeros(length(cut_pos),2);
    for i=1:length(cut_pos)
        frame=cut_pos(i,1);
        err(i,1)=frame;
        delta_x=abs(mean_x(frame-1)-cut_pos(i,2));
        delta_y=abs(mean_y(frame-1)-cut_pos(i,3));
        err(i,2)=sqrt(power(delta_x,2)+power(delta_y,2));
    end
    err(:,2)=err(:,2)/scale;
    mean_err=mean(err(:,2));
    std_err=std(err(:,2));
    [min_err,min_ind]=min(err(:,2));
end

