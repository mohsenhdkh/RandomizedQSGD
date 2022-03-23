%% QNN
% A MATLAB program constructing a QNN
% inputs:
%      - RhoIn: the input density operator
%      - layer_forward: used for QSGD. This parameter tells in which layer the gradient is to be measured/computed.  
%      - QNNArcitecture: a struct containing the information on the
%      architecture of the network. It has the following components:
%          + TotalQubit: total number of qubits input to the network.
%          + L: number of the layers
%           + mNeuron: a vector of length L telling the number of neurons in each layer.
%           + NeuronCell: A L x m cell array of structs each one is a neuron struct
%           + Neuron: a QNeuronClass object with the following components
%             + J: a vector with elements in [d] representing the systems the neuron acts on.
%             + k: narroness parametter
%             + a: a 1 x 4^k  vector of the Pauli coefficients taking values from {0,1,2,3} one for each combination of Pauli operators.
%      - a: a L x m cell array containing all the Fourier coefficients of each
%           neuron.Each cell is a 1 x 4^k  vector.
%
% Outputs:
%
%     - RhoOutlayer: computes the output density operator by acting the QNN
%                    upto layer = layer_forward. Thie output is used in QSGD.
%     - Uforward: Used for the QSGD. 
%       This is a unitary operator representing U_{L}U_{L-1}...U_{l+1}. 
%       This is the remaining part of the QNN for the forward layers.  
%     - Yhat: The predicted label. 
%     - Prob: Th eprobability distribution of Yhat conditioned on the input sample.  



function [RhoOutlayer, Uforward, Yhat, Prob] = QNN(RhoIn, QNNArcitecture,layer_forward)
L = QNNArcitecture.L;
d = QNNArcitecture.TotalQubit;
mNeuron = QNNArcitecture.mNeuron;
m_max=max(mNeuron);
U = cell(L, m_max);
Ulayer = speye(2^d);
Uforward =speye(2^d);
for l =1:L
    for j=1:mNeuron(l)
        as =  QNNArcitecture.NeuronCell{l,j}.a;
        s = QNNArcitecture.NeuronCell{l,j}.s;
        m = size(s,1);
        A=sparse(2^d,2^d);
        for r=1:m
            A = A + as(r).*Pauli(s(r,:));
        end
        A= sparse(A);
        U{l,j} = sparse(expm(1i*A));
       % UQNN = UQNN*U{l,j};
        if l > layer_forward
            Uforward = U{l,j} * Uforward;
        else
            Ulayer = U{l,j} * Ulayer;
        end
    end
    
end
UQNN = Uforward * Ulayer;  
if QNNArcitecture.EQubit >0
    ERho = QNNArcitecture.ERho;
    PaddedRho = Tensor(RhoIn, ERho);
else
    PaddedRho = RhoIn;
end
RhoOutlayer = (Ulayer * PaddedRho) * Ulayer';

RhoOut = (UQNN * PaddedRho) * UQNN';
q = real(trace(QNNArcitecture.Measurement{1}*RhoOut));
Prob = [q, 1-q];
Yhat = randPMF(Prob, [-1, 1] ,1);

end
