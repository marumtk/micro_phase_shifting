function [Phase]   = phase_unwrapping(proj2,result,frequencyVec,cam_dim)

num = 0:proj2-1; %�v���W�F�N�^�̗�

%9*1024�̍s��𐶐��D1024:�v���W�F�N�^�̗񐔁C9�F8��ނ̐����g�p�^�[���ɑ΂���cos�̒l�i1���sin���������Ă���j
%Test:�v���W�F�N�^�̗񂲂ƂɊe���g���ɂ�����cos(,sin)�̒l���i�[
Test = repmat(num, [size(result,1) 1]);
Test(1,:) = cos((mod(Test(1,:), frequencyVec(1)) / frequencyVec(1))*2*pi);                           
Test(2,:) = sin((mod(Test(2,:), frequencyVec(1)) / frequencyVec(1))*2*pi);                           

for i=3:size(result,1)
    Test(i,:) = cos((mod(Test(i,:), frequencyVec(i-1)) / frequencyVec(i-1))*2*pi);                   
end

%Phase:�J�����̃s�N�Z�����ƂɁC�Ή�����v���W�F�N�^�̃s�N�Z���i��j���������蓱�o
Phase = zeros(1, cam_dim(1)*cam_dim(2));                                                                                                                                                                            
parfor i=1:size(result,2)
    vec = result(:,i);
    %�J�����摜���瓱�o���ꂽcos�̒l�ƃv���W�F�N�^�̗񂲂Ɓi�S1024��j��cos�̒l�̍��̓��a���v�Z
    ErrorVec = sum(abs(repmat(vec,[1 proj2])-Test).^2, 1);
    %��L�̌덷���ŏ��ƂȂ�v���W�F�N�^�̗��Ind�Ƃ���
    [~, Ind] = min(ErrorVec(:));
    %�J�����̃s�N�Z�����ƂɑΉ�����v���W�F�N�^��Ind�𓱏o�CPhase�Ɋi�[
    Phase(1,i) = Ind;
end

Phase = Phase - 1;                                                                                          

%���ޖڂ̎��g���ɑ΂��đ��Έʑ������߂�
PhaseFirstFrequency = acos(result(1,:)); %0~pi�͈̔͂ňʑ������߂�                                               
PhaseFirstFrequency(result(2,:)<0) = 2*pi - PhaseFirstFrequency(result(2,:)<0); %sin�̒l�����̏ꍇ��pi~2*pi�͈̔͂ɂȂ�悤�v�Z�C
ColumnFirstFrequency = PhaseFirstFrequency * frequencyVec(1) / (2*pi); %���o�������Έʑ��ɑΉ�����v���W�F�N�^�̃s�N�Z���̂����C�ŏ��Ɍ����s�N�Z�������߂�      

%���ޖڂ̎��g���ɑ΂��Đ�Έʑ������߂�
NumCompletePeriodsFirstFreq = floor(Phase / frequencyVec(1)); %���o����ʑ����������ڂȂ̂����o�Dtheta_t = theta + 2pi*k �ɂ�����k�𓱏o���Ă���                                      
ICFrac = NumCompletePeriodsFirstFreq * frequencyVec(1) + ColumnFirstFrequency; %�J�����s�N�Z���ɑ΂��錵���ȃv���W�F�N�^�̃s�N�Z���ʒu�����܂�D�v����ɐ�Έʑ�

ICFrac(abs(ICFrac-Phase)>=1)               = Phase(abs(ICFrac-Phase)>=1); %�덷��1�ȏ゠��ꍇ�͂�������ʑ����g��
Phase                                      = ICFrac;

Phase          = Phase+1;


Phase          = reshape(Phase, [cam_dim(1) cam_dim(2)]); 
%Phase          = Phase/frequencyVec(1)*2*pi;
Phase          = medfilt2(Phase, [5 5]);

%{
ICFrac         = reshape(ICFrac, [cam_dim(1) cam_dim(2)]); 
figure;
imagesc(ICFrac);
colormap(jet(256)); %��Έʑ����J���[�o�[�ŏo�͂����
colorbar
%}
end

