typealias BigFloats Union(BigFloat,Complex{BigFloat})

# The following implements Bluestein's algorithm, following http://www.dsprelated.com/dspbooks/mdft/Bluestein_s_FFT_Algorithm.html
# To add more types, add them in the union of the function's signature.
function Base.fft{T<:BigFloats}(x::Vector{T})
    n = length(x)
    if ispow2(n) return fft_pow2(x) end
    ks = linspace(zero(real(T)),n-one(real(T)),n)
    Wks = exp(-im*convert(T,π)*ks.^2/n)
    xq,wq = x.*Wks,conj([exp(-im*convert(T,π)*n),reverse(Wks),Wks[2:end]])
    return Wks.*conv(xq,wq)[n+1:2n]
end

function Base.ifft{T<:BigFloats}(x::Vector{T})
    return conj(fft(conj(x)))/length(x)
end

function Base.ifft!{T<:BigFloats}(x::Vector{T})
    y = conj(fft(conj(x)))/length(x)
    x[:] = y
    return x
end

function Base.conv{T<:Number}(u::StridedVector{T}, v::StridedVector{T})
    nu,nv = length(u),length(v)
    n = nu + nv - 1
    np2 = nextpow2(n)
    pad!(u,np2),pad!(v,np2)
    y = ifft_pow2(fft_pow2(u).*fft_pow2(v))
    #TODO This would not handle Dual/ComplexDual numbers correctly
    y = T<:Real ? real(y[1:n]) : y[1:n]
end

######################################################################
# TO BE DEPRECATED FOR V0.4 UPGRADE
######################################################################

# plan_fft for BigFloats (covers Laurent svfft)

Base.plan_fft{T<:BigFloats}(x::Vector{T}) = fft
Base.plan_ifft{T<:BigFloats}(x::Vector{T}) = ifft

# Chebyshev transforms and plans for BigFloats

plan_chebyshevtransform{T<:BigFloats}(x::Vector{T};kwds...) = identity
plan_ichebyshevtransform{T<:BigFloats}(x::Vector{T};kwds...) = identity

#following Chebfun's @Chebtech1/vals2coeffs.m and @Chebtech2/vals2coeffs.m
function chebyshevtransform{T<:BigFloats}(x::Vector{T},plan::Function;kind::Integer=1)
    if kind == 1
        n = length(x)
        if n == 1
            x
        else
            w = [2exp(im*convert(T,π)*k/2n) for k=0:n-1]
            ret = w.*ifft([reverse(x);x])[1:n]
            ret = T<:Real ? real(ret) : ret
            ret[1] /= 2
            ret
        end
    elseif kind == 2
        n = length(x)
        if n == 1
            x
        else
            ret = ifft([reverse(x),x[2:end-1]])[1:n]
            ret = T<:Real ? real(ret) : ret
            ret[2:n-1] *= 2
            ret
        end
    end
end

#following Chebfun's @Chebtech1/vals2coeffs.m and @Chebtech2/vals2coeffs.m
function ichebyshevtransform{T<:BigFloats}(x::Vector{T},plan::Function;kind::Integer=1)
    if kind == 1
        n = length(x)
        if n == 1
            x
        else
            w = exp(-im*convert(T,π)*[0:2n-1]/2n)/2
            w[1] *= 2;w[n+1] *= 0;w[n+2:end] *= -1
            ret = fft(w.*[x,one(T),x[end:-1:2]])[n:-1:1]
            ret = T<:Real ? real(ret) : ret
        end
    elseif kind == 2
        n = length(x)
        if n == 1
            x
        else
            ##TODO: make thread safe
            x[1] *= 2;x[end] *= 2
            ret = chebyshevtransform(x;kind=kind)
            x[1] /=2;x[end] /=2
            ret[1] *= 2;ret[end] *= 2
            negateeven!(ret)
            ret *= .5*(n-1)
            reverse!(ret)
        end
    end
end

# Fourier space plans for BigFloats

function plan_transform{T<:BigFloat}(::Fourier,x::Vector{T})
    function plan(x)
        v = fft(x)
        n = div(length(x),2)+1
        [real(v[1:n]);imag(v[n-1:-1:2])]
    end
    plan
end
function plan_transform{T<:Complex{BigFloat}}(::Fourier,x::Vector{T})
    function plan(x)
        complex(plan_transform(Fourier(),real(x)),plan_transform(Fourier(),imag(x)))
    end
    plan
end

function plan_itransform{T<:BigFloat}(::Fourier,x::Vector{T})
    function plan(x)
        n = div(length(x),2)+1
        v = complex([x[1:n],x[n-1:-1:2]],[0,-x[2n-2:-1:n+1],0,x[n+1:2n-2]])
        real(fft(v))
    end
    plan
end
function plan_itransform{T<:Complex{BigFloat}}(::Fourier,x::Vector{T})
    function plan(x)
        complex(plan_itransform(Fourier(),real(x)),plan_itransform(Fourier(),imag(x)))
    end
    plan
end

# SinSpace plans for BigFloats

#plan_transform{T<:BigFloats}(::SinSpace,x::Vector{T})=FFTW.plan_r2r(x,FFTW.RODFT00)
#plan_itransform{T<:BigFloats}(::SinSpace,x::Vector{T})=FFTW.plan_r2r(x,FFTW.RODFT00)
