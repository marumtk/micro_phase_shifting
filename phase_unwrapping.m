function [Phase]   = phase_unwrapping(proj2,result,frequencyVec,cam_dim)

num = 0:proj2-1; %プロジェクタの列数

%9*1024の行列を生成．1024:プロジェクタの列数，9：8種類の正弦波パターンに対するcosの値（1種類sinが混ざっている）
%Test:プロジェクタの列ごとに各周波数におけるcos(,sin)の値を格納
Test = repmat(num, [size(result,1) 1]);
Test(1,:) = cos((mod(Test(1,:), frequencyVec(1)) / frequencyVec(1))*2*pi);                           
Test(2,:) = sin((mod(Test(2,:), frequencyVec(1)) / frequencyVec(1))*2*pi);                           

for i=3:size(result,1)
    Test(i,:) = cos((mod(Test(i,:), frequencyVec(i-1)) / frequencyVec(i-1))*2*pi);                   
end

%Phase:カメラのピクセルごとに，対応するプロジェクタのピクセル（列）をざっくり導出
Phase = zeros(1, cam_dim(1)*cam_dim(2));                                                                                                                                                                            
parfor i=1:size(result,2)
    vec = result(:,i);
    %カメラ画像から導出されたcosの値とプロジェクタの列ごと（全1024列）のcosの値の差の二乗和を計算
    ErrorVec = sum(abs(repmat(vec,[1 proj2])-Test).^2, 1);
    %上記の誤差が最小となるプロジェクタの列をIndとする
    [~, Ind] = min(ErrorVec(:));
    %カメラのピクセルごとに対応するプロジェクタ列Indを導出，Phaseに格納
    Phase(1,i) = Ind;
end

Phase = Phase - 1;                                                                                          

%一種類目の周波数に対して相対位相を求める
PhaseFirstFrequency = acos(result(1,:)); %0~piの範囲で位相を求める                                               
PhaseFirstFrequency(result(2,:)<0) = 2*pi - PhaseFirstFrequency(result(2,:)<0); %sinの値が負の場合はpi~2*piの範囲になるよう計算，
ColumnFirstFrequency = PhaseFirstFrequency * frequencyVec(1) / (2*pi); %導出した相対位相に対応するプロジェクタのピクセルのうち，最初に現れるピクセルを求める      

%一種類目の周波数に対して絶対位相を求める
NumCompletePeriodsFirstFreq = floor(Phase / frequencyVec(1)); %導出する位相が何周期目なのか導出．theta_t = theta + 2pi*k におけるkを導出している                                      
ICFrac = NumCompletePeriodsFirstFreq * frequencyVec(1) + ColumnFirstFrequency; %カメラピクセルに対する厳密なプロジェクタのピクセル位置が求まる．要するに絶対位相

ICFrac(abs(ICFrac-Phase)>=1)               = Phase(abs(ICFrac-Phase)>=1); %誤差が1以上ある場合はざっくり位相を使う
Phase                                      = ICFrac;

Phase          = Phase+1;


Phase          = reshape(Phase, [cam_dim(1) cam_dim(2)]); 
%Phase          = Phase/frequencyVec(1)*2*pi;
Phase          = medfilt2(Phase, [5 5]);

%{
ICFrac         = reshape(ICFrac, [cam_dim(1) cam_dim(2)]); 
figure;
imagesc(ICFrac);
colormap(jet(256)); %絶対位相がカラーバーで出力される
colorbar
%}
end

