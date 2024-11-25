function [y]=find_y_proj(y_temp, z_temp, point1, point2)

%axis perpendicular to the quasi-frontal plane (positive direction forwards)
Hort=cross(y_temp, z_temp);
Hort=Hort/norm(Hort);

%calculate 
vectTT=point2-point1;

%component of vectTT orthogonal to the frontal plane (projected on the axis
%orthogonal to the quasi-frontal plane
Tort=dot(vectTT, Hort)*Hort;

%axis y =component of vectTT that lies on the quasi-frontale plane (positive
% direction proximal)
y=vectTT-Tort;
y=y/norm(y);