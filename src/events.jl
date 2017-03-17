struct Event <: AbstractEvent
  bev :: BaseEvent
  function Event(env::Environment)
    new(BaseEvent(env))
  end
end

function succeed(ev::Event; priority::Int8=zero(Int8), value::Any=nothing) :: Event
  sta = state(ev)
  (sta == scheduled || sta == triggered) && throw(EventNotIdle(ev))
  schedule(ev.bev, priority=priority, value=value)
  ev
end

function fail(ev::Event, exc::Exception; priority::Int8=zero(Int8)) :: Event
  succeed(ev, priority=priority, value=exc)
end

struct Timeout <: AbstractEvent
  bev :: BaseEvent
  function Timeout(env::Environment, delay::Number=0; priority::Int8=zero(Int8), value::Any=nothing)
    ev = new(BaseEvent(env))
    schedule(ev.bev, delay, priority=priority, value=value)
    ev
  end
end

function run(sim::Simulation, until::Number=typemax(Float64))
  run(sim, Timeout(sim, until-now(sim)))
end
