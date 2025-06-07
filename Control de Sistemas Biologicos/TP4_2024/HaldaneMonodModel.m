function model = HaldaneMonodModel(s, n, params)
% Es un modelo que está compuesto por el producto de dos:
% El modelo de Haldane y el de Monod
% Se espera que params sea una estructura que tenga todos los 
% parámetros requeridos, siguiendo el siguiente esquema:
%
% model = max * (s/( k1 + s + s*s/k2 )) * (1/(k3 + n))

max=params.max;
k1=params.k1;
k2=params.k2;
k3=params.k3;

model = max .* (s./( k1 + s + s.*s./k2 )) .* (1./(k3 + n));

end