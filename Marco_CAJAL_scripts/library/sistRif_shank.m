function [Rs, Ts]=sistRif_shank(HF, TT, MM, LM, left)
% Create a function that, given the coordinates of the markers 
% of the shank, calculates the matrices of rotation R and of translation T 
% (origin) of the reference system of the shank.



% 1. Define a temporary reference system
% a. calculate Ts
Ts=(MM+LM)/2;

% 1.b. calculate z_temp between MM and LM
if left==1  
    z_temp=MM-LM;
else
    z_temp=LM-MM;
end
z_temp=z_temp/norm(z_temp);

% 1.c. calculate y_temp between T and HF
y_temp=HF-Ts;
y_temp=y_temp/norm(y_temp);

% 2. Calculate the vector y using the given function 
[y]=find_y_proj(y_temp, z_temp, Ts, TT);

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
    
