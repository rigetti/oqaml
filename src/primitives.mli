module M = Owl.Dense.Matrix.C

val id : M.mat
val proj_0 : M.mat
val proj_1 : M.mat
val sx : M.mat
val sy : M.mat
val sz : M.mat
val h : M.mat

val rx : float -> M.mat
val ry : float -> M.mat
val rz : float -> M.mat

val swap : M.mat
val cnot : M.mat