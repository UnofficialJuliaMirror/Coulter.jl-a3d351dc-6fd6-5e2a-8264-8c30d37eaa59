module Coulter

    import Base.-

    export CoulterCounterRun, loadZ2, -

    include("utils.jl")

    """
    A simplified representation of a coulter counter run
    """
    type CoulterCounterRun
        sample::String
        timepoint::DateTime
        data::Vector{Float64}
    end

    """
    loadZ2(filename::String, sample::String)

    Loads `filename` and assigns it a sample, returns a
    `CoulterCounterRun` object
    """
    function loadZ2(filename::String, sample::String)
        open(filename) do s
            # split windows newlines if present
            filebody = replace(readstring(s), "\r\n", "\n")
            # extract start time and date from body
            datetime = match(r"^StartTime= \d*\s*(?<time>\d*:\d*:\d*)\s*(?<date>\d*\s\w{3}\s\d{4})$"m, filebody)
            timepoint = DateTime("$(datetime[:date]) $(datetime[:time])", "dd uuu yyy HH:MM:SS")

            # extract data
            matcheddata = match(r"^\[#Bindiam\]\n(?<binlims>.*?)\n^\[Binunits\].*?\[#Binheight\]\n(?<binheight>.*?)\n^\[end\]"sm, filebody)
            binheights = [parse(Int64, x) for x in split(matcheddata[:binheight], "\n ")]
            binlims = [parse(Float64, x) for x in split(matcheddata[:binlims], "\n ")]

            # unbin data, i.e. the inverse of the hist function
            data = repvec(binlims, binheights)

            CoulterCounterRun(sample, timepoint, data)
        end
    end

    -(a::CoulterCounterRun, b::CoulterCounterRun) = a.timepoint - b.timepoint
    -(a::CoulterCounterRun, b::DateTime) = a.timepoint - b
end
