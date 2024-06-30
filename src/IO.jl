"""
    IO

The IO module contains functions and types for handling input and output operations.

# Types

  - `Parser`: A struct for parsing edge lines in the G-Sets problem.
  - `Graph`: A struct for representing a graph.

# Functions

  - `parse_edge_line!`: Parses an edge line in the G-Sets problem.
  - `Graph`: Constructs a graph based on the user's choice of problem and grid specification.
"""
module IO
using HTTP

"""
    Parser

A struct for parsing edge lines in the G-Sets problem.

# Fields

  - `buf::Vector{SubString{String}}`: A buffer for storing parsed substrings.
"""
struct Parser
  buf::Vector{SubString{String}}
  function Parser()::Parser
    """
    Constructs a new `Parser` object.
    """
    return new(Vector{SubString{String}}(undef, 3))
  end
end

"""
    parse_edge_line!(parser, line)

Parses an edge line in the G-Sets problem.

# Arguments

  - `parser::Parser`: The parser object.
  - `line::SubString{String}`: The edge line to parse.

# Returns

  - A tuple containing the edge indices and weight.
"""
function parse_edge_line!(self::Parser, line::SubString{String})::Tuple{Int, Int, Float64}
  idx = 1
  start = 1
  @inbounds for i in eachindex(line)
    if line[i] == ' '
      self.buf[idx] = SubString(line, start:(i - 1))
      start = i + 1
      idx += 1
    end
  end
  self.buf[idx] = SubString(line, start:lastindex(line))

  i = parse(Int, self.buf[1])
  j = parse(Int, self.buf[2])
  w_ij = parse(Float64, self.buf[3])

  return i, j, w_ij
end

"""
    Graph

A struct for representing a graph.

# Fields

  - `adj_matrix::Matrix{Float64}`: The adjacency matrix of the graph.

# Constructors

  - `Graph(problem_choice::Int, grid_specification::Int)`: Constructs a graph based on the user's choice of problem and grid specification.

# Examples

```julia
graph = Graph(1, 5)
graph = Graph(2, 5)
```
"""
struct Graph
  coupling_matrix::Matrix{Float64}

  function Graph(problem_choice::Int, grid_specification::Int)
    """
    Constructs a graph based on the user's choice of problem and grid specification.
    """
    # Construct a 2D square Ising lattice
    if problem_choice == 1
      println("Generating the Ising grid...")
      coupling_matrix = zeros(Float64, grid_specification, grid_specification)
      for i in 1:grid_specification
        for j in 1:grid_specification
          if i != j
            coupling_matrix[i, j] = -1.0
          end
        end
      end
      println("Ising grid successfully generated.")
      return new(coupling_matrix)
    end

    # Fetch graph data from the web
    if problem_choice == 2
      println("\033[3mFetching the graph data from the Stanford website...\033[0m")
      response = HTTP.get("https://web.stanford.edu/~yyye/yyye/Gset/G$grid_specification")
      # Check if the response is successful
      if response.status != 200
        throw(ArgumentError("Failed to fetch the graph data from https://web.stanford.edu/~yyye/yyye/Gset/G$grid_number"))
      end
      content = String(response.body)
      lines = split(content, "\n"; keepempty=false)
      first_line = split(lines[1])
      N = parse(Int, first_line[1])

      coupling_matrix = zeros(Float64, N, N)
      parser = Parser()
      for line in lines[2:end]
        i, j, w_ij = parse_edge_line!(parser, SubString(line))
        coupling_matrix[i, j] = w_ij
      end
      return new(coupling_matrix)
      println("Graph data successfully fetched.")
    end
  end
end

end # module IO
