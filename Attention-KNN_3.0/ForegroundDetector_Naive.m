function [mean_x,mean_y]=ForegroundDetector_Naive(svd_im_seq,min_th,max_th,lab_k,th,knn_k)
    
    Background=svd_im_seq{1};
    for frame=2:length(svd_im_seq)
        thisframe=svd_im_seq{frame};
        FrameDiff = abs(double(thisframe) - double(Background));
        Background=svd_im_seq{frame};
    
        Foreground_logical = (FrameDiff > min_th);
        A(frame)=sum(Foreground_logical,'all');
        if A(frame)>max_th
            Foreground_logical=zeros(size(Background));
        end
    % 
        Foreground = (double(thisframe)).*Foreground_logical;
        Foreground = bwareaopen(Foreground, 10);
        [row,col]=find(Foreground);
        mean_x(frame-1)=mean(col);
        mean_y(frame-1)=mean(row);
    

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
            rtimes = 2;
        else
            rtimes = 3;
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