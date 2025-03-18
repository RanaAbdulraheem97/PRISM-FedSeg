clc; clear all; close all;
load('trainedPRISM-fedseg.mat');
net_base = net;
% imds = imageDatastore('C:\Users\Abdual Manan\Desktop\Results section\test\test');
%  pximds = imageDatastore('C:\Users\Abdual Manan\Desktop\Results section\test\GT');

%for i=1:length(imds.Files)
for i=1:24
    i
    num=num2str(i);
    file=strcat('D:\PhD\Polyp\TestImg\', num,'.png');
    file1=strcat('D:\PhD\Polyp\Testmask\', num,'.png');
    I=imread(file);
    gt=imread(file1);
    I = imresize(I,[256 256]);
    gt = imresize(gt,[256 256]);
    [C,S,AS] = semanticseg(I, net_base);
    % C = Result of segmentation from trained network
    % subplot(3,2,1);
    % imshow(I)
    % title('Orgional Image')
    % B = labeloverlay(I,C);
    % subplot(3,2,2);
    % imshow(B)
    % title('Segmented overlay')
    
    % net_base
     out = zeros(size(C));
    out(C=='polyp')=1; out = logical(out);
%     figure;imshow(out);% Result of trained segnet 
 
    se = strel('disk',5); 
       out=imdilate(out,se)
     % out = imerode(out,se);
    B = labeloverlay(I,out);
    
%         New=double(rgb2gray(I)).*double(out);
%  level=graythresh(New).*max(New(:));
%    level=level-1;
% out=logical(imbinarize(New,level));

% figure,imshow(B,[])
   figure;
   subplot(1,5,1);
    imshow(I)
    title('Orgional Image')
    B = labeloverlay(I,out);
    subplot(1,5,2);
    imshow(B)
    title('Segmented overlay')
    subplot(1,5,3);
    imshow(gt)
    title('GT')
    subplot(1,5,4);
    imshow(out)
    title('segmented')
    C = labeloverlay(gt,out);
    subplot(1,5,5);
    imshow(C)
    title('overlay on gt')
%     figure;imshow(out);
   
   gt = logical(gt(:,:,1))
   
    gt = imresize(gt,[256 256]);
   gt = logical(gt(:,:,1))
   
   [measures(i,:),~,~,~,~] = getQualityMeasures_logical(out(:), gt(:)); 
%     cd 'C:\Users\Rao-Zaka\Desktop\Results section\images\4';
       imwrite(I,sprintf('%d_img.jpg',i));
%       cd 'C:\Users\Rao-Zaka\Desktop\Improve Results section\our results images\E-ophtha\segmented';
         imwrite(out,sprintf('%d_segmented.jpg',i));
%        cd 'C:\Users\Rao-Zaka\Desktop\Improve Results section\our results images\E-ophtha\overlay';
        imwrite(B,sprintf('%d_overlay.jpg',i));
% %        cd 'C:\Users\Rao-Zaka\Desktop\Results section\images\6';
      imwrite(gt,sprintf('%d_gt.jpg',i));
       imwrite(C,sprintf('%d_overlaygt.jpg',i));
%       cd 'C:\Users\Rao-Zaka\Desktop\Improve Results section';


    
end

Se = mean(measures(:,1))
Sp = mean(measures(:,2))
Acc = mean(measures(:,3))
Dice = mean(measures(:,4))
Precision=mean(measures(:,5))
F1=mean(measures(:,6))
Matthews=mean(measures(:,7))
% figure,imshow(I,[]);
% title('orgional Image')
% figure,imshow(out,[]);
% title('Segmented Image')
% % 
% figure,imshow(gt,[]);
% title('Grouth image')