clear;
clc;
% You should give an absolute path of work folder, which should 
% include folders with movies inside it
folder = '/Users/jiaweisun/Desktop/Object_Tracking/';
mov_str='.mp4'; 
% Change the movie type with your movie type, i.e. '.avi','.mp4'
label='_att'; % Algorithm version label
write_folder = 'result_folder'; 
% A folder located at "folder/write_path", which will store the processed movies
All_mov_path={'1'}; % All the movie folders, they should be inside
% the work folder.
dilate_x=100; % pixels along x, cutimage function parameter, change this if you
% want to resize image being cut.
dilate_y=100; % pixels along y, cutimage function parameter, change this if you
% want to resize image being cut.
svd_rank=1; % low rank approximation parameter, specifically, the rank.
min_th=20; % foreground detection function parameter, it is the minimum pixel 
% difference for a single point between the current frame and the previous
% frame, if the difference calculated is less than this threshold, this point 
% will not be activated.
max_th=1e4; % foreground detection function parameter, it is the sum of 
% the difference pixels for all points activated between the current frame
% and the previous frame, if the difference calculated is larger than this
% threshold, this frame will be considered as a noisy frame. And what
% happened in this frame will not be used to calculated the worm position
% directly, instead, will be predicted later.
knn_bool=1; % knn parameter, it is used to indicate
% whether to use knn method or not, 1 = use knn, 0 = not use knn
label_step=200; % knn parameter, it is the largest distance (pixels) between 
% the current point and the previous point, if the distance calculated is
% larger than this threshold, both the current point and the previous
% point will be considered as noisy points.
knn_k=8; % knn parameter, the number of nearest neigbour selected to judge
% a point whether it is a noise point or not.
shrink_k=0.2; % cutimage parameter, shrink image to reduce calculation time.
OutputResult=struct([]); % A struct which will store the result: folder name, 
% movie name, worm(x,y) location predicted, and T-maze location predicted.
Error_Video=[];
% There are other parameters which can be changed in order to get better
% result, such as in "ForegroundDetector.m", a variable called "rtime",
% which means how many times do we need to run knn, This parameter is very
% important, it can not be ignored.
% By default, it is set like this:
%         if length(mean_x)<30
%             rtimes = 1;
%         elseif length(mean_x)<60
%             rtimes = 3;
%         else
%             rtimes = 5;
%         end
%%
for jj=1:length(All_mov_path)
    B=All_mov_path(jj);
    orimov_path=B{1,1};
    disp(orimov_path);
    orimov_full_path=strcat(folder,orimov_path);
    addpath(orimov_full_path);
    All_movs=dir(fullfile(orimov_full_path,strcat('*',mov_str)));
    len_movs=length(All_movs);
    for ii=1:len_movs
        outputresult=struct;
        orimov_name=All_movs(ii,:).name;
        fprintf('Now processing %d video\n',ii);
        disp(orimov_name);
        A=split(orimov_name,'.');
        orimov_name=A{1,1};
        outputresult.genefolder=orimov_path;
        outputresult.movname=orimov_name;
        try
            [worm_x, worm_y, T_maze_loc,decision,distance,speed]=run_script(folder,orimov_path,...
                orimov_name,write_folder,...
                    label,mov_str,dilate_x,dilate_y,svd_rank,min_th,max_th,...
                    knn_bool,label_step,knn_k,shrink_k);
                outputresult.worm_loc=[worm_x, worm_y];
                outputresult.maze_loc=T_maze_loc;
                outputresult.decision = decision;
                outputresult.distance = distance;
                outputresult.speed = speed;
        catch ME
            msgText = getReport(ME);
            Error_Video = [Error_Video,orimov_name];
            fprintf('Error in processing %s due to %s\n',(orimov_name),(msgText));
            continue;
        end
        OutputResult=[OutputResult,outputresult];
        if mod(ii,10) == 0
            disp('Saving Processed Result!');
            save(fullfile(folder,write_folder,'Worm_Result.mat'),'OutputResult');
        end
    end
end

