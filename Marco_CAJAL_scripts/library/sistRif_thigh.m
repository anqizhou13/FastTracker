function [Rt, Tt]=sistRif_thigh(ME, LE, FH, left)
% Create a function that, given the coordinates of the markers 
% of the thigh, calculates the matrices of rotation R and of translation T 
% (origin) of the reference system of the thigh.


%1. Find Tt as midpoint……
Tt=(ME+LE)/2;

%2. Yt – line between the origin Ot and the head of femur FH, with positive direction proximally 
y=FH-Tt;

% 3. Zt lies on the frontal plane defined by Yt axis and the epicondyles, 
% with positive direction from left to right...we have to calculate a temporary axis Z_temp 
if left==1   
    z_temp=ME-LE;
else
    z_temp=LE-ME;
end
z_temp=z_temp/norm(z_temp);


% 4. Xt – it is perpendicular to the yz plane, with positive direction anteriorly
x=cross(y, z_temp);

% 5. Find the new Zt as vector perpendicular to Xt and Yt (vectorial product and right hand rule) 
z=cross(x, y);


% 6. Normalize all the vectors Xt, Yt and Zt to obtain versors
y=y/norm(y);
x=x/norm(x);
z=z/norm(z);

% check for orthogonality
check_ort=[dot(x,y);  dot(y,z);  dot(z,x)];

% 7. Calculate Rt as matrix with the versors in columns (look in the 
% workspace if they are row vectors or column vectors, and transpose if necessary)
Rt=[x' y' z'];

    
