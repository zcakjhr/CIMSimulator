"""
    Main.jl

This script is the main entry point for the Coherent Ising Machine Simulator. 
It allows the user to interactively choose methods and parameters for solving the Ising problem.
"""

include("IO.jl")
include("CoherentIsingMachine.jl")

using .IO
using .CoherentIsingMachine
using ProgressMeter

const MAX_ATTEMPTS = 3

"""
    clear_screen()

Clears the terminal screen.
"""
function clear_screen()
  if Sys.iswindows()
    run(`cmd /c cls`)
  else
    run(`clear`)
  end
end

"""
    close_program()

Prompts the user to close the program.
"""
function close_program()
  println("\033[1m\033[4mDo you wish to close the program? (yes/no)\033[0m")
  close_choice = lowercase(strip(readline()))
  if close_choice in ["yes", "y"]
    println("Exiting...")
    exit(0)
  else
    println("Continuing...")
  end
end

"""
    show_welcome()

Displays the welcome message to the user.
"""
function show_welcome()
  println("\033[1m***************************************")
  println("*   \033[35mCoherent Ising Machine Simulator  \033[0m\033[1m*")
  println("***************************************\033[0m")
  println()
  println("Welcome to the Coherent Ising Machine Simulator!")
  println("This script allows you to interactively choose methods and parameters.")
  println("Please select the options as prompted.")
  return println()
end

"""
    prompt_user(question::String, options::Vector{String}, attempt::Int = 1)

Prompts the user to select an option from a list of choices.

# Arguments

  - `question::String`: The question to ask the user.
  - `options::Vector{String}`: The list of options to choose from.

# Returns

  - The user's choice as an integer.
"""
function prompt_user(question::String, options::Vector{String}, attempt::Int=1)::Int
  println("\033[1m$question\033[0m")
  for (i, option) in enumerate(options)
    println("[$i] $option")
  end
  print("Enter your choice (1-$(length(options))): ")

  choice_str = strip(readline())
  choice = try
    parse(Int, choice_str)
  catch
    nothing
  end

  if isnothing(choice) || !(1 <= choice <= length(options))
    println("\u001b[31mInvalid input: Choice must be between 1 and $(length(options)).\u001b[0m")
    println()
    return handle_attempt_failure(question, options, attempt)
  end

  return choice
end

"""
    handle_attempt_failure(question::String, options::Vector{String}, attempt::Int)

Handles the case when the user has reached the maximum number of attempts.

# Arguments

  - `question::String`: The question to ask the user.
  - `options::Vector{String}`: The list of options to choose from.

# Returns

  - The user's choice as an integer.
"""
function handle_attempt_failure(question::String,
                                options::Vector{String},
                                attempt::Int)::Int
  if attempt < MAX_ATTEMPTS
    return prompt_user(question, options, attempt + 1)
  else
    println("You have reached the maximum number of attempts.")
    close_program()
    return -1
  end
end

"""
    select_problem()

Prompts the user to select a problem to solve.

# Returns

  - A tuple containing the problem choice and the grid specification.
"""
function select_problem()::Tuple{Int, Int}
  problems = ["2D Square Ising Lattice (Antiferromagnetic Coupling)", "MAX-CUT (G-Sets)"]

  while true
    clear_screen()
    show_welcome()

    problem_question = "Which problem are you trying to solve?"
    problem_choice = prompt_user(problem_question, problems)

    if problem_choice == -1
      return -1, -1

    elseif problem_choice == 1
      println()
      println("\033[1mPlease specify the size of the Ising grid (e.g., 5 for a 5x5 grid)\033[0m:")
      return get_grid_specification(problem_choice)

    elseif problem_choice == 2
      println()
      println("\033[1mPlease specify the G-Set problem of interest:\033[0m")
      return get_grid_specification(problem_choice, 1, 50)
    else
      println()
      println("Invalid choice. Please choose a valid problem.")
    end
  end
end


"""
    get_grid_specification(problem_choice::Int, min_val::Int = 1, max_val::Int = 100)

Prompts the user to enter the grid specification.

# Arguments

  - `problem_choice::Int`: The user's choice of problem.
  - `min_val::Int`: The minimum value allowed for the grid specification.
  - `max_val::Int`: The maximum value allowed for the grid specification.

# Return

  - A tuple containing the problem choice and the grid specification.
"""
function get_grid_specification(problem_choice::Int,
                                min_val::Int=1,
                                max_val::Int=5000)::Tuple{Int, Int}
  attempts = MAX_ATTEMPTS
  while attempts > 0
    grid_specification_str = readline()
    grid_specification = try
      parse(Int, grid_specification_str)
    catch
      nothing
    end

    if isnothing(grid_specification) || !(min_val <= grid_specification <= max_val)
      println("Invalid input. Please enter a valid integer between $min_val and $max_val.")
      attempts -= 1
      if attempts == 0
        println("Maximum number of wrong inputs has been given.")
        close_program()
        return -1, -1
      end
    else
      sleep(1)
      return problem_choice, grid_specification
    end
  end
  return -1, -1
end

"""
    select_method()

Prompts the user to select a method to solve the Ising problem.

# Returns

  - The user's choice of method as an integer.
"""
function select_method()::Int
  methods = ["CIM (Classical)",
             "CIM - NLF (Nonlinear Feedback)",
             "CIM - CAC (Chaotic Amplitude Control)",
             "CIM - CFC (Chaotic Feedback Control)",
             "CIM - SFC (Separable Feedback Control)"]

  while true
    clear_screen()
    show_welcome()

    method_question = "Which method would you like to try out?"
    method_choice = prompt_user(method_question, methods)

    if method_choice == -1
      return -1
    elseif method_choice in 1:5
      sleep(1)
      return method_choice
    else
      println("Invalid choice. Please choose a valid method.")
    end
  end
end


function select_modulation()
  methods_param = ["Constant", "Linear"]

  while true
    clear_screen()
    show_welcome()

    method_param_question = "How would you like to modulate the parameters?"
    parameter_choice = prompt_user(method_param_question, methods_param)

    if parameter_choice == -1
      return -1
    elseif parameter_choice in 1:2
      sleep(1)
      return parameter_choice
    else
      println("Invalid choice. Please choose a valid method.")
    end
  end
end

"""
    select_parameter_modulation()

Prompts the user to select a method to handle hyperparameters.

# Returns

  - The user's choice of parameter modulation as an integer.
"""
function prompt_parameter(question::String)::Float64
  println(question)
  param_str = readline()
  param = try
    parse(Float64, param_str)
  catch
    nothing
  end

  if isnothing(param)
    println("Invalid input. Please enter a valid number.")
    return prompt_parameter(question)
  else
    return param
  end
end

"""
    prompt_range(question::String)

Prompts the user to specify a range.

# Arguments

  - `question::String`: The question to ask the user.

# Returns

  - The range specified by the user.
"""
function prompt_range(question::String)
  println(question)
  range_str = readline()
  range = try
    parse.(Float64, split(range_str, r"\s*,\s*"))
  catch
    nothing
  end

  if isnothing(range) || length(range) != 2 || any(x -> !isa(x, Float64), range)
    println("Invalid input. Please enter a valid range as <lower_limit, upper_limit>.")
    return prompt_range(question)
  else
    return range
  end
end

"""
    get_parameters(modulation_choice::Int, method_choice::Int)

Prompts the user to specify the parameters for the chosen method.

# Arguments

  - `modulation_choice::Int`: The user's choice of parameter modulation.
  - `method_choice::Int`: The user's choice of method.

# Returns

  - The parameters specified by the user.
"""
function get_parameters(modulation_choice::Int, method_choice::Int)::Any
  if method_choice == 1 || method_choice == 2
    if modulation_choice == 1
      return prompt_parameter("Please specify the value for parameter p:")
    elseif modulation_choice == 2
      return prompt_range("Please specify the range for parameter p: <lower_limit, upper_limit>")
    end
  elseif method_choice == 3 || method_choice == 4
    if modulation_choice == 1
      p = prompt_parameter("Please specify the value for parameter p:")
      alpha = prompt_parameter("Please specify the value for parameter α:")
      beta = prompt_parameter("Please specify the value for parameter β:")
      return (p, alpha, beta)
    elseif modulation_choice == 2 
      p_range = prompt_range("Please specify the range for parameter p: <lower_limit, upper_limit>")
      alpha_range = prompt_range("Please specify the range for parameter α: <lower_limit, upper_limit>")
      beta_range = prompt_range("Please specify the range for parameter β: <lower_limit, upper_limit>")
      return (p_range, alpha_range, beta_range)
    end
  elseif method_choice == 5
    if modulation_choice == 1
      p = prompt_parameter("Please specify the value for parameter p:")
      c = prompt_parameter("Please specify the value for parameter c:")
      k = prompt_parameter("Please specify the value for parameter k:")
      β = prompt_parameter("Please specify the value for parameter β:")
      return (p, c, k, β)
    elseif modulation_choice == 2
      p_range = prompt_range("Please specify the range for parameter p: <lower_limit, upper_limit>")
      c_range = prompt_range("Please specify the range for parameter c: <lower_limit, upper_limit>")
      k_range = prompt_range("Please specify the range for parameter k: <lower_limit, upper_limit>")
      β_range = prompt_range("Please specify the range for parameter β: <lower_limit, upper_limit>")
      return (p_range, c_range, k_range, β_range)
    end
  end
end

"""
    specify_parameters(modulation_choice::Int, method_choice::Int)

Prompts the user to specify the parameters for the chosen method.

# Arguments

  - `modulation_choice::Int`: The user's choice of parameter modulation.
  - `method_choice::Int`: The user's choice of method.

# Returns

  - The parameters specified by the user.
"""
function specify_parameters(modulation_choice::Int, method_choice::Int)::Any
  while true
    clear_screen()
    show_welcome()

    println("\033[1mParameter Specifications:\033[0m")

    params = get_parameters(modulation_choice, method_choice)
    return params
  end
end


function prompt_iterations()::Int
  attempts = MAX_ATTEMPTS
  while true
    clear_screen()
    show_welcome()

    while attempts > 0
      println("Please specify for how long we should iterate (number of iterations):")
      iterations_str = readline()
      iterations = try
        parse(Int, iterations_str)
      catch
        nothing
      end
  
      if isnothing(iterations) || iterations <= 0
        println("Invalid input. Please enter a valid positive integer.")
        attempts -= 1
        if attempts == 0
          println("Maximum number of wrong inputs has been given.")
          close_program()
          return -1
        end
      else
        return iterations
      end
    end
    return -1
  end
end



function prompt_constant_end_step()::Bool
  println("Do you wish to keep the parameter constant at the end for additional steps? [y/n]")
  response = readline()
  if lowercase(response) in ["y", "yes"]
    return true
  elseif lowercase(response) in ["n", "no"]
    return false
  else
    println("Invalid input. Please enter 'y' or 'n'.")
    return prompt_constant_end_step()
  end
end

function prompt_constant_duration()::Int
  attempts = MAX_ATTEMPTS
  while attempts > 0
    println("Please specify for how long you wish to keep the parameter constant (number of iterations):")
    duration_str = readline()
    duration = try
      parse(Int, duration_str)
    catch
      nothing
    end

    if isnothing(duration) || duration <= 0
      println("Invalid input. Please enter a valid positive integer.")
      attempts -= 1
      if attempts == 0
        println("Maximum number of wrong inputs has been given.")
        close_program()
        return -1
      end
    else
      return duration
    end
  end
  return -1
end

function prompt_time_step()::Float64
  attempts = MAX_ATTEMPTS
  while attempts > 0
    println("Please specify the time step (ΔT):")
    time_step_str = readline()
    time_step = try
      parse(Float64, time_step_str)
    catch
      nothing
    end

    if isnothing(time_step) || time_step <= 0
      println("Invalid input. Please enter a valid positive number.")
      attempts -= 1
      if attempts == 0
        println("Maximum number of wrong inputs has been given.")
        close_program()
        return -1.0
      end
    else
      return time_step
    end
  end
  return -1.0
end


"""
    main()

The main function of the Coherent Ising Machine Simulator.
"""
function main()
  problem_choice, grid_specification = select_problem()
  graph = IO.Graph(problem_choice, grid_specification)

  method_choice = select_method()
  modulation_choice = select_modulation()
  params = specify_parameters(modulation_choice, method_choice)


  clear_screen()
  iterations = prompt_iterations()
  if iterations == -1 return end

  constant_end_step = if modulation_choice == 2 prompt_constant_end_step() else false end
  constant_duration = if constant_end_step prompt_constant_duration() else 0 end
  if constant_duration == -1 return end

  time_step = prompt_time_step()
  if time_step == -1.0 return end

  # Run the simulation
  cim = CoherentIsingMachine.CIM(graph.coupling_matrix,
                              iterations,
                              constant_duration,
                              time_step,
                              method_choice,
                              modulation_choice,
                              params)
  CoherentIsingMachine.evolve_system(cim, method_choice)
  if problem_choice == 1
    print("The minimum energy is: $(minimum(cim.energy_data))!")
  end
  if problem_choice == 2
    print("The maximum cut is: $(maximum(cim.cut_data))!")
  end

  return println("Thank you for using the Coherent Ising Machine Simulator!")
end

main()