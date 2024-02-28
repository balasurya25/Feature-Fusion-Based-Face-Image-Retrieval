clc;
clear all;
close all;

%creating a gabor filter
GA= gaborFilterBank(5,8,39,39);

%choosing a random sketch
sketchId= 3;
S = imread(sprintf('1 (%d).jpg', sketchId));
S1= im2gray(S);
% S1= imnoise(S, 'gaussian', 0.1, 0.0045);
%cropping the sketch
target= [175 140];
rs= centerCropWindow2d(size(S1),target);
Sc = imcrop(S1, rs);
%hog for sketch
[FVs,hogVizs]= extractHOGFeatures(Sc);
FVst= FVs';
%gabor for sketch
[sgaborRes,sgF]= gaborFeatures(Sc,GA,4,4);
%resize to scale match with hog of sketch
[m,n]= size(FVs);
sgFr= imresize(sgF,[n,1]);
%apply cca fusion for sketch
[Ztrs,~]= ccaFuse(FVst, sgFr, FVst, sgFr, 'sum');

imFolder= 'D:\The Losers Hub\SEM-VII\Project\FYP_final\FYP_Photos';
%features for image
Zi= ccaFusionImage(imFolder, target, GA, n);

%features for distorted image
% Zd= ccaFusionDistortedImage(imFolder, sketchId, target, GA, n);
% Zi= [Zi; Zd];

%computing k-shortlisted photos
[Idx,Dist]= knnsearch(Zi,Ztrs','K',10);
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

clear j k i m n pts eta x y d Dvar;

%applying s-dogogh
sigma1= 1;
sigma2= 2;
S1= imgaussfilt(Sc,sigma1);
S2= imgaussfilt(Sc,sigma2);
Sdog= S1-S2;
%vpoints is valid points sketch
[FVd,vpoints, vizS]= extractHOGFeatures(Sdog,[D(:,2) D(:,1)],'NumBins', 45, 'UseSignedOrientation', true,'CellSize', [1 1], 'BlockSize', [1 1] );

figure(3);
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
SFg= Dnorm + Dgnorm;
%before sorting
DIset= [Idx; SFg];
[R,sortedIdx]= sort(SFg,'ascend');
Idx= Idx(sortedIdx);
%after sorting
sortedSet= [Idx; R];

if sortedSet(1,1)== sketchId || sortedSet(1,1)== 189
    fprintf('Face retrieval rate (in percentage): %d', 100);
    sprintf('\n');
else
    fprintf('The right mugshot corresponsing to the sketch has not been retrieved');
    sprintf('\n');
end