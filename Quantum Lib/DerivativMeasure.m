% Measuring or Computing the gradient using the procedure in Figure 2 of
% the main paper for the 0-1 loss

function derivative = DerivativMeasure(s, RhoOutlayer,y, Uforward, M, MEASURE_FLAG)

MBar = M{2} - M{1};
V = expm((-1i*pi/4).*Pauli(s));
VTilde = (V*RhoOutlayer) * V';
Ea= 0.5*y*trace(MBar * (Uforward * (VTilde*Uforward') ) );

VTilde = (V'*RhoOutlayer) * V;
Eb= 0.5*y*trace(MBar * (Uforward * (VTilde*Uforward') ) );
E=Ea-Eb;

if MEASURE_FLAG
    q = (E+1)/2;
    derivative = randPMF([1-q, q],[-1,1],1);
else
    derivative = E;
end
end