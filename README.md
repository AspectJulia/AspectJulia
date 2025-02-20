# AspectJulia

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://hrontan.github.io/AspectJulia.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://hrontan.github.io/AspectJulia.jl/dev/)
[![Build Status](https://github.com/hrontan/AspectJulia.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/hrontan/AspectJulia.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Build Status](https://app.travis-ci.com/hrontan/AspectJulia.jl.svg?branch=main)](https://app.travis-ci.com/hrontan/AspectJulia.jl)
[![Coverage](https://codecov.io/gh/hrontan/AspectJulia.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/hrontan/AspectJulia.jl)
[![Coverage](https://coveralls.io/repos/github/hrontan/AspectJulia.jl/badge.svg?branch=main)](https://coveralls.io/github/hrontan/AspectJulia.jl?branch=main)

AspectJulia provide a simple way to add aspect-oriented programming to Julia.
Suggestions, issues and pull requests are welcome.

**_ >>> THIS PACKAGE IS NOT YET PRODUCT READY <<< _**

## Installation

This package is not yet released as a registered package. To install it, you need to clone this repository and add it to your Julia environment.

```julia

include("path/to/AspectJulia.jl")
using .AspectJulia
```

## Docs and Publications

- Aspect-oriented Programming with Julia: [arXiv](https://arxiv.org/abs/2412.18885)

## Feature Comparison

|                                       | AspectJulia | Cassette       | AspectJ     | AspectC++       |
| ------------------------------------- | ----------- | -------------- | ----------- | --------------- |
| Based language                        | Julia       | Julia          | Java        | C++             |
| Model                                 | AOP/JPM     | Similar to COP | AOP/JPM     | AOP/JPM         |
| Dynamic matching                      | no          | yes            | yes (cflow) | yes (cflow)     |
| Scope handling                        | yes         | yes (context)  | yes         | yes             |
| Function implementation modification  | yes         | yes (context)  | yes         | yes             |
| Function call modification            | yes         | yes (context)  | yes         | yes             |
| Intervention in a variable assignment | yes         | Not documented | yes         | yes             |
| Intervention in a variable reference  | partial     | Not documented | yes         | yes             |
| Intervention in other code blocks     | yes         | Not documented | external    | no              |
| Easy Modification of AST at JoinPoint | yes         | yes            | no          | no              |
| Order of extension objects            | yes         | -              | yes         | yes             |
| Inheritance of extension object       | no          | -              | yes         | partial (Slice) |
