function [aa,ie,fe]=ges(Rpros,Rdist,knee)
% Create a function that, given 2 reference systems in input 
% (rotation matrices Rpros of the proximal segment and Rdist of the distal 
% segment) calculate the angles between 2 reference systems according to 
% the Grood&Suntay convention.

% 1. Find R of the joint, starting from the 2 reference systems in input 
% to the funtion 

I = Rpros(:,3);
J = Rpros(:,1);
K = Rpros(:,2);

i = Rdist(:,3);
j = Rdist(:,1);
k = Rdist(:,2);
    
% rotation matrix
Rtrasp(:,:) = [dot(I,i) dot(J,i) dot(K,i); dot(I,j) dot(J,j) dot(K,j); dot(I,k) dot(J,k) dot(K,k)];
R=Rtrasp';

% other possible method
Rp=Rpros(:,[3 1 2]);
Rd=Rdist(:,[3 1 2]);
R1=Rp'*Rd;


aa=((acos(R(1,3)))*180/pi)-90; 
fe=(atan2(R(2,3),R(3,3)))*180/pi;
ie=(atan2(R(1,2),R(1,1)))*180/pi;


if knee ~= 1
    fe=-fe;
end


end

