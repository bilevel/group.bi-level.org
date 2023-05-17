import Bibliography: bibtex_to_web

function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end

function _read_bib(bib)
  isnothing(bib) && return 
  d = nothing
  try
    d = bibtex_to_web(bib) |> first
  catch
    @error "Cannot load $bib as a bib"
    return
  end
  d
end

function _bib_to_html(io, d, complete=false)
  isnothing(d) && return io
  write(io, "<p>")
  complete && write(io, d.names*", ")
  complete && write(io, "<b>")
  write(io, "<a href='"*d.link*"' target='_black' rel='no-follow'> "*d.title*"</a>")
  complete && write(io, "</b>")
  !complete && write(io, "<small>")
  write(io, " in " *string(d.in))
  !complete && write(io, "</small>")
  write(io, "</p>")
  io
end

function _get_bib_files()
  dir = "bib"
  bibs = []
  for bib in readdir(dir)
    file_name = joinpath(dir, bib)
    !isfile(file_name) && continue
    bib = _read_bib(file_name)
    isnothing(bib) && continue
    push!(bibs, bib)
  end
  bibs
  sort!(bibs, by = b -> b.year, rev=true)
end

function hfun_load_recent_publications()
  io = IOBuffer()
  max_recent = 5
  bibs = _get_bib_files()

  for (i, bib) in enumerate(bibs) 
    _bib_to_html(io, bib)
    i >= max_recent && break
  end

  if length(bibs) > max_recent
    write(io, "<div class='is-center'>")
    write(io, "<a class='button outline' href='/research'>see more</a>")
    write(io, "</div>")
  end
  
  return String(take!(io))
end


function lx_fillresearch(com, _)
  bibs = _get_bib_files()


  vs = [b.year for b in bibs] |> unique
  io = IOBuffer()

  for y in vs
    write(io, "\n\n## "*string(y), "\n\n")
    for bib in filter(b -> b.year==y, bibs)
      write(io, "~~~")
      _bib_to_html(io, bib, true)
      write(io, "~~~")
    end
  end

  return String(take!(io))
end
