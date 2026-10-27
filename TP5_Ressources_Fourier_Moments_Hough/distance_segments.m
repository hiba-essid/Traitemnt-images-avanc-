function dist = distance_segments(X1,Y1,X2,Y2,Xs,Ys,Xe,Ye)

% calcul la distance entre deux segments définis par les coordonnées (X,Y)
% de leurs extrémités (1 et 2 pour le 1er segment, s et e pour le second)

% changement de repère
long = norm([Xs-Xe,Ys-Ye]);

rot = -atan2(Ye-Ys,Xe-Xs);
%rot*180/pi

x1 = (X1-Xs)*cos(rot)-(Y1-Ys)*sin(rot);
y1 = (X1-Xs)*sin(rot)+(Y1-Ys)*cos(rot);
x2 = (X2-Xs)*cos(rot)-(Y2-Ys)*sin(rot);
y2 = (X2-Xs)*sin(rot)+(Y2-Ys)*cos(rot);

if x1>x2
    x=x1;
    y=y1;
    x1=x2;
    y1=y2;
    x2=x;
    y2=y;
end

% équation de la droite dans le nouveau repère
if((x1-x2)==0) % droite x = x0;
    a=100000;
else
    a = (y1-y2)/(x1-x2);
end
b = y1-a*x1;

if abs(a)>1
    dist = 9999;
else
    ind_int = 0;
    
    if a~=0
        i = -b/a;
        if i>x1 & i<x2 & i>0 & i<long
            ind_int = 1;
        end
    end
    
    dist = 0;
    
    % calcul de la distance entre les deux segments
    if x1<=0 & x2<=0
        
        a1 = a^2+1;
        b1 = 2*a*b;
        c1 = b^2;
        dist = integrale(a1,b1,c1,x1,x2);
        
    elseif x1<0 & x2>=0 & x2<=long
        
        a1 = a^2+1;
        b1 = 2*a*b;
        c1 = b^2;
        dist = integrale(a1,b1,c1,x1,0);
        if ind_int == 0
            dist = dist + abs((1/2)*a*x2^2+b*x2);
        else
            dist = dist + abs((1/2)*a*i^2+b*i);
            dist = dist + abs((1/2)*a*(x2^2-i^2)+b*(x2-i));
        end
        
    elseif x1<0 & x2>=long
        
        a1 = a^2+1;
        b1 = 2*a*b;
        c1 = b^2;
        dist = integrale(a1,b1,c1,x1,0);
        
        if ind_int == 0
            dist = dist + abs((1/2)*a*long^2+b*long);
        else
            dist = dist + abs((1/2)*a*i^2+b*i);
            dist = dist + abs((1/2)*a*(long^2-i^2)+b*(long-i));
        end
        
        a1 = a^2+1;
        b1 = 2*a*b - 2*long;
        c1 = b^2 + long^2;
        dist = dist + integrale(a1,b1,c1,long,x2);
        
    elseif x1>=0 & x1<=long & x2<=long
        
        if ind_int == 0
            dist = dist + abs((1/2)*a*(x2^2-x1^2)+b*(x2-x1));
        else
            dist = dist + abs((1/2)*a*(i^2-x1^2)+b*(i-x1));
            dist = dist + abs((1/2)*a*(x2^2-i^2)+b*(x2-i));
        end
        
    elseif x1>=0 & x1<=long & x2>long
        
        if ind_int == 0
            
            dist = dist + abs((1/2)*a*(long^2-x1^2)+b*(long-x1));
        else
            dist = dist + abs((1/2)*a*(i^2-x1^2)+b*(i-x1));
            dist = dist + abs((1/2)*a*(long^2-i^2)+b*(long-i));
        end
        a1 = a^2+1;
        b1 = 2*a*b - 2*long;
        c1 = b^2 + long^2;
        dist = dist + integrale(a1,b1,c1,long,x2);
        
    elseif x1>long & x2>long
        
        a1 = a^2+1;
        b1 = 2*a*b - 2*long;
        c1 = b^2 + long^2;
        dist = integrale(a1,b1,c1,x1,x2);
    end
    % normalisation
    dist = dist/norm([x1-x2,y1-y2]);
end

return;

function dist = integrale(a,b,c,x1,x2)

dist = (1/(8*(a^(5/2))))*((4*a^(5/2)*x2*sqrt(a*x2^2+b*x2+c) + 2*a^(3/2)*b*sqrt(a*x2^2+b*x2+c)...
    + (4*c*a^2 - a*b^2)*log((1/(2*sqrt(a)))*(2*a*x2+b+2*sqrt(a*x2^2+b*x2+c)*sqrt(a))))...
    - (4*a^(5/2)*x1*sqrt(a*x1^2+b*x1+c) + 2*a^(3/2)*b*sqrt(a*x1^2+b*x1+c)...
    + (4*c*a^2 - a*b^2)*log((1/(2*sqrt(a)))*(2*a*x1+b+2*sqrt(a*x1^2+b*x1+c)*sqrt(a)))));

return;