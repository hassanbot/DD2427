function [fpr, tpr, thresholds] = ComputeROC(Cparams, TData, c, thresholds)

test_inds = setdiff(1:length(TData.ys), TData.train_inds);
ys = TData.ys(test_inds);
scs = ApplyDetector(Cparams,TData.ii_ims(:,test_inds));

if nargin < 4
    nthresh = 500;
end
thresholds = linspace(min(scs),max(scs),nthresh);

% Each row in C corresponds to a threshold
[S, T] = meshgrid(scs, thresholds);

C = S > T;
C = 2*C-1;

pos_tot = sum(ys>0);
neg_tot = sum(ys<0);

YS = repmat(ys', size(C,1),1);
ntp = sum((YS>0).*(C>0),2);
nfp = sum((YS<0).*(C>0),2);

tpr = ntp / pos_tot;
fpr = nfp / neg_tot;
if nargin < 3
    plot(fpr,tpr)
else
    plot(fpr,tpr,c)
end

title('ROC curve')
xlabel('False positive rate')
ylabel('True positive rate')

end