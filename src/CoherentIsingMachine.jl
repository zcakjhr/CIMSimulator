module CoherentIsingMachine

using Random
using Plots
using ProgressMeter
using LinearAlgebra

"""
    IsingModel

A struct to represent an Ising model with a given coupling matrix `J`.

# Fields

  - `J::Matrix{Float64}`: Coupling matrix
"""
struct IsingModel
  J::Matrix{Float64}

  function IsingModel(J::Matrix{Float64})
    return new(J)
  end
end

"""
    ising_energy(model::IsingModel, s::Vector{Float64})::Float64

Compute the energy of the Ising model given the configuration `s`.

# Arguments

  - `model::IsingModel`: Ising model
  - `s::Vector{Float64}`: Configuration

# Returns

  - `Float64`: Energy of the configuration
"""
function ising_energy(self::IsingModel, s::Vector{Float64})::Float64
  n = length(s)
  E = 0.0
  for i in 1:n
    for j in (i + 1):n
      E += self.J[i, j] * s[i] * s[j]
    end
  end
  return E
end

"""
    max_cut(model::IsingModel, s::Vector{Float64})::Float64

Compute the maximum cut of the Ising model given the configuration `s`.

# Arguments

  - `model::IsingModel`: Ising model
  - `s::Vector{Float64}`: Configuration

# Returns

  - `Float64`: Maximum cut of the configuration
"""
function max_cut(self::IsingModel, s::Vector{Float64})::Float64
  n = length(s)
  cut = 0.0
  hamiltonian = -ising_energy(self, s)
  for i in 1:n
    for j in (i + 1):n
      cut += self.J[i, j]
    end
  end
  return 0.5 * cut + 0.5 * hamiltonian
end

"""
    CIM

A struct to represent a Coherent Ising Machine (CIM) with a given coupling matrix `J`.

# Fields

  - `J::Matrix{Float64}`: Coupling matrix
  - `T_r::Int`: Number of training steps
  - `T_p::Int`: Number of prediction steps
  - `ΔT::Float64`: Time step
  - `N::Int`: Number of spins
  - `N_step::Int`: Total number of steps
  - `energy_data::Vector{Float64}`: Energy data
  - `cut_data::Vector{Float64}`: Cut data
  - `x_data::Matrix{Float64}`: Configuration data
  - `err_data::Matrix{Float64}`: Error data
  - `del_x::Vector{Float64}`: Delta x
  - `del_err::Vector{Float64}`: Delta error
  - `x::Vector{Float64}`: Configuration
  - `err::Vector{Float64}`: Error
  - `p::Vector{Float64}`: Parameter
  - `alph::Vector{Float64}`: Alpha
  - `ξ::Float64`: Normalization factor
  - `β::Vector{Float64}`: Beta
  - `c::Vector{Float64}`: C
  - `k::Vector{Float64}`: K
  - `params::Any`: Parameters
  - `method::Int`: Methodology
  - `modulation::Int`: Modulation
"""
mutable struct CIM
  J::Matrix{Float64}
  T_r::Int
  T_p::Int
  ΔT::Float64
  N::Int
  N_step::Int
  energy_data::Vector{Float64}
  cut_data::Vector{Float64}
  x_data::Matrix{Float64}
  err_data::Matrix{Float64}
  del_x::Vector{Float64}
  del_err::Vector{Float64}
  x::Vector{Float64}
  err::Vector{Float64}
  p::Vector{Float64}
  alph::Vector{Float64}
  ξ::Float64
  β::Vector{Float64}
  c::Vector{Float64}
  k::Vector{Float64}
  params::Any
  method::Int
  modulation::Int

  function CIM(J::Matrix{Float64},
               T_r::Int,
               T_p::Int,
               ΔT::Float64,
               method::Int,
               modulation::Int,
               params::Any)::CIM
    """
    Constructs a Coherent Ising Machine (CIM) with a given coupling matrix `J`.
    """
    N = size(J, 1)
    N_step = T_r + T_p

    energy_data = zeros(Float64, N_step)
    cut_data = zeros(Float64, N_step)
    x_data = zeros(Float64, N, N_step)
    err_data = zeros(Float64, N, N_step)
    del_x = zeros(Float64, N)
    del_err = zeros(Float64, N)

    x = randn(Float64, N) * 0.0001
    err = ones(Float64, N)
    p = zeros(Float64, T_r + T_p)
    alph = zeros(Float64, T_r + T_p)
    β = zeros(Float64, T_r + T_p)
    c = zeros(Float64, T_r + T_p)
    k = zeros(Float64, T_r + T_p)
    ξ = sqrt(2.0 * N / sum(J .^ 2))

    # Modulate the parameters
    if method == 1 || method == 2
      if modulation == 1
        p .= fill(params[1], T_r + T_p)
      elseif modulation == 2
        p_range = [params]
        p = linear_mod(p_range, T_r, T_p)
      end

    elseif method == 3
      if modulation == 1
        p .= params[1]
        alph .= params[2]
        β .= params[3]
      elseif modulation == 2
        p_range, alph_range, β_range = params
        p = linear_mod(p_range, T_r, T_p)
        alph = linear_mod(alph_range, T_r, T_p)
        β = linear_mod(β_range, T_r, T_p)
      end

    elseif method == 4
      x = randn(Float64, N) * 0.1
      if modulation == 1
        p .= params[1]
        alph .= params[2]
        β .= params[3]
      elseif modulation == 2
        p_range, alph_range, β_range = params
        p = linear_mod(p_range, T_r, T_p)
        alph = linear_mod(alph_range, T_r, T_p)
        β = linear_mod(β_range, T_r, T_p)
      end

    elseif method == 5
      x = randn(Float64, N) * 0.1
      err = zeros(Float64, N)
      if modulation == 1
        p .= params[1]
        c .= params[2]
        k .= params[3]
        β .= params[4]
      elseif modulation == 2
        p_range, c_range, k_range, β_range = params
        p = linear_mod(p_range, T_r, T_p)
        c = linear_mod(c_range, T_r, T_p)
        k = linear_mod(k_range, T_r, T_p)
        β = linear_mod(β_range, T_r, T_p)
      end
    end

    return new(J,
               T_r,
               T_p,
               ΔT,
               N,
               N_step,
               energy_data,
               cut_data,
               x_data,
               err_data,
               del_x,
               del_err,
               x,
               err,
               p,
               alph,
               ξ,
               β,
               c,
               k,
               params,
               method,
               modulation)
  end
end

"""
    linear_mod(param_range::Vector{Float64}, T_r::Int, T_p::Int)::Vector{Float64}

Linearly modulate the parameter range.

# Arguments

  - `param_range::Vector{Float64}`: Parameter range
  - `T_r::Int`: Number of training steps
  - `T_p::Int`: Number of prediction steps

# Returns

  - `Vector{Float64}`: Linearly modulated parameter range
"""
function linear_mod(param_range, T_r, T_p)::Vector{Float64}
  param = zeros(Float64, T_r + T_p)
  if param_range[1] == param_range[2]
    param = ones(T_r) .* param_range[1]
  elseif param_range[1] < param_range[2]
    param = param_range[1] .+ (param_range[2] - param_range[1]) .* ((0:T_r) ./ T_r)
  elseif param_range[1] > param_range[2]
    param = param_range[1] .- (param_range[2] - param_range[1]) .* ((0:T_r) ./ T_r)
  end
  return vcat(param, ones(T_p) .* param_range[end])
end

"""
    evolve_system(cim::CIM, method::Int)

Evolve the Coherent Ising Machine (CIM) system.

# Arguments

  - `cim::CIM`: Coherent Ising Machine (CIM) object
  - `method::Int`: Methodology

# Returns

  - A tuple containing the configuration, configuration data, energy data, error data, and cut data.
"""
function evolve_system(self::CIM,
                       method::Int)::Tuple{Vector{Float64}, Matrix{Float64}, Vector{Float64},
                                           Matrix{Float64}, Vector{Float64}}
  ising = IsingModel(self.J)

  self.x_data[:, 1] .= self.x
  if length(self.err) > 0
    self.err_data[:, 1] .= self.err
  end

  # Define which function to use based on methodology
  evolve_func = get_evolve_function(method)

  for t in 2:(self.N_step)
    z = self.ξ * self.J * self.x
    evolve_func(self, t, z)

    # Store x and err data
    self.x_data[:, t] .= self.x
    if length(self.err) > 0
      self.err_data[:, t] .= self.err
    end

    # Compute current configuration, energy, and cut
    config = 2.0 * (self.x .> 0) .- 1.0
    self.energy_data[t] = ising_energy(ising, config)
    self.cut_data[t] = max_cut(ising, config)
  end

  return self.x, self.x_data, self.energy_data, self.err_data, self.cut_data
end

"""
    get_evolve_function(methodology::Int)

Get the evolve function based on the methodology.

# Arguments

  - `methodology::Int`: Methodology

# Returns

  - The evolve function
"""
function get_evolve_function(methodology::Int)::Function
  if methodology == 1
    return evolve_cim!
  elseif methodology == 2
    return evolve_cim_nonlinear!
  elseif methodology == 3
    return evolve_cim_cac!
  elseif methodology == 4
    return evolve_cim_cfc!
  elseif methodology == 5
    return evolve_cim_sfc!
  else
    error("Unknown methodology: $methodology")
  end
end

"""
    evolve_cim!(self::CIM, t::Int, z::Vector{Float64})

Evolve the Coherent Ising Machine (CIM) system using the linear method.

# Arguments

  - `self::CIM`: Coherent Ising Machine (CIM) object
  - `t::Int`: Time step
  - `z::Vector{Float64}`: Z

# Returns

  - `nothing`
"""
function evolve_cim!(self::CIM, t::Int, z::Vector{Float64})
  @. self.x = self.x + self.ΔT * (-self.x^3 + (self.p[t] - 1) * self.x - z)
end

"""
    evolve_cim_nonlinear!(self::CIM, t::Int, z::Vector{Float64})

Evolve the Coherent Ising Machine (CIM) system using the nonlinear method.

# Arguments

  - `self::CIM`: Coherent Ising Machine (CIM) object
  - `t::Int`: Time step
  - `z::Vector{Float64}`: Z

# Returns

  - `nothing`
"""
function evolve_cim_nonlinear!(self::CIM, t::Int, z::Vector{Float64})
  @. self.x = self.x + self.ΔT * (-self.x^3 + (self.p[t] - 1) * self.x - tanh(z))
end

"""
    evolve_cim_chaotic!(self::CIM, t::Int, z::Vector{Float64})

Evolve the Coherent Ising Machine (CIM) system using the CFC method.

# Arguments

  - `self::CIM`: Coherent Ising Machine (CIM) object
  - `t::Int`: Time step
  - `z::Vector{Float64}`: Z

# Returns

  - `nothing`
"""
function evolve_cim_cfc!(self::CIM, t::Int, z::Vector{Float64})
  @. self.x = self.x + self.ΔT * (-self.x^3 + (self.p[t] - 1) * self.x - self.err * z)
  @. self.err = self.err + self.ΔT * (-self.β[t] * self.err * (self.err^2 * z^2 - self.alph[t]))
  @. self.x = clamp(self.x, -1.5, 1.5)
  @. self.err = clamp(self.err, 0.01, Inf)
end

"""
    evolve_cim_cfc!(self::CIM, t::Int, z::Vector{Float64})

Evolve the Coherent Ising Machine (CIM) system using the CAC method.

# Arguments

  - `self::CIM`: Coherent Ising Machine (CIM) object
  - `t::Int`: Time step
  - `z::Vector{Float64}`: Z

# Returns
  
    - `nothing`
"""
function evolve_cim_cac!(self::CIM, t::Int, z::Vector{Float64})
  @. self.x = self.x + self.ΔT * (-self.x^3 + (self.p[t] - 1) * self.x - self.err * z)
  @. self.err = self.err + self.ΔT * (-self.β[t] * self.err * (self.x^2 - self.alph[t]))
  @. self.x = clamp(self.x, -1.5 * sqrt(self.alph[t]), 1.5 * sqrt(self.alph[t]))
end

"""
    evolve_cim_separable!(self::CIM, t::Int, z::Vector{Float64})

Evolve the Coherent Ising Machine (CIM) system using the SFC method.

# Arguments

  - `self::CIM`: Coherent Ising Machine (CIM) object
  - `t::Int`: Time step
  - `z::Vector{Float64}`: Z

# Returns

  - `nothing`
"""
function evolve_cim_sfc!(self::CIM, t::Int, z::Vector{Float64})
  @. self.x = self.x +
              self.ΔT * (-self.x^3 + (self.p[t] - 1) * self.x - tanh(self.c[t] * z) -
                         self.k[t] * (z - self.err))
  @. self.err = self.err + self.ΔT * (-self.β[t] * (self.err - z))
end

end # module
