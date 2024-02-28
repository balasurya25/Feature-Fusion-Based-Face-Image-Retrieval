function GFS= computeGLCMfeatureSketch(S);
eyeBB= [56 120 94 24];
noseBB= [79 137 59 34];
mouthBB= [71 168 58 56];
%eye props
Seye= imcrop(S,eyeBB);
glcmE= graycomatrix(Seye);
statsE= graycoprops(glcmE);
%nose props
Snose= imcrop(S,noseBB);
glcmN= graycomatrix(Snose);
statsN= graycoprops(glcmN);
%mouth props
Smouth= imcrop(S,mouthBB);
glcmM= graycomatrix(Smouth);
statsM= graycoprops(glcmM);

E= [statsE.Contrast statsE.Correlation statsE.Energy statsE.Homogeneity];
M= [statsM.Contrast statsM.Correlation statsM.Energy statsM.Homogeneity];
N= [statsN.Contrast statsN.Correlation statsN.Energy statsN.Homogeneity];

GFS= [E N M];
end