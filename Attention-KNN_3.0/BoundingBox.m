function [num_frame,min_x,min_y,max_x,max_y,bound_area,T_move_cut]=BoundingBox(gray_im_seq,dilate_x,dilate_y)
%     imageNames = dir(fullfile(write_gray_path,'*.jpg'));
%     imageNames = {imageNames.name}';

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   % load('/Users/jiaweisun/Desktop/Object_Tracking/matlab_T_4_5.mat');
%???????????????????
   
    Background=gray_im_seq{1};
    [H,W]=size(Background);
    num_frame=0;
%     sign=1;
    for k=1:length(gray_im_seq)
%         num_k = floor(length(gray_im_seq)/2)+sign*floor(k/2);
%         num_k = max(1,num_k);
%         num_k = min(length(gray_im_seq),num_k);
%         sign = -sign;
        image_value=gray_im_seq{k};
        [boundary,bound_area]=find_image_contours(image_value);
        min_x=min(boundary(:,2));
        max_x=max(boundary(:,2));
        min_y=min(boundary(:,1));
        max_y=max(boundary(:,1));
        
        %T_move = procrustes1(boundary,Aa);
        if (max_x-min_x)>500 && (max_y-min_y)>500
            num_frame=k;
            break;
        end
    end
    
    T_maze = find_Tmaze(min_x,min_y,max_x,max_y,boundary);
    if  length(T_maze)==length(boundary)
        T_move = procrustes(boundary,T_maze);    
    elseif length(T_maze)>length(boundary)
        sample=floor( [1:length(boundary)]/length(boundary) * length(T_maze) );
        T_sample = T_maze(sample,:);
        T_move = procrustes(boundary,T_sample);
    else
        sample=floor( [1:length(T_maze)]/length(T_maze) * length(boundary) );
        boundary_sample = boundary(sample,:);
        T_move = procrustes(boundary_sample,T_maze);
    end
    
%     delta_x=abs(max_x-min_x);
%     delta_y=abs(max_y-min_y);
%     dilate_x=int16(delta_x*dilate_x);
%     dilate_y=int16(delta_y*dilate_y);
    if num_frame == 0
        min_x = 0;
        min_y = 0;
        max_x = W;
        max_y = H;
    end
    min_x=max(0,min_x-dilate_x);
    max_x=min(W,max_x+dilate_x);
    min_y=max(0,min_y-dilate_y);
    max_y=min(H,max_y+dilate_y);
    
    T_move_cut(:,2) = T_move(:,2) - min_x;
    T_move_cut(:,1) = T_move(:,1) - min_y;
%     hold on;
%     plot(T_move_cut(:,2),T_move_cut(:,1));
%     hold on;
%     plot(min_x,min_y,'o');
    %xx=[];
    
end


