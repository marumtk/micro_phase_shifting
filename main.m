clear all; clc; 

%�v���W�F�N�^�̉f���ƃJ�����̎B�e�摜�̎擾�Dpass�͓K�X�ύX���K�v
camera_name = 'C:\Users\k2vision\Desktop\maruyama\�f�����f�B�A\result\220_old'; %�J�����ɂ��B�e�摜�̓������t�H���_(�����8��ނ̎��g�����������g�𓊉e����̂�8+2=10���̉摜��p����)
proj_name = 'C:\Users\k2vision\Desktop\maruyama\�f�����f�B�A\ProjectedImages\newimage'; %�v���W�F�N�^�̓��e�f���̓������t�H���_�ifreqData.mat�ɐ��l�f�[�^���i�[����Ă���j
load([proj_name, '\freqData.mat']); %�v���W�F�N�^�̓��e�f�[�^��ǂݍ���

prefix = 'Frame'; %�J�����B�e�摜�̃t�@�C�����̐ړ���                                                     
suffix = '.bmp'; %�J�����B�e�摜�̃t�@�C�����̐ڔ���                                                    
index = 3; %�J�����B�e�摜�̃t�@�C�����̐������̌���

proj_dim = [768 1024]; %�v���W�F�N�^�̉�f��
cam_dim = [300 400]; %�J�����̉�f��
medfilt = [5 5]; %���f�B�A���t�B���^

%��������_�����ɋL���ꂽ��v�ȃA���S���Y��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�J�����̎B�e�摜����C�e�s�N�Z���ł̋P�x���s��Luminance�Ɋi�[�i�_�����ł�R_micro�ƕ\�L����Ă���j%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Luminance�̍s�F10���̎B�e�摜�̃C���f�b�N�X��\��
%Luminance�̗�F�J�����̑S801*900�s�N�Z����\��
num_freq = length(frequencyVec); %�p���鐳���g�̎�ނ����߂�
Luminance = zeros(num_freq+2,cam_dim(1)*cam_dim(2));
for i=1:num_freq+2
    file_name = [camera_name, '\', prefix, sprintf(['%0', num2str(index), 'd'], i), suffix];
    temp = imread(file_name);  %�J�����̎B�e�摜�̓ǂݍ���
    temp(temp<10) = 0;
    Luminance_temp = im2double(temp);
    Luminance(i,:) = Luminance_temp(:)';
    clear Luminance_temp
end


%�ʑ�(�ɑΉ�����cos,sin�̒l)�̎Z�o%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_freq = length(frequencyVec);
size_M = 2+num_freq;
M = zeros(size_M,size_M); %�s��M��p���ĎZ�o�D(�_�����ł�M_micro�ƕ\�L����Ă���D��`�͘_�����ɂ���)

%�s��M�ɒl���i�[
M(:,1) = ones(size_M,1);
for i=1:3
    M(i,2)=cos(2*pi*(i-1)/3);
    M(i,3)=-sin(2*pi*(i-1)/3);
end
M(4:size_M,4:size_M) = eye(num_freq-1);

%�s��M��Luminance����s��U�𓱏o(�_�����ł�U_micro�ƕ\�L����Ă���D)
U=M\Luminance;
A=sqrt(U(2,:).^2+U(3,:).^2); %sin�g�̐U��
result = U(2:end,:)./repmat(A,size_M-1,1); 
%���̒i�K�ł͈ʑ��ł͂Ȃ��C�Ή�����cos�܂���sin�̒l�����߂Ă���D
%�����g�ɂ�����cos�܂���sin�̒l�͈�ӂɌ��܂�Ȃ��̂ŁC�ȍ~�̓v���W�F�N�^�̓��e�f�������Ɉʑ��ڑ����s�������Ɉڂ�

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����܂Ř_�����ŋL���ꂽ��v�ȃA���S���Y��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Phase = phase_unwrapping(proj_dim(2),result,frequencyVec,cam_dim); %�ʑ��ڑ�
Phase = medfilt2(Phase, medfilt); %���f�B�A���t�B���^�ɂ��m�C�Y����

%���ʂ��o�́E�\���Dpass�͓K�X�ύX���K�v
outputResult_name = camera_name;
save([outputResult_name, '\Phase.mat'], 'Phase');
figure;
pixel_lim = [0 1024];
imagesc(Phase, pixel_lim);
axis image;
colormap(jet(256)); %��Έʑ����J���[�o�[�ŏo�͂����
colorbar
title('��Έʑ��i�������g���j','Fontsize',16);
set(gca,'FontSize',16);

cd(camera_name);
saveas(gcf,'unwrappedphase_multi_hand.fig')