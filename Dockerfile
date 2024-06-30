FROM julia:1.9

WORKDIR /project

COPY . /project

RUN julia --project=/project -e 'using Pkg; Pkg.instantiate()'

CMD ["julia", "--project=/project", "/project/src/main.jl"]