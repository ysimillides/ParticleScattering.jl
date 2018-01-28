using PyPlot, ParticleScattering
import Optim

er = 4.5
k0 = 2π
l0 = 2π/k0
a_lens = 0.2*l0
R_lens = 10*a_lens

kin = k0*sqrt(er)
N_cells = Int64(round(2*R_lens/a_lens))
centers, ids, rs_lnbrg = luneburg_grid(R_lens, N_cells, er)
φs = zeros(Float64, length(ids))
θ_i = 0.0
P = 5

fmm_options = FMMoptions(true, acc = 6, dx = 2*a_lens, method = "pre")

optim_options =  Optim.Options(x_tol = 1e-4, iterations = 100, store_trace = true, extended_trace = true, show_trace = true, allow_f_increases = true)
linesearch = LineSearches.BackTracking()

points = [R_lens 0.0]
r_max = (a_lens/1.15/2)*ones(size(centers,1))
r_min = (a_lens*1e-3)*ones(size(centers,1))
rs0 = (0.25*a_lens)*ones(size(centers,1))

tic()
test_max = optimize_radius(rs0, r_min, r_max, points, P, θ_i, k0, kin,
                centers, fmm_options, optim_options, false, "BFGS", linesearch)
optim_time = toq()
rs_max = test_max.minimizer

# plot near fields
filename1 = dirname(@__FILE__) * "/tikz/opt_r_luneburg.tex"
filename2 = dirname(@__FILE__) * "/tikz/opt_r_max.tex"
filename3 = dirname(@__FILE__) * "/tikz/opt_r_0.tex"
border = (R_lens + a_lens)*[-1;1;-1;1]

sp1 = ScatteringProblem([CircleParams(rs_lnbrg[i]) for i in eachindex(rs_lnbrg)],
        ids, centers, φs)
Ez1 = plotNearField(k0, kin, P, sp1, θ_i, x_points = 150, y_points = 150,
        opt = fmm_options, border = border)
plotNearField_pgf(filename1, k0, kin, P, sp1, θ_i; opt = fmm_options,
    x_points = 201, y_points = 201, border = border)

sp2 = ScatteringProblem([CircleParams(rs_max[i]) for i in eachindex(rs_max)],
        collect(1:length(rs_max)), centers, φs)
Ez2 = plotNearField(k0, kin, P, sp2, θ_i, x_points = 150, y_points = 150,
            opt = fmm_options, border = border)
plotNearField_pgf(filename2, k0, kin, P, sp2, θ_i; opt = fmm_options,
    x_points = 201, y_points = 201, border = border)

sp3 = ScatteringProblem([CircleParams(rs0[i]) for i in eachindex(rs0)],
        collect(1:length(rs0)), centers, φs)
Ez3 = plotNearField(k0, kin, P, sp3, θ_i, x_points = 150, y_points = 150,
        opt = fmm_options, border = border)
plotNearField_pgf(filename3, k0, kin, P, sp3, θ_i; opt = fmm_options,
    x_points = 201, y_points = 201, border = border)

#plot convergence
inner_iters = length(test_max.trace)
iters = [test_max.trace[i].iteration for i=1:inner_iters]
fobj = -[test_max.trace[i].value for i=1:inner_iters]
gobj = [test_max.trace[i].g_norm for i=1:inner_iters]
rng = iters .== 0

figure()
plot(0:inner_iters-1, fobj)
plot(0:inner_iters-1, gobj)
plot((0:inner_iters-1)[rng], fobj[rng],"*")
plot((0:inner_iters-1)[rng], gobj[rng],"*")

import PGFPlotsX; const pgf = PGFPlotsX
pgf.@pgf begin
    fobj_plot = pgf.Plot(pgf.Coordinates(0:inner_iters-1, fobj),
                {blue, thick, no_markers},
                label = "\$f_{\\mathrm{obj}}\$")
    gobj_plot = pgf.Plot(pgf.Coordinates(0:inner_iters-1, gobj),
                {red, thick, dashed, no_markers},
                label = "\$\\|\\mathbf{g}_{\\mathrm{obj}}\\|_{\\infty}\$")
    fobj_outer = pgf.Plot(pgf.Coordinates((0:inner_iters-1)[rng], fobj[rng]),
                {blue, only_marks, mark = "*", mark_options = {fill = "blue"}})
    gobj_outer = pgf.Plot(pgf.Coordinates((0:inner_iters-1)[rng], gobj[rng]),
                {red, only_marks, mark = "triangle*", mark_options = {fill = "red"}})
    ax = pgf.Axis([fobj_plot;gobj_plot;fobj_outer;gobj_outer],
        {
            width = "\\figurewidth",
            xlabel = "Iterations",
            legend_pos = "north east",
            legend_style = "font = \\footnotesize"
        })
end
pgf.save(dirname(@__FILE__) * "/tikz/opt_r_conv.tex", ax ,include_preamble = false)

################ Testing with symmetry ######################
assert(length(ids)==size(centers,1))
centers_abs = centers[:,1] + 1im*abs.(centers[:,2])
ids2,centers_abs = ParticleScattering.my_uniqueind(centers_abs)

r_max = (a_lens/1.15/2)*ones(length(centers_abs))
r_min = (a_lens*1e-3)*ones(length(centers_abs))
rs0 = (0.25*a_lens)*ones(length(centers_abs))

test_max_sym = ParticleScattering.optimize_radius2(rs0, r_min, r_max, points, ids2, P, θ_i, k0, kin,
                centers, fmm_options, optim_options, false, optimmethod2)
rs4 = test_max_sym.minimizer
























#####################################
Ez_4 = calculateNearField(k0, kin, 4, sp1, points, θ_i; opt = fmm_options)
Ez_5 = calculateNearField(k0, kin, 5, sp1, points, θ_i; opt = fmm_options)
Ez_6 = calculateNearField(k0, kin, 6, sp1, points, θ_i; opt = fmm_options)
Ez_7 = calculateNearField(k0, kin, 7, sp1, points, θ_i; opt = fmm_options)
