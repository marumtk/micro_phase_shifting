camera_name = 'C:\Users\t2ladmin\Documents\MATLAB\�f�����f�B�A\cameraImages\WaxBowl\32-08'; %�J�����ɂ��B�e�摜�̓������t�H���_(�����8��ނ̎��g�����������g�𓊉e����̂�8+2=10���̉摜��p����)
proj_name = 'C:\Users\t2ladmin\Documents\MATLAB\�f�����f�B�A\ProjectedImages\32-08'; %�v���W�F�N�^�̓��e�f���̓������t�H���_�ifreqData.mat�ɐ��l�f�[�^���i�[����Ă���j
load([proj_name, '\freqData.mat']); %�v���W�F�N�^�̓��e�f�[�^��ǂݍ���

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

