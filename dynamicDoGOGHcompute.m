function Dg= dynamicDoGOGHcompute(folder_name, target_window, knnIndex, D, FV_sketch)
Dg= [];
sigma1= 1;
sigma2= 2;
file= 'D:\The Losers Hub\SEM-VII\Project\FYP_final\distorted_Photos';
figure('NumberTitle','Off','Name','D-DoGOGH Feature Extracted');

for i= 1:length(knnIndex)
    name= sprintf('2 (%d).jpg',knnIndex(i));
    I= imread(sprintf('2 (%d).jpg',knnIndex(i)));
    target= [175 140];
    rs= centerCropWindow2d(size(im2gray(I)),target);
    Ic = imcrop(I, rs);
    if isfile(name)
        imName= fullfile(folder_name,name);
        Ii= imread(imName);
        Iig= im2gray(Ii);
        rii= centerCropWindow2d(size(Iig),target_window);
        Ici = imcrop(Iig, rii);
        I1= imgaussfilt(Ici,sigma1);
        I2= imgaussfilt(Ici,sigma2);
    else
        Iname= fullfile(file,name);
        Id= imread(Iname);
        I1= imgaussfilt(Id,sigma1);
        I2= imgaussfilt(Id,sigma2);
    end
    Idog= I1-I2;
    %vpoints is valid points sketch
    [FVdi,vpointsi, vizSi]= extractHOGFeatures(Idog,[D(:,2) D(:,1)], 'NumBins', 45, 'UseSignedOrientation', true, 'CellSize', [1 1], 'BlockSize', [1 1] );
    subplot(size(knnIndex,2)/5,size(knnIndex,2)/2,i);
%     imshow(Idog);
%     colormap hsv;
    imshow(Ic);
    hold on;
    plot(vizSi,'Color', 'green');
    pause(1);   
    dg= norm((FV_sketch-FVdi),1);
    Dg= [Dg dg];
end
end