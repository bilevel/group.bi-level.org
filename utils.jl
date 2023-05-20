import Bibliography: bibtex_to_web
using Unicode
using StringDistances
using DelimitedFiles
using UnPack

tex2unicode_replacements = (
    "---" => "—", # em dash needs to go first
    "--"  => "–",
    "\\&"  => "&",
    "{\\'a}"  => "á", "{\\'{a}}"  => "á", "\\'{a}"  => "á",
    "{\\'e}"  => "é", "{\\'{e}}"  => "é", "\\'{e}"  => "é",
    "{\\'i}"  => "í", "{\\'{i}}"  => "í", "\\'{i}"  => "í", "\\'{\\i}"  => "í",
    "{\\'o}"  => "ó", "{\\'{o}}"  => "ó", "\\'{o}"  => "ó",
    "{\\'u}"  => "ú", "{\\'{u}}"  => "ú", "\\'{u}"  => "ú",
    "{\\~n}"  => "ñ",
    r"\\`\{(\S)\}" => s"\1\u300", # \`{o} 	ò 	grave accent
    r"\\'\{(\S)\}" => s"\1\u301", # \'{o} 	ó 	acute accent
    r"\\\^\{(\S)\}" => s"\1\u302", # \^{o} 	ô 	circumflex
    r"\\~\{(\S)\}" => s"\1\u303", # \~{o} 	õ 	tilde
    r"\\=\{(\S)\}" => s"\1\u304", # \={o} 	ō 	macron accent (a bar over the letter)
    r"\\u\{(\S)\}" => s"\1\u306",  # \u{o} 	ŏ 	breve over the letter
    r"\\\.\{(\S)\}" => s"\1\u307", # \.{o} 	ȯ 	dot over the letter
    r"\\\\\"\{(\S)\}" => s"\1\u308", # \"{o} 	ö 	umlaut, trema or dieresis
    r"\\r\{(\S)\}" => s"\1\u30A",  # \r{a} 	å 	ring over the letter (for å there is also the special command \aa)
    r"\\H\{(\S)\}" => s"\1\u30B",  # \H{o} 	ő 	long Hungarian umlaut (double acute)
    r"\\v\{(\S)\}" => s"\1\u30C",  # \v{s} 	š 	caron/háček ("v") over the letter
    r"\\d\{(\S)\}" => s"\1\u323",  # \d{u} 	ụ 	dot under the letter
    r"\\c\{(\S)\}" => s"\1\u327",  # \c{c} 	ç 	cedilla
    r"\\k\{(\S)\}" => s"\1\u328",  # \k{a} 	ą 	ogonek
    r"\\b\{(\S)\}" => s"\1\u331",  # \b{b} 	ḇ 	bar under the letter
    r"\{\}" => s"",  # empty curly braces should not have any effect
    r"\\o" => s"\u00F8",  # \o 	ø 	latin small letter O with stroke
    r"\\O" => s"\u00D8",  # \O 	Ø 	latin capital letter O with stroke
    r"\\l" => s"\u0142",  # \l 	ł 	latin small letter L with stroke
    r"\\L" => s"\u0141",  # \L 	Ł 	latin capital letter L with stroke
    r"\\i" => s"\u0131",  # \i 	ı 	latin small letter dotless I

    # TODO:
    # \t{oo} 	o͡o 	"tie" (inverted u) over the two letters
    # \"{\i} 	ï 	Latin Small Letter I with Diaeresis

    # Sources : https://www.compart.com/en/unicode/U+0131 enter the unicode character into the search box
)

function tex2unicode(s)
    for replacement in tex2unicode_replacements
        s = replace(s, replacement)
    end
    Unicode.normalize(s)
end

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
  complete && write(io, tex2unicode(d.names)*", ")
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

  String(take!(io))
end

function lx_collaborators(com, _)
  bibs = _get_bib_files()
  isnothing(bibs) && return

  # collaborators' names
  _n = [n => i for (i, b) in enumerate(bibs) for n in split(tex2unicode(b.names), ", ")] 
  names_dict = Dict(_n...)

  _names = first.(_n) |> unique!

  # string distance
  ds = pairwise(Levenshtein(), _names)

  # remove active members

  # remove duplicated names
  next = ones(Bool, length(_names))
  k = 5
  for i in 1:length(_names)
    !next[i] && continue
    idx = findall(ds[i, i+1:end] .< k)
    isempty(idx) && continue
    next[idx .+ i] .= false
    # remove active members
  end

  _M, _ = readdlm("members/members.csv", ',', header=true);
  members = _M[:,3]

  # output markdown
  io = IOBuffer()
  for _name in _names[next]
    # remove active members
    if minimum(pairwise(Levenshtein(),[_name], members)) < 3+ k
      continue
    end
    write(io, "- $_name ")
    try
      l = bibs[names_dict[_name]].link
      write(io, "[[see collaboration]($l)]")
    catch
    end
    write(io, "\n")
  end

  String(take!(io))
end

_row_to_dict(row, h) = Dict(Symbol(a) => b for (a, b) in zip(h, row))

function _print_person(io, M, h)
  for i in 1:size(M, 1)
    @unpack type,name,email,url,photo,bio = _row_to_dict(M[i,:], h)
    println(io, "### ", name)
    println(io, "\\photo{", name, "}{", photo,"}")
    println(io, bio)
    println(io, "~~~")
    println(io, "<span class=\"clearfix\"></span>")
    println(io, "~~~")
    !isempty(email) && println(io, "\n**Email:** [$email](mailto:$email)")
    if !isempty(url)
      _url = replace(url, "http://"=>"", "https://" =>"")
      println(io, " / **URL:** [$_url](", url, ")")
    end
    println(io, "\n\n***\n\n")
  end
end

function lx_members(com,_)
  M_all, h = readdlm("members/members.csv", ',', header=true);

  io = IOBuffer()
  println(io, "## Active Members")
  M = M_all[M_all[:,2] .== "member",:]
  _print_person(io, M, h)

  println(io, "## Student Members")
  M = M_all[M_all[:,2] .== "student",:]
  _print_person(io, M, h)

  return String(take!(io))

end

