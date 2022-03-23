function M = QMeasurement(Coordinates, TotalQubit, Type)

Dim = 2^TotalQubit;
PiJ =Coordinates; % The range space of PI

phi = [1,0];
if sum(find(PiJ == 1)) == 0
    PI = speye(2);
else
    PI = phi'*phi;
end

for j=2:TotalQubit
    if sum(find(PiJ == j)) == 0
        PI = Tensor(PI, speye(2));
    else
        PI = Tensor(PI, phi'*phi);
    end
end

psi = [0, 1];
if sum(find(PiJ == 1)) == 0
    Ptemp = speye(2);
else
    Ptemp = psi'*psi;
end

for j=2:TotalQubit
    if sum(find(PiJ == j)) == 0
        Ptemp = Tensor(Ptemp, speye(2));
    else
        Ptemp = Tensor(Ptemp, psi'*psi);
    end
end

PI =PI + Ptemp;

M = cell(1,2);
M{2} = PI;
M{1} = speye(Dim) - PI;
end