function [mean_x, mean_y,T_move_sim,decision,distance,speed]=run_script(folder,orimov_path,orimov_name,write_path,label,...
    mov_str,dilate_x,dilate_y,svd_rank,min_th,max_th,knn_bool,label_step,...
    knn_k,shrink_k)
    orimov_full_name=strcat(orimov_name,mov_str);
    orimov_full_path=fullfile(orimov_path,orimov_full_name);
    % You should give a direct workspace path and a movie path
    %%
    disp('convert2gray starts!');
    tic;
    [gray_im_seq,fs]=convert2gray(orimov_full_path);
    toc;
    disp('convert2gray finished!');
    %%
    disp('Finding Bounding Box!');
    tic;
    [num_frame,min_x,min_y,max_x,max_y,~,T_move_cut]=BoundingBox(...
        gray_im_seq,dilate_x,dilate_y);
    % min_x in Finding Bounding Box is min_y in cutimage and min_y in Finding Bounding Box is min_x in cutimage
%     scale=sqrt(bound_area/real_area);
    toc;
    disp('Finding Bounding Box Finished!');
    %%
    disp('cutimage starts!');   
    tic;
       % k shrinking scalar
    % It may take a lot of time to run cutimage
    if num_frame ~=0
        [cut_im_seq,coordinate,compenvalue]=cutimage(gray_im_seq,shrink_k,...
            num_frame,min_x,min_y,max_x,max_y);
    else
        cut_im_seq = gray_im_seq;
    end
        % k=0.2 scalar, num_frame as standard frame, min_x left_top point,
        % min_y left_top point, max_x wide of Tmaze, max_y length of Tmaze
    toc;
    disp('cutimage finished!'); 
    %%
%     disp('cutimage_video starts');
%     tic;
%     cutimage_str='_cutresult';
%     cutvideo_name=fullfile(folder,orimov_path,strcat(orimov_name,label,cutimage_str));
%     cutimage_video(write_cutimage_path,cutvideo_name);
%     toc;
%     disp('cutimage_video finished')
    %%  
    disp('SVD starts!');
    tic;
    % It may take a lot of time to run svd
    svd_im_seq=svd_worm(cut_im_seq,svd_rank);
    toc;
    disp('SVD finished!');
    %%
    disp('Foreground Detection starts!');
    if num_frame ~=0
        [mean_x,mean_y]=ForegroundDetector(svd_im_seq,T_move_cut,...
            coordinate,compenvalue,min_th,max_th,knn_bool,label_step,knn_k);
    else
        [mean_x,mean_y]=ForegroundDetector_Naive(svd_im_seq,min_th,max_th,knn_bool,label_step,knn_k);
    end
    disp('Foreground Detection finished!');
%%
    result_str='_result';
    video_name=fullfile(folder,write_path,orimov_path,strcat(orimov_name,label,...
        result_str));
    if ~exist(fullfile(folder,write_path,orimov_path),'dir')
        mkdir(fullfile(folder,write_path,orimov_path));
    end
%%
%     disp('Calculate starts!');
%     [gTruth_data,err,mean_err,std_err,~,min_ind]=calculate_err(...
%         gTruth_folder,orimov_path,orimov_name,...
%         mean_x,mean_y,cut_corr,scale);
%     disp('Calculate Error finished!');
%%
%     predicted_x=mean_x;
%     predicted_y=mean_y;
%     [gTruth_data,predicted_err,predicted_mean_err,predicted_std_err,~,~]=...
%         calculate_err(gTruth_folder,orimov_path,orimov_name,predicted_x,predicted_y);
    
    %write_label_data(gTruth_folder,orimov_path,orimov_name,predicted_err,predicted_mean_err,predicted_std_err,scale);
    disp('write to video starts!');
    tic;
    if num_frame ~=0
        [T_move_cut_c, decision, distance, speed]=show_video(video_name,cut_im_seq,...
            mean_x,mean_y,T_move_cut,coordinate,compenvalue, fs);
        polyin = polyshape(T_move_cut_c(:,2),T_move_cut_c(:,1),'Simplify',false);
        polyout = simplify(polyin);
        T_move_sim = polyout.Vertices;
    else
        show_video_naive(video_name,cut_im_seq,mean_x,mean_y, fs);
    end
    toc;
    disp('write to video finished!');
    close all;
    clearvars -except mean_x mean_y T_move_sim decision distance speed;
end


