% Analog phasor described in DAFX

fs = 44100; %fs/2

[x,fs] = audioread('highpitchchords.wav');
x = x(:,1);
t = 44100*2; % length of sound in samples
%x = 2*rand(1,t);
%x = x - mean(x); % remove DC off
%pluck = linspace(0,N);
%x = (pluck);
%x = [1, zeros(1,N-1)]; % Impulse response

out = 0;
signal = 0;

if t > length(x)
    diff = t - max(size(x));
    x = [x zeros(1,diff)];
end

R1 = 0.99;R2 = 0.99;R3 = 0.99;R4 = 0.8;
theta1 = 440*2*pi;theta2 = 500*2*pi;theta3 = 800*2*pi;theta4 = 100*2*pi;

a11 = -2*R1*cos(theta1);
a21 = R1^2;

a12 = -2*R2*cos(theta2);
a22 = R2^2;

a13 = -2*R3*cos(theta3);
a23 = R3^2;

a14 = -2*R4*cos(theta4);
a24 = R4^2;

AP1 = [0, 0, 0];
AP2 = [0, 0, 0];
AP3 = [0, 0, 0];
AP4 = [0, 0, 0];

xn1 = 0;
xn2 = 0;

wet = 0.6;
dry = 1-wet;

for i = 1:t % t is the iterations
    theta1 = 440*pi*(i)/fs;
    if theta1 > pi
        theta1 = theta1 - pi;
    end
    theta2 = 240*pi*(i)/fs;
    if theta2 > pi
        theta2 = theta2 - pi;
    end
    theta3 = 140*pi*(i)/fs;
    if theta3 > pi
        theta3 = theta3 - pi;
    end
    theta4 = 840*pi*(i)/fs;
    if theta4 > pi
        theta4 = theta4 - pi;
    end
    a11 = -2*R1*cos(theta1);

    a12 = -2*R2*cos(theta2);

    a13 = -2*R3*cos(theta3);

    a14 = -2*R4*cos(theta4);
    
    % first allpas
    AP1(1) = a21 * x(i) + a11 * xn1 + xn2 - a11 * AP1(2) - a21 * AP1(3);
    
    % second allpas
    AP2(1) = a22 * AP1(1)+ a12 * AP1(2) + AP1(3) - a12 * AP2(2) - a22 * AP2(3);
   
    % third allpass
    AP3(1) = a23 * AP2(1)+ a13 * AP2(2) + AP2(3) - a13 * AP3(2) - a23 * AP3(3);
    
    % fourth allpass
    AP4(1) = a24 * AP3(1)+ a14 * AP3(2) + AP3(3) - a14 * AP4(2) - a24 * AP4(3);
    
    % signal
    xn2 = xn1;
    xn1 = x(i); 
    
    % first allpass
    AP1(3) = AP1(2);
    AP1(2) = AP1(1);
    
    % second allpass
    AP2(3) = AP2(2);
    AP2(2) = AP2(1);
    
    % third allpass
    AP3(3) = AP3(2);
    AP3(2) = AP3(1);
    
    % fourth allpass
    AP4(3) = AP4(2);
    AP4(2) = AP4(1);
    
    signal = [signal, dry*x(i)+wet*AP4(1)];
end
plot(signal)
soundsc(signal, fs)