function [Rp, Tp]=sistRif_pelvi(RASIS, RPSIS, LASIS, LPSIS)
% Create a function that, given the coordinates of the markers 
% of the pelvi, calculates the matrices of rotation R and of translation T 
% (origin) of the reference system of the pelvi.


%1. Find Tp as midpoint……
Tp=(LASIS+RASIS)/2;

%2. Find Zp as vector from LASIS to RASIS
z=RASIS-LASIS;

% 3. Find the midpoint M between RPSIS and LPSIS
M=(RPSIS+LPSIS)/2;       %SACRUM

% 4. Find Xp_temp as vector from M to TP (in this way Xp_temp lies on the 
% plane defined by ASIS and midpoint between PSIS), find the versor
x_temp=Tp-M;
x_temp=x_temp/norm(x_temp);


% 5. Find Yp as vector perpendicular to Zp and Xp_temp (vectorial product and right hand rule) 
y=cross(z,x_temp);

% 6. Find the new Xp as vector perpendicular to Yp and Zp (vectorial product and right hand rule) 
x=cross(y,z);

% 7. Normalize all the vectors Xp, Yp and Zp to obtain versors
z=z/norm(z);
y=y/norm(y);
x=x/norm(x);

% check for orthogonality
check_ort=[dot(x,y);  dot(y,z);  dot(z,x)];

% 8. Calculate Rp as matrix with the versors in columns (look in the 
% workspace if they are row vectors or column vectors, and transpose if necessary)
Rp=[x' y' z'];