function [Y]=kalm2ord(X);

% This function filters data using a second order Kalman filter-based smoother 
% as described in Kitagawa, G., Gersch, W., IEEE transactions on Automatic
% Control, 30 N.1, 48-56, 1985.
% X input is a nxm matrix with m data series in columns, same for the yy output
% matrix Y.
% The value of the ratio between measnoise and statenoise 
% says how much we don't trust the data (high value>>poorly trust).
% this filter is based on accuracy rather than frequency and it's optimal.
% code by Stefano Corazza 
% University of Padova 2004 - Stanford University 2005-2006

measnoise_ = 7; % position measurement noise (mm) epsilon
statenoise_ = 2; % state noise (mm) tau

for u=1:1:size(X,2)
    Y(:,u)=kalmanfilter(X(:,u),measnoise_,statenoise_);
end

% % Plot the results
% figure;
% plot(Y,'-k');
% hold on;
% plot(X,'-r');
% grid on;
% xlabel('Frames');
% title('Kalman Filtering');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [yy]=kalmanfilter(xx,measnoise, statenoise);

frames=size(xx,1);   %  frames

I=eye(2);

A = [2 -1;1 0;]; % initial transition matrix
H = [1 0]; % measurement matrix
x = [xx(1); xx(2)]; % initial state vector

Q = [statenoise^2 0; 0 0]; % process noise covariance
P = [0 0;0 0]; % initial estimation covariance
R = measnoise^2; % measurement error covariance

% set up the size of the innovations vector
Inn = zeros(size(R));

pos = []; % true position array
poshat = []; % estimated position array
posmeas = []; % measured position array


for count=1:1:frames,
    z=[xx(count,1)];       %this is the measurement
    
    % time update
    xhat=A*x;
    Phat=A*P*A' + Q;
    
    % measurement update
    
    K=Phat*H'*inv(H*Phat*H'+R);
    Inn=z-H*xhat;
    x=xhat+K*Inn;
    P=(I-K*H)*Phat; 
    
    % Save some parameters in vectors for plotting later
    pos(:,count)=x;
    posmeas(:,count)=z;
    poshat(:,count)=xhat;
    Pi(:,:,count)=P;
    Pihat(:,:,count)=Phat;
end


%Smoother
k=0;
ii=0;
xN=pos;
xN(:,1)=[0; 0];
PN=Pi;
n=frames;
for ii=1:(frames-1),
    k=n-ii;
    F=Pi(:,:,k)*A'*([Pihat(:,:,k+1)]^-1);
    xN(:,k)=pos(:,k)+F*[xN(:,k+1)-poshat(:,k+1)];
    PN(:,:,k)=Pi(:,:,k)+F*[(PN(:,:,k+1)-Pihat(:,:,k+1))]*F';
end

yy=xN(1,:)';     


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


