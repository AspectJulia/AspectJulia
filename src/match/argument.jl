export AAny, VAAny, KAAny, KVAAny, AType, VAType, KAType, KVAAny
export AInt128, AInt64, AInt32, AInt16, AInt8, AFloat64, AFloat32, AFloat16, AString
export VAInt128, VAInt64, VAInt32, VAInt16, VAInt8, VAFloat64, VAFloat32, VAFloat16, VAString
export KAInt128, KAInt64, KAInt32, KAInt16, KAInt8, KAFloat64, KAFloat32, KAFloat16, KAString
export KVAInt128, KVAInt64, KVAInt32, KVAInt16, KVAInt8, KVAFloat64, KVAFloat32, KVAFloat16, KVAString

abstract type ArgumentType end


printtype(arg) = isnothing(arg.type) ? "*" : "::$(arg.type)"
printsymbol(arg) = isnothing(arg.symbol) ? "" : "$(arg.symbol)"
printvariadic(arg) = arg.isvariadic ? "..." : ""
printdefault(arg) = arg.hasdefault ? "" : "="

struct NormalArgumentType <: ArgumentType
  type::Nullable{Symbol}
  symbol::Nullable{Symbol}
  isvariadic::Bool
  hasdefault::Bool
  function NormalArgumentType(type::Nullable{DataType}, symbol::Nullable{Symbol}, isvariadic::Bool, hasdefault::Bool)
    new(isnothing(type) ? type : Symbol(type), symbol, isvariadic, hasdefault)
  end
end

Base.convert(::Type{String}, arg::NormalArgumentType) = begin
  "$(printsymbol(arg))$(printtype(arg))$(printvariadic(arg))$(printdefault(arg))"
end


struct KeywordArguentType <: ArgumentType
  type::Nullable{DataType}
  symbol::Symbol
  isvariadic::Bool
  hasdefault::Bool
  function KeywordArguentType(type::Nullable{DataType}, symbol::Symbol, isvariadic::Bool, hasdefault::Bool)
    new(isnothing(type) ? type : Symbol(type), symbol, isvariadic, hasdefault)
  end
end

Base.convert(::Type{String}, arg::KeywordArguentType) = begin
  "$(printsymbol(arg))$(printtype(arg))$(printvariadic(arg))$(printdefault(arg))"
end


# Declaration without keyword arguments should be declared after declaration with keyword arguments to avoid julia bug(specification?) relating to multiple dispatch
# https://github.com/JuliaLang/julia/issues/9498

AAny(; hasdefault=false) = NormalArgumentType(nothing, nothing, false, hasdefault)
VAAny(; hasdefault=false) = NormalArgumentType(nothing, nothing, true, hasdefault)
AAny(symbol; hasdefault=false) = NormalArgumentType(nothing, symbol, false, hasdefault)
VAAny(symbol; hasdefault=false) = NormalArgumentType(nothing, symbol, true, hasdefault)
KAAny(symbol; hasdefault=false) = KeywordArguentType(nothing, symbol, false, hasdefault)
KVAAny(symbol; hasdefault=false) = KeywordArguentType(nothing, symbol, true, hasdefault)

AType(T::DataType; hasdefault) = NormalArgumentType(T, nothing, false, hasdefault)
AInt128(; hasdefault=false) = AType(Int128; hasdefault=hasdefault)
AInt64(; hasdefault=false) = AType(Int64; hasdefault=hasdefault)
AInt32(; hasdefault=false) = AType(Int32; hasdefault=hasdefault)
AInt16(; hasdefault=false) = AType(Int16; hasdefault=hasdefault)
AInt8(; hasdefault=false) = AType(Int8; hasdefault=hasdefault)
AFloat64(; hasdefault=false) = AType(Float64; hasdefault=hasdefault)
AFloat32(; hasdefault=false) = AType(Float32; hasdefault=hasdefault)
AFloat16(; hasdefault=false) = AType(Float16; hasdefault=hasdefault)
AString(; hasdefault=false) = AType(String; hasdefault=hasdefault)

VAType(T::DataType; hasdefault) = NormalArgumentType(T, nothing, true, hasdefault)
VAInt128(; hasdefault=false) = VAType(Int128; hasdefault=hasdefault)
VAInt64(; hasdefault=false) = VAType(Int64; hasdefault=hasdefault)
VAInt32(; hasdefault=false) = VAType(Int32; hasdefault=hasdefault)
VAInt16(; hasdefault=false) = VAType(Int16; hasdefault=hasdefault)
VAInt8(; hasdefault=false) = VAType(Int8; hasdefault=hasdefault)
VAFloat64(; hasdefault=false) = VAType(Float64; hasdefault=hasdefault)
VAFloat32(; hasdefault=false) = VAType(Float32; hasdefault=hasdefault)
VAFloat16(; hasdefault=false) = VAType(Float16; hasdefault=hasdefault)
VAString(; hasdefault=false) = VAType(String; hasdefault=hasdefault)

AType(T::DataType, symbol; hasdefault) = NormalArgumentType(T, symbol, false, hasdefault)
AInt128(symbol; hasdefault=false) = AType(Int128, symbol; hasdefault=hasdefault)
AInt64(symbol; hasdefault=false) = AType(Int64, symbol; hasdefault=hasdefault)
AInt32(symbol; hasdefault=false) = AType(Int32, symbol; hasdefault=hasdefault)
AInt16(symbol; hasdefault=false) = AType(Int16, symbol; hasdefault=hasdefault)
AInt8(symbol; hasdefault=false) = AType(Int8, symbol; hasdefault=hasdefault)
AFloat64(symbol; hasdefault=false) = AType(Float64, symbol; hasdefault=hasdefault)
AFloat32(symbol; hasdefault=false) = AType(Float32, symbol; hasdefault=hasdefault)
AFloat16(symbol; hasdefault=false) = AType(Float16, symbol; hasdefault=hasdefault)
AString(symbol; hasdefault=false) = AType(String, symbol; hasdefault=hasdefault)

VAType(T::DataType, symbol; hasdefault) = NormalArgumentType(T, symbol, true, hasdefault)
VAInt128(symbol; hasdefault=false) = VAType(Int128, symbol; hasdefault=hasdefault)
VAInt64(symbol; hasdefault=false) = VAType(Int64, symbol; hasdefault=hasdefault)
VAInt32(symbol; hasdefault=false) = VAType(Int32, symbol; hasdefault=hasdefault)
VAInt16(symbol; hasdefault=false) = VAType(Int16, symbol; hasdefault=hasdefault)
VAInt8(symbol; hasdefault=false) = VAType(Int8, symbol; hasdefault=hasdefault)
VAFloat64(symbol; hasdefault=false) = VAType(Float64, symbol; hasdefault=hasdefault)
VAFloat32(symbol; hasdefault=false) = VAType(Float32, symbol; hasdefault=hasdefault)
VAFloat16(symbol; hasdefault=false) = VAType(Float16, symbol; hasdefault=hasdefault)
VAString(symbol; hasdefault=false) = VAType(String, symbol; hasdefault=hasdefault)

KAType(T::DataType, symbol; hasdefault) = KeywordArguentType(T, symbol, false, hasdefault)
KAInt128(symbol; hasdefault) = KAType(Int128, symbol; hasdefault=hasdefault)
KAInt64(symbol; hasdefault) = KAType(Int64, symbol; hasdefault=hasdefault)
KAInt32(symbol; hasdefault) = KAType(Int32, symbol; hasdefault=hasdefault)
KAInt16(symbol; hasdefault) = KAType(Int16, symbol; hasdefault=hasdefault)
KAInt8(symbol; hasdefault) = KAType(Int8, symbol; hasdefault=hasdefault)
KAFloat64(symbol; hasdefault) = KAType(Float64, symbol; hasdefault=hasdefault)
KAFloat32(symbol; hasdefault) = KAType(Float32, symbol; hasdefault=hasdefault)
KAFloat16(symbol; hasdefault) = KAType(Float16, symbol; hasdefault=hasdefault)
KAString(symbol; hasdefault) = KAType(String, symbol; hasdefault=hasdefault)

KVAAny(T::DataType, symbol; hasdefault) = KeywordArguentType(T, symbol, true, hasdefault)
KVAInt128(symbol; hasdefault) = KVAAny(Int128, symbol; hasdefault=hasdefault)
KVAInt64(symbol; hasdefault) = KVAAny(Int64, symbol; hasdefault=hasdefault)
KVAInt32(symbol; hasdefault) = KVAAny(Int32, symbol; hasdefault=hasdefault)
KVAInt16(symbol; hasdefault) = KVAAny(Int16, symbol; hasdefault=hasdefault)
KVAInt8(symbol; hasdefault) = KVAAny(Int8, symbol; hasdefault=hasdefault)
KVAFloat64(symbol; hasdefault) = KVAAny(Float64, symbol; hasdefault=hasdefault)
KVAFloat32(symbol; hasdefault) = KVAAny(Float32, symbol; hasdefault=hasdefault)
KVAFloat16(symbol; hasdefault) = KVAAny(Float16, symbol; hasdefault=hasdefault)
KVAString(symbol; hasdefault) = KVAAny(String, symbol; hasdefault=hasdefault)


function preprocess_argumenttype(ls)
  [d isa Function ? d() : d for d in ls]
end


