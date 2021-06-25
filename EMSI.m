function output = EMSI(Stim_freq, Data, fs, Nh, L)
% Multivariate synchronization index; EEG & reference ���� correlation �� ����ϴ� ���(CCA),
% S-estimator �� ����Ͽ� EEG �����Ϳ� �ִ��� synchronization �� ���̴� reference frequency �� 
% �з� ����μ� ����ϴ� �˰���
% 
% made by Hodam Kim, Computational Neuroengineering (CoNE) Laboratory, Hanyang University, South Korea
% rhg910907@hanyang.ac.kr 
%
% ===========================================================================
%
% ==== Input Arguments ====
%  - Stim_freq : the frequencies (Hz) used in the experiment
%  - Data : n (channel) x t (time) raw data to analyze
%  - fs : sampling rate
%  - Nh : number of harmonics. if it's not defined, 5 harmonic components are used (defualt).
%  - L : window size of the data to be analyzed in seconds. If it's not defined, the ratio of length of 'Data' to 'fs' is the default.
%
% ==== Output Arguments ====
%  - output : classification result as an index for 'Stim_freq'
%
% Reference : Zhang, Yangsong, et al. "Multivariate synchronization index for frequency recognition of SSVEP-based brain?computer interface." Journal of neuroscience methods 221 (2014): 32-40.

if nargin == 3 || nargin == 5
elseif nargin > 5
    error('At most 5 input arguments are acceptable');
elseif nargin < 3
    error('At least 3 input arguments are needed.');
end

if nargin == 3
    Nh = 5;
    L = size(Data, 2)/fs;
elseif nargin == 4
    L = size(Data, 2)/fs;
end

Ref_time = pi * Stim_freq' * linspace(0 , L, fs*L);

Ref_signal = zeros(fs*L,2*length(Stim_freq)*Nh);
for i = 1 : Nh
    Ref_signal(:,2*length(Stim_freq)*(i-1)+1:2*length(Stim_freq)*i) = [sin(2*i*Ref_time); cos(2*i*Ref_time)]';
end

Reference = permute(reshape(Ref_signal, fs*L, length(Stim_freq), 2*Nh), [3, 1, 2]);

S = zeros(1,length(Stim_freq));
X = Data(:,1:fs*L);
X = [X;circshift(X,1,2)];
X = (X-mean2(X))/std2(X);
for this_freq = 1:length(Stim_freq)
    Y = squeeze(Reference(:,:,this_freq));
    Y = (Y-mean2(Y))/std2(Y);    
    C11 = (X*X')/(fs*L); % C = [C11, C12; C21, C22]; 
    C12 = (X*Y')/(fs*L); % U = [C11^(-1/2), zeros; zeros, C22^(-1/2)]
    C21 = (Y*X')/(fs*L); % R = U*C*U'
    C22 = (Y*Y')/(fs*L);
    R = [eye(size(X,1)),C11^(-1/2)*C12*C22^(-1/2); C22^(-1/2)*C21*C11^(-1/2),eye(size(Y,1))];
    % C = cov(X',Y');
    % U = C.^(-1/2);
    % U(1,2) = 0; U(2,1) = 0;
    % R = U*C*U'
    e = eig(R);
    e = e/trace(R);
    S(this_freq) = 1+e'*log(e)/log(trace(R));
end

[~, output]  = max(S);