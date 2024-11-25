function [Rs, Ts]=sistRif_arm(RA, LA, ELB, left)
% Create a function that, given the coordinates of the markers 
% of the shank, calculates the matrices of rotation R and of translation T 
% (origin) of the reference system of the shank.



% 1. Define a temporary reference system
% a. calculate Ts
Ts=(RA+LA)/2;

% 1.b. calculate z_temp between MM and LM
if left==1  
    z_temp=LA-RA;
else
    z_temp=RA-LA;
end
z_temp=z_temp/norm(z_temp);

% 1.c. calculate y_temp between T and HF
y=ELB-Ts;
y=y/norm(y);

% 3. Calculate x perpendicular to y and z_temp, and then z ….
x=cross(y,z_temp);
z=cross(x,y);

% Normalize all the vectors
x=x/norm(x);
y=y/norm(y);
z=z/norm(z);

% check for orthogonality
check_ort=[dot(x,y);  dot(y,z);  dot(z,x)];

% Calculate Rt as matrix with the versors in columns (look in the 
% workspace if they are row vectors or column vectors, and transpose if necessary)
Rs=[x' y' z'];