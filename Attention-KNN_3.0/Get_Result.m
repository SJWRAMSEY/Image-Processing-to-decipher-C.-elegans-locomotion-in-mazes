data_path = fullfile(folder,'result_folder','Worm_Result.mat');
C=load(data_path);
Data = C.OutputResult;
[~,index] = sortrows({Data.movname}.');
Data = Data(index(end:-1:1)); 
clear index
Interval = squeeze(struct2cell(Data));
Mov_name = Interval(2,:);
Train_num = sum(count(Mov_name,'Training'));
%%
Train = squeeze(struct2cell(Data(1:Train_num)));
Test = squeeze(struct2cell(Data(Train_num+1:end)));
Train_left = sum(cell2mat(Train(5,:))== -1);
Train_no = sum(cell2mat(Train(5,:)) == 0);
Train_right = sum(cell2mat(Train(5,:)) == 1);

Test_left = sum(cell2mat(Test(5,:))== -1);
Test_no = sum(cell2mat(Test(5,:)) == 0);
Test_right = sum(cell2mat(Test(5,:)) == 1);

Train_dis = cell2mat(Train(6,:));
Test_dis = cell2mat(Test(6,:));

Train_speed = cell2mat(Train(7,:));
Test_speed = cell2mat(Test(7,:));

Train_Left_dis = Train_dis(find(Train_dis(cell2mat(Train(5,:))== -1)));
Train_No_dis = Train_dis(find(Train_dis(cell2mat(Train(5,:))== 0)));
Train_Right_dis = Train_dis(find(Train_dis(cell2mat(Train(5,:))== 1)));

Train_Left_speed = Train_speed(find(Train_speed(cell2mat(Train(5,:))== -1)));
Train_No_speed = Train_speed(find(Train_speed(cell2mat(Train(5,:))== 0)));
Train_Right_speed = Train_speed(find(Train_speed(cell2mat(Train(5,:))== 1)));


Test_Left_dis = Test_dis(find(Test_dis(cell2mat(Test(5,:))== -1)));
Test_No_dis = Test_dis(find(Test_dis(cell2mat(Test(5,:))== 0)));
Test_Right_dis = Test_dis(find(Test_dis(cell2mat(Test(5,:))== 1)));

Test_Left_speed = Test_speed(find(Test_speed(cell2mat(Test(5,:))== -1)));
Test_No_speed = Test_speed(find(Test_speed(cell2mat(Test(5,:))== 0)));
Test_Right_speed = Test_speed(find(Test_speed(cell2mat(Test(5,:))== 1)));
%%
disp(mean(Test_Right_dis));
disp(std(Test_Right_dis));
disp(mean(Test_Right_speed));
disp(std(Test_Right_speed));


