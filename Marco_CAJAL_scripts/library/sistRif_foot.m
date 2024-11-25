function [Rf, Tf]=sistRif_foot(CA, FM, SM, VM, left)
% Create a function that, given the coordinates of the markers 
% of the foot, calculates the matrices of rotation R and of translation T 
% (origin) of the reference system of the foot.

% Tf on the calcaneus
Tf=CA;

% 1.Define a temporary reference system
% 1.a. calculate z_temp between VM and FM (viceversa on le left)
if left==1
    z_temp=FM-VM;
else
    z_temp=VM-FM;
end
z_temp=z_temp/norm(z_temp);

% 1.b. calculate y_temp between T and FM
y_temp=CA-FM;
y_temp=y_temp/norm(y_temp);

% 2.Calculate the vector y using the given function 
[y]=find_y_proj(y_temp, z_temp, SM, CA);

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
Rf=[x' y' z'];
    
