function glcms= computeGLCMfeatureImage(Ig);
% GFI=[];
% for j= 1: 188
eyeBB= [56 119 94 26];
noseBB= [79 136 39 33];
mouthBB= [71 168 58 56];
% name= sprintf('2 (%d).jpg',j);
% imName= fullfile(folder_name,name);
% I= imread(imName);
% Ig= im2gray(I);
%eye props
Ieye= imcrop(Ig,eyeBB);
glcmE= graycomatrix(Ieye);
statsE= graycoprops(glcmE);
%nose props
Inose= imcrop(Ig,noseBB);
glcmN= graycomatrix(Inose);
statsN= graycoprops(glcmN);
%mouth props
Imouth= imcrop(Ig,mouthBB);
glcmM= graycomatrix(Imouth);
statsM= graycoprops(glcmM);
E= [statsE.Contrast statsE.Correlation statsE.Energy statsE.Homogeneity];
M= [statsM.Contrast statsM.Correlation statsM.Energy statsM.Homogeneity];
N= [statsN.Contrast statsN.Correlation statsN.Energy statsN.Homogeneity];
glcms= [E N M];
% GFI= [GFI; glcms];
% end
% Zfinal= [Zi GFI];
end