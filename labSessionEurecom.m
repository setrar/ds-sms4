% Eurecom lab session: OFDM receiver with coverage enhancement
% Date: May 2024
% Course: Radio Engineering
% Professor: Florian Kaltenberger
% Guest lecturers: Dr. Elena Lukashova (elukashova@sequans.com) 
%                  Dmitry Pyatkov 

clc
clear

% close all
%% Configurable simulation parameters

% Repetition level
R = 1;

% Number of transmissions
T = 1;

% Signal to Noise Ratio (SNR)
snrRange = -20:10:30;

% STO error in samples, MUST BE NEGATIVE
stoError = -0;
if(stoError > 0)
    error('STO error in samples MUST BE NEGATIVE')
end

% CFO error in Hz, We assume that sc spacing is 15 kHz and Fsmp = 1.92 MHz
cfoErrorHz = -0;


%% Non-configurable simulation parameter - DO NOT EDIT!

% Number of subcarriers per OFDM symbol
K  = 72;

% Number of OFDM symbols per repetition
L = 14;

% Number of pilots per OFDM symbol
P = 12;

% Pilot spacing in number of subcarriers
ps = K/P;

% Specify pilot positions per OFDM symbol
kp = 1:ps:K;

% STO rotation vector of each OFDM symbol
%rot = exp(1j*2*pi*(0:1:K-1)*sto/K).';

% EVM [%] to guarantee succesful decoding
targetEvm = 50;

% Enable repetition combining
combEnabled = 1;

% Limits of x-y constellation in plots
constLimit = 2;


%% Snr loop

for snrCnt = 1:length(snrRange)

    % Noise power
    N = 10^(-snrRange(snrCnt)/10);

    %% Transmission
    
    % Generate QPSK symbols
    x = 1/sqrt(2)*(2*randi([0 1], K, L)-1 + 1i*2*randi([0 1], K, L)-1i);
    
    % Assign pilots from symbols - these will be known to the receiver
    p = x(kp, :);
    
    % Save original QPSK symbols as reference for EVM estimation
    x_orig = x;

    % IFFT, no DC
    for symbolCnt = 1:L
        
        % place symbols to the central part of the bandwidth
        freq_128bins = [zeros(28,1); x(:,symbolCnt); zeros(28,1)].';
        
        % apply fftshift and ifft
        freq_128bins = fftshift(freq_128bins);
        time_128samp = ifft(freq_128bins)*sqrt(128);

        % add CP
        cpLength    = 9;
        cpSamples   = time_128samp(end-cpLength+1:end);
        timeSymbol  = [cpSamples time_128samp];

        xTimeDomain(:,symbolCnt) = timeSymbol.';

    end
    
    %% Channel
    
    % Generate flat, static channel
    h = 1/sqrt(2) + 1/sqrt(2)*1i;

    %% Reception
    
    % Loop over transmissions
    for t = 1:T

        % Initialize receive signal
        y = zeros(K, L);

        % Loop over repetitions
        for r = 1:R
    
            % Generate complex Gaussian noise
            n = sqrt(N/2)*randn(128+cpLength, L) + sqrt(N/2)*1i*randn(128+cpLength, L);

            % Received signal in time domain
            yTime = h*xTimeDomain + n;

            for symbolCnt = 1:L
                 
                symbolTd = yTime(:,symbolCnt).';

                % Add CFO
                samplingRate = 1.92e6;
                cfoPhaseRamp    = 2*pi*cfoErrorHz/samplingRate;
                cfoSampleInit   = (r-1)*length(symbolTd)*L + (symbolCnt-1)*length(symbolTd);
                % pay attention to numeric accuracy, this implementation is
                % could not be used for infinite CFO generation
                cfoVector       = exp(1j*cfoPhaseRamp*([0:length(symbolTd)-1]+cfoSampleInit));
                symbolTd        = symbolTd .* cfoVector;
                

                % Detection 

                % Remove CP containing STO error
                symbolTd = symbolTd(cpLength+1+stoError:end+stoError);
                
                % fft and fftshift
                symbolFd = fftshift(fft(symbolTd));

                startSc = (128 - 72)/2 + 1;
                
                % Extract central subcarriers 
                yr(1:K,symbolCnt) = symbolFd(startSc:startSc+K-1);

            end
    
            % Repetition combining (or not)
            y = combEnabled*y + yr;
    
            % Normalize the signal according to the repetition index
            y_norm = y/r;
    
            % Exctract pilot subcarriers from current signal
            yp = yr(kp,:); 

            % Least square channel estimation for pilots and average over
            % symbols and subcarriers
            h_est = mean(mean(yp./p, 2));
    
            % Zero-forcing equalization
            x_est = y_norm./h_est;
    
            % Calculate Error Vector Magnitude (EVM) per repetition

        end

        % Calculate EVM per transmission
    end

    % Calculate EVM per SNR


end

%Plot EVM vs SNR

