% Created by Zongyu Li on 2019/10/08
% Copyright © 2019 Zongyu Li & Jiawei Sun. All rights reserved.
% This is a worm tracker based on Attention_KNN.

% To run the code:
% 1. Create a Work folder, put your video folders, i.e.
%    "Train_SeqTesting", "CX32","CB1515"... into your work folder.
% 2. Open runn.m, there are some variables need to be changed.
% 3. Make sure your video type match variable called "mov_str" specified 
%    in runn.m 
% 4. Change the variable called "folder" into your folder dir.
% 5. Change the variable called "write_path" to your specified write path, 
%    it will be used to store processed videos.
% 6. Add your video folder names into the variable called "All_mov_path",
%    i.e."Train_SeqTesting", "CX32","CB1515"...
% 7. Click "Run" and leave it alone.
%
% PS: The default parameters work well for most videos, but if you need to
% get a better result, our advice is: try a different combo of knn_k & rtimes,
% these two parameters matter a lot for smoothing data. You can also change
% other parameters if you like.

