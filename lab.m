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

