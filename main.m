clear all; clc; 

%プロジェクタの映像とカメラの撮影画像の取得．passは適宜変更が必要
camera_name = 'C:\Users\k2vision\Desktop\maruyama\映像メディア\result\220_old'; %カメラによる撮影画像の入ったフォルダ(今回は8種類の周波数をもつ正弦波を投影するので8+2=10枚の画像を用いる)
proj_name = 'C:\Users\k2vision\Desktop\maruyama\映像メディア\ProjectedImages\newimage'; %プロジェクタの投影映像の入ったフォルダ（freqData.matに数値データが格納されている）
load([proj_name, '\freqData.mat']); %プロジェクタの投影データを読み込み

prefix = 'Frame'; %カメラ撮影画像のファイル名の接頭辞                                                     
suffix = '.bmp'; %カメラ撮影画像のファイル名の接尾辞                                                    
index = 3; %カメラ撮影画像のファイル名の数字部の桁数

proj_dim = [768 1024]; %プロジェクタの画素数
cam_dim = [300 400]; %カメラの画素数
medfilt = [5 5]; %メディアンフィルタ

%ここから論文中に記された主要なアルゴリズム%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%カメラの撮影画像から，各ピクセルでの輝度を行列Luminanceに格納（論文中ではR_microと表記されている）%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Luminanceの行：10枚の撮影画像のインデックスを表す
%Luminanceの列：カメラの全801*900ピクセルを表す
num_freq = length(frequencyVec); %用いる正弦波の種類を求める
Luminance = zeros(num_freq+2,cam_dim(1)*cam_dim(2));
for i=1:num_freq+2
    file_name = [camera_name, '\', prefix, sprintf(['%0', num2str(index), 'd'], i), suffix];
    temp = imread(file_name);  %カメラの撮影画像の読み込み
    temp(temp<10) = 0;
    Luminance_temp = im2double(temp);
    Luminance(i,:) = Luminance_temp(:)';
    clear Luminance_temp
end


%位相(に対応するcos,sinの値)の算出%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_freq = length(frequencyVec);
size_M = 2+num_freq;
M = zeros(size_M,size_M); %行列Mを用いて算出．(論文中ではM_microと表記されている．定義は論文中にあり)

%行列Mに値を格納
M(:,1) = ones(size_M,1);
for i=1:3
    M(i,2)=cos(2*pi*(i-1)/3);
    M(i,3)=-sin(2*pi*(i-1)/3);
end
M(4:size_M,4:size_M) = eye(num_freq-1);

%行列MとLuminanceから行列Uを導出(論文中ではU_microと表記されている．)
U=M\Luminance;
A=sqrt(U(2,:).^2+U(3,:).^2); %sin波の振幅
result = U(2:end,:)./repmat(A,size_M-1,1); 
%この段階では位相ではなく，対応するcosまたはsinの値を求めている．
%正弦波におけるcosまたはsinの値は一意に決まらないので，以降はプロジェクタの投影映像を元に位相接続を行う処理に移る

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ここまで論文中で記された主要なアルゴリズム%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Phase = phase_unwrapping(proj_dim(2),result,frequencyVec,cam_dim); %位相接続
Phase = medfilt2(Phase, medfilt); %メディアンフィルタによりノイズ除去

%結果を出力・表示．passは適宜変更が必要
outputResult_name = camera_name;
save([outputResult_name, '\Phase.mat'], 'Phase');
figure;
pixel_lim = [0 1024];
imagesc(Phase, pixel_lim);
axis image;
colormap(jet(256)); %絶対位相がカラーバーで出力される
colorbar
title('絶対位相（複数周波数）','Fontsize',16);
set(gca,'FontSize',16);

cd(camera_name);
saveas(gcf,'unwrappedphase_multi_hand.fig')