
Fs = 48000; % sample rate (Hz)
N = 16000; % number of samples to simulate
gain = 4.5; % input signal gain parameter
f0 = 80; % excitation frequency (Hz)
t = 0:N-1; % time vector for the excitation
input = gain.*sin(2*pi*f0/Fs.*t); % the excitation signal

output = zeros(1,length(input));

% Device parameters for the following simulations are
% Rs = 2.2k?, Ch = 0.47?F, Cl = 0.01?F, Is = 2.52 � 10?9 A, and Vt = 45.3mV.

V1 = VoltageSource(0, 2200);

Ch = 0.47e-6; % the capacitance value in Farads

C1 = Capacitor(1/(2*Ch*Fs)); % create the capacitance

Cl = 0.01e-6;

C2 = Capacitor(1/(2*Cl*Fs));

A1 = Series(V1,C1);
A2 = Parallel(A1, C2);

Is = 2.52e-9;
Vt = 45.3e-3;

Rp = (A2.PortRes*C2.PortRes)/(A2.PortRes+C2.PortRes);
maxIter = 100;
dx = 1e-6;
err =  1e-6;
epsilon = 1e-9;
b2 = [];
b = 0; %initial guess
%% The simulation loop:
for n = 1:N % run each time sample until N
    %n
    V1.E = input(n); % read the input signal for the voltage source
    a = WaveUp(A2); % get the waves up to the root

    iter = 1;
    %b = 0;
    while (abs(err) / abs(b) > epsilon )
        f = 2*Is*sinh((a + b)/(2*Vt)) - (a - b)/(2*Rp);
        df = 2*Is*sinh((a + (b+dx))/(2*Vt)) - (a-(b+dx))/(2*Rp);
        newB = b - (dx*f)/(df - f);
        b = newB;
        if (iter > maxIter)
            %iter
            break;
        end
        iter = iter + 1;
    end
    b2(n) = b;
    setWD(A2, b); % evaluate the wave leaving the diode (root element)
    %Vdiode = (s1.WD+s1.WU)/2; % update the diode voltage for next time sample
    output(n) = Voltage(A2); % the output is the voltage over the resistor R1
end
%% Plot the results
t = (1:length(input))./Fs; % create a time vector for the figure
hi = plot(t,input,'--'); hold on; % plot the input signal, keep figure open
ho = plot(t,output);  % plot output signal, prevent further plots
grid on; % use the grid for clarity
xlabel('Time (s)'); ylabel('Voltage (V)'); % insert x- and y-axis labels
%legend([hi ho],'Source voltage E','Voltage over R1'); % insert legend