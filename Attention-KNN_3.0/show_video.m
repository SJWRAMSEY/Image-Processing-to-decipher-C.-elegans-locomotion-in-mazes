function [T_move_cut_c, ret_decision, ret_distance, ret_speed]=show_video(movname,...
    cut_im_seq,mean_x,mean_y,T_move_cut,coordinate,compenvalue, fs)
%     track_im_seq=cell(length(cut_im_seq),1);
%     labelimageNames = dir(fullfile(labelpath,'*.jpg'));
%     labelimageNames = {labelimageNames.name}';
    set(0,'DefaultFigureVisible','off');
    Background = cut_im_seq{1};
    
%     track_im_seq{1}=Background;
%     imwrite(Background, fullfile(writepath, sprintf('%06d.jpg', 1)));
%     j=1;
    for i=2:length(cut_im_seq)
%         img = cut_im_seq{i};
        pos=[mean_x(i-1) mean_y(i-1)];
        
%         img=insertMarker(img,pos,'o','color','red','size',10);
        Background=insertMarker(Background,pos,'o','color','red','size',10);
        
%         if i==label_data(j,1)
%             img=insertMarker(img,[label_data(j,2) label_data(j,3)],'*',...
%                 'color','green','size',10);
%             Background=insertMarker(Background,[label_data(j,2) label_data(j,3)],'*',...
%                 'color','green','size',10);
%             j=j+1;
%             j=min(j,length(label_data));
%         end
%         track_im_seq{i}=img;
%         imwrite(img, fullfile(writepath, sprintf('%06d.jpg', i)));
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
        
        for j = 1:i
            cmean_x(j) = cmean_x(j) - compenvalue(i,2)+compenvalue(j,2);
            cmean_y(j) = cmean_y(j) - compenvalue(i,1)+compenvalue(j,1);     
        end
        
         T_move_cut_c(:,2) = T_move_cut(:,2)-compenvalue(i,2);  %%compensate T_maze
         T_move_cut_c(:,1) = T_move_cut(:,1)-compenvalue(i,2);
         

%         sample=floor( [1:500]/500 * length(T_move_cut) );
%         T_move_cut = T_move_cut(sample,:);
        
        polyin = polyshape(T_move_cut_c(:,2),T_move_cut_c(:,1),'Simplify',false);
        polyout1 = polybuffer(polyin,30);
        location = polyout1.Vertices;
        x1 = max(location(:,1)) - min(location(:,1));
        Left_boundary =  min(location(:,1)) + round( (3/16) * x1 );
        Right_boundary = max(location(:,1)) - round( (3/16) * x1 );
        [in,on] = inpolygon(cmean_x,cmean_y,polyout1.Vertices(:,1),polyout1.Vertices(:,2));
        max_y = max(location(:,2));
        min_y = min(location(:,2));

        pgon = polyshape(polyout1.Vertices(:,1),polyout1.Vertices(:,2),'Simplify',false);
        plot(pgon,'FaceColor','red','FaceAlpha',0.1);
        
        plot([Left_boundary,Left_boundary],[min_y,max_y],'b--','LineWidth',2);
        plot([Right_boundary,Right_boundary],[min_y,max_y],'b--','LineWidth',2);
        
        plot(cmean_x(in&~on),cmean_y(in&~on),'r--o','LineWidth',2); % points strictly inside
        
        
        
        plot(cmean_x(on),cmean_y(on),'k*') % points on edge
        plot(cmean_x(~in),cmean_y(~in),'b*') % points outside
        
        
        
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
        hold off;
        clf;
    end
    
    %%-----Left or Right decison start-----% 
    scalar = 5/(Right_boundary-Left_boundary);
    D_x = cmean_x(in&~on);
    D_y = cmean_y(in&~on);
    D_L = D_x <= Left_boundary;
    D_R = D_x >= Right_boundary;
    D_threshold = 2;
    if(sum(D_L)<D_threshold && sum(D_R)<D_threshold)
        decision = 0;  %no decision = 0;
    elseif(sum(D_L)>=D_threshold && sum(D_R)<D_threshold)
        decision = 1;   %left = 1
    elseif(sum(D_R)>=D_threshold && sum(D_L)<D_threshold)
        decision = -1;  %right = -1
    elseif(sum(D_R)>=D_threshold && sum(D_L)>=D_threshold)
        count_L = 0;
        count_R = 0;
        for i=1:length(D_L)
            if(D_L(i)==1)
                count_L = count_L +1;
            end
            if(D_R(i)==1)
                count_R = count_R +1;
            end
            if(count_L>=D_threshold || count_R>=D_threshold)
                break;
            end
        end
        if(count_L>count_R)
            decision = 1;
        else 
            decision = -1;
        end
        
    end
    %%-----Left or Right decison end-----% 
    
    %%-----distance start-----% 
    if(decision ==1 )
       distance = 0;
       for i=1:length(D_L)-1
           distance = distance + norm( [D_x(i+1)-D_x(i),D_y(i+1)-D_y(i)] );
           seconds = i*fs;
            if(D_L(i)==1)
                break;
            end
        end 
    end
    
    if(decision == -1 )
       distance = 0;
       for i=1:length(D_R)-1
           distance = distance + norm( [D_x(i+1)-D_x(i),D_y(i+1)-D_y(i)] );
           seconds = i*fs; 
           if(D_R(i)==1)
                break;
           end
        end 
    end
    
    if(decision == 0 )
       distance = 0;
       for i=1:length(D_x)-1
           distance = distance + norm( [D_x(i+1)-D_x(i),D_y(i+1)-D_y(i)] );
           seconds = i*fs;
        end 
    end
    %%-----distance end-----%
    
    
    cur_name=strcat(movname,'_curve');
    outputVideo = VideoWriter(cur_name,'MPEG-4');
    outputVideo.FrameRate = round(1/fs);
    open(outputVideo)
    for ii = 1:length(Img)
        writeVideo(outputVideo,Img{ii})
    end
    close(outputVideo)
    figure;
    imshow(Background);
    hold on;
    plot(mean_x(in&~on),mean_y(in&~on),'r','LineWidth',2);
    plot(cmean_x(on),cmean_y(on),'k*') % points on edge
    plot(cmean_x(~in),cmean_y(~in),'b*') % points outside
    plot([Left_boundary,Left_boundary],[min_y,max_y],'b--','LineWidth',2);
    plot([Right_boundary,Right_boundary],[min_y,max_y],'b--','LineWidth',2);
%     hold on;
%     plot(label_data(:,2),label_data(:,3),'g','LineWidth',2);
    legend({'Predicted'},'FontSize',12);
    if (decision==1)
        title({['Left decision with ','distance = ', num2str(distance*scalar),...
            '(mm)', ' speed = ', num2str(distance*scalar/seconds),'(mm/s)']});
    end
    if (decision==-1)
        title({['Right decision with ','distance = ', num2str(distance*scalar),...
            '(mm)', ' speed = ', num2str(distance*scalar/seconds),'(mm/s)']});
    end
    if (decision==0)
        title({['No decision with ','distance = ', num2str(distance*scalar),...
            '(mm)', ' speed = ', num2str(distance*scalar/seconds),'(mm/s)']});
    end
    hold off;
    saveas(gcf,strcat(movname, '.jpg'));
    
    ret_decision = -decision;
    ret_distance = distance*scalar;
    ret_speed = distance*scalar/seconds;
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


