" Integer comparator used to sort the complete list of possible colors
function! s:IntCompare(i1, i2)
  return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunc

" Color comparator to find the nearest element to a given one in a given list
function! s:NearestElemInList(elem, list)
  let len = len(a:list)
  for i in range(len-1)
    if (a:elem <= (a:list[i] + a:list[i+1]) / 2)
      return a:list[i]
    endif
  endfor
  return a:list[len-1]
endfunction

" Takes 3 decimal values for r, g, and b, and returns the closest cube number.
"
" This approximator considers closeness based upon the individiual components.
" For each of r, g, and b, it finds the closest cube component available on
" the cube.  If the three closest matches can combine to form a valid color,
" this color is used, otherwise we repeat the search with the greys removed,
" meaning that the three new matches must make a valid color when combined.
function! csapprox#per_component#Approximate(r,g,b)
  let hex = printf("%02x%02x%02x", a:r, a:g, a:b)

  let colors = csapprox#common#Colors()
  let greys = csapprox#common#Greys()
  let type = csapprox#common#PaletteType()

  if !exists('s:approximator_cache_'.type)
    let s:approximator_cache_{type} = {}
  endif

  let rv = get(s:approximator_cache_{type}, hex, -1)
  if rv != -1
    return rv
  endif

  " Only obtain sorted list once
  if !exists("s:".type."_greys_colors")
    let s:{type}_greys_colors = sort(greys + colors, "s:IntCompare")
  endif

  let greys_colors = s:{type}_greys_colors

  let r = s:NearestElemInList(a:r, greys_colors)
  let g = s:NearestElemInList(a:g, greys_colors)
  let b = s:NearestElemInList(a:b, greys_colors)

  let len = len(colors)
  if (r == g && g == b && index(greys, r) != -1)
    let rv = 16 + len * len * len + index(greys, r)
  else
    let r = s:NearestElemInList(a:r, colors)
    let g = s:NearestElemInList(a:g, colors)
    let b = s:NearestElemInList(a:b, colors)
    let rv = index(colors, r) * len * len
         \ + index(colors, g) * len
         \ + index(colors, b)
         \ + 16
  endif

  let s:approximator_cache_{type}[hex] = rv
  return rv
endfunction
