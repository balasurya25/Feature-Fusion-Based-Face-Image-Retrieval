clc;
clear all;
close all;

%HOG + GW followed by concat of GLCM
%GLCM Properties: Contrast, Homogeneity, Correlation, Energy for three
%features: eye, nose, mouth. hence, total 3 x 4, 12 features for every
%sketch and image

%creating a gabor filter
GA= gaborFilterBank(5,8,39,39);
count=0;
NoMatchIdx=[];
% totalPhotos= 188;
%choosing a random sketch
% for sketchId= 101:188
sketchId= 176;
S = imread(sprintf('1 (%d).jpg', sketchId));
S1= im2gray(S);
%cropping the sketch
target= [175 140];
rs= centerCropWindow2d(size(S1),target);
Sc = imcrop(S1, rs);
%hog for sketch
[FVs,hogVizs]= extractHOGFeatures(Sc);
%glcm features for sketch
glcmS= computeGLCMfeatureSketch(S1);
FVs= [FVs glcmS];
%gabor for sketch
[sgaborRes,sgF]= gaborFeatures(Sc,GA,4,4);
Z= [FVs sgF'];
%resize to scale match with hog of sketch
% [m,n]= size(FVs);
% sgFr= imresize(sgF,[n,1]);
%apply cca fusion for sketch
%[Ztrs,~]= ccaFuse(FVs', sgFr, FVs', sgFr, 'sum');

%Ztrs= [Ztrs; glcmS'];

imFolder= 'D:\The Losers Hub\SEM-VII\Project\FYP_final\FYP_Photos';
%features for image n= hogdim
Zi= ccaFusionImage(imFolder, target, GA);
%glcm features for image
% Z= computeGLCMfeatureImage(imFolder,Zi);

%computing k-shortlisted photos
[Idx,Dist]= knnsearch(Zi,Z,'K',10);
figure('NumberTitle','Off','Name','Input Sketch');
imshow(S1);

figure('NumberTitle','Off','Name','K Similar Mugshots To The Input Sketch Provided');
for i= 1:size(Idx,2)
    subplot(size(Idx,2)/5,size(Idx,2)/2,i);
    name= sprintf('2 (%d).jpg',Idx(i));
    if isfile(name)
        imshow(sprintf('2 (%d).jpg',Idx(i)));
    else
        imFolder1= 'D:\The Losers Hub\SEM-VII\Project\FYP_final\distorted_Photos';
        imName= fullfile(imFolder1,name);
        imshow(imName);
    end    
    pause(1);   
end

clear FVs FVst sgaborRes sgF sgFr Zd Zi Ztrs;

Sg= imgaussfilt(Sc);
%hysteresis thresholding is performed.
Se= edge(Sg,'canny'); 
figure('NumberTitle','Off','Name','Canny Line Sketch'); 
imshow(Se);
%output is a binary image as a logical array
[x,y]= find(Se);
eta= [x y];
rho= size(eta,1);
D= [];
i= 1;
k=0;
while ~isempty(eta)
    Dvar= eta(i,:);
    D= [D; Dvar];
    x(i,:)=[];
    y(i,:)=[];
    eta=[x y];
    %for j= 1: length(eta)
    while k<=length(eta)-1
        pts= [Dvar; eta(k+1,:)];
        d= pdist(pts,'euclidean');
        if d<= 25
            eta(k+1,:)=[];
        end
        k= k+1;
    end
    [m,n]= size(eta);
    x= eta(:,n-1);
    y= eta(:,n);
end

figure('NumberTitle','Off','Name','Generated PoI');
plot(D(:,2),D(:,1),'r+');
set(gca, 'xdir', 'reverse', 'ydir' , 'reverse');

clear j k i m n pts eta x y d Dvar;

%applying s-dogogh
sigma1= 1;
sigma2= 2;
S1= imgaussfilt(Sc,sigma1);
S2= imgaussfilt(Sc,sigma2);
Sdog= S1-S2;
%vpoints is valid points sketch
[FVd,vpoints, vizS]= extractHOGFeatures(Sdog,[D(:,2) D(:,1)],'NumBins', 45, 'UseSignedOrientation', true,'CellSize', [1 1], 'BlockSize', [1 1] );

figure('NumberTitle','Off','Name','S-DoGOGH Feature Extracted');
imshow(Sdog);
hold on;
plot(vizS,'Color', 'green');

Dg= dynamicDoGOGHcompute(imFolder, target, Idx, D, FVd);
%min-max normalization
Dmin= min(Dist);
Dmax= max(Dist);
Dgmin= min(Dg);
Dgmax= max(Dg);
Dnorm= (Dist-Dmin)./(Dmax-Dmin);
Dgnorm= (Dg-Dgmin)./(Dgmax-Dgmin);
SFg= (Dnorm + Dgnorm)/2;
%before sorting
DIset= [Idx; SFg];
[R,sortedIdx]= sort(SFg,'ascend');
Idx= Idx(sortedIdx);
%after sorting
sortedSet= [Idx; R];

% if sortedSet(1,1)== sketchId || sortedSet(1,2)== sketchId 
%     count= count + 1;
% else
%     NoMatchIdx= [NoMatchIdx sketchId];
% end
% end