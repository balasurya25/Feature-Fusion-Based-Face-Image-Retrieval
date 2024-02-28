function Z= ccaFusionImage(folder_name,tar_window,GA)
%hogDim

%%Input Parameter(s) are:
% %folder_name, which is the folder where the suspect sketches and mugshots
% %are stored
% %tar_window, which is the target cropping window size that will be used for
% %conversion into a rectangular window object
% %GA, gabor array
% %hogDim, which is the size of the HOG features and the dimensions are same
% %for sketch and mugshot
% %%Output Parameter is:
% %Z which is the CCA Fused output obtained. 

Z=[];
for j= 1: 188
    name= sprintf('2 (%d).jpg',j);
    imName= fullfile(folder_name,name);
    I= imread(imName);
    Ig= im2gray(I);
    ri= centerCropWindow2d(size(Ig),tar_window);
    Ic = imcrop(Ig, ri);
    
    %hog for image
    [FVi,hogVizi]= extractHOGFeatures(Ic);
    %glcm feature for image
    glcmI= computeGLCMfeatureImage(Ig);
    FVi= [FVi glcmI]; 
    
    %gabor for image
    [igaborRes,igaborFeature]= gaborFeatures(Ic,GA,4,4);
    Ztri= [FVi igaborFeature'];
    
    %resize to scale match with hog of sketch
%     igF= imresize(igaborFeature,[hogDim,1]);
%     
%     %cca fusion for fv obtained from every image
%     [Ztri,~]= ccaFuse(FVi', igF, FVi', igF, 'sum');
    Z= [Z; Ztri];  
end
end