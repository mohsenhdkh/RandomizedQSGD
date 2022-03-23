%% Quantum Stochastic Gradient Decent
% inputs:
%        - QNNArcitecture: a struct containing the information on the architecture of the network. It has the folloing components.
%          See QNN.m for more details.
%        - RhoOutlayer: Output state of QNN up to the given layer
%        - y: the label.
%        - Uforward: The remaining layers of the QNN.
%        - layer: the layer at which QSGD is applied.
%
%ouput:
%        - QNNArcitecture with updated coefficients.
function QNNArcitecture = QSGD_r(RhoOutlayer, Uforward, y, QNNArcitecture,layer)

%% Measuring the Gradient


mNeuron = QNNArcitecture.mNeuron(layer);


if mNeuron >0
    
    j =  randi(mNeuron);   % Randomly selecting a QP in the layer.
    s_set = QNNArcitecture.NeuronCell{layer,j}.s;
    
    r = randi(size(s_set,1)); % randomly selecting a coefficient a_s for the selected QP.
    
    s = s_set(r,:);
    
    
    derivative = DerivativMeasure(s, RhoOutlayer,y, Uforward, QNNArcitecture.Measurement, true);
    
    update = -QNNArcitecture.QSGD.StepSize*QNNArcitecture.QSGD.LearningRate*derivative;
    QNNArcitecture.NeuronCell{layer,j}.a(r) = QNNArcitecture.NeuronCell{layer,j}.a(r) + update;
    
    
    
    
    
    if layer == QNNArcitecture.L
        QNNArcitecture.QSGD.LearningRate = 1/(sqrt( (1/QNNArcitecture.QSGD.LearningRate^2) + 1));
    end
end

end
