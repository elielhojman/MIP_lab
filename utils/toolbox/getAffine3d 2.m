function [ aff ] = getAffine3d( rotAxis, rot_deg, translationXYZ_mm )
    aff = affine3d([utils.getRotationAboutAxisMatrix(rotAxis(:).',rot_deg) [0;0;0] ; translationXYZ_mm(:).' 1]);
end
