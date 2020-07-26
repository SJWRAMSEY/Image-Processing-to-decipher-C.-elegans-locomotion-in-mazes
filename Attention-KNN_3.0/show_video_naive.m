function show_video_naive(movname,cut_im_seq,mean_x,mean_y, fs)
%     track_im_seq=cell(length(cut_im_seq),1);
%     labelimageNames = dir(fullfile(labelpath,'*.jpg'));
%     labelimageNames = {labelimageNames.name}';
    Background = cut_im_seq{1};
    set(0,'DefaultFigureVisible','off');
%     track_im_seq{1}=Background;
%     imwrite(Background, fullfile(writepath, sprintf('%06d.jpg', 1)));
%     j=1;
    for i=2:length(cut_im_seq)
%         img = cut_im_seq{i};
        pos=[mean_x(i-1) mean_y(i-1)];
%         
%         img=insertMarker(img,pos,'o','color','red','size',10);
        Background=insertMarker(Background,pos,'o','color','red','size',10);
%         
%         if i==label_data(j,1)
%             img=insertMarker(img,[label_data(j,2) label_data(j,3)],'*',...
%                 'color','green','size',10);
%             Background=insertMarker(Background,[label_data(j,2) label_data(j,3)],'*',...
%                 'color','green','size',10);
%             j=j+1;
%             j=min(j,length(label_data));
%         end
%         track_im_seq{i}=img;
% %         imwrite(img, fullfile(writepath, sprintf('%06d.jpg', i)));
    end
    
    Img=cell(length(mean_x),1);
    figure;
    imshow(cut_im_seq{1});
    [H,W]=size(cut_im_seq{1});
%     cmean_x = mean_x + compenvalue(:,2);
%     cmean_y = mean_y + compenvalue(:,1);
    close;
    
    for i =1:length(mean_x)
        imshow(cut_im_seq{1+i})
        hold on;
        cmean_x = mean_x(1:i);
        cmean_y = mean_y(1:i);
        
        plot(cmean_x,cmean_y,'r--o','LineWidth',2); % points strictly inside
        
        hold off
        
        drawnow;
        axis([0 W 0 H]);
        thisframe= getframe(gcf);
        Img{i}=thisframe.cdata;
        Img{i}=imresize(Img{i},[H,W]);        
        A=zeros(H,W,3);
        A(:,:,1)=cut_im_seq{i};
        A(:,:,2)=cut_im_seq{i};
        A(:,:,3)=cut_im_seq{i};
        Img{i}=[A Img{i}];
        clf;
    end
    
    
    cur_name=strcat(movname,'_curve');
    outputVideo = VideoWriter(cur_name, 'MPEG-4');
    outputVideo.FrameRate = round(1/fs);
    open(outputVideo)
    for ii = 1:length(Img)
        writeVideo(outputVideo,Img{ii})
    end
    close(outputVideo)
    figure;
    imshow(Background);
    hold on;
    plot(mean_x,mean_y,'r','LineWidth',2);
    
%     hold on;
%     plot(label_data(:,2),label_data(:,3),'g','LineWidth',2);
    legend({'Predicted'},'FontSize',12);
    title('We cannot say anything about decision making, distance and speed');
    hold off;
    saveas(gcf,strcat(movname, '.jpg'));
%     outputVideo = VideoWriter(movname);
%     imageNames = dir(fullfile(writepath,'*.jpg'));
%     imageNames = {imageNames.name}';

%outputVideo.FrameRate = videoObject.FrameRate;
%     open(outputVideo)
%     for ii = 1:length(track_im_seq)
%         img = track_im_seq{ii};
%         writeVideo(outputVideo,img)
%     end
%     close(outputVideo)
end

function frame=get_plot_image(img,label,num_frame,mean_x,mean_y)
    figure;
    imshow(img);
    hold on;
    for k=2:num_frame
        if label(k-1)==0 
            plot(mean_x(max(1,k-2):k-1),mean_y(max(1,k-2):k-1),'r--o','LineWidth',2);
            hold on;
        else
            plot(mean_x(max(1,k-2):k-1),mean_y(max(1,k-2):k-1),'g--o','LineWidth',2);
            hold on;
        end
    end
    hold off;
    frame=getframe(gcf);
    close;
end