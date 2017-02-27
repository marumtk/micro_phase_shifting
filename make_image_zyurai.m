camera_name = 'C:\Users\t2ladmin\Documents\MATLAB\映像メディア\cameraImages\WaxBowl\32-08'; %カメラによる撮影画像の入ったフォルダ(今回は8種類の周波数をもつ正弦波を投影するので8+2=10枚の画像を用いる)
proj_name = 'C:\Users\t2ladmin\Documents\MATLAB\映像メディア\ProjectedImages\32-08'; %プロジェクタの投影映像の入ったフォルダ（freqData.matに数値データが格納されている）
load([proj_name, '\freqData.mat']); %プロジェクタの投影データを読み込み

num = length(frequencyVec);
img = zeros(768,1024,num+2);
str = 'Frame00%d.tif';

for i = 1:num
    if i==1
        for t = 1: 1024
            img(:,t,i)= (1+sin(2*pi*t/frequencyVec(i) - 2*pi/3))/2;
            img(:,t,i+1)= (1+sin(2*pi*t/frequencyVec(i)))/2;
            img(:,t,i+2)= (1+sin(2*pi*t/frequencyVec(i) + 2*pi/3))/2;
            imwrite(img(:,:,i),sprintf(str,i));
            imwrite(img(:,:,i+1),sprintf(str,i+1));
            imwrite(img(:,:,i+2),sprintf(str,i+2));
        end
    else
        for t = 1: 1024
            img(:,t,i+2)= (1+sin(2*pi*t/frequencyVec(i)))/2;
            imwrite(img(:,:,i+2),sprintf(str,i+2));
        end
    end
end

