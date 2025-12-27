%% MUT 304 - Final Project (1 point)
% Name - [Daniel Turk] (1 point)
% Date - [12/8/2025] (1 point)

% Tests eight_param_eq.m which uses biquad_filter.m
% Creates 2 figures and plays unprocessed, then processed white noise
% (Warning: LOUD!)

% Run script as a whole, run individual parts after running whole program if desired
%% Project parent folder must include biquad_filter.m and eight_param_eq.m



%% Testbench code:
%% General Parameters
fs = 44100;             
N = 4096 * 4; % num samples (power of 2 for speed!)

% generate rand signal 
input_signal = 2 * rand(N, 1) - 1;

%% Define eq parameters

% cutoff frequencies
cutoffs = [60, 150, 400, 1000, 2500, 5000, 10000, 16000];

% gains(dB), alternating positive and negative for visibility
gains = [0, -6, 6, -10, 10, -6, 6, 0]; 

% Q factors
q_factors = [0.707, 2, 2, 0.5, 2, 2, 1, 0.707];

%% Construct EQ
myEQ = eight_param_eq(cutoffs, gains, q_factors, fs);

%% Process Buffer
output_signal = processAudio(myEQ, input_signal);

%% Play signals
player = audioplayer(input_signal, fs);
playblocking(player);
player = audioplayer(output_signal, fs);
playblocking(player);

%% Create FFT 
N = length(input_signal);
f = (0:N-1) * (fs/N);  % Create real Frequency Axis (Hz)

in_fft  =  mag2db(abs(fft(input_signal)/N));
out_fft =  mag2db(abs(fft(output_signal)/N));



%% Plot
figure();

% create plot with input in white and output in blue 
semilogx(f(1:N/2), (in_fft(1:N/2)) + 30); hold on;
semilogx(f(1:N/2), (out_fft(1:N/2) - 10), 'b');

grid on;
title('Parametric EQ White Noise Frequency Response');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB) [Offset for visual clarity]');
xlim([20 20000]); 
ylim([-100 20]);
legend('Input (Offset)', 'Output (Offset)');

% Draw vertical lines at cutoff frequencies
for k = 1:length(cutoffs)
    xline(cutoffs(k), '--r', 'Alpha', 0.5, 'HandleVisibility', 'off');
  
end


%% Now lets do an impulse
N = 4096 * 4;

% signal starting with a 1 followed by zeros
impulse = [1; zeros(N-1, 1)];


% rebuild eq
myEQ = eight_param_eq(cutoffs, gains, q_factors, fs);


% process input
impulseFiltered = processAudio(myEQ, impulse);


%% Create the fft and plot it
f = (0:N-1) * (fs/N);  % Create real Frequency Axis (Hz)

in_fft  =  mag2db(abs(fft(impulse)/N));
out_fft =  mag2db(abs(fft(impulseFiltered)/N));

figure();

% create plot with input in white and output in green 
semilogx(f(1:N/2), (in_fft(1:N/2)) + 20); hold on;
semilogx(f(1:N/2), (out_fft(1:N/2) + 20), 'g');

grid on;
title('Parametric EQ Impulse Frequency Response');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
xlim([20 20000]); 
ylim([-100 -20]);
legend('Input (Offset)', 'Output (Offset)');

% Draw vertical lines at cutoff frequencies
for k = 1:length(cutoffs)
    xline(cutoffs(k), '--r', 'Alpha', 0.5, 'HandleVisibility', 'off');
  
end

