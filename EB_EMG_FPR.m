clear all; close all; clc;
% Sub1,2,3,4,5 EB, EMG FPR
load('Sub1_EMG.mat');
% Sub#_EMG.mat
% EMG data for thresholding
% 1 x data x trials
% number of EMG data : 2048 [4 s X 512 sampling rate]
% number of EMG trials : 30 (30 cycles)
EMGforThr = EMG; % For thresholding
load('Sub1_EBEMG_all.mat');
% Sub#_EBEMG_all.mat
% 1 x data x trials 
% EB 30 trials / SSVEP 30 trials / EMG 30 trials
% This data for FPR
% FPR for EB data is 60 trials ( 30 SSVEP + 30 EMG ) 
% FPR for EMG data is 60 trials (30 EB + 30 SSVEP )
% number of data : 2560 [5 s X 512 sampling rate]

EB = squeeze(EB);
EMG = squeeze(EMG);
SR = 512;
conf = [0.3 0.8]; % confidence range (peak interval) [seconds]
[M N] = size(EB);
thr_EB = 100; % thresholding for Eye-blink
EB_cor = [];

for n = 1:N
   
    [pks locs] = findpeaks(EB(:,n));
    if sum(pks > thr_EB) > 2
        TP = find(pks > thr_EB);
        interv = [];
        for tp = 1:length(TP)-1
            interv = [interv TP(tp+1)-TP(tp)];
        end
        
            
                
                TP_time = locs(TP);
                interv_time = [];
                
                for tp_t = 1:length(TP_time)-1
                    
                    interv_time = [interv_time TP_time(tp_t+1)-TP_time(tp_t)];
                    
                end
                
                if sum(SR*conf(1) < interv_time & interv_time < SR*conf(2)) == length(TP_time)-1
                   
                   if sum(pks > thr_EB) == 3
                       EB_cor = [EB_cor 1];
                   else
                    EB_cor = [EB_cor sum(pks > thr_EB)];    
                   end
                       
                else
                    if sum(SR*conf(1) < interv_time & interv_time < SR*conf(2)) == 2
                        EB_cor = [EB_cor 1];
                    else
                        EB_cor = [EB_cor sum(pks > thr_EB)];
                    end
                end
                
            

    else
    EB_cor = [EB_cor 0];    
    end
    
end

disp('EB accuracy (%)')
disp([num2str(sum(EB_cor==1)/60*100) ' %'])
disp([num2str(sum(EB_cor==1)/10) ' ea/min'])
% 10.33 min = 

thr_EMG = median(median(EMGforThr))/2;
% thr_EMG = 0.15;
EMG_cor = [];
conf = 2;
[M N] = size(EMG);
for n = 1:N
    
    area = sum(EMG(:,n)>thr_EMG);
    if area > SR*conf
        EMG_cor = [EMG_cor 1];
    else
        EMG_cor = [EMG_cor 0];
    end
end
disp('EMG accuracy (%)')
disp([num2str(sum(EMG_cor==1)/60*100) ' %'])
disp([num2str(sum(EMG_cor==1)/10) ' ea/min'])