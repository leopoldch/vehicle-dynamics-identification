% ici on s'intéresse aux entrées et sorties (𝛿- 𝐹𝑦)
% on utilise 𝛿1 et output 𝐹𝑦1 pour estimer le modèle et 𝛿2 𝐹𝑦2 pour
% le valider


% load des jeux de données 
load input_delta1
load input_delta2
load output_Fy1
load output_Fy2


% Déterminer l'ordre du système, le retard et l'ordre du numérateur

% Méthode arx
% trouver na, nb, nk

u = input_delta1
y = output_Fy1


na_fix = 2
% pour nb = 2 l'erreur de na reste acceptable 
% nb >= 2
% au moins 2 pôles d'entrées dépend de 2 entrées en paramètres
nb_fix = 2
nk_fix = 2

nc_fix = na_fix % cours

% max_val = 10; % ou selon ton choix
% allCR = zeros(max_val, max_val, max_val); % (na, nb, nk)
% 
% for na = 1:max_val
%    for nb = 1:max_val
%        for nk = 1:max_val
%            th = armax([y u], [na nb nc_fix nk])
%            ym = idsim(u, th)
%             CR = sum((y - ym).^2) / length(ym)
%             allCR(na, nb, nk) = CR
%         end
%     end
% end
% 
% 
% figure;
% surf(1:max_val, 1:max_val, allCR(:,:,nk_fix));
% xlabel('nb');
% ylabel('na');
% zlabel('CR');
% title(['Erreur pour nk = ', num2str(nk_fix)]);
% 
% figure;


allCRna = []

% trouver le bon na 
% attention nb=1 pour mieux voir
for tna = [1:10]
    % Utilisation de ARX
    th=armax([y u],[tna nb_fix nc_fix nk_fix])
    ym=idsim(u,th) % (entrée réelle appliquée au modèle)
    CR=sum((y-ym).*(y-ym))/length(ym)
    allCRna = [allCRna, CR]
end

%trouver visuellement 
plot(allCRna)
figure;

allCRnb = []

% trouver le bon na 
% attention nb=1 pour mieux voir
for tnb = [1:10]
    % Utilisation de ARX
    th=armax([y u],[na_fix tnb nc_fix nk_fix])
    ym=idsim(u,th) % (entrée réelle appliquée au modèle)
    CR=sum((y-ym).*(y-ym))/length(ym)
    allCRnb = [allCRnb, CR]
end

%trouver visuellement 
plot(allCRnb)
figure;




% alternative : tester pour toutes les combinaisons possibles de na,nb,nk

th=armax([y u],[na_fix nb_fix nc_fix nk_fix])
ym=sim(u,th) % (entrée réelle appliquée au modèle)
CR=sum((y-ym).*(y-ym))/length(ym)
plot(ym)
hold on
plot(y, 'r')
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
