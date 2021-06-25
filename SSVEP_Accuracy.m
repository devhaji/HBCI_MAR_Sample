clc; clear all; close all; 
% Sub1,2,3,4,5 SSVEP result
load('Sub1_SSVEP.mat');
% SSVEP# : channels X samples X trials (target is #)
% 3 X 2048 X 6 ( 3 channels, 2048 = 4 s X sampling rate, 6 trials )
% total trials is  30 ( SSVEP1~SSVEP5, 6 trials )
SR = 512;
% [Start_time-epoch_time]
Start_time = 0;
epoch_time = 4; % 3 means [0-3] 3 seconds / 4 means [0-4] 4 seconds
epoch_sample = epoch_time * SR;
Start_sample = Start_time * SR;

% target frequency
Stim_freq = [7.4 8.43 9.8 11.7 13.7];
% ch = 1:3;
ch = 1:3;

for in = 1:6
    xt1 = squeeze(SSVEP1(ch,Start_sample+1:epoch_sample,in));
    S1(in) = EMSI(Stim_freq,xt1,SR);
    
    xt2 = squeeze(SSVEP2(ch,Start_sample+1:epoch_sample,in));
    S2(in) = EMSI(Stim_freq,xt2,SR);

    xt3 = squeeze(SSVEP3(ch,Start_sample+1:epoch_sample,in));
    S3(in) = EMSI(Stim_freq,xt3,SR);
    
    xt4 = squeeze(SSVEP4(ch,Start_sample+1:epoch_sample,in));
    S4(in) = EMSI(Stim_freq,xt4,SR);
    
    xt5 = squeeze(SSVEP5(ch,Start_sample+1:epoch_sample,in));
    S5(in) = EMSI(Stim_freq,xt5,SR);
    

end
S = [S1; S2; S3; S4; S5;];
SS = [ones(1,6); ones(1,6)*2; ones(1,6)*3; ones(1,6)*4; ones(1,6)*5];
SS = SS-S;
disp('Accuracy (%)')
disp([num2str(sum(sum(SS==0))/30*100) ' %'])
