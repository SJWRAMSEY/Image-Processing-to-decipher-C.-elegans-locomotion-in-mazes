function [boundary,max_area]=find_image_contours(I)
%     I=imread(image_name);
    [BW,~] = segmentImage(I);
    [B,L]=bwboundaries(BW,'noholes');
%      figure
%      imshow(label2rgb(L,@jet, [.5 .5 .5]))
%      hold on;
    [len,~]=size(B);
    max_area_ind=1;
    max_area=0;
    for i=1:len
        boundary=B{i};
        area=polyarea(boundary(:,1),boundary(:,2));
        if area>max_area
            max_area=area;
            max_area_ind=i;
        end
    end
%     Len_boundary(ind)=0;
%     ind=Len_boundary==max(max(Len_boundary));
    boundary=B{max_area_ind};
%     plot(boundary(:,2),boundary(:,1),'r','LineWidth',2)
%     hold off;
end

