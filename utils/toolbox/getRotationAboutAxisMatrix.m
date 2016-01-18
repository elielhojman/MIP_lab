function R = getRotationAboutAxisMatrix( n,theta_deg )

if (abs(norm(n))<1e-10)
    R = eye(3);
    return;
else
    n = n/norm(n);
end

% SOURCE:
% http://en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_and_angle
ux = n(1);
uy = n(2);
uz = n(3);

UX = ...
    [   0   -uz uy;...
        uz  0   -ux;...
        -uy  ux 0];

UU = [ux;uy;uz]*[ux uy uz];

R = cosd(theta_deg) * eye(3) + sind(theta_deg) * UX + (1 - cosd(theta_deg)) * UU;

end

