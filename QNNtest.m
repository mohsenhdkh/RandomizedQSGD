%
% This function computes the validation accuracy of a trained QNN.


function [Test_acc, OPT_acc, Percentile_Psuccess] = QNNtest(QNNArcitecture, TestSamples)

[n_test,~] = size(TestSamples);
Dim = 2^QNNArcitecture.TotalQubit;
Test_loss =0;
Test_Psuccess =0;
RhoTypes{1} = sparse(Dim);
RhoTypes{2} = sparse(Dim);
nType = zeros(1,2);

for j=1:n_test
    RhoIn = TestSamples{j,1};
    y = TestSamples{j,2};
    [~, ~, Yhat, Prob] = QNN(RhoIn, QNNArcitecture, 1);
    Test_Psuccess = Test_Psuccess + Prob((y+1)/2+1);
    
    if y ~= Yhat
        Test_loss =  Test_loss + 1;
    end
    
    % optimal psuccess
    if y == -1
        RhoTypes{1} =   RhoTypes{1} + RhoIn;
        nType(1) = nType(1)+1;
    else
        RhoTypes{2} =   RhoTypes{2} + RhoIn;
        nType(2) = nType(2)+1;
    end
end
Percentile_Psuccess = 100*(Test_Psuccess/n_test);
Test_acc = 100*(1- Test_loss/n_test);

RhoTypes{1} = RhoTypes{1}./nType(1);
RhoTypes{2} = RhoTypes{2}./nType(2);
q =  (nType(1)/(nType(1)+nType(2)));
Opt_Psuccess = 0.5*(1+TraceNorm(q.*RhoTypes{1}-(1-q).*RhoTypes{2}));
OPT_acc = 100*Opt_Psuccess;

%% Displaying the results

if QNNArcitecture.QSGD.MEASURE_FLAG
        Method = 'Randomized QSGD';
    else
        Method = 'Direct Gradient Computation';
end
    
fprintf('---- Validation Results:  ------\n')
fprintf('  Training method: %s\n', Method)
fprintf('Test Accuracy = %3.2f \n',   Test_acc)
fprintf('Test Expected Accuracy = %3.2f \n',   Percentile_Psuccess)
fprintf('Test Optimal Accuracy = %3.2f \n',   OPT_acc)
end