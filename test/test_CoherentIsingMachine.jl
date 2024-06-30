# test/test_CoherentIsingMachine.jl

using Test
using CoherentIsingMachine

# Test IsingModel struct and functions
@testset "IsingModel Tests" begin
  J = [0.0 1.0; 1.0 0.0]
  model = CoherentIsingMachine.IsingModel(J)

  @testset "Initialization" begin
    @test model.J == J
  end

  @testset "ising_energy function" begin
    s = [1.0, -1.0]
    @test CoherentIsingMachine.ising_energy(model, s) == -1.0
  end

  @testset "max_cut function" begin
    s = [1.0, -1.0]
    @test CoherentIsingMachine.max_cut(model, s) == 1.0  # Adjust expected result as per function logic
  end
end

# Test CIM struct and methods
@testset "CIM Tests" begin
  J = [0.0 1.0; 1.0 0.0]
  T_r = 100
  T_p = 100
  ΔT = 0.1
  N = 2
  method = 1
  modulation = 1
  params = [0.5]  # Example parameter array
  cim = CoherentIsingMachine.CIM(J, T_r, T_p, ΔT, method, modulation, params)

  @testset "Initialization" begin
    @test cim.J == J
    @test cim.T_r == T_r
    @test cim.T_p == T_p
    @test cim.ΔT == ΔT
    @test cim.N == N
    @test cim.N_step == T_r + T_p
  end

  @testset "linear_mod function" begin
    p_range = [0.0, 1.0]
    linear_mod_result = CoherentIsingMachine.linear_mod(p_range, T_r, T_p)
    @test length(linear_mod_result) == T_r + T_p + 1
    @test linear_mod_result[1] == p_range[1]
    @test linear_mod_result[end] == p_range[2]
  end

  @testset "evolve_system function" begin
    x, x_data, energy_data, err_data, cut_data = CoherentIsingMachine.evolve_system(cim, method)

    # Test some basic properties of the returned data
    @test length(x) == size(J, 1)
    @test size(x_data) == (size(J, 1), cim.N_step)
    @test length(energy_data) == cim.N_step
  end

  @testset "get_evolve_function function" begin
    @test CoherentIsingMachine.get_evolve_function(1) ==
          CoherentIsingMachine.evolve_cim!
    @test CoherentIsingMachine.get_evolve_function(2) ==
          CoherentIsingMachine.evolve_cim_nonlinear!
    @test CoherentIsingMachine.get_evolve_function(3) ==
          CoherentIsingMachine.evolve_cim_chaotic!
    @test CoherentIsingMachine.get_evolve_function(4) ==
          CoherentIsingMachine.evolve_cim_separable!
    @test_throws ErrorException CoherentIsingMachine.get_evolve_function(5)
  end

  @testset "evolve_cim! function" begin
    t = 2
    z = 0.5 * J * cim.x
    prev_x = copy(cim.x)
    CoherentIsingMachine.evolve_cim!(cim, t, z)
    @test cim.x != prev_x  # Ensure x has been updated
  end

  @testset "evolve_cim_nonlinear! function" begin
    t = 2
    z = 0.5 * J * cim.x
    prev_x = copy(cim.x)
    CoherentIsingMachine.evolve_cim_nonlinear!(cim, t, z)
    @test cim.x != prev_x  # Ensure x has been updated
  end

  @testset "evolve_cim_chaotic! function" begin
    t = 2
    z = 0.5 * J * cim.x
    prev_x = copy(cim.x)
    prev_err = copy(cim.err)
    CoherentIsingMachine.evolve_cim_chaotic!(cim, t, z)
    @test cim.x != prev_x  # Ensure x has been updated
    @test cim.err != prev_err  # Ensure err has been updated
  end

  @testset "evolve_cim_separable! function" begin
    t = 2
    z = 0.5 * J * cim.x
    prev_x = copy(cim.x)
    prev_err = copy(cim.err)
    CoherentIsingMachine.evolve_cim_separable!(cim, t, z)
    @test cim.x != prev_x  # Ensure x has been updated
    @test cim.err != prev_err  # Ensure err has been updated
  end
end

# Test Graph struct and constructor
@testset "Graph Tests" begin
  @testset "Graph Constructor" begin
    @testset "Ising grid" begin
      grid_spec = 5
      graph = Graph(1, grid_spec)
      @test size(graph.coupling_matrix) == (grid_spec, grid_spec)
    end

    @testset "Fetch graph data" begin
      grid_spec = 5
      graph = Graph(2, grid_spec)
      @test size(graph.coupling_matrix) == (grid_spec, grid_spec)
    end
  end
end

# Test IO functions
@testset "IO Tests" begin
  @testset "read_graph_data function" begin
    # Test with a sample graph data file
    graph_data_file = "test/data/graph_data.txt"
    i, j, w_ij = read_graph_data(graph_data_file)
    @test i == 1
    @test j == 2
    @test w_ij == 1.0
  end
end
