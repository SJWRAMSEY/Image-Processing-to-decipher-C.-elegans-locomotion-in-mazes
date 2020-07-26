function [gray_im_seq,fs]=convert2gray(movpath)
    disp(movpath)
    videoObject = VideoReader(movpath);
    nFrameRead = videoObject.NumberOfFrames;
    fs = 1/(videoObject.FrameRate);
    gray_im_seq=cell(nFrameRead,1);
    for frame=1:nFrameRead
        thisFrame = read(videoObject, frame);
        %thisFrame=imresize(thisFrame,0.75);
        grayImage = rgb2gray(thisFrame);
        gray_im_seq{frame}=grayImage;
        %Iblur=imgaussfilt(grayImage);
%         imwrite(grayImage, fullfile(savpath, sprintf('%06d.jpg', frame)));
    end

%     imageNames = dir(fullfile(savpath,'*.jpg'));
%     imageNames = {imageNames.name}';
%     outputVideo = VideoWriter('gray_Image');
%     outputVideo.FrameRate = videoObject.FrameRate;
%     open(outputVideo)
%     for ii = 1:length(imageNames)
%     img = imread(fullfile(savpath,imageNames{ii}));
%     writeVideo(outputVideo,img)
%     end
%     close(outputVideo)
end


