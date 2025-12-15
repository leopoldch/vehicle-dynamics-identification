load input_delta1
load input_delta2
load output_Fy1
load output_Fy2

% Attention forte non linéarité du système donc résultats non optimaux

u = input_delta1
y = output_Fy1

nb = 2
nf = 4
nk = 2

allCR1 = []
allCR2 = []
allCR3 = []

% trouver le bon nb 
% attention nb=1 pour mieux voir
for tnb = [1:10]
    th=oe(u,y,[tnb nf nk])
    ym=idsim(u,th) % (entrée réelle appliquée au modèle)
    CR=sum((y-ym).*(y-ym))/length(ym)
    allCR1 = [allCR1, CR]
end

% trouver le bon nf
for tnf = [1:10]
    th=oe(u,y,[nb tnf nk])
    ym=idsim(u,th) % (entrée réelle appliquée au modèle)
    CR=sum((y-ym).*(y-ym))/length(ym)
    allCR2 = [allCR2, CR]
end

% trouver le bon nk
for tnk = [1:10]
    th=oe(u,y,[nb nf tnk])
    ym=idsim(u,th) % (entrée réelle appliquée au modèle)
    CR=sum((y-ym).*(y-ym))/length(ym)
    allCR3 = [allCR3, CR]
end

% trouver visuellement 
plot(allCR1)
figure
plot(allCR2)
figure
plot(allCR3)
figure

th=oe(u,y,[nb nf nk])
ym=sim(u,th) % (entrée réelle appliquée au modèle)
CR=sum((y-ym).*(y-ym))/length(ym)
plot(ym)
hold on
plot(y, 'r')
[A,B,C,D]=th2poly(th) %transformer le modèle sous forme polynomiale

figure;



% validation : 

u_val = input_delta2;
y_val = output_Fy2;

ym_val = idsim(u_val, th);
CR_val = sum((y_val - ym_val).^2) / length(ym_val);
disp(['CR validation = ', num2str(CR_val)]);
plot(ym_val)
hold on
plot(y_val, 'r')
[A,B,C,D]=th2poly(th) %transformer le modèle sous forme polynomiale

% fonction de transfert échantillonnée
Gz = tf(th.B, th.A, Ts);

disp('Fonction de transfert discrète G(z) :');
Gz

% réponse impulsionnelle ou indicielle
figure;
step(Gz);
title('Réponse indicielle du modèle ARX discret');

% pôles et zéros
[z, p, k] = tf2zp(Gz.Numerator{:}, Gz.Denominator{:});
disp('Zéros du système (discret) :'); disp(z);
disp('Pôles du système (discret) :'); disp(p);

% stabilité
if all(abs(p) < 1)
    disp('✔️ Le système est stable (tous les pôles sont à l interieur du cercle unite).');
else
    disp('❌ Le système est instable (au moins un pôle est en dehors du cercle unité).');
end

% Gain statique
dc_gain = dcgain(Gz);
disp(['Gain statique (DC gain) du système : ', num2str(dc_gain)]);

% conversion en continu
Gz_c = d2c(Gz, 'tustin'); % méthode bilinéaire
disp('Fonction de transfert en continu (approximation Tustin) :');
Gz_c



