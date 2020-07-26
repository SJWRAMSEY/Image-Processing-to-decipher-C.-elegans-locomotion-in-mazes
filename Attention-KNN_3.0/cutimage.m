% xcorr add by Jiawei Sun
%%
function [cut_im_seq,coordinate,compenvalue] = cutimage(gray_im_seq,k,num_frame,min_x,min_y,max_x,max_y) 
         % k=0.2 shrink scalar   filepath is input~ gray_image  writepath is output, write cutimage as video
    
    cut_im_seq=cell(length(gray_im_seq),1);
    [imrow,imcol]=size(gray_im_seq{1});
    coordinate = zeros(length(gray_im_seq),3);
    coordinate(num_frame,1) = min_y;   % the left-top point of T maze
    coordinate(num_frame,2) = min_x;   % the left-top point of T maze
    coordinate(num_frame,3) = num_frame;
    compenvalue = zeros(length(gray_im_seq),3);
    Tx_length = max_y - min_y; % the wide of T maze
    Ty_length = max_x - min_x;  % the length of T maze
    standardFrame = gray_im_seq{num_frame};
%     imshow(standardFrame);
    standardFrame_shrink = imresize(standardFrame,k);
    crr_self = xcorr2(standardFrame_shrink-mean(mean(standardFrame_shrink)),...
        standardFrame_shrink-mean(mean(standardFrame_shrink)));
    [ssr_self,snd_self] = max(crr_self(:));
    i = 1;
    for frame=1:length(gray_im_seq)
        thisFrame = gray_im_seq{frame};
        thisFrame_shrink = imresize(thisFrame,k);
        
        crr = xcorr2(thisFrame_shrink - mean(mean(thisFrame_shrink)),...
            standardFrame_shrink - mean(mean(standardFrame_shrink)));
        [ssr,snd] = max(crr(:));
        [ij,ji] = ind2sub(size(crr),snd);
        ij = 5*( ij - size(standardFrame_shrink,1) );
        ji = 5*( ji - size(standardFrame_shrink,2) );
        coordinate(frame,1) = coordinate(num_frame,1) + ij;
        
        coordinate(frame,2) = coordinate(num_frame,2) + ji;
        
        if coordinate(frame,1)<=0 && coordinate(frame,2)>0 && ...
                coordinate(frame,1)+Tx_length<=size(standardFrame,1) && ...
                coordinate(frame,2)+Ty_length<=size(standardFrame,2)
           compenvalue(frame,1) = 1 - coordinate(frame,1);
           coordinate(frame,1)=1;
        end
           
        if coordinate(frame,1)>0 && coordinate(frame,2)<=0 && ...
                coordinate(frame,1)+Tx_length<=size(standardFrame,1) && ...
                coordinate(frame,2)+Ty_length<=size(standardFrame,2)
           compenvalue(frame,2) = 1 - coordinate(frame,2);
           coordinate(frame,2)=1;
        end
        
        if coordinate(frame,1)>0 && coordinate(frame,2)>0 && ...
                coordinate(frame,1)+Tx_length>size(standardFrame,1) && ...
                coordinate(frame,2)+Ty_length<=size(standardFrame,2)
           compenvalue(frame,1) = size(standardFrame,1) - coordinate(frame,1) - Tx_length;
           coordinate(frame,1) = size(standardFrame,1) - Tx_length;
        end
        
        if coordinate(frame,1)>0 && coordinate(frame,2)>0 && ...
                coordinate(frame,1)+Tx_length<=size(standardFrame,1) && ...
                coordinate(frame,2)+Ty_length>size(standardFrame,2)
           compenvalue(frame,2) = size(standardFrame,2) - coordinate(frame,2) - Ty_length;
           coordinate(frame,2) = size(standardFrame,2) - Ty_length;
        end
        
        
        if  ssr<1.1*ssr_self && ssr>0.5*ssr_self && coordinate(frame,1)>0 && ...
                coordinate(frame,1)+Tx_length<=size(standardFrame,1) && ...
                coordinate(frame,2)>0 && coordinate(frame,2)+Ty_length<=size(standardFrame,2)
            cutimage = thisFrame(coordinate(frame,1):coordinate(frame,1)+Tx_length,...
                coordinate(frame,2):coordinate(frame,2)+Ty_length);
            cut_im_seq{i}=cutimage;
            i = i+1;
            coordinate(frame,3) = frame;
            compenvalue(frame,3) = frame;
%         else 
%             figure;
%             imshow(thisFrame);
%             hold on;
%             title(['discard ',num2str(frame),' frame']);
%             hold off;
        end
    end
    id = compenvalue(:,3)==0;
    compenvalue(id,:)=[];
    coordinate(id,:)=[];
    %compenvalue(:,1:2) = compenvalue(:,1:2) - coordinate(:,1:2) + coordinate(num_frame,1:2);
    coordinate(:,1:2) = coordinate(:,1:2) - coordinate(num_frame,1:2);
    
    cut_im_seq(cellfun(@isempty,cut_im_seq))=[];
    
end


