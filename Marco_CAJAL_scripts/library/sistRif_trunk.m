function [Rt, Tt]=sistRif_trunk(RA, LA, RPSIS, LPSIS)

% Set the midpoint of the PSID as Origin
MA = (RA + LA)/2;
MPSIS = (LPSIS + RPSIS)/2;

IT= (RA- LA)/norm(RA- LA);

PROVV= (MA- MPSIS)/norm(MA- MPSIS);

JT= cross(PROVV,IT);
JT= JT/norm(JT);

KT= cross(IT,JT);
KT= KT/norm(KT);

Tt= MPSIS;
Rt = [KT; IT; JT];


end