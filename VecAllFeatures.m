function fmat = VecAllFeatures(all_ftypes, W, H)
%fmat = VecAllFeatures(all_ftypes, W, H)
%Calculates a matrix representation of the features defined in all_ftypes.
%
%Input      Size/Type   Comment
%all_ftypes nf x 5      Matrix where each column represents a feature on
%                       the form (type, x, y, w, h). nf is the number of
%                       features (e.g. from EnumAllFeatures).
%W          1 x 1       Width of original image.
%H          1 x 1       Height of original image.
%
%Output     Size/Type   Comment
%fmat       nf x W*H    Matrix representation of features, where each
%                       row represents a feature on the same form as
%                       VecBoxSum and VecFeature, i.e. all except 1-4
%                       entries equal zero.

nf = size(all_ftypes,1);
fmat = zeros(nf,W*H);

for iter = 1:nf
    fmat(iter,:) = VecFeature(all_ftypes(iter,:),W,H);
end