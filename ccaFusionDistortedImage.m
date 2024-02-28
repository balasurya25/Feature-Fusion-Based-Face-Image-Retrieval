function Zd= ccaFusionDistortedImage(folder_name, im_num, tar_window, GA, hog_dim)

name= sprintf('2 (%d).jpg',im_num);
imName= fullfile(folder_name,name);
I= imread(imName);
gI= im2gray(I);

%rotated image
Ir= imrotate(gI,2);
r1= centerCropWindow2d(size(Ir),tar_window);
Irc= imcrop(Ir, r1);
%salt and pepper noise
Isp= imnoise(gI,'salt & pepper',0.01);
r2= centerCropWindow2d(size(Isp),tar_window);
Ispc= imcrop(Isp,r2);
%gaussian noise
Igauss= imnoise(gI, 'gaussian', 0.1, 0.0045);
r= centerCropWindow2d(size(Igauss),tar_window);
Igaussc= imcrop(Igauss,r);

%save in a folder
file= 'D:\The Losers Hub\SEM-VII\Project\FYP_final\distorted_Photos';
im1= sprintf('2 (189).jpg');
im2= sprintf('2 (190).jpg');
im3= sprintf('2 (191).jpg');
imgName1 = fullfile(file,im1);
imgName2 = fullfile(file,im2);
imgName3 = fullfile(file,im3);
imwrite(Irc,imgName1);
pause(1);
imwrite(Ispc,imgName2);
pause(1);
imwrite(Igaussc,imgName3);
pause(1);

%compute features
[FVr, ~]= extractHOGFeatures(Irc);
[FVsp, ~]= extractHOGFeatures(Ispc);
[FVg, ~]= extractHOGFeatures(Igaussc);
[~,gFr]= gaborFeatures(Irc,GA,4,4);
gFr= imresize(gFr,[hog_dim,1]);
[~,gFsp]= gaborFeatures(Ispc,GA,4,4);
gFsp= imresize(gFsp,[hog_dim,1]);
[~,gFg]= gaborFeatures(Igaussc,GA,4,4);
gFg= imresize(gFg,[hog_dim,1]);

%compute cca fusion
[Zr,~]= ccaFuse(FVr', gFr, FVr', gFr, 'sum');
[Zsp,~]= ccaFuse(FVsp', gFsp, FVsp', gFsp, 'sum');
[Zg,~]= ccaFuse(FVg', gFg, FVg', gFg, 'sum');

Zd= [Zr'; Zsp'; Zg'];
end