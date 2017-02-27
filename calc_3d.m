main; %位相接続
cd('C:\Users\k2vision\Desktop\maruyama\映像メディア')

image_height = 300;
image_width = 400;
load ('Projector.mat')
%プロジェクタの内部パラメタ行列
internal_proj = KK_p;
%カメラ座標系に対するプロジェクタ座標系のR,T
round_proj = R_p; 
translation_proj = T_p;
rt_proj = horzcat(round_proj,translation_proj);
%プロジェクタのRT行列
external_proj = vertcat(rt_proj,[0,0,0,1]);
%プロジェクタのゆがみ補正
distortion_proj = kc_p;
%プロジェクタの透視投影行列
P_proj = internal_proj * horzcat(round_proj,translation_proj);

load ('Calib_Results_basler.mat')
%カメラの内部パラメタ行列
internal_camera = KK;
%カメラのゆがみ補正
distortion_camera = kc_p;
%カメラの透視投影行列(もともとカメラ座標系をワールド座標にしているので，R=単位行列,T=0)
P_camera = horzcat(internal_camera,[0;0;0]);

%カメラのピクセル毎にデプスを計算
temp1 = [P_camera(3,1:3);P_proj(3,1:3)];
temp2 = [P_camera(1,1:3);P_camera(2,1:3);P_proj(1,1:3)];
temp3 = [P_camera(1:2,4);P_proj(1,4)];
temp4 = [P_camera(3,4);P_proj(3,4)];

%3次元位置(デプス)を格納する配列
result_depth = zeros(image_height,image_width);

%カメラのピクセル毎にデプスを計算
for u = 1:image_width
    for v = 1:image_height
        all_pixel = [u,0;v,0;0,Phase(v,u)];
        B = all_pixel*temp1-temp2;
        q = temp3-all_pixel*temp4;
        result_3d = B\q; %対応ピクセルのワールド座標.（＝カメラ座標）
        %temp_3dpoint = vertcat(result_3d,1); %同次座標に変換する
        %result_3dpoint = *temp_3dpoint; %カメラ座標に変換
        %result_depth(v,u) = result_3dpoint(3);
        if result_3d(3)>850 || result_3d(3)<700
            result_3d(3) = NaN;
        end
        result_depth(v,u) = result_3d(3);
    end
end
 
%実験ごとにパスを変更
cd('C:\Users\k2vision\Desktop\maruyama\映像メディア\result\220_old')
%%グラフ6
figure;
%medfilt2(result_depth,medfilt);
%mesh(result_depth);
imagesc(result_depth,[600 800]);
colormap(gray);
colorbar;

axis image;
hold on;
title('デプスマップ','Fontsize',16);
set(gca,'FontSize',16);
saveas(gcf,'depth_map.fig')

figure
colormap(gray);
mesh(result_depth)
saveas(gcf,'depth_3d.fig')

cd('C:\Users\k2vision\Desktop\maruyama\映像メディア')

