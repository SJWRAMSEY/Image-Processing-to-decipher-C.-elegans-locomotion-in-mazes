function [mean_x,mean_y]=ForegroundDetector(svd_im_seq,T_move_cut,...
    coordinate,compenvalue,min_th,max_th,lab_k,th,knn_k)
    %open(outputVideo)
%     imageNames = dir(fullfile(filepath,'*.jpg'));
%     imageNames = {imageNames.name}';
    Background=svd_im_seq{1};
    
    %Foreground = zeros(size(Background));
    A=zeros(length(svd_im_seq)-1,1);
    mean_x=zeros(size(A));
    mean_y=zeros(size(A));
    [M,N] = size(Background);
    %M =y,N=x; y<x; [y,x] = size(Background)
    L1=[];
    L2=[];
    for i=1:M
        L1 = [L1;[1:N]'];
    end
    for i=1:M
        L2 = [L2;i*ones(N,1)];
    end
    L = [L1 L2];
    sample=round( [1:500]/500 * length(T_move_cut) );
    T_move_cut = T_move_cut(sample,:);
    
    for frame=2:length(svd_im_seq)
        
        T_move_cut_c(:,2) = T_move_cut(:,2)-compenvalue(frame,2);  %%compensate T_maze
        T_move_cut_c(:,1) = T_move_cut(:,1)-compenvalue(frame,1);
        polyin = polyshape(T_move_cut_c(:,2),T_move_cut_c(:,1),'Simplify',false);
        polyout1 = polybuffer(polyin,30);
        
%         [in,on] = inpolygon(L1,L2,polyout1.Vertices(:,1),polyout1.Vertices(:,2));
%         T_maze_logical = reshape(in,[N,M]);
%         T_maze_logical = T_maze_logical';
%         
        
        thisframe=svd_im_seq{frame};
        FrameDiff = abs(double(thisframe) - double(Background));
        Background=svd_im_seq{frame};
        
        
        
        Foreground_logical = (FrameDiff > min_th);
        A(frame)=sum(Foreground_logical,'all');
        if A(frame)<=max_th
            f_l_t = Foreground_logical';
            Foreground_logical_vec = f_l_t(:) ;
            L_logical = L.*[Foreground_logical_vec, Foreground_logical_vec];
            in = zeros(length(L_logical),1);
            
            for i=1:length(L_logical)
                if L_logical(i,1)
                    [in(i),on] = inpolygon(L1(i),L2(i),polyout1.Vertices(:,1),polyout1.Vertices(:,2));
                end   
            end
            T_maze_logical = reshape(in,[N,M]);
            T_maze_logical = T_maze_logical';
            
            Foreground = (double(thisframe)).*T_maze_logical;
            Foreground = bwareaopen(Foreground, 10);
            
            [row,col]=find(Foreground);
            mean_x(frame-1)=mean(col);
            mean_y(frame-1)=mean(row);
        end
    %   

    end
    
    %t=linspace(1,nFrameRead-1,nFrameRead-1);
    for i=1:length(svd_im_seq)-1
        if isnan(mean_y(i))
            mean_y(i)=0;
        end
    end
    for i=1:length(svd_im_seq)-1
        if isnan(mean_x(i))
            mean_x(i)=0;
        end
    end
    
    
    
    color_label = zeros(length(mean_x),1);
    mean_x=linear_stable(mean_x);
    mean_y=linear_stable(mean_y);
    
    
    if length(mean_x)>20 && lab_k ==1
        if length(mean_x)<30
            rtimes = 1;
        elseif length(mean_x)<60
            rtimes = 3;
        else
            rtimes = 5;
        end
%         rtimes = 6;
        for times=1:rtimes
            color_label = change_color(mean_x,mean_y,color_label,th);
        
            location=[mean_x,mean_y];
            for i=1:length(mean_x)
                if color_label(i)==0
                    idx=knnsearch(location,[mean_x(i),mean_y(i)],'K',knn_k);
                    change_label=mode(color_label(idx(2:end)));
                    color_label(i)=change_label;
                end
            end
        
    
            for i=1:length(mean_x)
                if color_label(i) == 1
                    mean_x(i)=0;
                    mean_y(i)=0;
                end
            end
            mean_x=linear_stable(mean_x);
            mean_y=linear_stable(mean_y);
        end
    end
    
    
end


function plot_delta_xy(x,y)
    delta_mean_x=zeros(length(x)-1,1);
    for i=1:length(x)-1
        delta_mean_x(i)=x(i+1)-x(i);
    end
    delta_mean_y=zeros(length(y)-1,1);
    for i=1:length(y)-1
        delta_mean_y(i)=y(i+1)-y(i);
    end
    
    t=linspace(1,length(delta_mean_y),length(delta_mean_y));
    figure
    plot(t,delta_mean_x);
    figure
    plot(t,delta_mean_y);
    
end


function y=linear_regression(x)
    t=find(x(1:end),1);
    for i=1:t
        x(i)=x(t);
    end
    for i=1:length(x)
        if x(i)==0
            previous=i-find(x(1:i), 1, 'last' );
            next=find(x(i:end), 1 )-1;
            if ~isnan(next) 
                previous_sample=i-previous;
                next_sample=i+next;
                x(i)=(next/(previous+next))*x(previous_sample)+...
                (previous/(previous+next))*x(next_sample);
            end
        end
    end
    y=x;
end
function y=linear_stable(x)
    t=find(x(1:end),1);
    for i=1:t
        x(i)=x(t);
    end
    for i=1:length(x)
        if x(i)==0
            
            previous=i-find(x(1:i), 1, 'last' );
            next=find(x(i:end), 1 )-1;
            
            if ~isnan(next) 
                previous_sample=i-previous;
                next_sample=i+next;
                if previous>next
                    x(i)=x(next_sample);
                else
                    x(i)=x(previous_sample);
                end
            end
        end
    end
    tx=find(x(1:end),1,'last');
    for i=1+tx:length(x)
        x(i)=x(tx);
    end
    y=x;
end

function [y1,y2]=linear_filter(x1,x2,t)
    delta_x1=zeros(length(x1)-1,1);
    for i=1:length(x1)-1
        delta_x1(i)=x1(i+1)-x1(i);
    end
    delta_x2=zeros(length(x2)-1,1);
    for i=1:length(x2)-1
        delta_x2(i)=x2(i+1)-x2(i);
    end
    for i=1:length(delta_x1)
        if abs(delta_x1(i))>t
            x1(i+1)=0;
        end
        if abs(delta_x2(i))>t
            x2(i+1)=0;
        end
    end
    for i=1:length(x1)
        if x1(i)==0 || x2(i)==0
            x1(i)=0;
            x2(i)=0;
        end
    end
    y1=linear_regression(x1);
    y2=linear_regression(x2);
end

function color_label = change_color(mean_x,mean_y,color_label,th)
    num_frame = 1;
    M=zeros(length(mean_x),1);
    for i=1:length(mean_x)-1
        delta_x = mean_x(i+1)-mean_x(i);
        delta_y = mean_y(i+1)-mean_y(i);
        dis=sqrt(delta_x^2+delta_y^2);
        if dis>th
            M(num_frame)=i;
            M(num_frame+1)=i+1;
            num_frame=num_frame+2;
        end
    end
    M(num_frame:end)=[];
    
    for i=1:length(M)
        color_label(M(i))=1;
    end
end




%close(outputVideo)