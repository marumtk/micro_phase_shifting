main; %�ʑ��ڑ�
cd('C:\Users\k2vision\Desktop\maruyama\�f�����f�B�A')

image_height = 300;
image_width = 400;
load ('Projector.mat')
%�v���W�F�N�^�̓����p�����^�s��
internal_proj = KK_p;
%�J�������W�n�ɑ΂���v���W�F�N�^���W�n��R,T
round_proj = R_p; 
translation_proj = T_p;
rt_proj = horzcat(round_proj,translation_proj);
%�v���W�F�N�^��RT�s��
external_proj = vertcat(rt_proj,[0,0,0,1]);
%�v���W�F�N�^�̂䂪�ݕ␳
distortion_proj = kc_p;
%�v���W�F�N�^�̓������e�s��
P_proj = internal_proj * horzcat(round_proj,translation_proj);

load ('Calib_Results_basler.mat')
%�J�����̓����p�����^�s��
internal_camera = KK;
%�J�����̂䂪�ݕ␳
distortion_camera = kc_p;
%�J�����̓������e�s��(���Ƃ��ƃJ�������W�n�����[���h���W�ɂ��Ă���̂ŁCR=�P�ʍs��,T=0)
P_camera = horzcat(internal_camera,[0;0;0]);

%�J�����̃s�N�Z�����Ƀf�v�X���v�Z
temp1 = [P_camera(3,1:3);P_proj(3,1:3)];
temp2 = [P_camera(1,1:3);P_camera(2,1:3);P_proj(1,1:3)];
temp3 = [P_camera(1:2,4);P_proj(1,4)];
temp4 = [P_camera(3,4);P_proj(3,4)];

%3�����ʒu(�f�v�X)���i�[����z��
result_depth = zeros(image_height,image_width);

%�J�����̃s�N�Z�����Ƀf�v�X���v�Z
for u = 1:image_width
    for v = 1:image_height
        all_pixel = [u,0;v,0;0,Phase(v,u)];
        B = all_pixel*temp1-temp2;
        q = temp3-all_pixel*temp4;
        result_3d = B\q; %�Ή��s�N�Z���̃��[���h���W.�i���J�������W�j
        %temp_3dpoint = vertcat(result_3d,1); %�������W�ɕϊ�����
        %result_3dpoint = *temp_3dpoint; %�J�������W�ɕϊ�
        %result_depth(v,u) = result_3dpoint(3);
        if result_3d(3)>850 || result_3d(3)<700
            result_3d(3) = NaN;
        end
        result_depth(v,u) = result_3d(3);
    end
end
 
%�������ƂɃp�X��ύX
cd('C:\Users\k2vision\Desktop\maruyama\�f�����f�B�A\result\220_old')
%%�O���t6
figure;
%medfilt2(result_depth,medfilt);
%mesh(result_depth);
imagesc(result_depth,[600 800]);
colormap(gray);
colorbar;

axis image;
hold on;
title('�f�v�X�}�b�v','Fontsize',16);
set(gca,'FontSize',16);
saveas(gcf,'depth_map.fig')

figure
colormap(gray);
mesh(result_depth)
saveas(gcf,'depth_3d.fig')

cd('C:\Users\k2vision\Desktop\maruyama\�f�����f�B�A')

