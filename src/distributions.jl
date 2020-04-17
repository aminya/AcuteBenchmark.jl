# TODO Make a PR to Distributions.jl

using Distributions
import Distributions.@check_args
################################################################
function Distributions.Uniform(::Type{T}, a, b) where {T <: Real}
    return Uniform(T(a), T(b))
end
################################################################
struct Uniform2{T}
    a::T
    b::T

    # Uniform2{T}(a::T, b::T) constructor
    function Uniform2{T}(a::T, b::T; check_args=true) where {T <: Real}
        check_args && @check_args(Uniform2, a < b)
        return new{T}(a, b)
    end

    # Abstract a,b - Uniform2{T}(a, b) constructor
    function Uniform2{T}(a::Real, b::Real; check_args=true) where {T <: Real}
        check_args && @check_args(Uniform2, a < b)
        return new{T}(T(a), T(b))
    end

    # Uniform2{T}(a::T, b::T) constructor
    function Uniform2{T}(a::T, b::T) where {T <:Complex}
        new{T}(a, b)
    end

    # Abstract a,b - Uniform2{T}(a, b) constructor
    function Uniform2{T}(a, b) where {T <: Complex}
        return new{T}(T(a), T(b))
    end
end
# Real

# zeros() like constructor (Uniform2(T, a::T, b::T))
function Uniform2(::Type{T}, a::T, b::T; check_args=true) where {T <: Real}
    return Uniform2{T}(a, b, check_args = check_args)
end

# Abstract a,b - zeros() like constructor (Uniform2(T, a, b))
function Uniform2(::Type{T}, a, b; check_args=true) where {T <: Real}
    return Uniform2{T}(T(a), T(b), check_args = check_args)
end

# No type specified constructor:
function Uniform2(a::Float64, b::Float64; check_args=true)
    return Uniform2{Float64}(a, b, check_args = check_args)
end

# Abstract a,b - no type specified constructor:
function Uniform2(a, b; check_args=true)
    return Uniform2{Float64}(Float64(a), Float64(b), check_args = check_args)
end

# Complex

# zeros() like constructor (Uniform2(T, a::T, b::T))
function Uniform2(::Type{T}, a::T, b::T) where {T <: Complex}
    return Uniform2{T}(a, b)
end

# Abstract a,b - zeros() like constructor (Uniform2(T, a, b))
function Uniform2(::Type{T}, a, b) where {T <: Complex}
    return Uniform2{T}(T(a), T(b))
end

# No type specified constructor:
function Uniform2(a::ComplexF64, b::ComplexF64)
    return Uniform2{ComplexF64}(a, b)
end

Base.rand(d::Uniform2{T}, dims::Integer...) where {T} =   d.a .+ (d.b - d.a) .* Base.rand(T, dims)
