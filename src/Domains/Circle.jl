

export Circle


##  Circle


immutable Circle{T<:Number,V<:Real} <: PeriodicDomain{Complex{V}}
	center::T
	radius::V
end

Circle{T1<:Number,T2<:Number,V<:Real}(::Type{T1},c::T2,r::V) = Circle(convert(promote_type(T1,T2,V),c),convert(promote_type(real(T1),real(T2),V),r))
Circle{V<:Real}(r::V) = Circle(zero(V),r)
Circle(r::Int)=Circle(Float64,0.,r)

Circle{V<:Real}(::Type{V}) = Circle(one(V))
Circle()=Circle(1.)



isambiguous(d::Circle)=isnan(d.center) && isnan(d.radius)
Base.convert{T<:Number,V<:Number}(::Type{Circle{T,V}},::AnyDomain)=Circle{T,V}(NaN,NaN)
Base.convert{IT<:Circle}(::Type{IT},::AnyDomain)=Circle(NaN,NaN)


function tocanonical(d::Circle,ζ)
    v=mappoint(d,Circle(),ζ)- 0.im#Subtract 0.im so branch cut is right

    -1.im.*log(v)
end

tocanonicalD(d::Circle,ζ)=-1.im./(ζ.-d.center)  #TODO: Check formula
fromcanonical(d::Circle,θ)=d.radius*exp(1.im*θ) .+ d.center
fromcanonicalD(d::Circle,θ)=d.radius*1.im*exp(1.im*θ)

canonicaldomain(d::Circle)=PeriodicInterval()

Base.in(z,d::Circle)=isapprox(abs(z-d.center),d.radius)

Base.length(d::Circle) = 2π*d.radius
complexlength(d::Circle)=im*length(d)  #TODO: why?


==(d::Circle,m::Circle) = d.center == m.center && d.radius == m.radius



function mappoint(d1::Circle,d2::Circle,z)
   v=(z-d1.center)/d1.radius
   v*d2.radius+d2.center
end



