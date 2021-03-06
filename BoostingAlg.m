function Cparams = BoostingAlgTest(TData, T, t_inds)
% Cparams = BoostingAlg(Tdata, T)
% implements the boosting algorithm AdaBoost, creating a strong classifier
% from several weak ones.
% 
% Input     Size/Type   Comment
% TData     struct      Feature information and integral images to be used
%                       in the weak classifiers. On the same form as in
%                       SaveTrainingData.
% T         1 x 1       Number of weak classifiers to be used.
% t_inds    n_inds x 1  Optional: List of indices of features to use. 
%                       n_inds are the number of indices specified.
% 
% Output as a struct with the following fields:
% Fields    Size/Type   Comment
% alphas    T x 1       Parameter from Algorithm 1
% Thetas    T x 3       Each row is on the form (fs, theta, ps), where fs
%                       is the features chosen, theta is the threshold and
%                       ps is the parity.
% fmat      nf x np     Matrix representation of features, where each
%                       column represents a feature.
% all_ftypes nf x 5     all_ftypes have the columns (type, x, y, w, h) 
%                       where type is the feature type; x and y are 
%                       starting position for the feature (upper left 
%                       corner) and h and w denote the height and width.

if nargin < 3
   t_inds = 1:size(TData.fmat, 1);
end

ii_ims = TData.ii_ims(:,TData.train_inds);
% fmat = sparse(TData.fmat(t_inds,:));
fmat = TData.fmat(t_inds,:);
ys = TData.ys(TData.train_inds);

% Calculate initial weights
n = numel(ys);
m = sum(ys < 0);
w_n = (ys < 0)/(2*m); % Negative weights
w_p = (ys > 0)/(2*(n-m)); %Positive weights
ws = w_n + w_p;

nfeat = size(fmat, 1);
% errs = zeros(nfeat, 1);
% theta = zeros(nfeat, 1);
% p = zeros(nfeat, 1);

Thetas = zeros(T, 3);
alphas = zeros(T, 1);

fs = fmat*ii_ims;

ys_p = 1+ys;
ys_n = 1-ys;
Ys_p = repmat(ys_p,1,nfeat);
for t = 1:T
    ws = ws/sum(ws); % Normalization
    ws_t = ws';
    
    % Training of weak classifier, aka wall of matrix operations
    % Translated from LearnWeakClassifier
    A = fs.*repmat(ws_t,nfeat,1);
    N_p = A*ys_p; % Positive nominator of equation 10, algorithm 2 
    N_n = A*ys_n; % Negative nominator of equation 10, algorithm 2
    D_p = ws_t*ys_p; % Positive denominator of equation 10, algorithm 2
    D_n = ws_t*ys_n; % Negative denominator of equation 10, algorithm 2
    Mu_p = N_p./D_p;
    Mu_n = N_n./D_n;
    theta = (Mu_p + Mu_n)/2;
    G = fs > repmat(theta,1,n);
    G = G'*2;
    Err_n = (ws_t*abs(Ys_p - G))/2;
    p = Err_n > 0.5;
    errs = p.*(1-Err_n);
    errs = errs -(p-1).*Err_n;
    p = p*2-1;
    
    % Coose weak classifiers with lowest error and store parameters
    [err, ind] = min(errs);
    Thetas(t,:) = [ind, theta(ind), p(ind)];
    alphas(t) = log((1-err)/err)/2;
    
    % Update weights
    ws = ws.*exp(-alphas(t) * ys .* ...
        classify(Thetas(t,:), fmat(ind,:)*ii_ims));
end

Cparams = struct('alphas', alphas, 'Thetas', Thetas,...
    'fmat', fmat, 'all_ftypes', TData.all_ftypes(t_inds,:));

end

function h = classify(Theta_t, fs)
% Classifies the images according to equation 8.
theta = Theta_t(2);
p = Theta_t(3);
h = p*fs < p*theta;
h = (h*2-1)'; % Make elements of g be either 1 or -1.

end