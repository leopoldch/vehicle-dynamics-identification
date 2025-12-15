
% On s'intéresse aux entrées et sorties (𝛿 - 𝐹𝑦)
% On utilise 𝛿1 et 𝐹𝑦1 pour estimer le modèle, et 𝛿2, 𝐹𝑦2 pour le valider.

% Chargement des jeux de données
load input_delta1
load input_delta2
load output_Fy1
load output_Fy2

u = input_delta1;
y = output_Fy1;

Ts = 0.01;

figure;
plot(input_delta1)
title("Entrées données d'entrainement");
figure;
plot(output_Fy1)
title("Sorties données d'entrainement");


% si linéaire alors alignés sur une droite 
% sinon non linéaire 
figure;plot(u, y);title("Non linéarité du système");


% évualuation retard du système : 
figure;
[crosscorr, lags] = xcorr(y, u);
plot(lags, crosscorr);
xlabel('Délais (échantillons)');
ylabel('Corrélation croisée');


nk = 1; % Retard du système

% paramètres retenus

% Paramètres ARX
arx_na = 1;
arx_nb = 2;

% Paramètres ARMAX
armax_na = 3;
armax_nb = 2;
armax_nc = armax_na;

% Paramètres OE
oe_nf = 4;
oe_nb = 2;

% Paramètres IV4
iv4_na = 1;
iv4_nb = 2;

% Initialisation des tableaux d'erreurs quadratiques moyennes (CR)
allCRna_arx     = [];
allCRnb_arx     = [];
allCRna_armax   = [];
allCRnb_armax   = [];
allCRnc_armax = [];
allCRnb_oe      = [];
allCRnf_oe      = [];
allCRna_iv4     = [];
allCRnb_iv4     = [];

%% Balayage des hyperparamètres

% ARX - balayage sur na
% AVEC NB = 1
for tna = 1:10
    th = arx([y u], [tna 1 nk]);
    ym = idsim(u, th);
    CR = mean((y - ym).^2);
    allCRna_arx = [allCRna_arx, CR];
end

% ARX - balayage sur nb
% AVEC LE NA TROUVÉ DANS LE BALAYAGE PRECEDANT
for tnb = 1:10
    th = arx([y u], [arx_na tnb nk]);
    ym = idsim(u, th);
    CR = mean((y - ym).^2);
    allCRnb_arx = [allCRnb_arx, CR];
end

% ARMAX - balayage sur na
% AVEC NB = 1
for tna = 1:10
    th = armax([y u], [tna 1 tna nk]);
    ym = idsim(u, th);
    CR = mean((y - ym).^2);
    allCRna_armax = [allCRna_armax, CR];
end

% ARMAX - balayage sur nb
% AVEC LE NA TROUVÉ DANS LE BALAYAGE PRECEDANT
for tnb = 1:10
    th = armax([y u], [armax_na tnb armax_nc nk]);
    ym = idsim(u, th);
    CR = mean((y - ym).^2);
    allCRnb_armax = [allCRnb_armax, CR];
end

% ARMAX - balayage sur nc
% PAS DE BALAYAGE SUR NC 
% NC = NA

% OE - balayage sur nf
% AVEC NB = 2 
% on sait des études précédentes que nb = 2
for tnf = 1:10
    th = oe(u, y, [2 tnf nk]);
    ym = idsim(u, th);
    CR = mean((y - ym).^2);
    allCRnf_oe = [allCRnf_oe, CR];
end

% OE - balayage sur nb
% AVEC LE NF TROUVÉ DANS LE BALAYAGE PRECEDANT
for tnb = 1:10
    th = oe(u, y, [tnb oe_nf nk]);
    ym = idsim(u, th);
    CR = mean((y - ym).^2);
    allCRnb_oe = [allCRnb_oe, CR];
end

% IV4 - balayage sur na
% AVEC NB = 2
for na_t = 1:10
    th = iv4(u, y, [na_t 2 nk]);
    ym = idsim(u, th);
    CR = mean((y - ym).^2);
    allCRna_iv4 = [allCRna_iv4, CR];
end

% IV4 - balayage sur nb
% AVEC LE NA TROUVÉ DANS LE BALAYAGE PRECEDANT
for nb_t = 1:10
    th = iv4(u, y, [iv4_na nb_t nk]);
    ym = idsim(u, th);
    CR = mean((y - ym).^2);
    allCRnb_iv4 = [allCRnb_iv4, CR];
end

%% Affichage des courbes de performance

figure; plot(allCRna_arx); title('na ARX');
figure; plot(allCRnb_arx); title('nb ARX');
figure; plot(allCRna_armax); title('na ARMAX');
figure; plot(allCRnb_armax); title('nb ARMAX');
figure; plot(allCRnb_oe); title('nb OE');
figure; plot(allCRnf_oe); title('nf OE');
figure; plot(allCRna_iv4); title('na IV4');
figure; plot(allCRnb_iv4); title('nb IV4');

%% Ré-entraîner les modèles avec les paramètres retenus

th_arx   = arx([y u], [arx_na arx_nb nk]);
th_armax = armax([y u], [armax_na armax_nb armax_nc nk]);
th_oe    = oe(u, y, [oe_nb oe_nf nk]);
th_iv4   = iv4(u, y, [iv4_na iv4_nb nk]);

% Simulation sur les données d'entraînement
ym_arx   = idsim(u, th_arx);
ym_armax = idsim(u, th_armax);
ym_oe    = idsim(u, th_oe);
ym_iv4   = idsim(u, th_iv4);

% Affichage des résultats sur les données d'entraînement
figure;
plot(y, 'k', 'LineWidth', 1.5); hold on;
plot(ym_arx,   '--b', 'LineWidth', 1.5);
plot(ym_armax, '--g', 'LineWidth', 1.5);
plot(ym_oe,    '--m', 'LineWidth', 1.5);
plot(ym_iv4,   '--c', 'LineWidth', 1.5);
legend('Donnée réelle (y)', 'ARX', 'ARMAX', 'OE', 'IV4');
title('Modèles superposés sur les données d’entraînement');
xlabel('Temps'); ylabel('F_y'); grid on;

%% Validation des modèles

u_val = input_delta2;
y_val = output_Fy2;

ym_val_arx   = idsim(u_val, th_arx);
ym_val_armax = idsim(u_val, th_armax);
ym_val_oe    = idsim(u_val, th_oe);
ym_val_iv4   = idsim(u_val, th_iv4);

figure;
plot(y_val, 'k', 'LineWidth', 1.5); hold on;
plot(ym_val_arx,   '--b', 'LineWidth', 1.5);
plot(ym_val_armax, '--g', 'LineWidth', 1.5);
plot(ym_val_oe,    '--m', 'LineWidth', 1.5);
plot(ym_val_iv4,   '--c', 'LineWidth', 1.5);
legend('Donnée réelle (y_{val})', 'ARX', 'ARMAX', 'OE', 'IV4');
title('Modèles superposés sur les données de validation');
xlabel('Temps'); ylabel('F_y'); grid on;

%% Analyse du modèle ARMAX sélectionné

% Extraction des polynômes A, B
B = th_armax.B;         % Numérateur B(z⁻¹)
A = th_armax.A;         % Dénominateur A(z⁻¹)

% Construction de la fonction de transfert discrète G(z)
num = [zeros(1, nk - 1), B];   % Décalage dû au retard
den = A;
Gz = tf(num, den, Ts);

% Affichage de la fonction de transfert
disp('Fonction de transfert discrète G(z) du modèle ARMAX :');
Gz

% Réponse indicielle
figure;
step(Gz);
title('Réponse indicielle du modèle ARMAX');
xlabel('Temps (s)'); ylabel('Amplitude'); grid on;

% Zéros et pôles
[z, p, ~] = tf2zp(num, den);
disp('Zéros du système (discret) :');
disp(z);
disp('Pôles du système (discret) :');
disp(p);

% Vérification de la stabilité
if all(abs(p) < 1)
    disp('✔️ Le système est stable (tous les pôles sont à l’intérieur du cercle unité).');
else
    disp('❌ Le système est instable (au moins un pôle est en dehors du cercle unité).');
end

% Gain statique
dc_gain = dcgain(Gz);
disp(['Gain statique (DC gain) du système ARMAX : ', num2str(dc_gain)]);

% Conversion en temps continu (approximation bilinéaire)
Gz_c = d2c(Gz, 'tustin');
disp('Fonction de transfert en temps continu (approximation Tustin) :');
Gz_c


%% Simplification 

% Nouveau numérateur : suppression manuelle du zéro proche de pôle
num_simpl = 2.937e4;  % Suppression du (z - 0.9997)

% Nouveau dénominateur : suppression du pôle proche
% Dénominateur initial : z^3 - 0.4435 z^2 - 0.1796 z - 0.3756
% On divise à la main par (z - 0.9993)
% On suppose que le polynôme restant est :
den_simpl = [1, 0.5549, -0.0257];  % z^2 + 0.5549 z - 0.0257

% fonction de transfert simplifiée
Gz_simpl = tf(num_simpl, den_simpl, Ts);
disp('G(z) simplifié :');
Gz_simpl

ym_val_simpl = lsim(Gz_simpl, u_val, Ts*(0:length(u_val)-1));
figure;
plot(y_val, 'k'); hold on;
plot(ym_val_simpl, '--r');
legend('Données réelles', 'ARMAX simplifié');
title('Validation sur données de test (modèle simplifié)');
xlabel('Temps'); ylabel('F_y'); grid on;