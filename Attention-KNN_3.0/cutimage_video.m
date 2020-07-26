%
%%
function cutimage_video(writepath,movname)
    outputVideo = VideoWriter(movname);
    imageNames = dir(fullfile(writepath,'*.jpg'));
    imageNames = {imageNames.name}';

%outputVideo.FrameRate = videoObject.FrameRate;
    open(outputVideo)
    for ii = 1:length(imageNames)
        img = imread(fullfile(writepath,imageNames{ii}));
        writeVideo(outputVideo,img)
    end
    close(outputVideo)
end