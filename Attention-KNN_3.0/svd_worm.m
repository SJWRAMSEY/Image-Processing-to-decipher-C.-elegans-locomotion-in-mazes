function svd_im_seq=svd_worm(cut_im_seq,k)
%     imageNames = dir(fullfile(filepath,'*.jpg'));
%     imageNames = {imageNames.name}';
    [imrow,imcol]=size(cut_im_seq{1});
    
    svd_im_seq=cell(length(cut_im_seq),1);
    N=length(cut_im_seq);
    
    Matrix_SVD=zeros(imrow*imcol,N);
    
    %for i = 0:floor(N/l)-2       
    for frame=1:N
        thisFrame = cut_im_seq{frame};
        Matrix_SVD(:,frame)=double(thisFrame(:));           
    end
    
%     Matrix_SVD_dis = distributed(Matrix_SVD);
    [U,s,V]=svds(Matrix_SVD,k);
    Matrix_Res=Matrix_SVD-U*s*V';
    Matrix_Res=255*(Matrix_Res-min(Matrix_Res,[],'all'))...
        /(max(Matrix_Res,[],'all')-min(Matrix_Res,[],'all'));
%     Matrix_Res = gather(Matrix_Res);    
    
    for frame= 1 : N
        img=reshape(Matrix_Res(:,frame),imrow,imcol,[]);
        svd_im_seq{frame}=img;
    end
    
end

