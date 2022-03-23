%
% This function trains a QNN and returns the training loss markers and the
% trained QNN. 
% There are two ways to train a QNN: 
%  - QSGD with direct computation of the gradient. This method is useful
%    for testing only where unlimitted copy of each sample is available. 
%  
%   - Randomized QSGD as in Algorithm 1 of the main paper. This is the reallistic procedure where the
%     gradient is measured as apposed to direct computation.  


function [QNNArcitecture, EpochLoss, EpochPSuccess,Max_Psuccess, figure_handle] = QNNtrain(QNNArcitecture, SupervisedSamples, n_epoch, BatchSize, PlotFlag)


Dim = 2^QNNArcitecture.TotalQubit;

EpochLoss = -1*ones(n_epoch,1);
EpochPSuccess = -1*ones(n_epoch,1);
Max_Psuccess =  -1*ones(n_epoch,1);
RhoTypes = cell(1,2);

layer_forward =0;
for epoch = 1: n_epoch
    loss =0;
    Psuccess =0;
    
    RhoTypes{1} = sparse(Dim);
    RhoTypes{2} = sparse(Dim);
    nType = zeros(1,2);
    
    for i = 1:BatchSize
        Indx = (epoch -1)*BatchSize + i;
        RhoIn = SupervisedSamples{Indx,1};
        y = SupervisedSamples{Indx,2};
        
        if ~QNNArcitecture.QSGD.MEASURE_FLAG
            [QNNArcitecture, Yhat, Prob] = QSGD_c(RhoIn, y, QNNArcitecture);  % Update rule with direct computation of the gradient
        else
            
            layer_forward = layer_forward+1;
            if layer_forward > QNNArcitecture.L
                layer_forward =1;
            end
            
            [RhoOutlayer, Uforward, Yhat, Prob] = QNN(RhoIn, QNNArcitecture, layer_forward);
            QNNArcitecture = QSGD_r(RhoOutlayer, Uforward, y, QNNArcitecture, layer_forward); % Update rule with the randomized gradient measurement
        end
        %samples success probability
        Psuccess = Psuccess + Prob((y+1)/2+1);
        
        % empirical loss
        if y ~= Yhat
            loss =  loss + 1;
        end
        
        % Maximum Psuccess
        if y == -1
            RhoTypes{1} =   RhoTypes{1} + RhoIn;
            nType(1) = nType(1)+1;
        else
            RhoTypes{2} =   RhoTypes{2} + RhoIn;
            nType(2) = nType(2)+1;
        end
    end
    
    EpochLoss(epoch) = loss/BatchSize;
    EpochPSuccess(epoch) = Psuccess/BatchSize;
    
    q =  (1/(nType(1)+nType(2)));
    Max_Psuccess(epoch) = 0.5*(1+TraceNorm(q.*RhoTypes{1}-(q).*RhoTypes{2})); % calculation of a theoretical bound on the maximum accuracy. 
    
end


%% Plotting the training loss
if PlotFlag
    figure_handle = figure;
    plot(1:n_epoch,EpochLoss,'.')
    hold on
    plot(1:n_epoch,1-EpochPSuccess,'r')
    hold on
    plot(1:n_epoch,1-Max_Psuccess,'-- k')
    
    if QNNArcitecture.QSGD.MEASURE_FLAG
        Method = 'Randomized QSGD';
    else
        Method = 'Gradient Comp.';
    end
    
    title(['Training Loss with ', Method, ...
        'StepSize =', num2str(QNNArcitecture.QSGD.StepSize)])
    
    ylabel('Loss')
    xlabel('Batch')
    legend('Empirical Loss', 'Expected Loss', 'Minimum Loss')
    grid on
end

end