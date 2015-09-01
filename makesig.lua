#!/usr/bin/env texlua
kpse.set_program_name("luatex")
local lapp = require "lapp"
local options = [[
makesig - generování signatur
-o,--output (default signatury.pdf) Výstupní soubor
-s,--sequence (default empty)
-c,--count (default 65) Počet štítků na list
<input> (default stdin)
]]

local args = lapp(options)

local signatury = {}
if args.sequence == "empty" then args.sequence = nil end

if not args.sequence then
	for line in args.input:lines() do
		line:gsub("^%s*([0-9]*[a-zA-Z]+[0-9]+[/%-0-9a-zA-Z%,ěščřžýáíéúůťďň%.]*)", function(s) table.insert(signatury,"\\stitky{"..s.."}") end)
	end
end
local template = [[
\documentclass{minimal}
\usepackage[czech]{babel}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{stitky}
\def\stitekfontstyle{\bfseries}
\renewcommand*\familydefault{\sfdefault} %% Only if the base font of the document is to be sans serif

\begin{document}
\fontfamily{ugq}\selectfont
{{content}}
\end{document}
]]

local content = ""
if args.sequence then
	local count = tonumber(args.count) - 1
	local prefix, start = args.sequence:match("([a-zA-Z]+)([0-9]+)")
	content = ('\\stiteksekvence{%s}{%i}{%i}'):format(prefix,start, count)
else
--]]
	content = table.concat(signatury,"\n")
end

local input = template:gsub('{{content}}',content)
local jobname = args.output:gsub('.pdf$','')

--print(input)
--print(jobname)

local latex = io.popen('pdflatex -file-line-error -jobname='..jobname,'w')
latex:write(input)
latex:close()
os.execute("evince ".. jobname..'.pdf &')

