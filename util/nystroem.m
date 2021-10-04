function [eigVal,eigVec] = nystroem(XX,XY,nrEV)

tic;
fprintf("Calculate Nyström Method ... ");

% Normalize
oneL = ones(size(XX,1),1);
oneNL = ones(size(XY,2),1);
dx = XX * oneL + XY * oneNL;
dy = XY' * oneL + (XY' * (pinv(XX) * (XY * oneNL)));                                                % Clamping influences result (not sure which one is the most correct)
sx = sqrt(dx);
sy = sqrt(dy);
XX_hat = XX ./ (sx * sx');
XY_hat = XY ./ (sx * sy');
clear sx sy dx dy oneL oneNL;

% Calculate Eigenvales and Eigenvectors of normalized XX
[eigVecXX,eigValXX] = eig(XX_hat);


% Calculate Eigenvales and Eigenvectors of normalized XX_2
eigValXXDivSqrt = (eigValXX^(-1/2));                                                            
S    = eigVecXX * eigValXXDivSqrt * eigVecXX';
XX_2 = XX_hat + S * (XY_hat * XY_hat') * S;
XX_2 = (XX_2 + XX_2') / 2;                                                                          % added: make symmetric (sometimes not symmetric because of numerical errors)
[eigVecXX_2,eigValXX_2] = eig(XX_2);
 clear S XX_2 XX_hat XX_2;
 
 % Sort Eigenvalues and Eigenvectors
eigVal = eye(size(eigValXX_2,1))-eigValXX_2;
[~,ind] = sort(diag(eigVal),'ascend');
selInd = ind(1:nrEV);
eigVal = eigVal(selInd,selInd);

% Calculate Eigenvectors and Eigenvalues of Whole Matrix
top = eigVecXX * eigValXX^(1/2) * eigVecXX' * eigVecXX_2 * eigValXX_2^(-1/2);
bottom = eigVecXX * eigValXXDivSqrt * eigVecXX' * eigVecXX_2 * eigValXX_2^(-1/2);
eigVec = [top(:,selInd); XY_hat' * bottom(:,selInd)];
eigVec = real( eigVec );



% normalize eigenvectors
for i = 1:size(eigVec,2)
    if norm(eigVec(:,i)) ~= 0
        eigVec(:,i) = eigVec(:,i) / norm(eigVec(:,i));
    else
        eigVec = eigVec(:,1:i-1);
        eigVal = eigVal(1:i-1,1:i-1);
        break;
    end
end


time = toc;
fprintf([' in ', num2str(time),' seconds.\n'])
