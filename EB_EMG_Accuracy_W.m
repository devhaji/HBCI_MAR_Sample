clear all; close all; clc;
% Sub1,2,3,4,5 EB, EMG FPR
load('Sub1_EMG.mat');
% Sub#_EMG.mat
% EMG data for thresholding
% 1 x data x trials
% number of EMG data : 2048 [4 s X 512 sampling rate]
% number of EMG trials : 30 (30 cycles)
EMGforThr = EMG; % For thresholding
load('Sub1_EB.mat');
% Sub#_EB.mat
% 1 x data x trials
% number of EB data : 1536 [3 s X 512 sampling rate]
% number of EB trials : 30 (30 cycles)

EB = squeeze(EB);
EMG = squeeze(EMG);
SR = 512;
conf = [0.3 0.8]; % confidence range (peak interval) [seconds]
[M N] = size(EB);
thr_EB = 100; % thresholding for Eye-blink
thr_for_CWT = 20;
EB_cor = [];

for n = 1:N
    
    CW_blink = cwt(EB(:,n),1:8,'bior1.3');
    [pks_cwt locs_cwt] = findpeaks(-CW_blink(8,:));
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
                
            

    elseif sum(pks_cwt > thr_for_CWT) > 2
            
            
            TP = find(pks_cwt > thr_for_CWT);
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
                   
                   if sum(pks_cwt > thr_for_CWT) == 3
                       EB_cor = [EB_cor 1];
                       
                   else
                    EB_cor = [EB_cor sum(pks_cwt > thr_for_CWT)];    
                   end
                       
                else
                    if sum(SR*conf(1) < interv_time & interv_time < SR*conf(2)) == 2
                        EB_cor = [EB_cor 1];
                        disp('11');
                    else
                        EB_cor = [EB_cor sum(pks_cwt > thr_for_CWT)];
                        
                    end
                end
                
    else    
        disp('2');
    EB_cor = [EB_cor 0];    
    end
    
end

disp('EB accuracy (%)')
disp([num2str(sum(EB_cor==1)/30*100) ' %'])

thr_EMG = median(median(EMGforThr))/2;
% thr_EMG = 0.15; % Thresholding for realtime
EMG_cor = [];
conf = 2; % [seconds] 
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
disp([num2str(sum(EMG_cor==1)/30*100) ' %'])