%% Quantum Stochastic Gradient Decent with gradient computation
% inputs:
%        - QNNArcitecture: a struct containing all the information on the architecture of the QNN. 
%          See QNN.m for more details.
%        - RhoIn: Input density operator
%        - y: the label.
function [QNNArcitecture, Yhat, Prob] = QSGD_c(RhoIn, y, QNNArcitecture)

L = QNNArcitecture.L;

for layer = 1 : L
    mNeuron = QNNArcitecture.mNeuron(layer);
    if mNeuron >0
        [RhoOutlayer, Uforward, Yhat, Prob] = QNN(RhoIn, QNNArcitecture, layer);
        for j = 1:mNeuron
            
            s_set = QNNArcitecture.NeuronCell{layer,j}.s;
            m = size(s_set,1);
            for r=1:m
                s = s_set(r,:);
                
                derivative = DerivativMeasure(s, RhoOutlayer,y, Uforward, QNNArcitecture.Measurement, false);
                
                update = -QNNArcitecture.QSGD.StepSize*QNNArcitecture.QSGD.LearningRate*derivative;
                QNNArcitecture.NeuronCell{layer,j}.a(r) = QNNArcitecture.NeuronCell{layer,j}.a(r) + update;
            end
        end
    end
end


QNNArcitecture.QSGD.LearningRate = 1/(sqrt( (1/QNNArcitecture.QSGD.LearningRate^2) + 1));

end
