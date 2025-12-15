load input_delta1 input_delta2 output_Fy1 output_Fy2

u = input_delta1
y = output_Fy1

Ts     = 0.01;

% na = 1 
% nb = 2 

na = 1;  nb = 2;  nk = 1;


allCRna = []
% trouver le bon nb 
% attention nb=1 pour mieux voir
for na_t = [1:10]
    th=iv4(u,y,[na_t 2 nk])
    ym=idsim(u,th) % (entrée réelle appliquée au modèle)
    CR=sum((y-ym).*(y-ym))/length(ym)
    allCRna = [allCRna, CR]
end

plot(allCRna)
figure

allCRnb = []
% trouver le bon nb 
% attention nb=1 pour mieux voir
for nb_t = [1:10]
    th=iv4(u,y,[na nb_t nk])
    ym=idsim(u,th) % (entrée réelle appliquée au modèle)
    CR=sum((y-ym).*(y-ym))/length(ym)
    allCRnb = [allCRnb, CR]
end

%trouver visuellement 
plot(allCRnb)
figure

th = iv4(u,y,[na,nb,nk]);

ym=sim(u,th) % (entrée réelle appliquée au modèle)
CR=sum((y-ym).*(y-ym))/length(ym)
plot(ym)
hold on
plot(y, 'r')
[A,B,C,D]=th2poly(th) %transformer le modèle sous forme polynomiale

